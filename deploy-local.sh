#!/bin/bash
set -e

NAMESPACE="production"
echo "🚀 Iniciando deploy local no OrbStack..."

# 0. Adicionar Repositórios Helm
echo "--> Adicionando repositório Bitnami..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 1. Configurar Namespace
echo "--> Criando namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 2. Instalar Dependências
echo "--> Instalando MariaDB (Substituto MySQL)..."
helm upgrade --install mariadb bitnami/mariadb -f mariadb/values-local.yaml -n $NAMESPACE

echo "--> Instalando Redis (Leve)..."
helm upgrade --install redis bitnami/redis -f redis/values-local.yaml -n $NAMESPACE

echo "--> Instalando RabbitMQ (Manifesto Simples)..."
# Usamos manifesto direto para evitar problemas com init-containers da Bitnami
kubectl apply -f rabbitmq/local-manifest.yaml -n $NAMESPACE

# 3. Aguardar DBs iniciarem
echo "⏳ Aguardando bancos de dados subirem..."
kubectl rollout status statefulset/mariadb -n $NAMESPACE --timeout=300s
kubectl rollout status statefulset/redis-master -n $NAMESPACE --timeout=300s
kubectl rollout status statefulset/rabbitmq -n $NAMESPACE --timeout=300s

# 4. Instalar Apps
echo "--> Instalando Tudoonline App..."
helm upgrade --install tudoonline-app ./local-app-chart \
    -n $NAMESPACE \
    --set app.nginx.image=local/tudoonline-app-nginx:latest \
    --set app.nginx.pullPolicy=Never \
    --set app.php.image=local/tudoonline-app-php:latest \
    --set app.php.pullPolicy=Never \
    --set ingress.hosts[0]=tudoonline.local \
    --set env.DB_HOST=mariadb-primary.production.svc.cluster.local

echo "--> Instalando Goolhub API..."
helm upgrade --install goolhub-api ./local-app-chart \
    -n $NAMESPACE \
    --set app.nginx.image=local/goolhub-api-nginx:latest \
    --set app.nginx.pullPolicy=Never \
    --set app.php.image=local/goolhub-api-php:latest \
    --set app.php.pullPolicy=Never \
    --set ingress.hosts[0]=api.goolhub.local \
    --set env.DB_HOST=mariadb-primary.production.svc.cluster.local

echo "✅ Deploy concluído!"
echo "📡 Acessos (Adicione ao /etc/hosts):"
echo "   127.0.0.1 tudoonline.local"
echo "   127.0.0.1 api.goolhub.local"
