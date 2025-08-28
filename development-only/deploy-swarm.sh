#!/bin/bash

# Simple deploy script - requires manual secret creation
# Usage: ./deploy-swarm.sh

set -e

echo "🚀 Simple Docker Swarm Deployment"
echo "======================================="
echo ""

# Initialize swarm if not already initialized
echo "Initializing Docker Swarm..."
echo "→ docker swarm init"
docker swarm init 2>/dev/null || echo "Swarm already initialized"

# Remove existing stack
echo "Removing existing stack if present..."
echo "→ docker stack rm react-app-stack"
docker stack rm react-app-stack 2>/dev/null || true
echo "→ sleep 3"
sleep 3

# Load required secrets from configuration
SECRETS_CONFIG="./secrets.json"
if [ ! -f "$SECRETS_CONFIG" ]; then
    echo "❌ secrets.json not found!"
    exit 1
fi

# Extract secrets from JSON (simple parsing)
echo "→ grep -o '\"[^\"]*\"' \"$SECRETS_CONFIG\" | grep -v '\"secrets\"' | tr -d '\"'"
REQUIRED_SECRETS=$(grep -o '"[^"]*"' "$SECRETS_CONFIG" | grep -v '"secrets"' | tr -d '"')

echo "Checking required secrets from configuration..."
MISSING_SECRETS=""

for secret in $REQUIRED_SECRETS; do
    echo "→ docker secret inspect $secret"
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
    echo "  echo 'production' | docker secret create REACT_APP_ENVIRONMENT -"
    echo ""
    exit 1
fi

# Deploy the stack
echo ""
echo "Deploying stack to Docker Swarm..."
echo "→ docker stack deploy -c docker-compose.yml react-app-stack"
docker stack deploy -c docker-compose.yml react-app-stack

echo ""
echo "✅ Deployment Complete!"
echo "======================================="
echo "Status: docker stack ps react-app-stack"
echo "Logs:   docker service logs react-app-stack_react-app -f"
echo "URL:    http://localhost:3000"
echo "======================================="