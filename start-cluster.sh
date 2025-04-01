#!/bin/bash

# Verifica se o kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo "kubectl não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

# Aplica as configurações do cluster
kubectl apply -f ../cluster.yaml

# Aguarda o cluster ficar pronto
echo "Aguardando o cluster PostgreSQL inicializar..."
kubectl wait --for=condition=Ready pods \
    -l cnpg.io/cluster=guardia-lke-pg-cluster \
    -n guardia-lke-postgres \
    --timeout=300s

# Verifica se todos os pods estão rodando
PODS_RUNNING=$(kubectl get pods -n guardia-lke-postgres -l cnpg.io/cluster=guardia-lke-pg-cluster -o jsonpath='{.items[*].status.phase}' | grep -c "Running")
TOTAL_PODS=$(kubectl get cluster guardia-lke-pg-cluster -n guardia-lke-postgres -o jsonpath='{.spec.instances}')

if [ "$PODS_RUNNING" -eq "$TOTAL_PODS" ]; then
    echo "Cluster PostgreSQL iniciado com sucesso!"
    echo "Pods em execução: $PODS_RUNNING/$TOTAL_PODS"
    
    # Mostra informações de conexão
    echo -e "\nInformações de conexão:"
    echo "Namespace: guardia-lke-postgres"
    echo "Service: guardia-lke-pg-cluster-rw"
    echo "Port: 5432"
    echo "Usuario: postgres"
    echo "Banco: lke"
    
    echo -e "\nPara conectar localmente, execute:"
    echo "kubectl port-forward -n guardia-lke-postgres svc/guardia-lke-pg-cluster-rw 5432:5432"
else
    echo "Erro: Nem todos os pods estão rodando ($PODS_RUNNING/$TOTAL_PODS)"
    exit 1
fi