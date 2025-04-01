# Verifica se o Docker está rodando
try {
    docker info | Out-Null
} catch {
    Write-Host "Erro: Docker não está rodando. Por favor, inicie o Docker primeiro." -ForegroundColor Red
    exit 1
}

# Subir o container
Write-Host "Iniciando container PostgreSQL..." -ForegroundColor Blue
try {
    docker-compose up -d
    Write-Host "Container iniciado com sucesso!" -ForegroundColor Green
    
    # Mostrar status
    Write-Host "`nStatus do container:" -ForegroundColor Blue
    docker ps --filter "name=guardia_pg_17"
} catch {
    Write-Host "Erro ao iniciar o container" -ForegroundColor Red
    exit 1
}

Write-Host "`nPara conectar ao PostgreSQL:" -ForegroundColor Yellow
Write-Host "Host: localhost" -ForegroundColor Gray
Write-Host "Port: 5432" -ForegroundColor Gray
Write-Host "User: postgres" -ForegroundColor Gray
Write-Host "Database: postgres" -ForegroundColor Gray