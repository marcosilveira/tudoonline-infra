#!/bin/bash
set -e

# ==============================================================================
# SCRIPT DE INSTALAÇÃO - NODE 1 (BANCO DE DADOS)
# Execute este script dentro da VPS 1 (Debian 12/Ubuntu 24.04)
# ==============================================================================

echo "🚀 Iniciando Configuração do NODE 1 (Master / Database)..."

# 1. Instalar Utilitários Básicos
apt-get update && apt-get install -y curl ufw unzip htop git

# 2. Configurar Firewall (UFW)
echo "🔒 Configurando Firewall..."
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw allow 6443/tcp # K3s API Access
ufw allow 10250/tcp # Kubelet Metrics
# Permitir rede interna (Ajuste para sua subnet, ex: 10.0.0.0/16)
# ufw allow from 10.0.0.0/16 to any
echo "⚠️ ATENÇÃO: Habilite a rede interna no UFW manualmente depois!"
# ufw enable

# 3. Instalar K3s (Master Mode)
# Desabilitamos o traefik padrão pois instalaremos manualmente ou usaremos nginx depois
echo "📦 Instalando K3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik --node-label svc.tudoonline.io/role=db" sh -

# 4. Extrair Token para adicionar outros nodes
K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
MY_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "✅ NODE 1 Configurado com Sucesso!"
echo "---------------------------------------------------------"
echo "📋 DADOS PARA OS PRÓXIMOS PASSOS:"
echo "Master IP: $MY_IP"
echo "Token K3s: $K3S_TOKEN"
echo "---------------------------------------------------------"
echo "👉 Copie o Token acima, você vai precisar dele para os scripts 02 e 03."
