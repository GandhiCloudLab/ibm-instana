from typing import Dict, List, Optional
from datetime import datetime
import uuid
from models import Todo, TodoCreate, TodoUpdate, Priority, Category


class InMemoryDatabase:
    """In-memory database for storing todos"""
    
    def __init__(self):
        self.todos: Dict[str, dict] = {}
    
    def create_todo(self, todo_data: TodoCreate) -> Todo:
        """Create a new todo"""
        todo_id = str(uuid.uuid4())
        now = datetime.utcnow().isoformat() + "Z"
        
        todo_dict = {
            "id": todo_id,
            "title": todo_data.title,
            "description": todo_data.description,
            "isCompleted": todo_data.isCompleted,
            "priority": todo_data.priority,
            "category": todo_data.category,
            "dueDate": todo_data.dueDate,
            "createdAt": now,
            "completedAt": None,
            "tags": todo_data.tags
        }
        
        self.todos[todo_id] = todo_dict
        return Todo(**todo_dict)
    
    def get_todo(self, todo_id: str) -> Optional[Todo]:
        """Get a todo by ID"""
        todo_dict = self.todos.get(todo_id)
        if todo_dict:
            return Todo(**todo_dict)
        return None
    
    def get_all_todos(
        self,
        search: Optional[str] = None,
        priority: Optional[Priority] = None,
        category: Optional[Category] = None,
        completed: Optional[bool] = None
    ) -> List[Todo]:
        """Get all todos with optional filters"""
        todos = list(self.todos.values())
        
        # Apply search filter
        if search:
            search_lower = search.lower()
            todos = [
                t for t in todos
                if search_lower in t["title"].lower()
                or search_lower in t["description"].lower()
                or any(search_lower in tag.lower() for tag in t["tags"])
            ]
        
        # Apply priority filter
        if priority is not None:
            todos = [t for t in todos if t["priority"] == priority]
        
        # Apply category filter
        if category is not None:
            todos = [t for t in todos if t["category"] == category]
        
        # Apply completion status filter
        if completed is not None:
            todos = [t for t in todos if t["isCompleted"] == completed]
        
        return [Todo(**t) for t in todos]
    
    def update_todo(self, todo_id: str, todo_update: TodoUpdate) -> Optional[Todo]:
        """Update a todo"""
        if todo_id not in self.todos:
            return None
        
        todo_dict = self.todos[todo_id]
        update_data = todo_update.model_dump(exclude_unset=True)
        
        # Handle completion status change
        if "isCompleted" in update_data:
            if update_data["isCompleted"] and not todo_dict["isCompleted"]:
                # Mark as completed
                todo_dict["completedAt"] = datetime.utcnow().isoformat() + "Z"
            elif not update_data["isCompleted"] and todo_dict["isCompleted"]:
                # Mark as not completed
                todo_dict["completedAt"] = None
        
        # Update fields
        todo_dict.update(update_data)
        self.todos[todo_id] = todo_dict
        
        return Todo(**todo_dict)
    
    def delete_todo(self, todo_id: str) -> bool:
        """Delete a todo"""
        if todo_id in self.todos:
            del self.todos[todo_id]
            return True
        return False
    
    def toggle_todo(self, todo_id: str) -> Optional[Todo]:
        """Toggle todo completion status"""
        if todo_id not in self.todos:
            return None
        
        todo_dict = self.todos[todo_id]
        todo_dict["isCompleted"] = not todo_dict["isCompleted"]
        
        if todo_dict["isCompleted"]:
            todo_dict["completedAt"] = datetime.utcnow().isoformat() + "Z"
        else:
            todo_dict["completedAt"] = None
        
        self.todos[todo_id] = todo_dict
        return Todo(**todo_dict)
    
    def delete_completed_todos(self) -> int:
        """Delete all completed todos and return count"""
        completed_ids = [
            todo_id for todo_id, todo in self.todos.items()
            if todo["isCompleted"]
        ]
        
        for todo_id in completed_ids:
            del self.todos[todo_id]
        
        return len(completed_ids)
    
    def get_statistics(self) -> dict:
        """Get todo statistics"""
        all_todos = list(self.todos.values())
        total = len(all_todos)
        completed = sum(1 for t in all_todos if t["isCompleted"])
        active = total - completed
        
        # Calculate overdue and due today
        now = datetime.utcnow()
        overdue = 0
        due_today = 0
        
        for todo in all_todos:
            if todo["dueDate"] and not todo["isCompleted"]:
                try:
                    due_date = datetime.fromisoformat(todo["dueDate"].replace("Z", "+00:00"))
                    if due_date.date() < now.date():
                        overdue += 1
                    elif due_date.date() == now.date():
                        due_today += 1
                except:
                    pass
        
        # Count by priority
        by_priority = {
            "low": sum(1 for t in all_todos if t["priority"] == Priority.LOW),
            "medium": sum(1 for t in all_todos if t["priority"] == Priority.MEDIUM),
            "high": sum(1 for t in all_todos if t["priority"] == Priority.HIGH),
        }
        
        # Count by category
        by_category = {
            "personal": sum(1 for t in all_todos if t["category"] == Category.PERSONAL),
            "work": sum(1 for t in all_todos if t["category"] == Category.WORK),
            "shopping": sum(1 for t in all_todos if t["category"] == Category.SHOPPING),
            "health": sum(1 for t in all_todos if t["category"] == Category.HEALTH),
            "other": sum(1 for t in all_todos if t["category"] == Category.OTHER),
        }
        
        return {
            "total": total,
            "completed": completed,
            "active": active,
            "overdue": overdue,
            "dueToday": due_today,
            "byPriority": by_priority,
            "byCategory": by_category
        }


# Global database instance
db = InMemoryDatabase()

# Made with Bob
