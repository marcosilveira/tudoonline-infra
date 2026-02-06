#!/bin/bash
set -e

# ==============================================================================
# SCRIPT DE INSTALAÇÃO - NODE 3 (WORKERS)
# Execute este script dentro da VPS 3 (Debian 12/Ubuntu 24.04)
# ==============================================================================

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "❌ Erro: Informe o IP do Master e o Token."
    echo "Uso: ./03-setup-node-worker.sh <MASTER_IP> <TOKEN>"
    exit 1
fi

MASTER_IP=$1
TOKEN=$2

echo "🚀 Iniciando Configuração do NODE 3 (Workers)..."

# 1. Instalar NFS Common (Para montar o disco da VPS 2)
apt-get update && apt-get install -y curl nfs-common htop git

# 2. Instalar K3s (Agent Mode)
echo "📦 Conectando ao Cluster K3s..."
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN INSTALL_K3S_EXEC="agent --node-label svc.tudoonline.io/role=worker" sh -

echo ""
echo "✅ NODE 3 Configurado e Conectado!"
