#!/bin/bash
echo "Starting Helm script"

# Prompt for user input for namespace
read -p "Enter namespace: " NAMESPACE

# Validate if the namespace is not empty
if [ -z "$NAMESPACE" ]; then
  echo "Namespace cannot be empty. Exiting."
  exit 1
fi

# Set dynamic values using environment variables
export APP_NAME="nextjsv1"
export IMAGE="muyleangin/nextjsv1"
export TAG="1.2"
export CONTAINER_PORT="3000"
export DOMAIN="app.sen-pai.live"

# Define other variables
BASE_DIR="$(pwd)/../"  # Go up one level to the parent directory
CHART_PATH="${BASE_DIR}deployment/frontend_app/"
VALUES_FILE="${CHART_PATH}values.yaml"
NEXUS_REPO_URL="https://nx.sen-pai.live/repository/helm/"
NEXUS_USERNAME="admin"
NEXUS_PASSWORD="080720"
CHART_NAME="dev-release"

# Create or update values.yaml with dynamic values
cat <<EOF > "$VALUES_FILE"
appName: $APP_NAME
image: $IMAGE
tag: $TAG
containerPort: $CONTAINER_PORT
domain: $DOMAIN
EOF

cat "$VALUES_FILE"
# Step 1: Install Helm chart
helm install $NAMESPACE $CHART_PATH

# # Step 2: Package Helm chart
# helm package $CHART_PATH

# # Step 3: Upload Helm chart to Nexus Repository Manager
# CHART_FILENAME=$(ls *.tgz | head -n 1)
# curl -u $NEXUS_USERNAME:$NEXUS_PASSWORD --upload-file $CHART_FILENAME $NEXUS_REPO_URL/$CHART_NAME/$CHART_FILENAME

# # Step 4: Clean up temporary chart package
# rm $CHART_FILENAME

echo "Helm script completed successfully."
