CREATE TABLE IF NOT EXISTS dim_country (
    country_key BIGSERIAL PRIMARY KEY,
    country_code VARCHAR(10),
    country_name VARCHAR(100) UNIQUE,
    region VARCHAR(100),
    continent VARCHAR(50)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_country_name
    ON dim_country (country_name);

INSERT INTO dim_country (
    country_code,
    country_name,
    region,
    continent
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
