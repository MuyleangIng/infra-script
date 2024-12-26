#!/bin/bash
helmChartName=$2
imageTag=$1
username=$3
# directory=../../../helm/
cd /home/sen/helm
#directory="$(dirname "$0")/../helm"  # Use the script's directory to construct the path

#cd "$directory" || exit

directory=~/helm

# Ensure the source helm chart file exists
# if [ ! -f "${directory}/${helmChartName}-${imageTag}.tgz" ]; then
#     echo "Helm chart file '${helmChartName}-${imageTag}.tgz' not found in the specified directory."
#     exit 1
# fi

# Nexus Repository URL and Path
nexusUrl="https://nexus.automatex.dev"
nexusRepositoryPath="repository/helm"


# Fetch Helm chart from Nexus
curl -u "admin:080720" "${nexusUrl}/${nexusRepositoryPath}/${helmChartName}-${imageTag}.tgz" -o "${helmChartName}-${imageTag}.tgz"

# Create the Argo CD directory if it doesn't exist
mkdir "${helmChartName}-argocd"

# Unzip the Helm chart in the Argo CD directory
tar -xvf "${helmChartName}-${imageTag}.tgz" -C "${directory}/${helmChartName}-argocd" --strip-components=1

rm -rf "${helmChartName}-${imageTag}.tgz"
# Change to the Argo CD directory
cd "${helmChartName}-argocd" || exit 1

gitusername="root"
gitUrl="git.automatex.dev/automatex"
# Update the Helm chart values
if [ -d ".git" ]; then
    echo "Git repo exists"
    git add .
    git commit -m "Update helm chart"
    git push https://${gitusername}:${gitpassword}@${gitUrl}/${helmChartName}.git

    exit 0
fi
git init 
git add . 
git branch -M main
git commit -m "update helm chart"
git remote add origin "https://${gitUrl}/${helmChartName}.git"
git push https://${gitusername}:${gitpassword}@${gitUrl}/${helmChartName}.git
cd -
cd -

# Create the Argo CD Application YAML
APP_NAME="${helmChartName}-argocd"
DEST_NAME="https://kubernetes.default.svc"
DEST_NAMESPACE="default"
ARGOCD_SERVER="https://argocd.automatex.dev/"
GIT_REPO_PATH="."

GIT_REPO_URL="https://${gitusername}:${gitpassword}@${gitUrl}/${helmChartName}.git"


GIT_TARGET_REVISION="main"

if kubectl get application "$APP_NAME"  > /dev/null 2>&1; then
  echo "Application $APP_NAME already exists!! Sipping Creation" 
  exit 1
fi

# Create the Argo CD Application YAML
YAML_CONTENT=$(cat <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${helmChartName}-argocd
  namespace: argocd
spec:
  destination:
    name: ''
    namespace: ${username}
    server: 'https://kubernetes.default.svc'
  source:
    path: .
    repoURL: ${GIT_REPO_URL}
    targetRevision: ${GIT_TARGET_REVISION}
    helm:
      valueFiles:
        - values.yaml
  sources: []
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - Validate=false

EOF
)

# Create a temporary file to store the Argo CD Application YAML
TMP_FILE=$(mktemp)
echo "$YAML_CONTENT" > "$TMP_FILE"

# Apply the Argo CD Application YAML
kubectl apply -f "$TMP_FILE"

# Clean up the temporary file
rm "$TMP_FILE"
