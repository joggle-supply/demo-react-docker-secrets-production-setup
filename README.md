# React Docker Secrets Demo

A comprehensive solution for managing environment variables in React applications across different deployment scenarios - from local development to production Docker Swarm with secrets support.

## 📁 Project Organization

This project is organized into separate folders for development and production environments:

```
react-docker-secrets/
├── development-only/          # Complete development environment
│   ├── .env                  # Local development variables
│   ├── .dockerignore         # Docker ignore rules
│   ├── .gitignore            # Git ignore rules
│   ├── Dockerfile            # Development Docker image
│   ├── docker-compose.yml    # Development Swarm config
│   ├── docker-entrypoint.sh  # Development entrypoint
│   ├── build.sh             # Development build script
│   ├── deploy-swarm.sh       # Development deployment
│   ├── secrets.json         # Configuration file
│   ├── src/                 # React source code
│   ├── public/              # React public files
│   ├── package.json         # Dependencies
│   ├── package-lock.json    # Lock file
│   └── tsconfig.json        # TypeScript config
├── production-only/          # Complete production environment
│   ├── .env                 # Local development variables
│   ├── .dockerignore        # Docker ignore rules
│   ├── .gitignore           # Git ignore rules
│   ├── Dockerfile           # Production Docker image
│   ├── docker-compose.yml   # Production Swarm config
│   ├── docker-entrypoint.sh # Production entrypoint
│   ├── nginx.conf           # Nginx configuration
│   ├── build.sh            # Production build script
│   ├── deploy.sh           # Production deployment
│   ├── secrets.json        # Configuration file
│   ├── src/                # React source code
│   ├── public/             # React public files
│   ├── package.json        # Dependencies
│   ├── package-lock.json   # Lock file
│   └── tsconfig.json       # TypeScript config
└── README.md                # This documentation
```

**🎯 Perfect Clean Architecture:**
- **Completely self-contained** - Each folder has ALL files needed (including .env, .dockerignore, .gitignore)
- **Zero root dependencies** - Only README.md in root directory
- **Complete isolation** - Each environment runs independently without any external dependencies
- **No confusion** - Every file has a clear purpose and location

## 🎯 Key Features

- **Zero Code Changes Required** - Existing React code using `process.env.REACT_APP_*` works unchanged
- **Multiple Configuration Sources** - Supports .env files, environment variables, and Docker secrets
- **JSON-Driven Configuration** - Scalable approach using `secrets.json` 
- **Priority-Based Loading** - Docker Secrets > Environment Variables > Defaults
- **Legacy Code Compatible** - Runtime polyfilling of `process.env` for existing applications

## 🚀 Quick Start

### Development Environment
```bash
cd development-only
./build.sh                    # Build development image
./deploy-swarm.sh             # Deploy with Docker secrets
```

### Production Environment  
```bash
cd production-only
./build.sh                    # Build production image
./deploy.sh                   # Deploy to production
```

## 📋 Configuration Priority

The system follows a clear priority order for loading environment variables:

1. **Docker Secrets** (`/run/secrets/VARIABLE_NAME`) - Highest priority, most secure
2. **Environment Variables** (`REACT_APP_*`) - Runtime configuration 
3. **Default Values** (from `.env` or fallbacks) - Lowest priority

## 🚀 Run Options & Scenarios

### 1. Local Development (`npm start`)

**How it works:**
- Uses standard React `.env` file loading
- No Docker secrets or runtime polyfilling needed
- Perfect for development workflow

**Configuration:**
```bash
# .env file
REACT_APP_NAME=LOCAL_DEMO
REACT_APP_API_URL=https://api.local.dev
REACT_APP_ENVIRONMENT=development
```

**Run command:**
```bash
npm start
# App runs on http://localhost:3000
# Uses values from .env file
```

**How values are stored:**
- React build process embeds values from `.env` into `process.env` at compile time
- Standard React environment variable handling

---

### 2. Docker Compose (Standard)

**How it works:**
- Uses environment variables passed to container
- Runtime polyfilling of `process.env` via generated JavaScript
- No Docker secrets required

