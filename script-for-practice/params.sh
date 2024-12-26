# Set dynamic values using environment variables
export APP_NAME="reactjs"
export IMAGE="muyleangin/reactjs"
export TAG="1.3"
export CONTAINER_PORT="80"
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