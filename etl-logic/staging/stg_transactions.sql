CREATE TABLE IF NOT EXISTS stg_transactions (
    transaction_id     VARCHAR(100),
    customer_id        VARCHAR(100),
    product_id         VARCHAR(100),
    date               DATE,
    country            VARCHAR(100),
    quantity           NUMERIC(18,4),
    unit_price_usd     NUMERIC(18,4),
    total_usd          NUMERIC(18,2)
);
