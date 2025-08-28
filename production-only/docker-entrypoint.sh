#!/bin/bash

echo "========================================="
echo "Starting production application..."
echo "========================================="

# Load secrets configuration
SECRETS_CONFIG="/app/secrets.json"
if [ ! -f "$SECRETS_CONFIG" ]; then
  echo "ERROR: secrets.json not found!" >&2
  exit 1
fi

# Function to get value with error handling
get_config_value() {
  var_name=$1
  secret_file="/run/secrets/${var_name}"
  
  # Check Docker secret first
  if [ -f "$secret_file" ]; then
    value=$(cat "$secret_file")
    echo "  $var_name: Using Docker secret" >&2
    echo "$value"
    return
  fi
  
  # Check environment variable
  env_value=$(eval echo \${$var_name})
  if [ ! -z "$env_value" ]; then
    echo "  $var_name: Using environment variable" >&2
    echo "$env_value"
    return
  fi
  
  # Error - no configuration found
  echo "ERROR: $var_name not found in Docker secrets or environment variables!" >&2
  echo "Create secret: docker secret create $var_name <value>" >&2
  exit 1
}

# Extract secrets from JSON config
echo "Loading secrets from configuration..."
SECRETS=$(grep -o '"[^"]*"' "$SECRETS_CONFIG" | grep -v '"secrets"' | tr -d '"')

# Build the JavaScript configuration that polyfills process.env
echo "Building runtime configuration..."
cat <<EOF > /usr/share/nginx/html/env-config.js
// Runtime configuration - polyfills process.env for legacy code compatibility
window.process = window.process || {};
window.process.env = window.process.env || {};

// Override process.env with runtime values from Docker secrets
Object.assign(window.process.env, {
EOF

# Process each secret dynamically
first=true
for secret_name in $SECRETS; do
  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> /usr/share/nginx/html/env-config.js
  fi
  
  value=$(get_config_value "$secret_name")
  printf "  $secret_name: \"$value\"" >> /usr/share/nginx/html/env-config.js
done

# Close the JavaScript object
cat <<EOF >> /usr/share/nginx/html/env-config.js

});

console.log("Runtime configuration loaded from Docker secrets");
EOF

echo "Configuration complete!"
echo "========================================="

# Start nginx in foreground
exec nginx -g 'daemon off;'