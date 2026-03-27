# Get statistics
curl http://localhost:8000/api/todos/statistics

# Health check
curl http://localhost:8000/health

# Get all todos
curl http://localhost:8000/api/todos

# Create todo
curl -X POST http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{ "title": "Test 1", "description": "Testing 1", "priority": 2, "category": 0, "tags": ["test", "monitoring"]}'

curl -X POST http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{ "title": "Test 2", "description": "Testing 2", "priority": 2, "category": 0, "tags": ["test", "monitoring"]}'

# Get all todos
curl http://localhost:8000/api/todos

# Get statistics
curl http://localhost:8000/api/todos/statistics

# Health check
curl http://localhost:8000/health

# Create todo
curl -X POST http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{ "title": "Test 3", "description": "Testing 3", "priority": 2, "category": 0, "tags": ["test", "monitoring"]}'

curl -X POST http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{ "title": "Test 4", "description": "Testing 4", "priority": 1, "category": 0, "tags": ["test", "monitoring"]}'

# Get all todos
curl http://localhost:8000/api/todos

# Get statistics
curl http://localhost:8000/api/todos/statistics

# Health check
curl http://localhost:8000/health


# Create todo
curl -X POST http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{ "title": "Test 5", "description": "Testing 5", "priority": 4, "category": 0, "tags": ["test", "monitoring"]}'

curl -X POST http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{ "title": "Test 6", "description": "Testing 6", "priority": 3, "category": 0, "tags": ["test", "monitoring"]}'

# Get all todos
curl http://localhost:8000/api/todos

# Get statistics
curl http://localhost:8000/api/todos/statistics

# Health check
curl http://localhost:8000/health

# Create a todo

curl -X PUT http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{ "title": "Test 6", "description": "Testing 6666", "priority": 3, "category": 0, "tags": ["test", "monitoring"]}'


  # Get all todos
curl http://localhost:8000/api/todos

# Get statistics
curl http://localhost:8000/api/todos/statistics

# Health check
curl http://localhost:8000/health