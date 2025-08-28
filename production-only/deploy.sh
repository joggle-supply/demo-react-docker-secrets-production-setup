#!/bin/bash

# Production deployment script for Docker Swarm
# Usage: ./deploy-production.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Production Docker Swarm Deployment"
echo -e "======================================${NC}"
echo ""

# Initialize swarm if not already initialized
echo -e "${YELLOW}Initializing Docker Swarm...${NC}"
docker swarm init 2>/dev/null || echo "Swarm already initialized"

# Load required secrets from configuration
SECRETS_CONFIG="./secrets.json"
if [ ! -f "$SECRETS_CONFIG" ]; then
    echo -e "${RED}❌ secrets.json not found!${NC}"
    exit 1
fi

# Extract secrets from JSON
REQUIRED_SECRETS=$(grep -o '"[^"]*"' "$SECRETS_CONFIG" | grep -v '"secrets"' | tr -d '"')

echo -e "${YELLOW}Checking required secrets for production...${NC}"
MISSING_SECRETS=""

for secret in $REQUIRED_SECRETS; do
    if ! docker secret inspect "$secret" >/dev/null 2>&1; then
        MISSING_SECRETS="$MISSING_SECRETS $secret"
    else
        echo -e "${GREEN}✓${NC} Secret exists: $secret"
    fi
done

if [ ! -z "$MISSING_SECRETS" ]; then
    echo ""
    echo -e "${RED}❌ Missing production secrets:$MISSING_SECRETS${NC}"
    echo ""
    echo -e "${YELLOW}Create them with:${NC}"
    for secret in $MISSING_SECRETS; do
        echo "  echo 'your_production_value' | docker secret create $secret -"
    done
    echo ""
    echo -e "${RED}⚠️  SECURITY WARNING: Use strong, production-ready values!${NC}"
    exit 1
fi

# Remove existing stack
echo -e "${YELLOW}Removing existing stack if present...${NC}"
docker stack rm react-app-production 2>/dev/null || true
sleep 5

# Deploy production stack
echo -e "${GREEN}Deploying production stack to Docker Swarm...${NC}"
docker stack deploy -c docker-compose.yml react-app-production

echo ""
echo -e "${GREEN}========================================="
echo -e "✅ Production Deployment Complete!"
echo -e "=========================================${NC}"
echo ""
echo -e "${BLUE}Production URLs:${NC}"
echo "  Application: http://localhost"
echo "  Health Check: http://localhost/health"
echo ""
echo -e "${BLUE}Management Commands:${NC}"
echo "  docker stack ps react-app-production"
echo "  docker service logs react-app-production_react-app -f"
echo "  docker secret ls"
echo ""
echo -e "${BLUE}Monitoring:${NC}"
echo "  docker service ls"
echo "  docker node ls"
echo "  docker stack services react-app-production"
echo ""
echo -e "${GREEN}🔒 Production Security Features Enabled:${NC}"
echo "  ✅ Docker secrets for sensitive data"
echo "  ✅ Non-root container user"
echo "  ✅ Security headers (X-Frame-Options, CSP, etc.)"
echo "  ✅ Resource limits and health checks"
echo "  ✅ Automatic failover and rolling updates"
echo -e "${GREEN}=========================================${NC}"