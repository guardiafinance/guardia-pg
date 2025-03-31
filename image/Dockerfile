FROM ghcr.io/cloudnative-pg/postgresql:17

LABEL name="Guardia PostgreSQL" \
      vendor="Guardia" \
      version="17" \
      release="1.0.0" \
      summary="PostgreSQL customizado para o Guardia Core Banking" \
      description="Imagem PostgreSQL customizada com extensões para Ledger (TimescaleDB, pgAudit, Periods)" \
      maintainer="Guardias Team" \
      org.opencontainers.image.source="https://github.com/guardiafinance/guardia-pg" \
      org.opencontainers.image.licenses="AGPL-3.0"

USER root

RUN apt-get update && apt-get install -y \
    curl \
    make \
    gcc \
    libpq-dev \
    postgresql-server-dev-17 \
    git \
    gpg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://packagecloud.io/timescale/timescaledb/gpgkey | gpg --dearmor > /usr/share/keyrings/timescaledb.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/timescaledb.gpg] https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/timescaledb.list \
    && apt-get update \
    && apt-get install -y timescaledb-2-postgresql-17 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/xocolatl/periods.git /tmp/periods \
    && cd /tmp/periods \
    && make \
    && make install \
    && rm -rf /tmp/periods

RUN echo "shared_preload_libraries = 'timescaledb,pgaudit'" >> /usr/share/postgresql/postgresql.conf.sample

RUN echo "CREATE EXTENSION IF NOT EXISTS btree_gist;" > /docker-entrypoint-initdb.d/init_extensions.sql \
    && echo "CREATE EXTENSION IF NOT EXISTS pgcrypto;" >> /docker-entrypoint-initdb.d/init_extensions.sql \
    && echo "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;" >> /docker-entrypoint-initdb.d/init_extensions.sql \
    && echo "CREATE EXTENSION IF NOT EXISTS periods;" >> /docker-entrypoint-initdb.d/init_extensions.sql \
    && echo "CREATE EXTENSION IF NOT EXISTS pgaudit;" >> /docker-entrypoint-initdb.d/init_extensions.sql \
    && echo "CREATE EXTENSION IF NOT EXISTS timescaledb;" >> /docker-entrypoint-initdb.d/init_extensions.sql

RUN usermod -u 26 postgres
USER 26