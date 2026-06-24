from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import json
from pydantic import BaseModel

from .db import Base, engine, get_db
from .models import User, Account, Email, Classification, AISummary, SpamAnalysis, Application, Deadline, CalendarEvent
from .generator import seed_demo_data, generate_random_email
from .ai_service import AIService

# Initialize tables
Base.metadata.create_all(bind=engine)

# Seed demo user & emails
db = next(get_db())
seed_demo_data(db)

app = FastAPI(title="MailMind AI Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class LoginRequest(BaseModel):
    username: str
    password: str

@app.post("/auth/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == req.username).first()
    if not user:
         raise HTTPException(status_code=401, detail="Invalid username or password")
    # For simplicity of the demo, we support a simple verification
    return {
        "status": "success",
        "user_id": user.id,
        "username": user.username,
        "token": "demo-jwt-token-xyz"
    }
