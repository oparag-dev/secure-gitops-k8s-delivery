# Secure GitOps Kubernetes Delivery

[![CI Security Pipeline](https://github.com/oparag-dev/secure-gitops-k8s-delivery/actions/workflows/ci.yml/badge.svg)](https://github.com/oparag-dev/secure-gitops-k8s-delivery/actions/workflows/ci.yml)

A production-oriented DevSecOps reference project that provisions AWS infrastructure, runs a full-stack task management application on Kubernetes, and delivers changes through an automated GitOps workflow.

The project combines Terraform, kOps, Helm, Argo CD, Kyverno, GitHub Actions, Docker, Prometheus, and Grafana. The sample application is a React/TypeScript Kanban frontend backed by a Flask API and a private Amazon RDS for PostgreSQL database.

Live application: [https://app.oparatechstack.com](https://app.oparatechstack.com)

## Architecture

```text
Developer push
     |
     v
GitHub Actions -- test, build, scan --> Docker Hub
     |                                  |
     +---- updates Helm image tags -----+
                       |
                       v
                    Git repo
                       |
                       v
                    Argo CD
                       |
                       v
Internet --> AWS Load Balancer --> React/Nginx frontend --> Flask API
                                                           |
                                                           v
                                              Amazon RDS PostgreSQL

             Kyverno admission policies | Prometheus + Grafana
```

The AWS foundation consists of a VPC spanning three availability zones, public and private subnets, NAT access for private workloads, Route 53 DNS, an encrypted S3 state store for kOps, and a private RDS instance. The Kubernetes control plane and worker nodes are created with kOps; application workloads run in private subnets.

## What this repository demonstrates

- Infrastructure as code with reusable Terraform modules
- Protected remote Terraform state in versioned, encrypted S3 storage
- A Kubernetes cluster built with kOps on AWS and Calico networking
- Declarative application packaging with Helm
- Automated reconciliation, pruning, and self-healing with Argo CD
- Immutable image tags based on the Git commit SHA
- CI security checks with Gitleaks, Checkov, and Trivy
- Kyverno admission controls for workload security
- Non-root containers, dropped Linux capabilities, disabled privilege escalation, and `RuntimeDefault` seccomp
- Resource requests, limits, health probes, and restricted service-account token mounting
- Managed PostgreSQL outside the cluster for a stateless application tier
- Prometheus, Alertmanager, and Grafana observability foundations

## Technology stack

| Layer | Technology |
|---|---|
| Frontend | React 18, TypeScript, Vite, Tailwind CSS, Nginx |
| Backend | Python 3.11, Flask, SQLAlchemy, JWT |
| Database | Amazon RDS for PostgreSQL |
| Cloud | AWS VPC, EC2, S3, Route 53, ACM, ELB, RDS, IAM |
| Infrastructure | Terraform, kOps, Ansible |
| Delivery | Docker, GitHub Actions, Helm, Argo CD |
| Security | Gitleaks, Checkov, Trivy, Kyverno |
| Observability | Prometheus, Alertmanager, Grafana |

## Repository layout

```text
.
├── .github/workflows/       # CI, security scanning, image publishing, GitOps tag updates
├── ansible/                 # Local DevOps workstation bootstrap
├── app/
│   ├── taskapp_backend/     # Flask REST API and tests
│   └── taskapp_frontend/    # React/TypeScript SPA
├── argocd/                  # Argo CD Application definition
├── docs/                    # Architecture decisions and deployment evidence
├── helm/taskapp/            # Application chart and production values
├── k8s/                     # Shared Kubernetes resources and namespaces
├── kops/                    # Kubernetes cluster definition
├── kyverno/                 # Admission policies and negative tests
├── monitoring/              # kube-prometheus-stack values
├── scripts/                 # Guarded deployment, destruction, and kOps helpers
└── terraform/
    ├── bootstrap/backend/   # Protected Terraform state bucket
    ├── modules/             # VPC, RDS, S3, DNS, and core modules
    └── root/                # Main AWS environment
```

## Delivery workflow

Every pull request to `main` runs the validation job:

1. Gitleaks checks the repository for committed secrets.
2. Pytest runs the Flask backend test suite against PostgreSQL 15.
3. The React frontend is installed and built with Node.js 20.
4. Checkov scans Terraform, Kubernetes, and Helm configuration.
5. Trivy scans the repository for high and critical findings.

After a push to `main`, the pipeline builds and scans both container images, publishes them to Docker Hub with the seven-character commit SHA, and commits that tag to `helm/taskapp/values.yaml`. Argo CD detects the Git change and automatically reconciles the `taskapp` namespace.

> Checkov and Trivy currently provide scan visibility without blocking the pipeline; Gitleaks, application tests, and the frontend build are blocking checks.

## Prerequisites

- An AWS account and AWS CLI credentials with permission to create the documented resources
- Terraform 1.6 or newer
- `kubectl`, Helm, kOps, Git, Docker, and `curl`
- A registered domain whose nameservers can be delegated to the Route 53 hosted zone
- Docker Hub credentials for CI image publishing
- A Linux workstation if using the included Ansible bootstrap playbook

Install the local Helm and kubectl prerequisites on Debian/Ubuntu with:

```bash
ansible-galaxy collection install community.general
ansible-playbook --ask-become-pass ansible/install-devops-tools.yml
```

## Provision the AWS foundation

The checked-in configuration targets `eu-west-3` and the `oparatechstack.com` domain. Forks should replace the project-specific bucket names, domain, account-specific ARNs, cluster identifiers, subnet IDs, and allowed administrator CIDR before deployment.

1. Authenticate to AWS and set the database password without committing it:

   ```bash
   aws sts get-caller-identity
   export TF_VAR_db_password='replace-with-a-strong-password'
   ```

2. Review both variable files and adjust them for your environment:

   ```text
   terraform/bootstrap/backend/prod.tfvars
   terraform/root/prod.tfvars
   ```

3. Run the guarded two-stage Terraform workflow:

   ```bash
   ./scripts/deploy.sh
   ```

The script bootstraps the protected remote-state bucket first, then formats, initializes, validates, and plans the root stack. Before applying, it rejects legacy project identifiers, accidental management of the backend bucket, and public SSH exposure. Both applies require explicit confirmation.

After the root stack is created, delegate the domain to the nameservers shown by:

```bash
terraform -chdir=terraform/root output route53_name_servers
```

## Create the Kubernetes cluster

`scripts/kops-generate-cluster-config.sh` is a dry-run generator. Update its VPC and subnet IDs from the Terraform outputs, then run:

```bash
./scripts/kops-generate-cluster-config.sh
```

Review `kops/cluster.yaml` carefully. It restricts Kubernetes API and SSH access to a single administrator `/32`, uses private worker subnets, encrypts etcd volumes, disables anonymous kubelet authentication, and uses Calico networking.

Create and validate the cluster:

```bash
export KOPS_CLUSTER_NAME=k8s.oparatechstack.com
export KOPS_STATE_STORE=s3://taskapp-kops-state-opara

kops create -f kops/cluster.yaml
kops update cluster --name "$KOPS_CLUSTER_NAME" --yes --admin
kops validate cluster --wait 10m
kubectl get nodes
```

## Install platform services

Create the namespaces:

```bash
kubectl apply -f k8s/namespaces.yaml
```

Install Argo CD, Kyverno, and the monitoring stack from their official Helm repositories:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install argocd argo/argo-cd -n argocd
helm upgrade --install kyverno kyverno/kyverno -n kyverno
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring -f monitoring/kube-prometheus-stack-values.yaml
```

Apply the admission policy before deploying the application:

```bash
kubectl apply -f kyverno/policies/taskapp-deployment-security.yaml
kubectl get clusterpolicy taskapp-deployment-security
```

## Configure and deploy TaskApp

The backend expects a Kubernetes Secret containing the database username, database password, and JWT signing key. Create it directly in the cluster; do not commit the values:

```bash
kubectl -n taskapp create secret generic taskapp-backend-secrets \
  --from-literal=DATABASE_USER='taskapp_user' \
  --from-literal=DATABASE_PASSWORD='replace-with-the-rds-password' \
  --from-literal=SECRET_KEY="$(openssl rand -hex 32)"
```

Before deployment, update these environment-specific fields in `helm/taskapp/values.yaml`:

- `backend.env.databaseHost` with the `rds_endpoint` Terraform output
- Backend and frontend image repositories if using your own Docker Hub account
- The ACM certificate ARN used by the frontend LoadBalancer
- Image tags if the CI workflow has not populated them

Render and inspect the chart locally:

```bash
helm lint helm/taskapp
helm template taskapp helm/taskapp --namespace taskapp
```

Start GitOps reconciliation:

```bash
kubectl apply -f argocd/taskapp-application.yaml
kubectl -n argocd get application taskapp
kubectl -n taskapp get pods,services
```

The frontend LoadBalancer terminates TLS with ACM. Nginx serves the SPA and proxies `/api/` to the internal `taskapp-backend` ClusterIP service, so the API is not exposed through a separate public service.

## Verify the deployment

```bash
# Argo CD reconciliation
kubectl -n argocd get application taskapp

# Workload health
kubectl -n taskapp get pods
kubectl -n taskapp get svc taskapp-frontend

# API and database health through the frontend proxy
curl -fsS https://app.oparatechstack.com/api/health

# Kyverno policy status
kubectl get clusterpolicy taskapp-deployment-security
```

The expected health response reports `"status":"healthy"` and `"database":"connected"`. Reproducible command output from the implemented environment is retained under `docs/evidence/`.

## Kyverno policy controls

Deployments in the `taskapp` namespace are rejected unless they:

- use a versioned image rather than `latest`
- disable service-account token automounting
- run as a non-root user with the `RuntimeDefault` seccomp profile
- disable privilege escalation and drop all Linux capabilities
- define CPU and memory requests and limits

Negative test manifests are available in `kyverno/tests/` to demonstrate admission denial.

## Local application development

### Backend

```bash
cd app/taskapp_backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt pytest

export DATABASE_HOST='localhost'
export DATABASE_PORT='5432'
export DATABASE_NAME='taskapp'
export DATABASE_USER='taskapp_user'
export DATABASE_PASSWORD='taskapp_password'
export DATABASE_SSL_MODE='disable'
export SECRET_KEY='local-development-key'
pytest
python run.py
```

The backend listens on port `5000`. Its health endpoint is `GET /api/health`; authentication endpoints are under `/api/auth`, and JWT-protected task CRUD endpoints are under `/api/tasks`.

### Frontend

```bash
cd app/taskapp_frontend
npm ci
VITE_API_URL=http://localhost:5000/api npm run dev
```

The Vite development server is available at `http://localhost:5173`. See the component-specific READMEs in `app/taskapp_backend/` and `app/taskapp_frontend/` for API and UI details.

## Destruction

Destroying the environment is intentionally guarded:

```bash
export TF_VAR_db_password='the-password-used-during-deployment'
./scripts/destroy.sh
```

The script creates a reviewable destroy plan and requires the exact confirmation `DESTROY_ROOT`. It destroys only resources managed by `terraform/root`; the remote-state bucket is protected and retained. Delete kOps-managed cluster resources with kOps before destroying their supporting VPC resources.

## Security and production notes

- Never commit Terraform state, Kubernetes Secrets, database credentials, kubeconfigs, private keys, or `.env` files.
- Replace every repository-specific ARN, bucket name, endpoint, domain, subnet ID, VPC ID, and administrator CIDR when deploying a fork.
- RDS is private, but the current reference configuration is cost-conscious: it is single-AZ, retains one day of backups, skips the final snapshot, and has deletion protection disabled. Strengthen these settings for a critical production workload.
- CI image and configuration scans are currently non-blocking. Change their exit behavior when the accepted risk baseline is established.
- JWTs are stored by the frontend in local storage. Higher-security deployments should consider short-lived access tokens, refresh-token rotation, and HttpOnly cookies.

## Further documentation

- [Backend API documentation](app/taskapp_backend/README.md)
- [Frontend documentation](app/taskapp_frontend/README.md)
- [Database architecture decision](docs/decisions/database-strategy.md)
- [Deployment and security evidence](docs/evidence/)
