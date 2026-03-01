#!/bin/sh
set -eo pipefail

INGRESS_NAME="tudoonline-app-customer-ingress"
NAMESPACE="production"
SERVICE_NAME="tudoonline-app"
SERVICE_PORT="80"
CLUSTER_ISSUER="letsencrypt-prod"

# Lê os hosts do arquivo gerado pelo curl na etapa anterior
HOSTS=$(jq -r '.hosts[]' hosts-raw.json)

if [ -z "$HOSTS" ]; then
  echo "ERROR: No hosts found in API response!" >&2
  exit 1
fi

echo "### Hosts encontrados: ###" >&2
echo "$HOSTS" >&2

# Início do manifesto
cat <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${INGRESS_NAME}
  namespace: ${NAMESPACE}
  annotations:
    cert-manager.io/cluster-issuer: "${CLUSTER_ISSUER}"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    nginx.ingress.kubernetes.io/client-body-buffer-size: "100m"
    nginx.ingress.kubernetes.io/enable-access-log: "true"
spec:
  ingressClassName: nginx
  rules:
EOF

# Gera uma rule por host
for HOST in $HOSTS; do
cat <<EOF
  - host: ${HOST}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ${SERVICE_NAME}
            port:
              number: ${SERVICE_PORT}
EOF
done

# Seção TLS — um entry por host com secretName único
echo "  tls:"
for HOST in $HOSTS; do
  # Converte pontos em hifens para o secretName (ex: app.pluglar.com.br → app-pluglar-com-br)
  SECRET_NAME="tls-$(echo $HOST | tr '.' '-')"
  cat <<EOF
  - hosts:
    - ${HOST}
    secretName: ${SECRET_NAME}
EOF
done