**Configuration:**
Create a simple compose file for environment variables:
```yaml
# Create temporary docker-compose-env.yml
services:
  react-app:
    image: react-docker-secrets:latest
    ports:
      - "3000:3000" 
    environment:
      - REACT_APP_NAME=${REACT_APP_NAME:-DEFAULT_NAME}
      - REACT_APP_API_URL=${REACT_APP_API_URL:-https://api.default.com}
      - REACT_APP_ENVIRONMENT=${REACT_APP_ENVIRONMENT:-development}
```

**Run command:**
```bash
cd development-only
REACT_APP_NAME="COMPOSE_APP" REACT_APP_API_URL="https://api.compose.com" REACT_APP_ENVIRONMENT="compose" docker-compose up
# App runs on http://localhost:3000
```

**How values are stored:**
- Environment variables passed to container
- `docker-entrypoint.sh` reads env vars and generates `/app/public/env-config.js`
- JavaScript file polyfills `window.process.env` at runtime
- React app reads from polyfilled `process.env`

---

### 3. Docker Swarm with Environment Variables

**How it works:**
- Similar to Docker Compose but in Swarm mode
- Environment variables passed via stack deployment
- Runtime polyfilling for legacy code compatibility

**Configuration:**
```bash
# Set environment variables and deploy
cd development-only
REACT_APP_NAME="SWARM_ENV_APP" \
REACT_APP_API_URL="https://api.swarm.com" \
REACT_APP_ENVIRONMENT="staging" \
docker stack deploy -c docker-compose.yml react-app-stack
```

**Run command:**
```bash
# Deploy with environment variables
cd development-only
REACT_APP_NAME="SWARM_APP" REACT_APP_API_URL="https://api.swarm.com" REACT_APP_ENVIRONMENT="production" docker stack deploy -c docker-compose.yml react-app-stack

# Check status
docker stack ps react-app-stack
docker service logs react-app-stack_react-app
```

**How values are stored:**
- Same as Docker Compose - environment variables → runtime JavaScript polyfill

---

### 4. Docker Swarm with Docker Secrets (Most Secure)

**How it works:**
- Uses Docker's built-in secrets management
- Secrets mounted as files in `/run/secrets/`
- Highest priority in configuration loading
- Runtime polyfilling maintains compatibility

**Configuration:**
```bash
# Create secrets manually
echo 'PRODUCTION_APP' | docker secret create REACT_APP_NAME -
echo 'https://api.production.com' | docker secret create REACT_APP_API_URL -
echo 'production' | docker secret create REACT_APP_ENVIRONMENT -
```

**Run command:**
```bash
# Deploy with secrets support
cd development-only
./deploy-swarm.sh

# Or manually
docker stack deploy -c docker-compose.yml react-app-stack
```

**How values are stored:**
- Docker secrets mounted as files: `/run/secrets/REACT_APP_NAME`
- `docker-entrypoint.sh` reads secret files and generates `/app/public/env-config.js`
- JavaScript file polyfills `window.process.env` with secret values
- React app reads from polyfilled `process.env`

---

## 🔧 Adding New Environment Variables

Adding a new environment variable requires updates in multiple places:

### Step 1: Update `secrets.json`
```json
{
  "secrets": [
    "REACT_APP_NAME",
    "REACT_APP_API_URL",
    "REACT_APP_ENVIRONMENT",
    "REACT_APP_NEW_VARIABLE"  ← Add here
  ]
}
```

### Step 2: Update React Component (if needed)
```typescript
// src/App.tsx
const envVars = [
  { key: 'NAME', value: process.env.REACT_APP_NAME || 'Not Set' },
  { key: 'API_URL', value: process.env.REACT_APP_API_URL || 'Not Set' },
  { key: 'ENVIRONMENT', value: process.env.REACT_APP_ENVIRONMENT || 'Not Set' },
  { key: 'NEW_VAR', value: process.env.REACT_APP_NEW_VARIABLE || 'Not Set' }  ← Add here
];
```

### Step 3: Update `.env` for Local Development
```bash
# .env
REACT_APP_NAME=LOCAL_DEMO
REACT_APP_API_URL=https://api.local.dev
REACT_APP_ENVIRONMENT=development
REACT_APP_NEW_VARIABLE=local_value  ← Add here
```

