# Database Strategy

TaskApp uses Amazon RDS for PostgreSQL instead of running PostgreSQL inside Kubernetes.

## Current implementation

The backend runs as a Kubernetes workload and connects to Amazon RDS PostgreSQL using environment variables provided through Helm and Kubernetes Secrets.

Required backend variables:

- DATABASE_HOST
- DATABASE_PORT
- DATABASE_NAME
- DATABASE_USER
- DATABASE_PASSWORD
- SECRET_KEY

The RDS instance is deployed in private subnets and is not publicly accessible.

## Why RDS was chosen

RDS was selected because it better reflects a production-style architecture:

- the application pods remain stateless
- database storage is managed outside the Kubernetes cluster
- backups and recovery are easier to manage
- the database can survive cluster rebuilds
- infrastructure ownership is clearer between app runtime and persistent data

## Alternative considered

PostgreSQL inside Kubernetes was considered for speed and simplicity. It would have demonstrated StatefulSets and PersistentVolumeClaims, but would also add operational responsibility around backups, storage lifecycle, recovery, and data safety.

## Trade-off

RDS adds extra AWS cost and Terraform work, but it provides a stronger real-company architecture for a cloud-native Kubernetes project.
