
#!/usr/bin/env bash
echo "run Started ...."

docker run -d -p 8000:8000 --name my-todo-app --env INSTANA_AGENT_PORT="443"  gandigit/todo-app:latest

echo "run completed ...."
