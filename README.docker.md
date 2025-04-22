# Guardia PostgreSQL

PostgreSQL customizado com configurações otimizadas para construção de Ledger e operação em ambiente Kubernetes, focado em imutabilidade, rastreabilidade, auditoria e dados temporais.

## Status do Projeto

![Docker Pulls](https://img.shields.io/docker/pulls/guardiafinance/guardia-pg)
![Docker Stars](https://img.shields.io/docker/stars/guardiafinance/guardia-pg)

## Características

- Baseado no PostgreSQL 17
- Otimizado para Kubernetes
- Configurado com pgAudit
- Suporte a alta disponibilidade
- Métricas integradas

## Uso Rápido

```bash
docker pull guardiafinance/guardia-postgres:17
```

## Variáveis de Ambiente

| Variável | Descrição | Valor Padrão |
|----------|-----------|---------------|
| POSTGRES_USER | Usuário principal do banco | postgres |
| POSTGRES_PASSWORD | Senha do usuário principal | postgres |
| POSTGRES_DB | Nome do banco de dados padrão | lke |

## Kubernetes

Exemplo de deployment no Kubernetes:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: guardia-lke-pg-cluster
  namespace: guardia-lke-postgres
spec:
  instances: 3
  imageName: guardiafinance/guardia-postgres:17
```

## Configurações

Esta imagem inclui as seguintes configurações do pgAudit:
- pgaudit.log: write,function,role,ddl
- pgaudit.log_catalog: on
- pgaudit.log_parameter: on
- pgaudit.log_relation: on

## Recursos

Recomendações de recursos mínimos:
- CPU: 200m
- Memória: 512Mi

## Suporte

- [Documentação Oficial](link_para_sua_documentacao)
- [GitHub Issues](link_para_issues)
- [Canal de Suporte](link_para_suporte)

## Contribuindo

Contribuições são bem-vindas! Por favor, leia nosso guia de contribuição antes de submeter pull requests.

## Licença

Este projeto está licenciado sob [sua licença] - veja o arquivo LICENSE para detalhes.

## Segurança

Para reportar vulnerabilidades de segurança, por favor envie um email para [seu-email].

## Mantenedores

- [Fernando Seguim](#)
- [Douglas Picolotto](#)
- [Equipe Guardia](#)

## Tags e Versões

| Tag | Descrição |
|-----|-----------|
| `17`, `latest` | PostgreSQL 17 com todas as extensões |

## Exemplos de Uso

### Docker Compose

```yaml
version: '3.8'
services:
  postgres:
    image: guardiafinance/guardia-pg:17
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: lke
    ports:
      - "5432:5432"
    volumes:
      - guardia_pgdata:/var/lib/postgresql/data

volumes:
  guardia_pgdata:
```

### Kubernetes com CloudNativePG

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: guardia-lke-pg-cluster
spec:
  instances: 3
  imageName: guardiafinance/guardia-postgres:17
  storage:
    size: 4Gi
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1Gi
```

## Monitoramento

A imagem inclui exportadores de métricas compatíveis com Prometheus.

### Métricas Disponíveis

- Estatísticas de conexões
- Performance de queries
- Uso de recursos
- Métricas de replicação

## Backup e Restauração

### Backup

```bash
pg_dump -h localhost -U postgres -d lke > backup.sql
```

### Restauração

```bash
psql -h localhost -U postgres -d lke < backup.sql
```

## Troubleshooting

### Problemas Comuns

1. **Erro de conexão**
   ```bash
   # Verifique se o serviço está rodando
   docker ps | grep postgres
   ```

2. **Problemas de permissão**
   ```bash
   # Ajuste as permissões do volume
   chmod 700 postgres_data
   ```

## Extensões Incluídas

### Extensões Principais
1. **btree_gist**
   - Suporte para índices GiST em tipos ordenáveis
   - Útil para constraints de exclusão e índices em ranges

2. **pgcrypto**
   - Funções criptográficas
   - Geração de hashes
   - Criptografia de dados

3. **pg_stat_statements**
   - Rastreamento de estatísticas de execução SQL
   - Monitoramento de performance de queries
   - Análise de tempo de execução

4. **periods**
   - Suporte para períodos temporais
   - Gerenciamento de dados temporais
   - Implementação do padrão SQL:2016 temporal

5. **pgaudit**
   - Auditoria detalhada de sessão e objetos
   - Log de escritas, funções, roles e DDL
   - Monitoramento de alterações no banco

6. **timescaledb**
   - Otimização para dados de séries temporais
   - Particionamento automático por tempo
   - Compressão de dados
   - Funções de análise temporal

### Como as Extensões são Carregadas

As extensões são automaticamente criadas durante a inicialização do container através do script `/docker-entrypoint-initdb.d/init_extensions.sql`.

### Configurações Específicas

- TimescaleDB está configurado como biblioteca compartilhada:
```postgresql
shared_preload_libraries = 'timescaledb'
```

### Notas de Uso

- Todas as extensões são instaladas e habilitadas automaticamente na inicialização do banco
- Não é necessário executar CREATE EXTENSION manualmente
- TimescaleDB requer a configuração de shared_preload_libraries que já está incluída 