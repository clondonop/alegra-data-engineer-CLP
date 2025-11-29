-- Cerrar suscripciones que cambiaron de status o plan
UPDATE DIM_SUBSCRIPTION_SCD
SET 
    valid_to = CURRENT_DATE - 1,
    is_current = FALSE
WHERE subscription_id IN (
    SELECT stg.subscription_id
    FROM stg_subscriptions stg
    INNER JOIN DIM_SUBSCRIPTION_SCD dim ON stg.subscription_id = dim.subscription_id
    WHERE dim.is_current = TRUE
    AND (
        stg.plan <> dim.plan OR
        stg.status <> dim.status OR
        stg.monthly_price_usd <> dim.monthly_price_usd
    )
);

-- Insertar nuevas versiones
INSERT INTO DIM_SUBSCRIPTION_SCD (
    subscription_key, subscription_id, plan, status, monthly_price_usd,
    start_date_key, end_date_key,
    valid_from, valid_to, is_current
)
SELECT 
    (SELECT COALESCE(MAX(subscription_key), 0) + ROW_NUMBER() OVER (ORDER BY stg.subscription_id) 
     FROM DIM_SUBSCRIPTION_SCD) as subscription_key,
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
    FROM DIM_SUBSCRIPTION_SCD 
    WHERE valid_to = CURRENT_DATE - 1
);

-- Insertar suscripciones nuevas
INSERT INTO DIM_SUBSCRIPTION_SCD (
    subscription_key, subscription_id, plan, status, monthly_price_usd,
    start_date_key, end_date_key,
    valid_from, valid_to, is_current
)
SELECT 
    (SELECT COALESCE(MAX(subscription_key), 0) + ROW_NUMBER() OVER (ORDER BY stg.subscription_id) 
     FROM DIM_SUBSCRIPTION_SCD) as subscription_key,
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
    SELECT 1 FROM DIM_SUBSCRIPTION_SCD dim 
    WHERE dim.subscription_id = stg.subscription_id
);