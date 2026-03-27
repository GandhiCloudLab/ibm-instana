from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import IntEnum


class Priority(IntEnum):
    """Priority levels matching Flutter enum"""
    LOW = 0
    MEDIUM = 1
    HIGH = 2


class Category(IntEnum):
    """Categories matching Flutter enum"""
    PERSONAL = 0
    WORK = 1
    SHOPPING = 2
    HEALTH = 3
    OTHER = 4


class TodoBase(BaseModel):
    """Base Todo model for creation and updates"""
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(default="", max_length=1000)
    isCompleted: bool = False
    priority: Priority = Priority.MEDIUM
    category: Category = Category.PERSONAL
    dueDate: Optional[str] = None  # ISO 8601 string
    tags: List[str] = Field(default_factory=list)


class TodoCreate(TodoBase):
    """Model for creating a new todo"""
    pass


class TodoUpdate(BaseModel):
    """Model for updating a todo (all fields optional)"""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    isCompleted: Optional[bool] = None
    priority: Optional[Priority] = None
    category: Optional[Category] = None
    dueDate: Optional[str] = None
    tags: Optional[List[str]] = None


class Todo(TodoBase):
    """Complete Todo model with all fields"""
    id: str
    createdAt: str  # ISO 8601 string
    completedAt: Optional[str] = None  # ISO 8601 string

    class Config:
        json_schema_extra = {
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "title": "Buy groceries",
                "description": "Milk, eggs, bread",
                "isCompleted": False,
                "priority": 1,
                "category": 2,
                "dueDate": "2026-03-26T10:00:00.000Z",
                "createdAt": "2026-03-25T11:00:00.000Z",
                "completedAt": None,
                "tags": ["shopping", "urgent"]
            }
        }


class TodoStatistics(BaseModel):
    """Statistics about todos"""
    total: int
    completed: int
    active: int
    overdue: int
    dueToday: int
    byPriority: dict
    byCategory: dict


class MessageResponse(BaseModel):
    """Generic message response"""
    message: str

# Made with Bob
