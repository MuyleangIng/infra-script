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
            - name: {{.Values.env.database.DBname}}
              valueFrom:
                secretKeyRef:
                  name: {{.Values.appName}}-sec-config
                  key: db
            - name: {{.Values.env.database.DBpassword}}
              valueFrom:
                secretKeyRef:
                  name: {{.Values.appName}}-sec-config
                  key: password
          args:
            - --default-authentication-plugin=caching_sha2_password
          ports:
            - containerPort: {{.Values.containerPort}}
{{- end }}