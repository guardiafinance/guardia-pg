#!/bin/bash

# Definição das variáveis
IMAGE_NAME="guardiafinance/guardia-pg"
VERSION="17"
FULL_IMAGE_NAME="$IMAGE_NAME:$VERSION"

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Iniciando build da imagem PostgreSQL..."

# Verifica se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Erro: Docker não está rodando. Por favor, inicie o Docker primeiro.${NC}"
    exit 1
fi

# Build da imagem
echo "Construindo imagem: $FULL_IMAGE_NAME"
if docker build -t $FULL_IMAGE_NAME .; then
    echo -e "${GREEN}Build completado com sucesso!${NC}"
else
    echo -e "${RED}Erro durante o build da imagem${NC}"
    exit 1
fi

# Pergunta se deseja fazer push da imagem
read -p "Deseja fazer push da imagem para o Docker Hub? (s/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Fazendo push da imagem para o Docker Hub..."
    if docker push $FULL_IMAGE_NAME; then
        echo -e "${GREEN}Push completado com sucesso!${NC}"
    else
        echo -e "${RED}Erro durante o push da imagem${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}Processo finalizado!${NC}" 