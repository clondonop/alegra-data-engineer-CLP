CREATE TABLE IF NOT EXISTS dim_product (
    product_key         BIGSERIAL PRIMARY KEY,
    product_id          VARCHAR(200) UNIQUE,
    product_name        VARCHAR(200),
    product_type        VARCHAR(100),
    product_category    VARCHAR(100),
    unit_cost_usd       NUMERIC(18,2),
    is_active           BOOLEAN
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_product_id
    ON dim_product (product_id);

INSERT INTO dim_product (
    product_id,
    product_name,
    product_type,
    product_category,
    unit_cost_usd,
    is_active
)
SELECT DISTINCT
    TRIM(t.product_id)                AS product_id,
    INITCAP(TRIM(t.product_id))       AS product_name,   -- Lo mismo por ahora
    NULL::VARCHAR(100)                AS product_type,
    NULL::VARCHAR(100)                AS product_category,
    NULL::NUMERIC(18,2)               AS unit_cost_usd,
    TRUE                              AS is_active
FROM stg_transactions t
WHERE t.product_id IS NOT NULL
ON CONFLICT (product_id) DO UPDATE
SET
    product_name = EXCLUDED.product_name;
