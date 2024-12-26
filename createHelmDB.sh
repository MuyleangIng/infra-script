#!/bin/bash
imageTag=$1
DB_NAME=$2
DB_USERNAME=$3
DB_PASSWORD=$4
NodePort=$5
domainName=$6
helmChartName=$7
# extract file zip
# cd /home/sen/scripts
# tar -xvf db-deployment.tar.gz

HELM_DIR="/home/sen/helm"
BASE_DIR="$(pwd)/../"
CHART_PATH="db-deployment/"
# VALUES_FILE="${CHART_PATH}values.yaml"
APP_NAME="postgres"
TAG=14
mkdir -p "$HELM_DIR"
mkdir -p "$CHART_PATH"

cd /home/sen/scripts/db-deployment
# Define the values file path
VALUES_FILE="values.yaml"

cd /home/sen/scripts/db-deployment

VALUES_FILE="/home/sen/scripts/db-deployment/values.yaml"
# Create or update values.yaml with dynamic values
cat <<EOF > "$VALUES_FILE"
appName: "$helmChartName"
replicaset: 1
image: postgres
tag: 16.1
containerPort: 5432
nodePort: "$NodePort"
domain: "$domainName"
secret:
  tls: "$helmChartName-secret_tls"
env:
  database:
    DBname: POSTGRES_DB
    db: "$DB_NAME"
    DBuser: POSTGRES_USER
    username: "$DB_USERNAME"
    DBpassword: POSTGRES_PASSWORD
    password: "$DB_PASSWORD"
EOF
CHART_PATH="/home/sen/scripts/db-deployment/Chart.yaml"
cat <<EOF > "$CHART_PATH"
apiVersion: v2
name: "$helmChartName"
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: 1.16.1
EOF
cat "$VALUES_FILE"


NEW_CHART_PATH="${HELM_DIR}/${helmChartName}"

# If the new chart directory already exists, remove it
if [ -d "$NEW_CHART_PATH" ]; then
  rm -rf "$NEW_CHART_PATH"
fi

# Duplicate db-deployment directory to a new one based on helmChartName
#cp -r "$CHART_PATH" "$helmChartName"
cp -r /home/sen/scripts/db-deployment/ "$helmChartName"
mv "$helmChartName" "$HELM_DIR"
#remove file db-deployment
rm -rf /home/sen/scripts/db-deployment

cd "$HELM_DIR"
helm package ${helmChartName} --version ${imageTag}

# Assuming Nexus Repository URL
nexusUrl="https://nexus.automatex.dev"

# Assuming Nexus Repository Path
nexusRepositoryPath="repository/helm"

# Assuming Nexus Repository Username and Password
nexusUsername="admin"
nexusPassword="080720"

# Path to the generated Helm chart package
chartPackage="${helmChartName}-${imageTag}.tgz"

# Upload Helm Chart Package to Nexus Repository
curl -u "${nexusUsername}:${nexusPassword}" \
  -X PUT "${nexusUrl}/${nexusRepositoryPath}/${chartPackage}" \
  --upload-file "${chartPackage}"

