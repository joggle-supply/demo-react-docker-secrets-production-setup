#!/bin/bash

echo "Building production React Docker image..."
echo "========================================"

# Build production image
docker build -t react-docker-secrets:production -f Dockerfile .

echo ""
echo "Production build complete!"
echo "=========================="
echo "Image: react-docker-secrets:production"
echo "Features:"
echo "  ✅ Production optimized React build"
echo "  ✅ Nginx web server"
echo "  ✅ Security headers"
echo "  ✅ Gzip compression"
echo "  ✅ Health checks"
echo "  ✅ Non-root user"
echo "  ✅ Resource limits"
echo "  ✅ Multi-stage build (small image)"
echo ""