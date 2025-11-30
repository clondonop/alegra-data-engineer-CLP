CREATE TABLE IF NOT EXISTS dim_subscription_scd (
    subscription_key       BIGSERIAL PRIMARY KEY,
    subscription_id        VARCHAR(100),
    plan                   VARCHAR(100),
    status                 VARCHAR(50),
    monthly_price_usd      NUMERIC(18,2),
    start_date_key         INTEGER,
    end_date_key           INTEGER,
    valid_from             DATE,
    valid_to               DATE,
    is_current             BOOLEAN DEFAULT TRUE
);

-- Cerrar suscripciones que cambiaron de status o plan
UPDATE dim_subscription_scd
SET 
    valid_to = CURRENT_DATE - 1,
    is_current = FALSE
WHERE subscription_id IN (
    SELECT stg.subscription_id
    FROM stg_subscriptions stg
    INNER JOIN dim_subscription_scd dim ON stg.subscription_id = dim.subscription_id
    WHERE dim.is_current = TRUE
    AND (
        stg.plan <> dim.plan OR
        stg.status <> dim.status OR
        stg.monthly_price_usd <> dim.monthly_price_usd
    )
);

-- Insertar nuevas versiones
INSERT INTO dim_subscription_scd (
    subscription_key, subscription_id, plan, status, monthly_price_usd,
    start_date_key, end_date_key,
    valid_from, valid_to, is_current
)
SELECT 
    (SELECT COALESCE(MAX(subscription_key), 0) + ROW_NUMBER() OVER (ORDER BY stg.subscription_id) 
     FROM dim_subscription_scd) as subscription_key,
    stg.subscription_id,
    stg.plan,
    stg.status,
    stg.monthly_price_usd,
    TO_CHAR(stg.start_date, 'YYYYMMDD')::INTEGER as start_date_key,
    TO_CHAR(stg.end_date, 'YYYYMMDD')::INTEGER as end_date_key,
    CURRENT_DATE as valid_from,
    '9999-12-31'::DATE as valid_to,
    TRUE as is_current
FROM stg_subscriptions stg
WHERE stg.subscription_id IN (
    SELECT subscription_id 
    FROM dim_subscription_scd 
    WHERE valid_to = CURRENT_DATE - 1
);

-- Insertar suscripciones nuevas
INSERT INTO dim_subscription_scd (
    subscription_key, subscription_id, plan, status, monthly_price_usd,
    start_date_key, end_date_key,
    valid_from, valid_to, is_current
)
SELECT 
    (SELECT COALESCE(MAX(subscription_key), 0) + ROW_NUMBER() OVER (ORDER BY stg.subscription_id) 
     FROM dim_subscription_scd) as subscription_key,
    stg.subscription_id,
    stg.plan,
    stg.status,
    stg.monthly_price_usd,
    TO_CHAR(stg.start_date, 'YYYYMMDD')::INTEGER as start_date_key,
    TO_CHAR(stg.end_date, 'YYYYMMDD')::INTEGER as end_date_key,
    stg.start_date as valid_from,
    '9999-12-31'::DATE as valid_to,
    TRUE as is_current
FROM stg_subscriptions stg
WHERE NOT EXISTS (
    SELECT 1 FROM dim_subscription_scd dim 
    WHERE dim.subscription_id = stg.subscription_id
);