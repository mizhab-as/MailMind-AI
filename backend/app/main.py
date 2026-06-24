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


@app.get("/accounts")
def get_accounts(user_id: int = 1, db: Session = Depends(get_db)):
    return db.query(Account).filter(Account.user_id == user_id).all()


class AccountCreate(BaseModel):
    name: str
    provider: str
    email_address: str
    is_primary: bool = False

@app.post("/accounts")
def create_account(req: AccountCreate, user_id: int = 1, db: Session = Depends(get_db)):
    acc = Account(
        user_id=user_id,
        name=req.name,
        provider=req.provider,
        email_address=req.email_address,
        is_primary=req.is_primary,
        is_sync_enabled=True
    )
    db.add(acc)
    db.commit()
    db.refresh(acc)
    return acc


@app.delete("/accounts/{account_id}")
def delete_account(account_id: int, db: Session = Depends(get_db)):
    acc = db.query(Account).filter(Account.id == account_id).first()
    if not acc:
        raise HTTPException(status_code=404, detail="Account not found")
    db.delete(acc)
    db.commit()
    return {"status": "success"}


@app.get("/emails")
def get_emails(account_id: int = None, category: str = None, db: Session = Depends(get_db)):
    query = db.query(Email)
    if account_id:
        query = query.filter(Email.account_id == account_id)
    if category:
        query = query.join(Classification).filter(Classification.category == category)
    
    emails = query.order_by(Email.received_at.desc()).all()
    
    result = []
    for e in emails:
        tags = json.loads(e.classification.secondary_tags) if e.classification else []
        result.append({
            "id": e.id,
            "account_id": e.account_id,
            "account_name": e.account.name,
            "sender": e.sender,
            "recipient": e.recipient,
            "subject": e.subject,
            "body": e.body,
            "received_at": e.received_at,
            "is_read": e.is_read,
            "importance_score": e.importance_score,
            "category": e.classification.category if e.classification else "Inbox",
            "tags": tags
        })
    return result

