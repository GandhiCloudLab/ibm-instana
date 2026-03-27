from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from models import Todo, TodoCreate, TodoUpdate, TodoStatistics, MessageResponse, Priority, Category
from database import db

# Import Instana for custom instrumentation
try:
    from instana.singletons import tracer
    INSTANA_AVAILABLE = True
except (ImportError, AttributeError):
    INSTANA_AVAILABLE = False

router = APIRouter(prefix="/api/todos", tags=["todos"])


@router.get("", response_model=List[Todo])
async def get_todos(
    search: Optional[str] = Query(None, description="Search in title, description, and tags"),
    priority: Optional[Priority] = Query(None, description="Filter by priority"),
    category: Optional[Category] = Query(None, description="Filter by category"),
    completed: Optional[bool] = Query(None, description="Filter by completion status")
):
    """Get all todos with optional filters"""
    # Instana auto-instruments FastAPI, we just add custom attributes
    if INSTANA_AVAILABLE:
        span = tracer.start_span('get_todos_operation')
        span.set_attribute('filter.search', search is not None)
        span.set_attribute('filter.priority', str(priority) if priority else 'none')
        span.set_attribute('filter.category', str(category) if category else 'none')
        span.set_attribute('filter.completed', str(completed) if completed is not None else 'none')
        
    todos = db.get_all_todos(search=search, priority=priority, category=category, completed=completed)
    
    if INSTANA_AVAILABLE:
        span.set_attribute('result.count', len(todos))
        span.end()
    
    return todos


@router.get("/statistics", response_model=TodoStatistics)
async def get_statistics():
    """Get todo statistics"""
    if INSTANA_AVAILABLE:
        span = tracer.start_span('get_statistics_operation')
        
    stats = db.get_statistics()
    
    if INSTANA_AVAILABLE:
        span.set_attribute('stats.total', stats.get('total', 0))
        span.set_attribute('stats.completed', stats.get('completed', 0))
        span.set_attribute('stats.pending', stats.get('pending', 0))
        span.end()
    
    return TodoStatistics(**stats)


@router.get("/{todo_id}", response_model=Todo)
async def get_todo(todo_id: str):
    """Get a specific todo by ID"""
    if INSTANA_AVAILABLE:
        span = tracer.start_span('get_todo_operation')
        span.set_attribute('todo.id', todo_id)
    
    todo = db.get_todo(todo_id)
    if not todo:
        if INSTANA_AVAILABLE:
            span.set_attribute('error', True)
            span.set_attribute('error.message', 'Todo not found')
            span.end()
        raise HTTPException(status_code=404, detail="Todo not found")
    
    if INSTANA_AVAILABLE:
        span.set_attribute('todo.priority', str(todo.priority))
        span.set_attribute('todo.category', str(todo.category))
        span.set_attribute('todo.completed', todo.completed)
        span.end()
    
    return todo


@router.post("", response_model=Todo, status_code=201)
async def create_todo(todo: TodoCreate):
    """Create a new todo"""
    if INSTANA_AVAILABLE:
        span = tracer.start_span('create_todo_operation')
        span.set_attribute('todo.priority', todo.priority.name if hasattr(todo.priority, 'name') else str(todo.priority))
        span.set_attribute('todo.category', todo.category.name if hasattr(todo.category, 'name') else str(todo.category))
        span.set_attribute('todo.has_due_date', todo.dueDate is not None)
        span.set_attribute('todo.tags_count', len(todo.tags))
    
    created_todo = db.create_todo(todo)
    
    if INSTANA_AVAILABLE:
        span.set_attribute('todo.id', created_todo.id)
        span.end()
    
    return created_todo


@router.put("/{todo_id}", response_model=Todo)
async def update_todo(todo_id: str, todo_update: TodoUpdate):
    """Update an existing todo"""
    if INSTANA_AVAILABLE:
        span = tracer.start_span('update_todo_operation')
        span.set_attribute('todo.id', todo_id)
        
        # Track what fields are being updated
        update_fields = []
        if todo_update.title is not None:
            update_fields.append('title')
        if todo_update.description is not None:
            update_fields.append('description')
        if todo_update.priority is not None:
            update_fields.append('priority')
            span.set_attribute('todo.new_priority', str(todo_update.priority))
        if todo_update.category is not None:
            update_fields.append('category')
            span.set_attribute('todo.new_category', str(todo_update.category))
        if todo_update.completed is not None:
            update_fields.append('completed')
        
        span.set_attribute('update.fields', ','.join(update_fields))
    
    updated_todo = db.update_todo(todo_id, todo_update)
    if not updated_todo:
        if INSTANA_AVAILABLE:
            span.set_attribute('error', True)
            span.set_attribute('error.message', 'Todo not found')
            span.end()
        raise HTTPException(status_code=404, detail="Todo not found")
    
    if INSTANA_AVAILABLE:
        span.end()
    
    return updated_todo


@router.patch("/{todo_id}/toggle", response_model=Todo)
async def toggle_todo(todo_id: str):
    """Toggle todo completion status"""
    if INSTANA_AVAILABLE:
        span = tracer.start_span('toggle_todo_operation')
        span.set_attribute('todo.id', todo_id)
    
    toggled_todo = db.toggle_todo(todo_id)
    if not toggled_todo:
        if INSTANA_AVAILABLE:
            span.set_attribute('error', True)
            span.set_attribute('error.message', 'Todo not found')
            span.end()
        raise HTTPException(status_code=404, detail="Todo not found")
    
    if INSTANA_AVAILABLE:
        span.set_attribute('todo.new_status', 'completed' if toggled_todo.completed else 'pending')
        span.end()
    
    return toggled_todo


@router.delete("/{todo_id}", response_model=MessageResponse)
async def delete_todo(todo_id: str):
    """Delete a todo"""
    if INSTANA_AVAILABLE:
        span = tracer.start_span('delete_todo_operation')
        span.set_attribute('todo.id', todo_id)
    
    success = db.delete_todo(todo_id)
    if not success:
        if INSTANA_AVAILABLE:
            span.set_attribute('error', True)
            span.set_attribute('error.message', 'Todo not found')
            span.end()
        raise HTTPException(status_code=404, detail="Todo not found")
    
    if INSTANA_AVAILABLE:
        span.end()
    
    return MessageResponse(message="Todo deleted successfully")


@router.delete("", response_model=MessageResponse)
async def delete_completed_todos():
    """Delete all completed todos"""
    if INSTANA_AVAILABLE:
        span = tracer.start_span('delete_completed_todos_operation')
    
    count = db.delete_completed_todos()
    
    if INSTANA_AVAILABLE:
        span.set_attribute('deleted.count', count)
        span.end()
    
    return MessageResponse(message=f"Deleted {count} completed todo(s)")

# Made with Bob
