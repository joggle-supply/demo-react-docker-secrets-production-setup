#!/bin/bash

echo "Building React Docker image (without environment variables)..."
docker build -t react-docker-secrets:latest .

echo "Build complete!"
echo "Environment variables will be injected at runtime."