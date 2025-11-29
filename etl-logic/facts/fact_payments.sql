INSERT INTO FACT_PAYMENTS (
    fact_payment_id, payment_date_key, transaction_key, customer_key,
    payment_method_key, country_key, amount_usd
)
SELECT 
    (SELECT COALESCE(MAX(fact_payment_id), 0) + ROW_NUMBER() OVER (ORDER BY stg.payment_id)),
    TO_CHAR(stg.payment_date, 'YYYYMMDD')::INTEGER as payment_date_key,
    stg.transaction_id as transaction_key,
    dc.customer_key,
    dpm.payment_method_key,
    dc.country_key,
    stg.amount_usd
FROM stg_payments stg
INNER JOIN DIM_CUSTOMER dc ON stg.customer_id = dc.customer_id 
    AND stg.payment_date BETWEEN dc.effective_from_date AND dc.effective_to_date
INNER JOIN DIM_PAYMENT_METHOD dpm ON stg.payment_method = dpm.method
WHERE stg.payment_date = CURRENT_DATE - 1
AND NOT EXISTS (
    SELECT 1 FROM FACT_PAYMENTS f WHERE f.transaction_key = stg.transaction_id
);