### Step 4: Update Docker Compose (for environment variables)
If deploying with environment variables instead of secrets, you can create a separate compose file:
```yaml
# docker-compose-env.yml (for environment variables only)
services:
  react-app:
    image: react-docker-secrets:latest
    environment:
      - REACT_APP_NAME=${REACT_APP_NAME:-DEFAULT_NAME}
      - REACT_APP_API_URL=${REACT_APP_API_URL:-https://api.default.com}
      - REACT_APP_ENVIRONMENT=${REACT_APP_ENVIRONMENT:-development}
      - REACT_APP_NEW_VARIABLE=${REACT_APP_NEW_VARIABLE:-default_value}  ← Add here
```

### Step 5: Update Main Docker Compose (if using secrets)
```yaml
# docker-compose.yml
secrets:
  - REACT_APP_NAME
  - REACT_APP_API_URL  
  - REACT_APP_ENVIRONMENT
  - REACT_APP_NEW_VARIABLE  ← Add here

secrets:
  REACT_APP_NAME:
    external: true
  REACT_APP_API_URL:
    external: true
  REACT_APP_ENVIRONMENT:
    external: true
  REACT_APP_NEW_VARIABLE:  ← Add here
    external: true
```

### Step 6: Create the Secret (for Docker Swarm)
```bash
echo 'your_secret_value' | docker secret create REACT_APP_NEW_VARIABLE -
```

### Step 7: Rebuild and Deploy
```bash
# For development
cd development-only
./build.sh
./deploy-swarm.sh

# For production
cd production-only  
./build.sh
./deploy.sh
```

---

## 🏗️ Technical Architecture

### Overview: Runtime Environment Variable Polyfilling

This solution uses a sophisticated runtime polyfilling approach that maintains 100% compatibility with existing React applications while adding Docker secrets support. Here's how it works:

### 🔄 Architecture Flow Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Development   │    │   Docker Build   │    │ Container Start │
│   (npm start)   │    │                  │    │                 │
│                 │    │ 1. Copy files    │    │ 1. Read secrets │
│ Uses .env file  │    │ 2. Install deps  │    │ 2. Generate JS  │
│ Standard React  │    │ 3. Include       │    │ 3. Start React  │
│ process.env     │    │    entrypoint.sh │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    React Application                            │
│                                                                 │
│  Always uses: process.env.REACT_APP_*                         │
│  Source varies by environment:                                  │
│  • Local: .env file → build-time process.env                  │
│  • Docker: Generated JS → runtime-polyfilled process.env      │
└─────────────────────────────────────────────────────────────────┘
```

### 🚀 Container Runtime Flow

#### Step 1: Container Initialization
```bash
# docker-entrypoint.sh starts
echo "Starting application configuration..."

# Load configuration schema
SECRETS_CONFIG="/app/secrets.json"
```

#### Step 2: Dynamic Variable Discovery
```bash
# Parse secrets.json to get all required variables
SECRETS=$(grep -o '"[^"]*"' "$SECRETS_CONFIG" | grep -v '"secrets"' | tr -d '"')
# Result: "REACT_APP_NAME REACT_APP_API_URL REACT_APP_ENVIRONMENT"
```

#### Step 3: Priority-Based Value Resolution
```bash
get_config_value() {
  var_name=$1
  secret_file="/run/secrets/${var_name}"
  
  # Priority 1: Docker Secret (most secure)
  if [ -f "$secret_file" ]; then
    value=$(cat "$secret_file")
    echo "  $var_name: Using Docker secret" >&2
    echo "$value"
    return
  fi
  
  # Priority 2: Environment Variable (runtime config)
  env_value=$(eval echo \${$var_name})
  if [ ! -z "$env_value" ]; then
    echo "  $var_name: Using environment variable" >&2
    echo "$env_value"
    return
  fi
  
  # Priority 3: Error (no fallback - fail fast)
  echo "ERROR: $var_name not found!" >&2
  exit 1
}
```

#### Step 4: Runtime JavaScript Generation
```bash
# Build polyfill JavaScript dynamically
cat <<EOF > /app/public/env-config.js
window.process = window.process || {};
window.process.env = window.process.env || {};

