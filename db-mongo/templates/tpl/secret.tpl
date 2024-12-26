{{- define "secret.tpl" }}
apiVersion: v1
kind: Secret
metadata:
  name: {{.Values.appName}}-sec-config
type: Opaque
data:
  username: {{.Values.env.database.username | b64enc }}
  password: {{.Values.env.database.password | b64enc }}
{{- end }}