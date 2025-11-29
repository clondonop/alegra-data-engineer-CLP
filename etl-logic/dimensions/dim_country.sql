-- Índice único por nombre de país (business key)
CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_country_name
    ON dim_country (country_name);

-- ETL / UPSERT desde todas las fuentes que traen country
INSERT INTO dim_country (
    country_code,          -- NULL por ahora
    country_name,
    region,                -- NULL por ahora
    continent              -- NULL por ahora
)
SELECT DISTINCT
    NULL::VARCHAR(10)                        AS country_code,
    INITCAP(TRIM(c.country))                 AS country_name,
    NULL::VARCHAR(100)                       AS region,
    NULL::VARCHAR(50)                        AS continent
FROM (
    SELECT country FROM stg_customers
    UNION
    SELECT country FROM stg_employees
    UNION
    SELECT country FROM stg_transactions
    UNION
    SELECT country FROM stg_expenses
) c
WHERE c.country IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;
