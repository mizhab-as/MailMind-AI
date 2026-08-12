from fastapi import FastAPI, Depends, HTTPException, status, Query, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
import json
from datetime import datetime
from pydantic import BaseModel

from .db import Base, engine, get_db
from .models import User, Account, Email, Classification, AISummary, SpamAnalysis, Application, Deadline, CalendarEvent, EmailRule, Draft, AuditLog, SecurityAlert
from .generator import seed_demo_data, generate_random_email
from .ai_service import AIService
from .rules_engine import RulesEngine



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


@app.get("/emails/{email_id}")
def get_email_detail(email_id: int, db: Session = Depends(get_db)):
    e = db.query(Email).filter(Email.id == email_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Email not found")
        
    tags = json.loads(e.classification.secondary_tags) if e.classification else []
    summary_bullets = json.loads(e.summary.bullet_points) if e.summary else []
    summary_actions = json.loads(e.summary.action_items) if e.summary else []
    
    app_data = None
    if e.application:
        app_data = {
            "company": e.application.company,
            "role": e.application.role,
            "current_status": e.application.current_status,
            "timeline_events": json.loads(e.application.timeline_events)
        }
        
    spam_data = None
    if e.spam_analysis:
        spam_data = {
            "risk_score": e.spam_analysis.risk_score,
            "trust_score": e.spam_analysis.trust_score,
            "explanation": e.spam_analysis.explanation,
            "phishing_detected": e.spam_analysis.phishing_detected,
            "malicious_attachment_detected": e.spam_analysis.malicious_attachment_detected
        }
        
    return {
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
        "tags": tags,
        "summary": {
            "quick": e.summary.quick_summary if e.summary else "",
            "bullets": summary_bullets,
            "actions": summary_actions
        } if e.summary else None,
        "application": app_data,
        "spam_analysis": spam_data
    }


class ReadStatusRequest(BaseModel):
    is_read: bool

@app.put("/emails/{email_id}/read")
def update_read_status(email_id: int, req: ReadStatusRequest, db: Session = Depends(get_db)):
    e = db.query(Email).filter(Email.id == email_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Email not found")
    e.is_read = req.is_read
    db.commit()
    return {"status": "success"}


class ChatRequest(BaseModel):
    query: str

@app.post("/assistant/chat")
def chat_assistant(req: ChatRequest, db: Session = Depends(get_db)):
    # Build simple context from recent emails
    emails = db.query(Email).order_by(Email.received_at.desc()).limit(10).all()
    context_str = ""
    for idx, e in enumerate(emails):
        cat = e.classification.category if e.classification else "Unknown"
        context_str += f"Email {idx+1}: From {e.sender}, Subject: {e.subject}, Category: {cat}\nBody Summary: {e.summary.quick_summary if e.summary else ''}\n\n"
        
    ai = AIService()
    answer = ai.answer_assistant_query(req.query, context_str)
    return {"response": answer}


@app.get("/analytics/stats")
def get_analytics(db: Session = Depends(get_db)):
    total_emails = db.query(Email).count()
    unread_important = db.query(Email).filter(Email.is_read == False, Email.importance_score >= 70).count()
    
    # Categories count
    categories = ["Opportunities", "Interviews", "Acceptance", "Rejection", "Academic", "Finance", "Social", "Promotions", "Newsletters", "Spam"]
    cat_counts = {}
    for cat in categories:
        count = db.query(Classification).filter(Classification.category == cat).count()
        cat_counts[cat] = count
        
    # Opportunities statistics
    opportunities = db.query(Application).count()
    interviews = db.query(Application).filter(Application.current_status == "Interview").count()
    accepts = db.query(Application).filter(Application.current_status == "Accepted").count()
    rejects = db.query(Application).filter(Application.current_status == "Rejected").count()
    
    # Phishing alerts
    blocked_phishing = db.query(SpamAnalysis).filter(SpamAnalysis.phishing_detected == True).count()
    
    return {
        "total_emails": total_emails,
        "unread_important": unread_important,
        "categories_breakdown": cat_counts,
        "applications": {
            "total": opportunities,
            "interviews": interviews,
            "accepts": accepts,
            "rejects": rejects
        },
        "blocked_phishing": blocked_phishing,
        "security_score": 92 if blocked_phishing < 5 else 78
    }


@app.post("/sync/mock")
def trigger_sync(db: Session = Depends(get_db)):
    email = generate_random_email(db)
    if not email:
        return {"status": "error", "message": "Failed to sync new email"}
    return {
        "status": "success",
        "email": {
            "id": email.id,
            "sender": email.sender,
            "subject": email.subject,
            "category": email.classification.category if email.classification else "Inbox"
        }
    }

# --------------------------------------------------------------------------
# PHASE 1 NEW ENDPOINTS: Advanced Search, Rules, Drafts, Security & WS
# --------------------------------------------------------------------------

@app.get("/emails/search/advanced")
def search_emails_advanced(
    q: Optional[str] = None,
    category: Optional[str] = None,
    account_id: Optional[int] = None,
    is_read: Optional[bool] = None,
    min_importance: Optional[int] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Email)
    if account_id:
        query = query.filter(Email.account_id == account_id)
    if is_read is not None:
        query = query.filter(Email.is_read == is_read)
    if min_importance is not None:
        query = query.filter(Email.importance_score >= min_importance)
    if category and category != "All":
        query = query.join(Classification).filter(Classification.category == category)
    if q:
        search_pattern = f"%{q}%"
        query = query.filter(
            (Email.subject.ilike(search_pattern)) | 
            (Email.sender.ilike(search_pattern)) | 
            (Email.body.ilike(search_pattern))
        )
    
    emails = query.order_by(Email.received_at.desc()).all()
    result = []
    for e in emails:
        tags = json.loads(e.classification.secondary_tags) if e.classification else []
        result.append({
            "id": e.id,
            "account_id": e.account_id,
            "account_name": e.account.name if e.account else "Inbox",
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


class DraftCreate(BaseModel):
    recipient: str = ""
    subject: str = ""
    body: str = ""
    tone: str = "Professional"

@app.get("/drafts")
def get_drafts(db: Session = Depends(get_db)):
    return db.query(Draft).order_by(Draft.updated_at.desc()).all()

@app.post("/drafts")
def create_draft(req: DraftCreate, db: Session = Depends(get_db)):
    draft = Draft(
        user_id=1,
        recipient=req.recipient,
        subject=req.subject,
        body=req.body,
        tone=req.tone,
        updated_at=datetime.utcnow()
    )
    db.add(draft)
    db.commit()
    db.refresh(draft)
    return draft

@app.delete("/drafts/{draft_id}")
def delete_draft(draft_id: int, db: Session = Depends(get_db)):
    draft = db.query(Draft).filter(Draft.id == draft_id).first()
    if not draft:
        raise HTTPException(status_code=404, detail="Draft not found")
    db.delete(draft)
    db.commit()
    return {"status": "success"}


class RuleCreate(BaseModel):
    rule_name: str
    condition_field: str
    condition_operator: str
    condition_value: str
    action_type: str
    action_value: str

@app.get("/rules")
def get_rules(db: Session = Depends(get_db)):
    return db.query(EmailRule).all()

@app.post("/rules")
def create_rule(req: RuleCreate, db: Session = Depends(get_db)):
    rule = EmailRule(
        user_id=1,
        rule_name=req.rule_name,
        condition_field=req.condition_field,
        condition_operator=req.condition_operator,
        condition_value=req.condition_value,
        action_type=req.action_type,
        action_value=req.action_value,
        is_active=True
    )
    db.add(rule)
    db.commit()
    db.refresh(rule)
    return rule

@app.delete("/rules/{rule_id}")
def delete_rule(rule_id: int, db: Session = Depends(get_db)):
    rule = db.query(EmailRule).filter(EmailRule.id == rule_id).first()
    if not rule:
        raise HTTPException(status_code=404, detail="Rule not found")
    db.delete(rule)
    db.commit()
    return {"status": "success"}

@app.post("/rules/execute")
def execute_rules(db: Session = Depends(get_db)):
    engine = RulesEngine(db)
    emails = db.query(Email).all()
    applied_count = sum(engine.evaluate_rules_for_email(e) for e in emails)
    return {"status": "success", "applied_actions": applied_count}



@app.get("/security/alerts")
def get_security_alerts(db: Session = Depends(get_db)):
    return db.query(SecurityAlert).order_by(SecurityAlert.created_at.desc()).all()


class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            await connection.send_text(message)

ws_manager = ConnectionManager()

@app.websocket("/ws/notifications")
async def websocket_notifications(websocket: WebSocket):
    await ws_manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            await ws_manager.broadcast(f"Notification Echo: {data}")
    except WebSocketDisconnect:
        ws_manager.disconnect(websocket)



