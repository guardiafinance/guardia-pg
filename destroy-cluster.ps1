# Definição das variáveis
$NAMESPACE = "guardia-lke-postgres"

# Função para verificar se o kubectl está instalado
function Check-Kubectl {
    if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
        Write-Host "Erro: kubectl não está instalado" -ForegroundColor Red
        exit 1
    }
}

# Função para verificar se o namespace existe
function Check-Namespace {
    try {
        kubectl get namespace $NAMESPACE | Out-Null
    } catch {
        Write-Host "Erro: Namespace $NAMESPACE não encontrado" -ForegroundColor Red
        exit 1
    }
}

# Função para fazer backup dos dados (opcional)
function Backup-Data {
    $backup = Read-Host "Deseja fazer backup dos dados antes de destruir o cluster? (s/N)"
    if ($backup -eq 's' -or $backup -eq 'S') {
        Write-Host "Iniciando backup..." -ForegroundColor Yellow
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "postgres_backup_${timestamp}.sql"
        
        # Obtém o nome do pod primário
        $primaryPod = kubectl get pods -n $NAMESPACE -l postgresql-role=primary -o jsonpath='{.items[0].metadata.name}'
        
        if ($primaryPod) {
            try {
                kubectl exec -n $NAMESPACE $primaryPod -- pg_dumpall -U postgres > $backupFile
                Write-Host "Backup salvo em: $backupFile" -ForegroundColor Green
            } catch {
                Write-Host "Erro ao criar backup" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "Pod primário não encontrado" -ForegroundColor Red
            exit 1
        }
    }
}

# Função principal para destruir o cluster
function Destroy-Cluster {
    Write-Host "ATENÇÃO: Esta ação irá destruir o cluster PostgreSQL e todos os dados" -ForegroundColor Red
    $confirmation = Read-Host "Digite 'DESTRUIR' para confirmar"
    
    if ($confirmation -ne "DESTRUIR") {
        Write-Host "Operação cancelada"
        exit 1
    }

    Write-Host "Iniciando processo de destruição do cluster..."

    # Remove o cluster PostgreSQL
    Write-Host "Removendo cluster PostgreSQL..."
    kubectl delete -f ../cluster.yaml

    # Remove o namespace
    Write-Host "Removendo namespace..."
    kubectl delete namespace $NAMESPACE

    # Remove PVCs relacionados
    Write-Host "Removendo volumes persistentes..."
    kubectl delete pvc -n $NAMESPACE --all

    # Aguarda a finalização
    Write-Host "Aguardando finalização..."
    try {
        kubectl wait --for=delete namespace/$NAMESPACE --timeout=300s 2>$null
    } catch {
        # Ignora erros do wait, pois o namespace pode já ter sido removido
    }

    Write-Host "Cluster destruído com sucesso!" -ForegroundColor Green
}

# Execução principal
function Main {
    Check-Kubectl
    Check-Namespace
    Backup-Data
    Destroy-Cluster
}

# Inicia a execução
Main
