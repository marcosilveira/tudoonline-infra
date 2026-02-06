#!/bin/bash
set -e

# ==============================================================================
# SEGURANÇA E VPN - NODE 1 (MASTER/DB)
# Execute este script na VPS 1 após o Deploy do Cluster
# ==============================================================================

echo "🔒 Iniciando Blindagem do Servidor e Instalação VPN..."

# 1. Instalar UFW (Firewall)
apt-get update && apt-get install -y ufw

# 2. Configurar Regras Padrão
ufw default deny incoming
ufw default allow outgoing

# 3. Portas Essenciais (Públicas)
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # Ingress HTTP
ufw allow 443/tcp  # Ingress HTTPS
ufw allow 6443/tcp # K3s API (Apenas se precisar gerenciar remotamente sem VPN)

# 4. Regras da VPN (OpenVPN usa 1194 UDP por padrão)
ufw allow 1194/udp

# 5. BLINDAGEM DO MYSQL (Porta 32000)
# Bloqueia acesso externo
# Libera acesso apenas para a interface da VPN (tun0)
echo "🛡️ Configurando acesso exclusivo ao MySQL via VPN..."
ufw allow in on tun0 to any port 32000 proto tcp
# Libera acesso para a rede interna (Substitua xxx pelo IP/Faixa da sua rede privada se necessário)
# ufw allow from 10.0.0.0/16 to any port 32000 proto tcp

# 6. Instalação do OpenVPN
if [ ! -f "openvpn-install.sh" ]; then
    echo "⬇️ Baixando instalador OpenVPN..."
    curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh
fi

echo ""
echo "=========================================================="
echo "⚠️  ATENÇÃO: VAMOS INICIAR A INSTALAÇÃO DO OPENVPN"
echo "    Responda às perguntas do instalador."
echo "    Recomendação: Aceite os padrões (Porta 1194, UDP, DNS Cloudflare)."
echo "=========================================================="
echo "Pressione ENTER para continuar..."
read

./openvpn-install.sh

# 7. Ativar Firewall
echo "🔥 Ativando Firewall UFW..."
# Precisamos garantir que o K3s funcione com UFW
ufw allow from 10.42.0.0/16 to any # Pods Network
ufw allow from 10.43.0.0/16 to any # Service Network
ufw --force enable

echo ""
echo "✅ SERVIDOR BLINDADO E VPN INSTALADA!"
echo "Para conectar no banco:"
echo "1. Baixe o arquivo .ovpn gerado para seu computador."
echo "2. Conecte na VPN."
echo "3. Acesse o banco em: 10.8.0.1 (IP da VPN) na porta 32000"
