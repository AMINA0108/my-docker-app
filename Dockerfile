# ── Stage 1: Builder ──
FROM python:3.12-alpine AS builder
WORKDIR /app

RUN pip install --no-cache-dir \
    flask \
    gunicorn

# ── Stage 2: Runtime ───
FROM python:3.12-alpine AS runtime
WORKDIR /app

COPY --from=builder /usr/local/lib/python3.12/site-packages \
    /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/gunicorn \
    /usr/local/bin/gunicorn

COPY app.py .

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -qO- http://localhost:5000/health || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
