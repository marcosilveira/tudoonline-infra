#!/bin/bash
set -e

echo "🐳 Construindo imagens Docker localmente..."

# 1. Tudoonline App (Copia direto do contexto)
echo "--> Building tudoonline-app Nginx..."
docker build -t local/tudoonline-app-nginx:latest -f tudoonline-app/docker/nginx/Dockerfile tudoonline-app/
echo "--> Building tudoonline-app PHP..."
docker build -t local/tudoonline-app-php:latest -f tudoonline-app/docker/php/Dockerfile tudoonline-app/

# 2. Goolhub API (Depende de local/build:latest)
echo "--> Preparando imagem base fake para goolhub-api..."
# Cria a imagem local/build que o Dockerfile exige, contendo o código fake
docker build -t local/build:latest -f Dockerfile.fake-build goolhub-api/

echo "--> Building goolhub-api Nginx..."
docker build -t local/goolhub-api-nginx:latest -f goolhub-api/docker/nginx/Dockerfile goolhub-api/
echo "--> Building goolhub-api PHP..."
docker build -t local/goolhub-api-php:latest -f goolhub-api/docker/php/Dockerfile goolhub-api/

# 3. Workers (Usa COPY app/ $USER_HOME)
echo "--> Building tudoonline-workers..."
docker build -t local/tudoonline-worker:latest -f tudoonline-workers/docker/worker/Dockerfile tudoonline-workers/

echo "✅ Imagens construídas com sucesso!"
