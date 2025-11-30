CREATE TABLE IF NOT EXISTS dim_customer_scd (
    customer_key            BIGSERIAL PRIMARY KEY,
    customer_id             VARCHAR(100),
    segment                 VARCHAR(100),
    acquisition_channel_key INTEGER,
    country_key             INTEGER,
    registration_date_key   INTEGER,
    valid_from              DATE,
    valid_to                DATE,
    is_current              BOOLEAN DEFAULT TRUE
);

-- Marcar como historicos aquellos registros que cambiaron
UPDATE dim_customer_scd
SET 
    valid_to = CURRENT_DATE - 1,
    is_current = FALSE
WHERE customer_id IN (
    SELECT stg.customer_id
    FROM stg_customers stg
    INNER JOIN dim_customer_scd dim ON stg.customer_id = dim.customer_id
    INNER JOIN dim.acquisition_channel dac ON stg.acquisition_channel = dac.channel_name
    WHERE dim.is_current = TRUE
    AND (
        stg.segment <> dim.segment OR
        dac.channel_key <> dim.acquisition_channel_key
    )
);

-- Insertar nuevas versiones de registros cambiados
INSERT INTO dim_customer_scd (
    customer_key, customer_id, segment, acquisition_channel_key, 
    country_key, registration_date_key, 
    valid_from, valid_to, is_current
)
SELECT 
    (SELECT COALESCE(MAX(customer_key), 0) + ROW_NUMBER() OVER (ORDER BY stg.customer_id) 
     FROM dim_customer_scd) as customer_key,
    stg.customer_id,
    stg.segment,
    dac.channel_key as acquisition_channel_key,
    c.country_key,
    TO_CHAR(stg.registration_date, 'YYYYMMDD')::INTEGER as registration_date_key,
    CURRENT_DATE as valid_from,
    '9999-12-31'::DATE as valid_to,
    TRUE as is_current
FROM stg_customers stg
LEFT JOIN dim_country c ON stg.country_code = c.country_code
LEFT JOIN dim_acquisition_channel dac ON stg.acquisition_channel = dac.channel_name
WHERE stg.customer_id IN (
    SELECT customer_id 
    FROM dim_customer_scd 
    WHERE valid_to = CURRENT_DATE - 1
);

-- Insertar clientes completamente nuevos
INSERT INTO dim_customer_scd (
    customer_key, customer_id, segment, acquisition_channel_key, 
    country_key, registration_date_key, 
    valid_from, valid_to, is_current
)
SELECT 
    (SELECT COALESCE(MAX(customer_key), 0) + ROW_NUMBER() OVER (ORDER BY stg.customer_id) 
     FROM dim_customer_scd) as customer_key,
    stg.customer_id,
    stg.segment,
    dac.channel_key as acquisition_channel_key,
    c.country_key,
    TO_CHAR(stg.registration_date, 'YYYYMMDD')::INTEGER as registration_date_key,
    stg.registration_date as valid_from,
    '9999-12-31'::DATE as valid_to,
    TRUE as is_current
FROM stg_customers stg
LEFT JOIN dim_country c ON stg.country_code = c.country_code
LEFT JOIN dim_acquisition_channel dac ON stg.acquisition_channel = dac.channel_name
WHERE NOT EXISTS (
    SELECT 1 FROM dim_customer_scd dim 
    WHERE dim.customer_id = stg.customer_id
);