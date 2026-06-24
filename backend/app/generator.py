import random
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from .models import User, Account, Email, Classification, AISummary, SpamAnalysis, Application, Deadline, CalendarEvent
from .ai_service import AIService

# Sample email templates for seeding the inbox
TEMPLATES = [
    {
        "provider": "Professional Gmail",
        "sender": "careers@google.com",
        "subject": "Google Software Engineering Intern: Technical Interview Invitation",
        "body": "Hi student, We are excited to move you forward in our Software Engineering Internship hiring process. Please schedule your 45-minute technical interview using the link below before June 30, 2026. The interview will cover data structures and algorithms."
    },
    {
        "provider": "Professional Gmail",
        "sender": "recruiter@microsoft.com",
        "subject": "Microsoft: Coding Test Assessment Assigned",
        "body": "Hello, Thank you for applying for the Software Engineer role. Your technical coding test is now active. Please complete the assessment within 5 days. Link: http://microsoft-careers.com/test."
    },
    {
        "provider": "College Gmail",
        "sender": "professor.adams@university.edu",
        "subject": "CS-401 Machine Learning: Midterm Assignment Deadline Extended",
        "body": "Dear class, The submission deadline for Assignment 3 has been extended to July 4, 2026 at 11:59 PM. Please submit your Jupyter notebook files via the course platform. Late submissions will face penalties."
    },
        "body": "Dear students, Registration for the upcoming Semester Finals will close on June 28, 2026. Please verify your course enrollments and complete the payment portal to secure your seat. Late registration is not permitted."
    },
    {
        "provider": "Personal Gmail",
        "sender": "notifications@github.com",
        "subject": "[GitHub] Security Alert: vulnerability in packages",
        "body": "Hey developer, We found a dependency vulnerability in your repository. Please review the advisory notice and update package versions."
    },
    {
        "provider": "Personal Gmail",
        "sender": "noreply@secure-bank.com",
        "subject": "Statement Alert: monthly credit card statement available",
        "body": "Hi user, Your monthly statement for your secure credit card ending in 4321 is ready. Your current balance is $450.00, due on July 5, 2026."
    },
    {
        "provider": "Internship Gmail",
        "sender": "giftcards@scammy-promotions.com",
        "subject": "CONGRATULATIONS! You won a $1000 Amazon Gift Card!",
        "body": "Dear Winner, You have been randomly chosen to receive a $1000 Amazon gift card! Click the link below within 24 hours to confirm your banking details and claim your prize: http://claim-amazon-giftcard.net."
    }
]

