CREATE TABLE IF NOT EXISTS dim_acquisition_channel (
    channel_key BIGSERIAL PRIMARY KEY,
    channel_name VARCHAR(200) UNIQUE,
    channel_category VARCHAR(100),
    cost_per_acquisition_avg NUMERIC(18,2)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_acquisition_channel_name
    ON dim_acquisition_channel (channel_name);

INSERT INTO dim_acquisition_channel (
    channel_name,
    channel_category,
    cost_per_acquisition_avg
)
SELECT DISTINCT
    INITCAP(TRIM(c.acquisition_channel)) AS channel_name,
    NULL::VARCHAR(100)                   AS channel_category,
    NULL::NUMERIC(18,2)                  AS cost_per_acquisition_avg
FROM stg_customers c
WHERE c.acquisition_channel IS NOT NULL
ON CONFLICT (channel_name) DO NOTHING;
