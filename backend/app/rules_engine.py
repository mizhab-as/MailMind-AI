from sqlalchemy.orm import Session
from .models import EmailRule, Email, Classification, AuditLog

class RulesEngine:
    def __init__(self, db: Session):
        self.db = db

    def evaluate_rules_for_email(self, email: Email) -> int:
        rules = self.db.query(EmailRule).filter(EmailRule.is_active == True).all()
        actions_applied = 0
        for rule in rules:
            field_value = str(getattr(email, rule.condition_field, "") or "")
            match = False
            
            if rule.condition_operator == "contains":
                match = rule.condition_value.lower() in field_value.lower()
            elif rule.condition_operator == "equals":
                match = rule.condition_value.lower() == field_value.lower()
            elif rule.condition_operator == "starts_with":
                match = field_value.lower().startswith(rule.condition_value.lower())

            if match:
                actions_applied += 1
                if rule.action_type == "set_category":
                    if not email.classification:
                        email.classification = Classification(email_id=email.id, category=rule.action_value, secondary_tags="[]")
                    else:
                        email.classification.category = rule.action_value
                elif rule.action_type == "flag_urgent":
                    email.importance_score = min(100, int(rule.action_value))
                elif rule.action_type == "set_read":
                    email.is_read = (rule.action_value.lower() == "true")
                
                # Log audit event
                log = AuditLog(
                    user_id=1,
                    action=f"Rule Applied: {rule.rule_name}",
                    target_type="Email",
                    target_id=email.id,
                    details=f"Condition '{rule.condition_field} {rule.condition_operator} {rule.condition_value}' matched. Action: {rule.action_type}={rule.action_value}"
                )
                self.db.add(log)
        
        self.db.commit()
        return actions_applied
