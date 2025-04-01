# Definição das variáveis
$IMAGE_NAME = "guardiafinance/guardia-pg"
$VERSION = "17"
$FULL_IMAGE_NAME = "${IMAGE_NAME}:${VERSION}"
$LATEST_IMAGE_NAME = "${IMAGE_NAME}:latest"

Write-Host "Iniciando build da imagem PostgreSQL..." -ForegroundColor Blue

# Verifica se o Docker está rodando
try {
    docker info | Out-Null
} catch {
    Write-Host "Erro: Docker não está rodando. Por favor, inicie o Docker primeiro." -ForegroundColor Red
    exit 1
}

# Build da imagem
Write-Host "Construindo imagem: $FULL_IMAGE_NAME" -ForegroundColor Blue
try {
    docker build -t $FULL_IMAGE_NAME -t $LATEST_IMAGE_NAME .
    Write-Host "Build completado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro durante o build da imagem" -ForegroundColor Red
    exit 1
}

# Pergunta se deseja fazer push da imagem
$push = Read-Host "Deseja fazer push da imagem para o Docker Hub? (s/N)"
if ($push -eq 's' -or $push -eq 'S') {
    Write-Host "Fazendo push das imagens para o Docker Hub..." -ForegroundColor Blue
    try {
        docker push $FULL_IMAGE_NAME
        docker push $LATEST_IMAGE_NAME
        Write-Host "Push completado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "Erro durante o push das imagens" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Processo finalizado!" -ForegroundColor Green
