from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from metrics.router import router as metrics_router

import prometheus_client
from starlette.responses import Response
import time
import psutil

app = FastAPI()

# Middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Métriques Prometheus
http_requests_total = prometheus_client.Counter("http_requests_total", "Total HTTP Requests (count)", ["method", "endpoint"])
http_requests_duration = prometheus_client.Histogram("http_request_duration_seconds", "HTTP request duration (seconds)", ["endpoint"])
memory_usage = prometheus_client.Gauge("memory_usage_bytes", "Memory usage of the webservice (bytes)")
cpu_usage = prometheus_client.Gauge("cpu_usage_seconds", "CPU usage of the webservice (seconds)")

# Middleware pour collecter les métriques
@app.middleware("http")
async def collect_metrics(request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time

    http_requests_total.labels(method=request.method, endpoint=request.url.path).inc()
    http_requests_duration.labels(endpoint=request.url.path).observe(process_time)

    # Métriques de la mémoire
    memory_usage.set(psutil.virtual_memory().used)

    # Métriques du CPU
    cpu_times = psutil.cpu_times()
    cpu_usage.set(cpu_times.user + cpu_times.system)

    return response

# Endpoint pour Prometheus
@app.get("/metrics")
async def metrics():
    return Response(prometheus_client.generate_latest(), media_type="text/plain")

app.include_router(metrics_router)

# Root endpoint
@app.get("/")
async def root():
    return {"message": "Welcome !"}
