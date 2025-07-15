# Production Deployment Guide

This document explains how to build and run all FountainAI services using Docker Compose.

Each generated server already contains a `Dockerfile`. The root `docker-compose.yml` composes these images so they can be started together.

## Building the Containers

Run the following command at the repository root:

```bash
docker compose build
```

This compiles each service into a minimal Swift container.

Before running the containers configure the environment variables described in [environment_variables.md](../../../../../docs/environment_variables.md). At minimum set `TYPESENSE_URL`, `TYPESENSE_API_KEY` and `OPENAI_API_KEY` so the services can reach external dependencies.

## Starting the Services

To start all containers:

```bash
docker compose up
```

The services start minimal Swift HTTP servers that handle simple JSON requests. Persistence uses an in-memory `TypesenseClient`.
Set environment variables like `TYPESENSE_URL`, `TYPESENSE_API_KEY`, `OPENAI_API_KEY` and optionally `OPENAI_API_BASE` before starting containers so services can connect to external dependencies.
Refer to [environment_variables.md](../../../../../docs/environment_variables.md) for details on these variables.

### Running a Single Service

To build and run only the Baseline Awareness service:

```bash
docker build -f Generated/Server/baseline-awareness/Dockerfile -t baseline-awareness .
docker run -p 8080:8080 baseline-awareness
```

After the container starts, verify the health endpoint:

```bash
curl http://localhost:8080/health
```

## Stopping and Removing Containers

Press `Ctrl+C` to stop the running services, then remove containers with:

```bash
docker compose down
```

This workflow lets you run the microservices locally. Future updates will add full networking and durable persistence.
All containers emit JSON logs which can be aggregated by your logging stack.