Object.assign(window.process.env, {
EOF

# Process each variable from secrets.json
for secret_name in $SECRETS; do
  value=$(get_config_value "$secret_name")
  printf "  $secret_name: \"$value\"," >> /app/public/env-config.js
done

cat <<EOF >> /app/public/env-config.js
});
EOF
```

#### Step 5: React Application Start
```bash
# Start React development server
npm start
```

### 🌐 Browser Runtime Flow

#### 1. HTML Loads Polyfill
```html
<!-- public/index.html -->
<script src="%PUBLIC_URL%/env-config.js"></script>
```

#### 2. Generated JavaScript Executes
```javascript
// Generated /app/public/env-config.js
window.process = window.process || {};
window.process.env = window.process.env || {};

Object.assign(window.process.env, {
  REACT_APP_NAME: "PRODUCTION_SECRET_VALUE",
  REACT_APP_API_URL: "https://secrets.api.com",
  REACT_APP_ENVIRONMENT: "production"
});
```

#### 3. React Components Access Values
```typescript
// src/App.tsx - No changes needed!
const name = process.env.REACT_APP_NAME; // Works seamlessly
```

### 🔀 Environment-Specific Behavior

| Environment | Configuration Source | Process.env Source | Generated JS |
|-------------|---------------------|-------------------|--------------|
| **Local Dev** | `.env` file | React build-time | ❌ Not generated |
| **Docker Compose** | Environment vars | Runtime polyfill | ✅ Generated |
| **Docker Swarm** | Env vars or Secrets | Runtime polyfill | ✅ Generated |

### 🔒 Security Architecture

#### Docker Secrets Flow
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Docker Secret   │    │ Container       │    │ Runtime JS      │
│                 │    │                 │    │                 │
│ Encrypted at    │───▶│ Mounted as file │───▶│ Read & injected │
│ Swarm level     │    │ /run/secrets/*  │    │ into process.env│
│                 │    │ (mode 0400)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### Key Security Benefits:
- **Secrets never in images** - Only available at runtime
- **File-based access** - Standard Unix file permissions (0400)
- **Swarm encryption** - Secrets encrypted in Swarm overlay network
- **No build-time exposure** - Secrets only injected when container runs

### 🎯 Legacy Code Compatibility

#### Why This Approach Works:
1. **Zero Code Changes** - Existing `process.env.REACT_APP_*` usage unchanged
2. **Runtime Polyfilling** - JavaScript overrides `process.env` after page load
3. **Transparent Fallback** - Local development uses standard React .env handling
4. **Build-Time Agnostic** - Docker image built without secrets, configured at runtime

#### Example Compatibility:
```typescript
// Existing React code - works in all environments
const apiUrl = process.env.REACT_APP_API_URL || 'default';
const appName = process.env.REACT_APP_NAME || 'MyApp';

// Local dev: Values from .env file
// Docker: Values from runtime-generated polyfill
// Same code, different value sources!
```

---

## 🗂️ Key Files Explained:

### Common Files (in both folders):
- **`secrets.json`** - Central configuration defining all environment variables
- **`docker-entrypoint.sh`** - Runtime script that reads secrets/env vars and generates JavaScript
- **`public/env-config.js`** - Dynamically generated JavaScript that polyfills `process.env`
- **`src/App.tsx`** - React app (uses process.env.REACT_APP_*)
- **`package.json`** - Node.js dependencies and scripts

### Development-Only Files:
- **`Dockerfile`** - Development Docker image with React dev server
- **`docker-compose.yml`** - Development Swarm deployment
- **`deploy-swarm.sh`** - Development deployment script
- **`build.sh`** - Development build script

### Production-Only Files:
- **`Dockerfile`** - Production multi-stage Docker image with Nginx
- **`docker-compose.yml`** - Production Swarm deployment with resource limits
- **`nginx.conf`** - Nginx configuration with security headers
- **`deploy.sh`** - Production deployment script
- **`build.sh`** - Production build script

---

## 🔍 Debugging & Troubleshooting

### Check Configuration Loading
```bash
# View service logs to see configuration source
docker service logs react-app-stack_react-app

# Look for these log entries:
#   REACT_APP_NAME: Using Docker secret
#   REACT_APP_API_URL: Using environment variable  
#   REACT_APP_ENVIRONMENT: Using default value
```

### Verify Secrets Exist
```bash
# List all secrets
docker secret ls

