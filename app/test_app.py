from app import app

def test_hello():
    r = app.test_client().get("/")
    assert r.status_code == 200
    assert b"Deployed by Mohammad Maaz via Full CI/CD Pipeline" in r.data

def test_health():
    r = app.test_client().get("/health")
    assert r.status_code == 200
    assert r.get_json() == {"status": "healthy"}
