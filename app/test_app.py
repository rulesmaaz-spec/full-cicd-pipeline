import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

from app import app  # noqa: E402


def test_health_endpoint():
    client = app.test_client()
    resp = client.get('/health')
    assert resp.status_code == 200
    assert resp.get_json()['status'] == 'healthy'


def test_index_returns_html():
    client = app.test_client()
    resp = client.get('/')
    assert resp.status_code == 200
    assert b'Deployed via Full CI/CD Pipeline!' in resp.data