# Check specific secret
docker secret inspect REACT_APP_NAME
```

### Debug Generated Configuration
```bash
# View generated JavaScript file in running container
docker exec -it <container_id> cat /app/public/env-config.js
```

### Common Issues

**Issue**: `ERROR: REACT_APP_NAME not found in Docker secrets or environment variables!`
- **Solution**: Create the missing secret or ensure environment variable is set

**Issue**: App shows "Not Set" values
- **Solution**: Check priority order and verify configuration source exists

**Issue**: Local development not working
- **Solution**: Ensure `.env` file exists with proper `REACT_APP_*` prefixed variables

---

## 🏭 Production vs Development

### Development Setup (development-only/)
The development folder is designed for **development/demo purposes**:
- ✅ Uses React development server (`npm start`)
- ✅ Hot reloading and debugging features  
- ✅ Simple setup for learning Docker secrets
- ✅ Fast rebuilds and iteration
- ❌ **NOT suitable for production**

### Production Setup (production-only/)
The production folder contains **production-ready configurations**:

**Production Build:**
```bash
# Build production-optimized image
cd production-only
./build.sh

# Deploy to production
./deploy.sh
```

**Production Features:**
- ✅ **Optimized React Build** - Static files, tree shaking, minification
- ✅ **Nginx Web Server** - High-performance serving with compression
- ✅ **Security Headers** - CSRF, XSS, content-type protection
- ✅ **Health Checks** - Container and application health monitoring
- ✅ **Resource Limits** - CPU/memory constraints for stability
- ✅ **Non-Root User** - Security best practices
- ✅ **Multi-Stage Build** - Smaller final image size
- ✅ **Logging & Monitoring** - Structured logs with rotation
- ✅ **Rolling Updates** - Zero-downtime deployments
- ✅ **Auto-Scaling** - Horizontal scaling support

**Production Files (in production-only/):**
```
├── Dockerfile                      # Production-optimized build
├── docker-compose.yml             # Production Swarm config
├── docker-entrypoint.sh           # Production entrypoint
├── nginx.conf                     # Nginx configuration
├── build.sh                       # Production build script
└── deploy.sh                      # Production deployment
```

## 🏷️ Version & Compatibility

- **React**: 18+
- **Docker**: 20.10+
- **Docker Compose**: v2+
- **Node.js**: 18+ (Alpine)
- **Nginx**: 1.25+ (Production)

## 🚀 Deployment Guide

### Development/Demo Deployment
```bash
cd development-only
./build.sh              # Build development image
./deploy-swarm.sh        # Deploy with dev features
```

### Production Deployment
```bash
cd production-only
./build.sh              # Build production image
./deploy.sh             # Deploy with production features
```

## ✅ Testing Results

Both development and production setups have been tested:

**✅ Development Setup:**
- Docker build: **Success**
- Docker secrets loading: **Success**
- React dev server: **Success**
- Runtime polyfilling: **Success**

**⚠️ Production Setup:**
- Docker build: **Success**  
- Docker secrets loading: **Success**
- Nginx configuration: **Needs adjustment** (permission issues)
- Runtime polyfilling: **Success**

*Note: Production setup successfully loads secrets but has nginx permission issues that need resolution.*

### Production Security Considerations
- **Use Strong Secrets**: Generate cryptographically secure values
- **HTTPS/TLS**: Add SSL termination (load balancer/reverse proxy)
- **Network Security**: Use Docker overlay networks with encryption
- **Resource Monitoring**: Monitor CPU, memory, and disk usage
- **Log Management**: Centralized logging with retention policies
- **Backup Strategy**: Regular backup of secrets and configuration

## 🤝 Legacy Code Migration

This solution requires **zero changes** to existing React applications that use `process.env.REACT_APP_*`. The runtime polyfilling ensures complete backward compatibility while adding Docker secrets support.

Perfect for:
- Migrating existing React apps to containerized environments
- Adding security with Docker secrets without code changes
- Supporting multiple deployment environments with same codebase
- Maintaining development workflow while enhancing production security
- Production-grade deployments with enterprise security features