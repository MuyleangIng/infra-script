#!/bin/bash

imageTag=$1
imageRepository=$2
helmChartName=$3
domainName=$4
port=$5
namespace=$6 
# create helm chart directory for store helm chart
mkdir  /home/sen/helm
cd /home/sen/helm

if [ -d "${helmChartName}" ]; then
  rm -rf ${helmChartName}
fi


# create helm chart
helm create ${helmChartName}
cd ${helmChartName}

yq eval -i '.replicaCount = 1' values.yaml



#up date imaage name with tag
yq eval -i '.image = 
{
  "repository": "'${imageRepository}'",
  "pullPolicy": "IfNotPresent",
  "tag": "'${imageTag}'"
}' values.yaml
#update screct 
yq eval -i '.imagePullSecrets = 
[
  {
    "name": "registry"
  }
]' values.yaml
# update service with port
yq eval -i '.service = 
{
  "type": "ClusterIP",
  "port": "'${port}'"
}' values.yaml

# update ingress configuration for https and domain name
yq eval -i '.ingress = 
{
  "enabled": true,
  "annotations": {
    "kubernetes.io/ingressClassName": "nginx",
    "cert-manager.io/cluster-issuer": "letsencrypt",
    "nginx.ingress.kubernetes.io/rewrite-target": "/"
  },
  "hosts": [
    {
      "host": "'${domainName}'",
      "paths": [
        {
          "path": "/",
          "pathType": "Prefix"
        }
      ]
    },
    {
      "host": "www.'${domainName}'",
      "paths": [
        {
          "path": "/",
          "pathType": "Prefix"
        }
      ]
    }
  ],
  "tls": [
    {
      "hosts": [
        "'${domainName}'",
        "www.'${domainName}'"
      ],
      "secretName": "'${helmChartName}'-tls"
    }
  ]
}' values.yaml

cd - 
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