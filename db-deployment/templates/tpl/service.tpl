{{- define "service.tpl" }}
apiVersion: v1
kind: Service
metadata:
    name: {{.Values.appName}}-svc
spec:
    type: NodePort
    selector:
        app: {{.Values.appName}}-app
    ports:
        - protocol: TCP
          port: {{.Values.containerPort}}
          targetPort: {{.Values.containerPort}}
          nodePort: {{.Values.nodePort}}
{{- end}}
