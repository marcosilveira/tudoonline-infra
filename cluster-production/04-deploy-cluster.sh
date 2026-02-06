#!/bin/bash
set -e

# ==============================================================================
# SCRIPT DE DEPLOY - NODE 1 (MASTER)
# Execute este script dentro da VPS 1 após configurar os 3 nodes
# ==============================================================================

if [ -z "$1" ]; then
    echo "❌ Erro: Informe o IP Interno da VPS 2 (NFS Server)."
    echo "Uso: ./04-deploy-cluster.sh <NFS_SERVER_IP>"
    exit 1
fi

NFS_IP=$1
NAMESPACE="production"

echo "🚀 Iniciando Deploy do Cluster de Produção..."

# 0. Instalar Helm (se não tiver)
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# 1. Configurar Namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 2. Configurar Storage Compartilhado (NFS)
echo "💾 Configurando PV/PVC NFS (Apontando para $NFS_IP)..."
sed "s/NFS_SERVER_IP_PLACEHOLDER/$NFS_IP/g" storage-nfs.yaml | kubectl apply -f -

# 3. Portainer (Painel de Gestão)
echo "🚢 Instalando Portainer..."
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
helm upgrade --install portainer portainer/portainer \
    -n portainer --create-namespace \
    --set service.type=ClusterIP \
    --set ingress.enabled=true \
    --set ingress.hosts[0]=painel.tudoonline.com.br \
    --set nodeSelector."svc\.tudoonline\.io/role"=app # Roda na VPS de Apps

# 4. Infraestrutura (MySQL, Redis, RabbitMQ)
echo "🗄️ Instalando Banco de Dados (Node 1)..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install mysql bitnami/mysql \
    -n $NAMESPACE \
    --set primary.nodeSelector."svc\.tudoonline\.io/role"=db \
    --set auth.rootPassword=STHVJWHrvGc91MiY1ya9DDFMA6v0uGvX \
    --set auth.database=tudoonline \
    --set primary.persistence.enabled=true \
    --set primary.persistence.size=280Gi \
    --set primary.resources.requests.memory=16Gi \
    --set primary.resources.requests.cpu=4000m \
    --set primary.resources.limits.memory=20Gi \
    --set primary.resources.limits.cpu=8000m \
    --set primary.service.type=NodePort \
    --set primary.service.nodePorts.mysql=32000 \
    --set primary.configuration="[mysqld]\ninnodb_buffer_pool_size=14G\nmax_connections=1000\ninnodb_log_file_size=1G\ninnodb_flush_log_at_trx_commit=2"

echo "⚡ Instalando Redis (Node 2)..."
helm upgrade --install redis bitnami/redis \
    -n $NAMESPACE \
    --set master.nodeSelector."svc\.tudoonline\.io/role"=app \
    --set architecture=standalone \
    --set auth.password=redis_prod_password

echo "🐰 Instalando RabbitMQ (Node 2 - Simples Manifest)..."
# Usamos nosso manifesto customizado, mas precisamos adicionar o NodeSelector nele
# Vou aplicar um patch rápido
kubectl apply -f ../rabbitmq/local-manifest.yaml -n $NAMESPACE
kubectl patch statefulset rabbitmq -n $NAMESPACE --type='json' -p='[{"op": "add", "path": "/spec/template/spec/nodeSelector", "value": {"svc.tudoonline.io/role": "app"}}]'

# 5. Apps (Tudoonline e Goolhub)
# Aqui usaríamos o chart real com as imagens do Docker Hub (privado)
echo "⚠️ PULAR DEPLOY DE APPS POR ENQUANTO (Requer Imagens Oficiais)"
echo "O ambiente está pronto para receber os deploys!"

echo ""
echo "✅ Cluster Configurado!"
echo "Acesse o Portainer em: http://painel.tudoonline.com.br (configure o DNS!)"
