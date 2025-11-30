CREATE TABLE IF NOT EXISTS fact_sales (
    fact_sales_id          BIGSERIAL PRIMARY KEY,     -- surrogate key

    transaction_date_key   INTEGER NOT NULL,           -- FK a DIM_DATE (YYYYMMDD)
    customer_key           BIGINT NOT NULL,            -- FK a DIM_CUSTOMER
    product_key            BIGINT NOT NULL,            -- FK a DIM_PRODUCT
    country_key            BIGINT NOT NULL,            -- FK a DIM_COUNTRY

    quantity               NUMERIC(18,2) NOT NULL,
    unit_price_usd         NUMERIC(18,2) NOT NULL,
    total_usd              NUMERIC(18,2) NOT NULL,

    created_at             TIMESTAMP DEFAULT NOW()     -- auditoría opcional
);

INSERT INTO FACT_SALES (
    fact_sales_id,
    transaction_date_key,
    customer_key,
    product_key,
    country_key,
    quantity,
    unit_price_usd,
    total_usd
)
SELECT 
    (SELECT COALESCE(MAX(fact_sales_id), 0)
            + ROW_NUMBER() OVER (ORDER BY stg.transaction_id)
    ) AS fact_sales_id,
    TO_CHAR(stg.transaction_date, 'YYYYMMDD')::INTEGER AS transaction_date_key,
    dc.customer_key,
    dp.product_key,
    dc.country_key,
    stg.quantity,
    stg.unit_price_usd,
    stg.quantity * stg.unit_price_usd AS total_usd
FROM stg_transactions stg
INNER JOIN dim_customer dc
    ON stg.customer_id = dc.customer_id 
   AND stg.transaction_date BETWEEN dc.effective_from_date
                               AND dc.effective_to_date
INNER JOIN dim_product dp
    ON stg.product_id = dp.product_id
WHERE stg.transaction_date = CURRENT_DATE - INTERVAL '1 day'
  AND NOT EXISTS (
        SELECT 1
        FROM fact_sales f 
        WHERE f.transaction_date_key = TO_CHAR(stg.transaction_date, 'YYYYMMDD')::INTEGER
          AND f.customer_key         = dc.customer_key
          AND f.product_key          = dp.product_key
    );
