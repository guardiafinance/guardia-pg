#!/bin/bash

# Definição das variáveis
NAMESPACE="guardia-lke-postgres"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Função para verificar se o kubectl está instalado
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}Erro: kubectl não está instalado${NC}"
        exit 1
    fi
}

# Função para verificar se o namespace existe
check_namespace() {
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        echo -e "${RED}Erro: Namespace $NAMESPACE não encontrado${NC}"
        exit 1
    fi
}

# Função para fazer backup dos dados (opcional)
backup_data() {
    echo -e "${YELLOW}Deseja fazer backup dos dados antes de destruir o cluster? (s/N)${NC}"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "Iniciando backup..."
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="postgres_backup_${TIMESTAMP}.sql"
        
        # Obtém o nome do pod primário
        PRIMARY_POD=$(kubectl get pods -n $NAMESPACE -l postgresql-role=primary -o jsonpath='{.items[0].metadata.name}')
        
        if [ -n "$PRIMARY_POD" ]; then
            kubectl exec -n $NAMESPACE $PRIMARY_POD -- pg_dumpall -U postgres > $BACKUP_FILE
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Backup salvo em: $BACKUP_FILE${NC}"
            else
                echo -e "${RED}Erro ao criar backup${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Pod primário não encontrado${NC}"
            exit 1
        fi
    fi
}

# Função principal para destruir o cluster
destroy_cluster() {
    echo -e "${RED}ATENÇÃO: Esta ação irá destruir o cluster PostgreSQL e todos os dados${NC}"
    echo -e "${RED}Digite 'DESTROY' para confirmar:${NC}"
    read confirmation
    
    if [ "$confirmation" != "DESTROY" ]; then
        echo "Operação cancelada"
        exit 1
    fi

    echo "Iniciando processo de destruição do cluster..."

    # Remove o cluster PostgreSQL
    echo "Removendo cluster PostgreSQL..."
    kubectl delete -f cluster.yaml
    
    # Remove o namespace
    echo "Removendo namespace..."
    kubectl delete namespace $NAMESPACE

    # Remove PVCs relacionados
    echo "Removendo volumes persistentes..."
    kubectl delete pvc -n $NAMESPACE --all

    # Aguarda a finalização
    echo "Aguardando finalização..."
    kubectl wait --for=delete namespace/$NAMESPACE --timeout=300s 2>/dev/null

    echo -e "${GREEN}Cluster destruído com sucesso!${NC}"
}

# Execução principal
main() {
    check_kubectl
    check_namespace
    backup_data
    destroy_cluster
}

main 