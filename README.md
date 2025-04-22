# Guia de Instalação e Configuração do Cluster PostgreSQL no Kubernetes

## Pré-requisitos

Antes de começar, você precisará instalar os seguintes componentes:

### 1. Docker
- Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Linux:
```bash
curl -fsSL https://get.docker.com | sh
```

### 2. Minikube
```bash
# Windows (usando chocolatey)
choco install minikube

# Mac (usando homebrew)
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 3. kubectl
```bash
# Windows (usando chocolatey)
choco install kubernetes-cli

# Mac (usando homebrew)
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

## Configuração do Ambiente

### 1. Iniciar o Minikube
```bash
minikube start
```

### 2. Verificar se está tudo funcionando
```bash
kubectl get nodes
```

### 3. Instalar o Operador CloudNativePG
```bash
kubectl apply -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.21/releases/cnpg-1.21.0.yaml
```

## Deploy do Cluster PostgreSQL

### 1. Clone o repositório (se aplicável)
```bash
git clone [URL_DO_SEU_REPOSITORIO]
cd [NOME_DO_DIRETORIO]
```

### 2. Aplique as configurações do cluster
```bash
kubectl apply -f cluster.yaml
```

### 3. Verifique o status do cluster
```bash
# Verificar os pods
kubectl get pods -n guardia-lke-postgres

# Verificar o cluster PostgreSQL
kubectl get cluster -n guardia-lke-postgres
```

## Acessando o PostgreSQL

### 1. Port-forward para acessar localmente
```bash
kubectl port-forward -n guardia-lke-postgres svc/guardia-lke-pg-cluster-rw 5432:5432
```

### 2. Conectar ao banco de dados
```bash
# Usando psql (se instalado)
psql -h localhost -p 5432 -U postgres -d lke

# As credenciais são:
# usuário: postgres
# senha: postgres
```

## Scripts de Automação

O projeto inclui dois scripts para facilitar o deploy:

### No Linux/Mac:
```bash
chmod +x start-cluster.sh
./start-cluster.sh
```

### No Windows:
```powershell
.\start-cluster.ps1
```

## Estrutura do Cluster

O cluster PostgreSQL está configurado com:
- 3 instâncias (1 primária e 2 réplicas)
- 4Gi de armazenamento por instância
- Recursos limitados:
  - CPU: 200m-500m
  - Memória: 512Mi-1Gi
- Auditoria habilitada através do pgAudit
- Banco de dados padrão: `lke`

## Monitoramento

Para verificar os logs do cluster:
```bash
kubectl logs -n guardia-lke-postgres -l postgresql-role=primary
```

## Troubleshooting

### Problemas comuns:

1. Se os pods não iniciarem:
```bash
kubectl describe pods -n guardia-lke-postgres
```

2. Se o minikube não iniciar:
```bash
minikube delete
minikube start
```

3. Para reiniciar o cluster PostgreSQL:
```bash
kubectl delete -f cluster.yaml
kubectl apply -f cluster.yaml
```

## Limpeza

Para remover o cluster:
```bash
kubectl delete -f cluster.yaml
```

Para parar o minikube:
```bash
minikube stop
```

## Notas de Segurança

⚠️ **Importante**: As credenciais definidas no arquivo `cluster.yaml` são para desenvolvimento local apenas. Em um ambiente de produção, você deve:
- Usar senhas fortes
- Implementar rotação de credenciais
- Usar gerenciadores de segredos
- Configurar network policies
- Habilitar TLS

## Suporte

Para problemas ou dúvidas, por favor:
1. Verifique os logs dos pods
2. Consulte a [documentação do CloudNativePG](https://cloudnative-pg.io/documentation/)
3. Abra uma issue no repositório do projeto
