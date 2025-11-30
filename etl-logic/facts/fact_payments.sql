CREATE TABLE IF NOT EXISTS fact_payments (
    fact_payment_id      BIGSERIAL PRIMARY KEY,
    payment_date_key     INTEGER        NOT NULL,
    transaction_key      VARCHAR(100)   NOT NULL,
    payment_method_key   BIGINT         NOT NULL,
    amount_usd           NUMERIC(18,2)  NOT NULL,

    CONSTRAINT fk_fpay_date
        FOREIGN KEY (payment_date_key)
        REFERENCES dim_date (date_key),

    CONSTRAINT fk_fpay_method
        FOREIGN KEY (payment_method_key)
        REFERENCES dim_payment_method (payment_method_key)
);

INSERT INTO fact_payments (
    fact_payment_id,
    payment_date_key,
    transaction_key,
    payment_method_key,
    amount_usd
)
SELECT 
    (SELECT COALESCE(MAX(fact_payment_id), 0)
            + ROW_NUMBER() OVER (ORDER BY stg.payment_id)
    )                                  AS fact_payment_id,
    TO_CHAR(stg.payment_date, 'YYYYMMDD')::INTEGER AS payment_date_key,
    stg.transaction_id                 AS transaction_key,
    dpm.payment_method_key,
    stg.amount_usd
FROM stg_payments stg
INNER JOIN dim_payment_method dpm
    ON stg.payment_method = dpm.method
WHERE stg.payment_date = CURRENT_DATE - INTERVAL '1 day'
  AND NOT EXISTS (
        SELECT 1
        FROM fact_payments f
        WHERE f.transaction_key = stg.transaction_id
    );
