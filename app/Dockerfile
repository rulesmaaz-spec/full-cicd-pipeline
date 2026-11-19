# ---- Stage 1: build ----
FROM python:3.11-slim-bookworm AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- Stage 2: runtime ----
FROM gcr.io/distroless/python3-debian12:nonroot

WORKDIR /app
COPY --from=builder /install /usr/local/lib/python3.11/site-packages
COPY app.py .

USER nonroot:nonroot
EXPOSE 5000

ENTRYPOINT ["python3", "-m", "gunicorn"]
CMD ["--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-", "app:app"]
