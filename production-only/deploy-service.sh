#!/bin/bash

# Production Docker Service Create deployment
# Usage: ./deploy-service.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Production Docker Service Create Deployment"
echo -e "===============================================${NC}"
echo ""

# Initialize swarm if not already initialized
echo -e "${YELLOW}Initializing Docker Swarm...${NC}"
echo "→ docker swarm init"
docker swarm init 2>/dev/null || echo "Swarm already initialized"

# Load required secrets from configuration
SECRETS_CONFIG="./secrets.json"
if [ ! -f "$SECRETS_CONFIG" ]; then
    echo -e "${RED}❌ secrets.json not found!${NC}"
    exit 1
fi

# Extract secrets from JSON
echo "→ grep -o '\"[^\"]*\"' \"$SECRETS_CONFIG\" | grep -v '\"secrets\"' | tr -d '\"'"
REQUIRED_SECRETS=$(grep -o '"[^"]*"' "$SECRETS_CONFIG" | grep -v '"secrets"' | tr -d '"')

echo -e "${YELLOW}Checking required secrets for production...${NC}"
MISSING_SECRETS=""

for secret in $REQUIRED_SECRETS; do
    echo "→ docker secret inspect $secret"
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

# Remove existing service if present
echo -e "${YELLOW}Removing existing service if present...${NC}"
echo "→ docker service rm react-app-production"
docker service rm react-app-production 2>/dev/null || true
echo "→ sleep 5"
sleep 5

# Build secret arguments dynamically
SECRET_ARGS=""
for secret in $REQUIRED_SECRETS; do
    SECRET_ARGS="$SECRET_ARGS --secret $secret"
done

echo -e "${GREEN}Creating production service with docker service create...${NC}"
echo "→ docker service create \\"
echo "    --name react-app-production \\"
echo "    --replicas 3 \\"
echo "    --publish published=80,target=80 \\"
echo "    $SECRET_ARGS \\"
echo "    --update-parallelism 1 \\"
echo "    --update-delay 10s \\"
echo "    --update-failure-action rollback \\"
echo "    --restart-condition on-failure \\"
echo "    --restart-delay 5s \\"
echo "    --restart-max-attempts 3 \\"
echo "    --restart-window 120s \\"
echo "    --limit-cpu 0.5 \\"
echo "    --limit-memory 512M \\"
echo "    --reserve-cpu 0.25 \\"
echo "    --reserve-memory 256M \\"
echo "    --health-cmd \"curl -f http://localhost/health || exit 1\" \\"
echo "    --health-interval 30s \\"
echo "    --health-timeout 10s \\"
echo "    --health-retries 3 \\"
echo "    --health-start-period 40s \\"
echo "    --log-driver json-file \\"
echo "    --log-opt max-size=10m \\"
echo "    --log-opt max-file=3 \\"
echo "    react-docker-secrets:production"

# Create the production service using docker service create
docker service create \
    --name react-app-production \
    --replicas 3 \
    --publish published=80,target=80 \
    $SECRET_ARGS \
    --update-parallelism 1 \
    --update-delay 10s \
    --update-failure-action rollback \
    --restart-condition on-failure \
    --restart-delay 5s \
    --restart-max-attempts 3 \
    --restart-window 120s \
    --limit-cpu 0.5 \
    --limit-memory 512M \
    --reserve-cpu 0.25 \
    --reserve-memory 256M \
    --health-cmd "curl -f http://localhost/health || exit 1" \
    --health-interval 30s \
    --health-timeout 10s \
    --health-retries 3 \
    --health-start-period 40s \
    --log-driver json-file \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    react-docker-secrets:production

echo ""
echo -e "${GREEN}========================================="
echo -e "✅ Production Service Deployment Complete!"
echo -e "=========================================${NC}"
echo ""
echo -e "${BLUE}Production URLs:${NC}"
echo "  Application: http://localhost"
echo "  Health Check: http://localhost/health"
echo ""
echo -e "${BLUE}Management Commands:${NC}"
echo "  docker service ps react-app-production"
echo "  docker service logs react-app-production -f"
echo "  docker service scale react-app-production=5"
echo "  docker service update react-app-production"
echo "  docker service rm react-app-production"
echo "  docker secret ls"
echo ""
echo -e "${BLUE}Monitoring:${NC}"
echo "  docker service ls"
echo "  docker node ls"
echo "  docker service inspect react-app-production"
echo ""
echo -e "${GREEN}🔒 Production Security Features Enabled:${NC}"
echo "  ✅ Docker secrets for sensitive data"
echo "  ✅ Resource limits (CPU: 0.5, Memory: 512M)"
echo "  ✅ Health checks with curl"
echo "  ✅ Automatic failover and rolling updates"
echo "  ✅ Rollback on update failure"
echo "  ✅ Log rotation (10MB, 3 files)"
echo -e "${GREEN}=========================================${NC}"