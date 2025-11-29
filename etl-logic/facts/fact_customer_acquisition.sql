INSERT INTO FACT_CUSTOMER_ACQUISITION (
    fact_customer_acq_id, customer_key, acquisition_date_key,
    acquisition_channel_key, country_key, acquired_customers
)
SELECT 
    (SELECT COALESCE(MAX(fact_customer_acq_id), 0) + ROW_NUMBER() OVER (ORDER BY stg.customer_id)),
    dc.customer_key,
    TO_CHAR(stg.registration_date, 'YYYYMMDD')::INTEGER as acquisition_date_key,
    dc.acquisition_channel_key, -- Viene de DIM_CUSTOMER
    dc.country_key,
    1 as acquired_customers
FROM stg_customers stg
INNER JOIN DIM_CUSTOMER dc ON stg.customer_id = dc.customer_id 
    AND dc.effective_from_date = stg.registration_date
    AND dc.is_current = TRUE
WHERE stg.registration_date = CURRENT_DATE - 1
AND NOT EXISTS (
    SELECT 1 FROM FACT_CUSTOMER_ACQUISITION f 
    WHERE f.customer_key = dc.customer_key
);