from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from .db import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    gemini_api_key = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    accounts = relationship("Account", back_populates="user", cascade="all, delete-orphan")


class Account(Base):
    __tablename__ = "accounts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    provider = Column(String, nullable=False)  # "Gmail", "Outlook", etc.
    email_address = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    is_sync_enabled = Column(Boolean, default=True)
    is_primary = Column(Boolean, default=False)

    user = relationship("User", back_populates="accounts")
    emails = relationship("Email", back_populates="account", cascade="all, delete-orphan")


class Email(Base):
    __tablename__ = "emails"

    id = Column(Integer, primary_key=True, index=True)
    account_id = Column(Integer, ForeignKey("accounts.id"), nullable=False)
    sender = Column(String, nullable=False)
    recipient = Column(String, nullable=False)
    subject = Column(String, nullable=False)
    body = Column(Text, nullable=False)
    received_at = Column(DateTime, default=datetime.utcnow)
    is_read = Column(Boolean, default=False)
    importance_score = Column(Integer, default=50)  # 0 to 100

    account = relationship("Account", back_populates="emails")
    
    # Relationships to detail tables (1-to-1 or 1-to-many)
    classification = relationship("Classification", uselist=False, back_populates="email", cascade="all, delete-orphan")
    summary = relationship("AISummary", uselist=False, back_populates="email", cascade="all, delete-orphan")
    spam_analysis = relationship("SpamAnalysis", uselist=False, back_populates="email", cascade="all, delete-orphan")
    application = relationship("Application", uselist=False, back_populates="email", cascade="all, delete-orphan")
    deadlines = relationship("Deadline", back_populates="email", cascade="all, delete-orphan")


class Classification(Base):
    __tablename__ = "classifications"

    email_id = Column(Integer, ForeignKey("emails.id"), primary_key=True)
    category = Column(String, nullable=False)  # "Opportunities", "Interviews", "Social", etc.
    secondary_tags = Column(Text, nullable=False)  # JSON-serialized list of tags

    email = relationship("Email", back_populates="classification")


class AISummary(Base):
    __tablename__ = "ai_summaries"

    email_id = Column(Integer, ForeignKey("emails.id"), primary_key=True)
    quick_summary = Column(Text, nullable=False)
    bullet_points = Column(Text, nullable=False)  # JSON-serialized list of points
    action_items = Column(Text, nullable=False)   # JSON-serialized list of action items

    email = relationship("Email", back_populates="summary")


class SpamAnalysis(Base):
    __tablename__ = "spam_analysis"

    email_id = Column(Integer, ForeignKey("emails.id"), primary_key=True)
    risk_score = Column(Integer, default=0)       # 0 to 100
    trust_score = Column(Integer, default=100)    # 0 to 100
    explanation = Column(Text, nullable=False)
    phishing_detected = Column(Boolean, default=False)
    malicious_attachment_detected = Column(Boolean, default=False)

    email = relationship("Email", back_populates="spam_analysis")


class Application(Base):
    __tablename__ = "applications"

    id = Column(Integer, primary_key=True, index=True)
    email_id = Column(Integer, ForeignKey("emails.id"), nullable=False)
    company = Column(String, nullable=False)
    role = Column(String, nullable=False)
    current_status = Column(String, default="Applied")  # "Applied", "Assessment", "Interview", "Selected", "Rejected"
    timeline_events = Column(Text, nullable=False)       # JSON-serialized list of status + date events

    email = relationship("Email", back_populates="application")


class Deadline(Base):
    __tablename__ = "deadlines"

    id = Column(Integer, primary_key=True, index=True)
    email_id = Column(Integer, ForeignKey("emails.id"), nullable=False)
    title = Column(String, nullable=False)
    due_at = Column(DateTime, nullable=False)
    source_type = Column(String, nullable=False)         # "Assignment", "Assessment", "Interview", "Registration"

    email = relationship("Email", back_populates="deadlines")
    calendar_event = relationship("CalendarEvent", uselist=False, back_populates="deadline", cascade="all, delete-orphan")


class CalendarEvent(Base):
    __tablename__ = "calendar_events"

    id = Column(Integer, primary_key=True, index=True)
    deadline_id = Column(Integer, ForeignKey("deadlines.id"), nullable=True)
    email_id = Column(Integer, ForeignKey("emails.id"), nullable=True)
    title = Column(String, nullable=False)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)
    synced_google = Column(Boolean, default=False)
    synced_outlook = Column(Boolean, default=False)

    deadline = relationship("Deadline", back_populates="calendar_event")


