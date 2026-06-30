import os
import pytest
from werkzeug.security import generate_password_hash

from app import create_app, db
from app.models import User


@pytest.fixture
def app():
    """Create application for testing."""
    os.environ["DATABASE_HOST"] = "localhost"
    os.environ["DATABASE_PORT"] = "5432"
    os.environ["DATABASE_NAME"] = "testdb"
    os.environ["DATABASE_USER"] = "test"
    os.environ["DATABASE_PASSWORD"] = "test"
    os.environ["DATABASE_SSL_MODE"] = "disable"
    os.environ["SECRET_KEY"] = "test-secret-key"

    app = create_app()
    app.config["TESTING"] = True

    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()


@pytest.fixture
def client(app):
    """Test client."""
    return app.test_client()


@pytest.fixture
def auth_headers(client):
    """Get authentication headers."""
    user = User(
        username="testuser",
        password_hash=generate_password_hash("testpass"),
    )

    db.session.add(user)
    db.session.commit()

    resp = client.post(
        "/api/auth/login",
        json={
            "username": "testuser",
            "password": "testpass",
        },
    )

    token = resp.json["token"]
    return {"Authorization": f"Bearer {token}"}