# Multi-stage production Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci --silent

# Copy source code
COPY . .

# Build the React app for production
RUN npm run build

# Production stage
FROM nginx:1.25-alpine AS production

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S reactuser -u 1001

# Install runtime dependencies
RUN apk add --no-cache bash curl && \
    rm -rf /var/cache/apk/*

# Copy built React app
COPY --from=builder /app/build /usr/share/nginx/html

# Copy configuration files
COPY --from=builder /app/secrets.json /app/secrets.json
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf

# Set proper permissions and create nginx directories
RUN chmod +x /docker-entrypoint.sh && \
    chown -R reactuser:nodejs /app && \
    chown -R reactuser:nodejs /usr/share/nginx/html && \
    chown -R reactuser:nodejs /var/cache/nginx && \
    chown -R reactuser:nodejs /var/log/nginx && \
    chown -R reactuser:nodejs /etc/nginx && \
    touch /var/run/nginx.pid && \
    chown reactuser:nodejs /var/run/nginx.pid && \
    mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    chown -R reactuser:nodejs /var/cache/nginx

# Switch to non-root user
USER reactuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Expose port
EXPOSE 80

# Start with entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]