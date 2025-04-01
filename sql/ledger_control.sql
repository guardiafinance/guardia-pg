CREATE SCHEMA IF NOT EXISTS guardia;

-- Tabela para controle dos ledgers
CREATE TABLE IF NOT EXISTS guardia.ledger_control (
    entity_id bigint NOT NULL PRIMARY KEY,
    external_entity_id VARCHAR(36) NOT NULL UNIQUE,
    entity_type VARCHAR(6) DEFAULT 'LEDGER',
    ledger_name VARCHAR(128) NOT NULL UNIQUE,
    description VARCHAR(512),
    metadata JSONB,
    tablespace_name TEXT NOT NULL,
    schema_name TEXT NOT NULL,
    created_at TIMESTAMPT DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPT,
    discarded_at TIMESTAMPT
);

-- Adicionar suporte temporal
SELECT periods.add_system_time_period('guardia.ledger_control', 'valid_from', 'valid_to');
SELECT periods.add_system_versioning('guardia.ledger_control');

-- Função para criar novo ledger
CREATE OR REPLACE PROCEDURE guardia.create_ledger(
    p_entity_id BIGINT,
    p_ledger_name VARCHAR(128),
    p_external_entity_id VARCHAR(36),
    p_description VARCHAR(512) DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tablespace_name TEXT;
    v_schema_name TEXT;
BEGIN
    -- Validações
    IF p_entity_id IS NULL THEN
        RAISE EXCEPTION 'entity_id não pode ser NULL';
    END IF;

    IF p_ledger_name !~ '^[a-zA-Z][a-zA-Z0-9_]*$' THEN
        RAISE EXCEPTION 'Nome do ledger inválido. Use apenas letras, números e underscore.';
    END IF;

    -- Criar nomes padronizados
    v_tablespace_name := 'lke_' || p_ledger_name || '_ts';
    v_schema_name := 'lke_' || p_ledger_name;

    -- Criar tablespace
    EXECUTE format(
        'CREATE TABLESPACE %I LOCATION %L',
        v_tablespace_name,
        '/var/lib/postgresql/data/tablespaces/' || v_tablespace_name
    );

    -- Criar schema
    EXECUTE format('CREATE SCHEMA %I', v_schema_name);

    -- Registrar no controle
    INSERT INTO guardia.ledger_control (
        entity_id,
        external_entity_id,
        ledger_name,
        description,
        metadata,
        tablespace_name,
        schema_name
    ) VALUES (
        p_entity_id,
        p_external_entity_id,
        p_ledger_name,
        p_description,
        p_metadata,
        v_tablespace_name,
        v_schema_name
    );

EXCEPTION WHEN OTHERS THEN
    -- Rollback em caso de erro
    IF v_tablespace_name IS NOT NULL THEN
        EXECUTE format('DROP TABLESPACE IF EXISTS %I', v_tablespace_name);
    END IF;
    IF v_schema_name IS NOT NULL THEN
        EXECUTE format('DROP SCHEMA IF EXISTS %I CASCADE', v_schema_name);
    END IF;
    RAISE;
END;
$$;
