#!/bin/bash
imageTag=$1
DB_USERNAME=$2
DB_PASSWORD=$3
NodePort=$4
domainName=$5
helmChartName=$6
# extract file zip
# cd /home/sen/scripts
# tar -xvf db-mongo.tar.gz

HELM_DIR="/home/sen/helm"
BASE_DIR="$(pwd)/../"
CHART_PATH="db-mongo/"
# VALUES_FILE="${CHART_PATH}values.yaml"
APP_NAME="mongo"
TAG=14
mkdir -p "$HELM_DIR"
mkdir -p "$CHART_PATH"

cd /home/sen/scripts/db-mongo
# Define the values file path
VALUES_FILE="values.yaml"

cd /home/sen/scripts/db-mongo

VALUES_FILE="/home/sen/scripts/db-mongo/values.yaml"
# Create or update values.yaml with dynamic values
cat <<EOF > "$VALUES_FILE"
appName: $helmChartName
replicaset: 1
image: mongo
tag: 4.4
containerPort: 27017
nodePort: "$NodePort"
domain: "$domainName"
secret:
  tls: "$helmChartName-secret_tls"
env:
  database:
    DBuser: MONGO_INITDB_ROOT_USERNAME
    username: "$DB_USERNAME"
    DBpassword: MONGO_INITDB_ROOT_PASSWORD
    password: "$DB_PASSWORD"
EOF
CHART_PATH="/home/sen/scripts/db-mongo/Chart.yaml"
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

# Duplicate db-mongo directory to a new one based on helmChartName
#cp -r "$CHART_PATH" "$helmChartName"
cp -r /home/sen/scripts/db-mongo/ "$helmChartName"
mv "$helmChartName" "$HELM_DIR"
#remove file db-mongo
rm -rf /home/sen/scripts/db-mongo

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

