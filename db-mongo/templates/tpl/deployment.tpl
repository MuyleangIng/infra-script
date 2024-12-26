{{- define "deployment.tpl" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{.Values.appName}}-deployment
spec:
  replicas: {{.Values.replicaset}}
  selector:
    matchLabels:
      app: {{.Values.appName}}-app
  template:
    metadata:
      labels:
        app: {{.Values.appName}}-app
    spec:
      containers:
        - name: {{.Values.appName}}-container
          image: {{.Values.image}}:{{.Values.tag}}
          env:
            - name: MONGO_INITDB_ROOT_USERNAME
              valueFrom:
                secretKeyRef:
                  name: {{.Values.appName}}-sec-config
                  key: username
            - name: MONGO_INITDB_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{.Values.appName}}-sec-config
                  key: password
          ports:
            - containerPort: {{.Values.containerPort}}
{{- end }}