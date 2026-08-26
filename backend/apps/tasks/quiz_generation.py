"""
AI / Provider generation extension point for task verification quizzes.
Phase 5 establishes the interface and manual provider without locking to an external AI vendor.
"""

class QuizGenerationProvider:
    """Abstract interface for quiz question generation."""
    def generate_for_task(self, task):
        raise NotImplementedError("Quiz generation providers must implement generate_for_task.")

class ManualQuizGenerationProvider(QuizGenerationProvider):
    """
    Standard manual/admin provider that retrieves pre-authored questions configured on the task.
    """
    def generate_for_task(self, task):
        return task.quiz_questions.filter(active=True)
