# Verifica se o kubectl está instalado
if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "kubectl não está instalado. Por favor, instale-o primeiro." -ForegroundColor Red
    exit 1
}

# Aplica as configurações do cluster
kubectl apply -f cluster.yaml

# Aguarda o cluster ficar pronto
Write-Host "Aguardando o cluster PostgreSQL inicializar..."
kubectl wait --for=condition=Ready pods `
    -l cnpg.io/cluster=guardia-lke-pg-cluster `
    -n guardia-lke-postgres `
    --timeout=300s

# Verifica se todos os pods estão rodando
$PODS_RUNNING = (kubectl get pods -n guardia-lke-postgres -l cnpg.io/cluster=guardia-lke-pg-cluster -o jsonpath='{.items[*].status.phase}' | Select-String -Pattern "Running" -AllMatches).Matches.Count
$TOTAL_PODS = kubectl get cluster guardia-lke-pg-cluster -n guardia-lke-postgres -o jsonpath='{.spec.instances}'

if ($PODS_RUNNING -eq $TOTAL_PODS) {
    Write-Host "Cluster PostgreSQL iniciado com sucesso!" -ForegroundColor Green
    Write-Host "Pods em execução: $PODS_RUNNING/$TOTAL_PODS"
    
    # Mostra informações de conexão
    Write-Host "`nInformações de conexão:" -ForegroundColor Yellow
    Write-Host "Namespace: guardia-lke-postgres"
    Write-Host "Service: guardia-lke-pg-cluster-rw"
    Write-Host "Port: 5432"
    Write-Host "Usuario: postgres"
    Write-Host "Banco: lke"
    
    Write-Host "`nPara conectar localmente, execute:" -ForegroundColor Yellow
    Write-Host "kubectl port-forward -n guardia-lke-postgres svc/guardia-lke-pg-cluster-rw 5432:5432"
} else {
    Write-Host "Erro: Nem todos os pods estão rodando ($PODS_RUNNING/$TOTAL_PODS)" -ForegroundColor Red
    exit 1
} 