INSERT INTO FACT_SALES (
    fact_sales_id, transaction_date_key, customer_key, product_key,
    country_key, payment_key, quantity, unit_price_usd, total_usd
)
SELECT 
    (SELECT COALESCE(MAX(fact_sales_id), 0) + ROW_NUMBER() OVER (ORDER BY stg.transaction_id)),
    TO_CHAR(stg.transaction_date, 'YYYYMMDD')::INTEGER as transaction_date_key,
    dc.customer_key,
    dp.product_key,
    dc.country_key,
    dpm.payment_method_key,
    stg.quantity,
    stg.unit_price_usd,
    stg.quantity * stg.unit_price_usd as total_usd
FROM stg_transactions stg
INNER JOIN DIM_CUSTOMER dc ON stg.customer_id = dc.customer_id 
    AND stg.transaction_date BETWEEN dc.effective_from_date AND dc.effective_to_date
INNER JOIN DIM_PRODUCT dp ON stg.product_id = dp.product_id
INNER JOIN DIM_PAYMENT_METHOD dpm ON stg.payment_method = dpm.method
WHERE stg.transaction_date = CURRENT_DATE - 1
AND NOT EXISTS (
    SELECT 1 FROM FACT_SALES f 
    WHERE f.transaction_date_key = TO_CHAR(stg.transaction_date, 'YYYYMMDD')::INTEGER
    AND f.customer_key = dc.customer_key
    AND f.product_key = dp.product_key
);