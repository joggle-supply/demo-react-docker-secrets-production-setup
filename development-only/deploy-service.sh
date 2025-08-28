#!/bin/bash

# Docker Service Create deployment - Alternative to stack deployment
# Usage: ./deploy-service.sh

set -e

echo "🚀 Docker Service Create Deployment"
echo "===================================="
echo ""

# Initialize swarm if not already initialized
echo "Initializing Docker Swarm..."
docker swarm init 2>/dev/null || echo "Swarm already initialized"

# Load required secrets from configuration
SECRETS_CONFIG="./secrets.json"
if [ ! -f "$SECRETS_CONFIG" ]; then
    echo "❌ secrets.json not found!"
    exit 1
fi

# Extract secrets from JSON (simple parsing)
REQUIRED_SECRETS=$(grep -o '"[^"]*"' "$SECRETS_CONFIG" | grep -v '"secrets"' | tr -d '"')

echo "Checking required secrets from configuration..."
MISSING_SECRETS=""

for secret in $REQUIRED_SECRETS; do
    if ! docker secret inspect "$secret" >/dev/null 2>&1; then
        MISSING_SECRETS="$MISSING_SECRETS $secret"
    else
        echo "✓ Secret exists: $secret"
    fi
done

if [ ! -z "$MISSING_SECRETS" ]; then
    echo ""
    echo "❌ Missing secrets:$MISSING_SECRETS"
    echo ""
    echo "Create them manually with:"
    for secret in $MISSING_SECRETS; do
        echo "  echo 'your_value' | docker secret create $secret -"
    done
    echo ""
    echo "Example:"
    echo "  echo 'MY_APP_NAME' | docker secret create REACT_APP_NAME -"
    echo "  echo 'https://api.example.com' | docker secret create REACT_APP_API_URL -"
    echo "  echo 'development' | docker secret create REACT_APP_ENVIRONMENT -"
    echo ""
    exit 1
fi

# Remove existing service if present
echo ""
echo "Removing existing service if present..."
docker service rm react-app-dev 2>/dev/null || true
sleep 3

# Build secret arguments dynamically
SECRET_ARGS=""
for secret in $REQUIRED_SECRETS; do
    SECRET_ARGS="$SECRET_ARGS --secret $secret"
done

echo "Creating service with docker service create..."

# Create the service using docker service create
docker service create \
    --name react-app-dev \
    --replicas 2 \
    --publish published=3000,target=3000 \
    $SECRET_ARGS \
    --update-parallelism 1 \
    --update-delay 10s \
    --restart-condition on-failure \
    --restart-delay 5s \
    --restart-max-attempts 3 \
    --restart-window 120s \
    react-docker-secrets:latest

echo ""
echo "✅ Service Deployment Complete!"
echo "================================"
echo "Status: docker service ps react-app-dev"
echo "Logs:   docker service logs react-app-dev -f"
echo "Scale:  docker service scale react-app-dev=3"
echo "Update: docker service update react-app-dev"
echo "Remove: docker service rm react-app-dev"
echo "URL:    http://localhost:3000"
echo "================================"