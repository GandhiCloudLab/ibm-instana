# Build step #2: build the API with the client as static files
FROM python:3.11-slim

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

RUN pip install -r requirements.txt

COPY ./ /app

ENV INSTANA_SERVICE_NAME todo-api-backend
ENV INSTANA_AGENT_HOST localhost
ENV INSTANA_AGENT_PORT 42699
ENV INSTANA_ENABLED  true

EXPOSE 8000

CMD ["python", "-u", "main.py"]
