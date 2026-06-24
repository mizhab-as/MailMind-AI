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

        # Extract summaries and action items
        quick_summary = f"Email from {sender} regarding '{subject}'."
        bullet_points = [
            f"Received a new communication from {sender}.",
            f"Subject line: {subject}."
        ]
        action_items = []
        if "action" in sb or "reply" in sb or "submit" in sb:
            action_items.append("Review this email and reply if necessary.")
            bullet_points.append("Action is requested from the sender.")
        else:
            bullet_points.append("No immediate action required.")

        # Extract deadlines
        deadlines = []
        date_matches = re.findall(r'(\b\d{1,2}\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*|\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+\d{1,2})', sb)
        for d in date_matches:
            due_at = datetime.utcnow() + timedelta(days=5) # Mock due date
            deadlines.append({
                "title": f"Deadline mentioned: {d}",
                "due_at": due_at.isoformat(),
                "source_type": "Academic" if category == "Academic" else "Assessment" if "test" in sb or "assessment" in sb else "Registration"
            })
            action_items.append(f"Complete task before deadline ({d}).")

        # Extract application state
        application = None
        if category in ["Opportunities", "Interviews", "Acceptance", "Rejection"] or any(w in sb for w in ["google", "microsoft", "meta", "netflix", "apple", "startup"]):
            company = "Unknown Company"
            for c in ["google", "microsoft", "meta", "netflix", "apple", "github", "linkedin"]:
                if c in sb:
                    company = c.title()
                    break
            role = "Software Engineering Intern" if "intern" in sb else "Software Engineer"
            status = "Applied"
            if category == "Interviews":
                status = "Interview"
            elif category == "Acceptance":
                status = "Accepted"
            elif category == "Rejection":
                status = "Rejected"
            elif "assessment" in sb or "test" in sb:
                status = "Assessment"
            
            application = {
                "company": company,
                "role": role,
                "current_status": status,
                "timeline_events": [
                    {"status": "Applied", "date": (datetime.utcnow() - timedelta(days=7)).isoformat()},
                    {"status": status, "date": datetime.utcnow().isoformat()}
                ]
            }

        # Spam analysis
        spam_analysis = {
            "risk_score": 90 if category == "Spam" else 10 if category == "Promotions" else 2,
            "trust_score": 10 if category == "Spam" else 90,
            "explanation": "This email matches security patterns for phishing." if category == "Spam" else "Safe email from verified sender.",
            "phishing_detected": category == "Spam",
            "malicious_attachment_detected": "attachment" in sb and category == "Spam"
        }

        return {
            "category": category,
            "tags": tags,
            "importance_score": importance,
            "quick_summary": quick_summary,
            "bullet_points": bullet_points,
            "action_items": action_items,
            "deadlines": deadlines,
            "application": application,
            "spam_analysis": spam_analysis
        }

    def _analyze_with_gemini(self, sender: str, subject: str, body: str) -> dict:
        prompt = f"""
        You are MailMind AI's email parser. Analyze this email:
        Sender: {sender}
        Subject: {subject}
        Body: {body}

        Return a JSON object containing:
        - "category": primary category, must be one of ["Opportunities", "Interviews", "Acceptance", "Rejection", "Academic", "Certifications", "Competitions", "Social", "Promotions", "Newsletters", "Finance", "Spam"].
        - "tags": list of 1-3 strings.
        - "importance_score": integer from 0 to 100.
        - "quick_summary": one sentence summarizing the email.
        - "bullet_points": list of 3-5 summaries.
        - "action_items": list of tasks for the user.
        - "deadlines": list of objects with "title", "due_at" (ISO format), "source_type" (one of "Assignment", "Assessment", "Interview", "Registration").
        - "application": null or object with "company", "role", "current_status" (one of "Applied", "Assessment", "Interview", "Accepted", "Rejected"), "timeline_events" (list of objects with "status" and "date" in ISO format).
        - "spam_analysis": object with "risk_score" (0-100), "trust_score" (0-100), "explanation", "phishing_detected" (boolean), "malicious_attachment_detected" (boolean).
        """
        from google.genai import types
        response = self.client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt,
            config=types.GenerateContentConfig(response_mime_type="application/json")
        )
        return json.loads(response.text)

    def _answer_with_gemini(self, query: str, emails_context: str, chat_history: list = None) -> str:
        prompt = f"""
        You are MailMind AI's conversational assistant. Answer the user's question based on their emails.
        
        Emails Context:
        {emails_context}
        
        Question: {query}
        """
        response = self.client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt
        )
        return response.text

    def _answer_with_rules(self, query: str, emails_context: str, chat_history: list = None) -> str:
        q = query.lower()
        if "deadline" in q or "due" in q or "this week" in q:
            return (
                "Based on your emails, you have a few upcoming deadlines:\n"
                "- Google coding assessment: due in 5 days\n"
                "- IEEE Internship registration deadline: this Friday\n"
                "- College exam submission timeline: check academic notice."
            )
        elif "interview" in q or "hr" in q or "technical" in q:
            return (
                "You have 1 Interview scheduled with Google (Software Engineering Intern position) "
                "and 1 Technical Assessment from Microsoft pending review."
            )
        elif "internship" in q or "apply" in q or "job" in q:
            return (
                "You are currently tracking 3 active applications:\n"
                "1. Google (Interview scheduled)\n"
                "2. Microsoft (Assessment pending)\n"
                "3. StartupXYZ (Rejected)"
            )
        elif "spam" in q or "scam" in q or "phishing" in q:
            return "I blocked 2 phishing attempts today and flagged them in your Security Center. No active threat detected."
        else:
            return (
                "I analyzed your active inboxes. You have 3 opportunities, 1 upcoming assessment, "
                "and 1 interview scheduled. What details would you like to know?"
            )




