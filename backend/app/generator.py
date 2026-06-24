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


