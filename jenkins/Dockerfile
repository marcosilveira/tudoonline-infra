FROM jenkins/jenkins:lts

USER root

# Instalar dependências
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    git-crypt \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Instalar Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Instalar kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Dar permissão ao usuário jenkins para usar docker
RUN usermod -aG docker jenkins

# Voltar para usuário jenkins
USER jenkins
