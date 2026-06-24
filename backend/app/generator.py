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
    {
        "provider": "College Gmail",
        "sender": "registrar@university.edu",
        "subject": "Urgent: College Exam Schedule and Registration Notice",
        "body": "Dear students, Registration for the upcoming Semester Finals will close on June 28, 2026. Please verify your course enrollments and complete the payment portal to secure your seat. Late registration is not permitted."
    }
]
