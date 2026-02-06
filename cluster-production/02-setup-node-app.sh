#!/bin/bash
set -e

# ==============================================================================
# SCRIPT DE INSTALAÇÃO - NODE 2 (APP + STORAGE)
# Execute este script dentro da VPS 2 (Debian 12/Ubuntu 24.04)
# ==============================================================================

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "❌ Erro: Informe o IP do Master e o Token."
    echo "Uso: ./02-setup-node-app.sh <MASTER_IP> <TOKEN>"
    exit 1
fi

MASTER_IP=$1
TOKEN=$2
STORAGE_PATH="/srv/tudoonline-storage"

echo "🚀 Iniciando Configuração do NODE 2 (App + Storage)..."

# 1. Instalar Utilitários e NFS Server
apt-get update && apt-get install -y curl nfs-kernel-server htop git

# 2. Configurar Storage Compartilhado (NFS)
echo "📂 Configurando Pasta Compartilhada em $STORAGE_PATH..."
mkdir -p $STORAGE_PATH
chown -R nobody:nogroup $STORAGE_PATH
chmod 777 $STORAGE_PATH

# Adicionar exportação ao /etc/exports se não existir
if ! grep -q "$STORAGE_PATH" /etc/exports; then
    # Ajuste o * para a subnet da rede privada para mais segurança (ex: 10.0.0.0/16)
    echo "$STORAGE_PATH *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
    exportfs -a
    systemctl restart nfs-kernel-server
    echo "✅ NFS Server configurado!"
fi

# 3. Instalar K3s (Agent Mode)
echo "📦 Conectando ao Cluster K3s..."
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN INSTALL_K3S_EXEC="agent --node-label svc.tudoonline.io/role=app" sh -

echo ""
echo "✅ NODE 2 Configurado e Conectado!"
echo "---------------------------------------------------------"
echo "O NFS Server está ativo exportando: $STORAGE_PATH"
echo "---------------------------------------------------------"
