#!/bin/bash
set -e

echo "🛠️  Criando código fonte FAKE para teste de infraestrutura..."

# Função para criar estrutura fake
create_fake_app() {
    DIR=$1
    echo "--> Criando fake app em $DIR/app..."
    mkdir -p $DIR/app
    
    # Criar index.php
    echo "<?php echo 'Hello from Infra Test - $DIR'; ?>" > $DIR/app/index.php
    
    # Criar composer.json mínimo para não falhar o build
    echo '{ "require": {} }' > $DIR/app/composer.json
    
    # Criar composer.lock vazio
    echo '{}' > $DIR/app/composer.lock
}

create_fake_app "tudoonline-app"
create_fake_app "goolhub-api"
create_fake_app "tudoonline-workers"

echo "✅ Código fonte fake criado com sucesso!"
