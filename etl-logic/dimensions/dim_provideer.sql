CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_provider_name
    ON dim_provider (provider);

INSERT INTO dim_provider (
    provider
)
SELECT DISTINCT
    INITCAP(TRIM(e.provider)) AS provider
FROM stg_expenses e
WHERE e.provider IS NOT NULL
ON CONFLICT (provider) DO NOTHING;