def seed_demo_data(db: Session):
    # Check if demo user exists
    user = db.query(User).filter(User.username == "demo").first()
    if not user:
        from passlib.hash import bcrypt
        user = User(
            username="demo",
            password_hash=bcrypt.hash("demo123"),
            gemini_api_key=None
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    # Check if accounts exist
    providers = [
        {"name": "Personal Gmail", "provider": "Gmail", "email_address": "demo.personal@gmail.com", "is_primary": True},
        {"name": "College Gmail", "provider": "Gmail", "email_address": "demo.academic@university.edu", "is_primary": False},
        {"name": "Professional Gmail", "provider": "Gmail", "email_address": "demo.professional@gmail.com", "is_primary": False},
        {"name": "Internship Gmail", "provider": "Gmail", "email_address": "demo.intern@gmail.com", "is_primary": False}
    ]

    accounts_map = {}
    for p in providers:
        acc = db.query(Account).filter(Account.email_address == p["email_address"]).first()
        if not acc:
            acc = Account(
                user_id=user.id,
                provider=p["provider"],
                email_address=p["email_address"],
                name=p["name"],
                is_sync_enabled=True,
                is_primary=p["is_primary"]
            )
            db.add(acc)
            db.commit()
            db.refresh(acc)
        accounts_map[p["name"]] = acc

    # Seed emails if database is empty of emails
    if db.query(Email).count() == 0:
        ai = AIService()
        for t in TEMPLATES:
            acc = accounts_map.get(t["provider"])
            if not acc:
                continue
            
            # Create Email
            email = Email(
                account_id=acc.id,
                sender=t["sender"],
                recipient=acc.email_address,
                subject=t["subject"],
                body=t["body"],
                received_at=datetime.utcnow() - timedelta(hours=random.randint(1, 24)),
                is_read=False,
                importance_score=50
            )
            db.add(email)
            db.commit()
            db.refresh(email)
            
            # Analyze using AI
            analysis = ai.analyze_email(email.sender, email.subject, email.body)
            _save_analysis_to_db(db, email.id, analysis)


def _save_analysis_to_db(db: Session, email_id: int, analysis: dict):
    import json
    
    # 1. Classification
    cl = Classification(
        email_id=email_id,
        category=analysis["category"],
        secondary_tags=json.dumps(analysis["tags"])
    )
    db.add(cl)
    
    # 2. AISummary
    sm = AISummary(
        email_id=email_id,
        quick_summary=analysis["quick_summary"],
        bullet_points=json.dumps(analysis["bullet_points"]),
        action_items=json.dumps(analysis["action_items"])
    )
    db.add(sm)
    
    # 3. SpamAnalysis
    sp = SpamAnalysis(
        email_id=email_id,
        risk_score=analysis["spam_analysis"]["risk_score"],
        trust_score=analysis["spam_analysis"]["trust_score"],
        explanation=analysis["spam_analysis"]["explanation"],
        phishing_detected=analysis["spam_analysis"]["phishing_detected"],
        malicious_attachment_detected=analysis["spam_analysis"]["malicious_attachment_detected"]
    )
    db.add(sp)
    
    # Update email importance score
    email = db.query(Email).filter(Email.id == email_id).first()
    if email:
        email.importance_score = analysis["importance_score"]
        
    # 4. Application Tracking
    if analysis["application"]:
        app_data = analysis["application"]
        app = Application(
            email_id=email_id,
            company=app_data["company"],
            role=app_data["role"],
            current_status=app_data["current_status"],
            timeline_events=json.dumps(app_data["timeline_events"])
        )
        db.add(app)
        
    # 5. Deadlines & Calendar Events
    for d in analysis["deadlines"]:
        dl = Deadline(
            email_id=email_id,
            title=d["title"],
            due_at=datetime.fromisoformat(d["due_at"]),
            source_type=d["source_type"]
        )
        db.add(dl)
        db.commit()
        db.refresh(dl)
        
        # Link Calendar Event
        ev = CalendarEvent(
            deadline_id=dl.id,
            email_id=email_id,
            title=dl.title,
            start_time=dl.due_at - timedelta(hours=1),
            end_time=dl.due_at,
            synced_google=True,
            synced_outlook=False
        )
        db.add(ev)
        
    db.commit()


def generate_random_email(db: Session):
    """
    Simulates sync by fetching a random template, adding variation, and adding it to the inbox.
    """
    user = db.query(User).filter(User.username == "demo").first()
    if not user:
        return
    accounts = db.query(Account).filter(Account.user_id == user.id).all()
    if not accounts:
        return
        
    template = random.choice(TEMPLATES)
    acc = next((a for a in accounts if a.name == template["provider"]), accounts[0])
    
    # Add minor text variation to simulate a new mail
    variation = f" [Received Ref: #{random.randint(1000, 9999)}]"
    subject = template["subject"] + variation
    
    email = Email(
        account_id=acc.id,
        sender=template["sender"],
        recipient=acc.email_address,
        subject=subject,
        body=template["body"] + f"\n\nSystem Timestamp: {datetime.utcnow().isoformat()}",
        received_at=datetime.utcnow(),
        is_read=False,
        importance_score=50
    )
    db.add(email)
    db.commit()
    db.refresh(email)
    
    ai = AIService()
    analysis = ai.analyze_email(email.sender, email.subject, email.body)
    _save_analysis_to_db(db, email.id, analysis)
    return email




