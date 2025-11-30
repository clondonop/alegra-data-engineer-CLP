CREATE TABLE IF NOT EXISTS dim_payment_method (
    payment_method_key   BIGSERIAL PRIMARY KEY,
    method               VARCHAR(200) UNIQUE
);

INSERT INTO dim_payment_method (payment_method_key, method)
SELECT 
    (SELECT COALESCE(MAX(payment_method_key), 0) + ROW_NUMBER() OVER (ORDER BY method)),
    method
FROM stg_payments
WHERE method NOT IN (SELECT method FROM dim_payment_method);
