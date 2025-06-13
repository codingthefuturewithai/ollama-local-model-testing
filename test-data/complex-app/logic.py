# filepath: test-data/complex-app/logic.py
import uuid
from datetime import datetime
import utils  # Direct import instead of relative import

# Core logic for task management.
# This module contains classes for Task and TaskManager.
# It has opportunities for refactoring, such as:
# - Better ID generation (e.g., sequential integers or more robust UUIDs)
# - More sophisticated status management
# - Improved error handling and validation

class Task:
    def __init__(self, description, task_id=None, status="pending", created_at=None, completed_at=None):
        self.id = task_id if task_id is not None else self._generate_simple_id() # Could use UUID
        self.description = description
        self.status = status # "pending", "completed"
        self.created_at = created_at if created_at else datetime.now().isoformat()
        self.completed_at = completed_at

    def _generate_simple_id(self):
        # Simple ID for now, could be replaced by sequential or more robust UUID
        # For testing, a predictable ID might be useful, or a mockable one.
        return str(uuid.uuid4())[:8] # Shortened UUID for simplicity

    def complete(self):
        self.status = "completed"
        self.completed_at = datetime.now().isoformat()

    def to_dict(self):
        return {
            "id": self.id,
            "description": self.description,
            "status": self.status,
            "created_at": self.created_at,
            "completed_at": self.completed_at
        }

    @classmethod
    def from_dict(cls, data):
        return cls(
            description=data["description"],
            task_id=data["id"],
            status=data["status"],
            created_at=data.get("created_at"),
            completed_at=data.get("completed_at")
        )

class TaskManager:
    def __init__(self, data_file=utils.DATA_FILE):
        self.data_file = data_file
        self.tasks = self._load_all_tasks() # Load tasks on initialization

    def _load_all_tasks(self):
        # Internal method to load tasks from the data file
        # LLM might suggest making this more robust or part of utils
        raw_tasks = utils.load_tasks_from_json(self.data_file)
        return [Task.from_dict(t) for t in raw_tasks]

    def _save_all_tasks(self):
        # Internal method to save tasks
        utils.save_tasks_to_json([task.to_dict() for task in self.tasks], self.data_file)

    def add_task(self, description):
        if not description or not isinstance(description, str):
            # Basic validation, LLM could improve this
            raise ValueError("Task description must be a non-empty string")
        new_task = Task(description)
        self.tasks.append(new_task)
        self._save_all_tasks()
        return new_task

    def complete_task(self, task_id):
        # ID can be int (old simple) or str (UUID-like)
        for task in self.tasks:
            # Handle both int and str IDs for compatibility during transition if any
            if str(task.id) == str(task_id):
                if task.status == "pending":
                    task.complete()
                    self._save_all_tasks()
                    return task
                else:
                    # Task already completed, or other status
                    return task # Or raise an error/warning
        return None # Task not found

    def list_tasks(self, status_filter=None):
        """Lists tasks, optionally filtering by status ("pending", "completed")."""
        if status_filter:
            if status_filter not in ["pending", "completed"]:
                raise ValueError("status_filter must be 'pending' or 'completed'")
            return [task for task in self.tasks if task.status == status_filter]
        return self.tasks

    def get_task_by_id(self, task_id):
        for task in self.tasks:
            if str(task.id) == str(task_id):
                return task
        return None

# Example of how an LLM might suggest adding more complex logic or interactions
# For instance, dependencies between tasks, priorities, etc.
