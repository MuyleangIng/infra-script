{{- define "ingress.tpl" }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{.Values.appName}}-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt"
    spec.ingressClassName: "nginx"
spec:
  tls:
  - hosts:
    - {{.Values.domain}}
    secretName: my-tls
  rules:
    - host: {{.Values.domain}}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{.Values.appName}}-svc
                port:
                  number: {{.Values.containerPort}}        
{{- end }}