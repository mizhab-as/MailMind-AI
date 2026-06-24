import os
import json
from datetime import datetime, timedelta
import re

class AIService:
    def __init__(self, api_key: str = None):
        # Read API key from environment if not explicitly provided
        self.api_key = api_key or os.getenv("GEMINI_API_KEY")
        self.client = None
        if self.api_key:
            try:
                # We'll use the google-genai SDK if available
                from google import genai
                self.client = genai.Client(api_key=self.api_key)
            except Exception as e:
                print(f"Failed to initialize Gemini Client: {e}")

    def analyze_email(self, sender: str, subject: str, body: str) -> dict:
        """
        Analyzes an email to extract category, tags, summaries, deadlines,
        spam risk, and application tracking updates. Falls back to local
        parser if Gemini API is unavailable.
        """
        if self.client:
            try:
                return self._analyze_with_gemini(sender, subject, body)
            except Exception as e:
                print(f"Gemini API analysis failed, falling back: {e}")
        
        return self._analyze_with_rules(sender, subject, body)

    def answer_assistant_query(self, query: str, emails_context: str, chat_history: list = None) -> str:
        """
        Conversational assistant that answers questions about user's emails.
        """
        if self.client:
            try:
                return self._answer_with_gemini(query, emails_context, chat_history)
            except Exception as e:
                print(f"Gemini API assistant failed, falling back: {e}")

        return self._answer_with_rules(query, emails_context, chat_history)

    def _analyze_with_rules(self, sender: str, subject: str, body: str) -> dict:
        sb = (subject + " " + body).lower()
        
        # Determine category, tags, and importance
        category = "Newsletters"
        tags = ["Inbox"]
        importance = 30
        
        if "unsubscribe" in sb:
            category = "Newsletters"
            tags = ["Subscription"]
            importance = 20
        if any(w in sb for w in ["linkedin", "github", "discord", "instagram"]):
            category = "Social"
            tags = ["Social Media"]
            importance = 15
        if any(w in sb for w in ["bank", "statement", "invoice", "payment", "bill", "transaction"]):
            category = "Finance"
            tags = ["Billing"]
            importance = 65
        if any(w in sb for w in ["assignment", "exam", "syllabus", "notice", "college"]):
            category = "Academic"
            tags = ["Academic"]
            importance = 70
        if any(w in sb for w in ["offer", "selected", "shortlisted", "accepted"]):
            category = "Acceptance"
            tags = ["Career", "Offer"]
            importance = 95
        if any(w in sb for w in ["unfortunately", "not selected", "not moving forward", "rejected"]):
            category = "Rejection"
            tags = ["Application Update"]
            importance = 50
        if any(w in sb for w in ["interview", "coding test", "assessment", "schedule"]):
            category = "Interviews"
            tags = ["Interview", "Action Required"]
            importance = 90
        if any(w in sb for w in ["internship", "fellowship", "scholarship", "placement"]):
            category = "Opportunities"
            tags = ["Career Opportunity"]
            importance = 80
        if any(w in sb for w in ["phishing", "scam", "gift card", "verify bank", "winner"]):
            category = "Spam"
            tags = ["Suspicious"]
            importance = 5

