from fastapi import APIRouter, Body, HTTPException
from metrics import redisConf
from metrics import schemas
from metrics import db

router = APIRouter()

db.init_db()

db.init_client_data()

@router.post("/metrics", tags=["metrics"])
async def create_metrics(req: schemas.Metric):
    domain = req.tracker.WINDOW_LOCATION_HREF.split('/')[2]  # Extrait le domaine de l'URL

    print(f"Received metrics for {domain}.")

    with db.session_scope() as session:
        
        client = session.query(db.Client).filter(db.Client.domain == domain).first()
        if not client:
            raise HTTPException(status_code=404, detail="Client not found")

    # Incrémenter le compteur dans Redis
    redisConf.redis_client.incr(f"page_count:{req.tracker.WINDOW_LOCATION_HREF}")

    # Afficher le compteur
    page_count = redisConf.redis_client.get(f"page_count:{req.tracker.WINDOW_LOCATION_HREF}")
    print(f"Page count for {req.tracker.WINDOW_LOCATION_HREF}: {page_count}")
    return {"status": "success", "data": req}