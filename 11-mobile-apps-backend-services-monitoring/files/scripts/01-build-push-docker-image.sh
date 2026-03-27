#!/usr/bin/env bash

echo "build Started ...."

cd ../backend

docker build --platform linux/amd64 -f Dockerfile -t gandigit/todo-app:latest .
docker push gandigit/todo-app:latest

echo "build completed ...."