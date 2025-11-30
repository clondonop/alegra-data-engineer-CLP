CREATE TABLE IF NOT EXISTS fact_customer_acquisition (
    fact_customer_acq_id      BIGSERIAL PRIMARY KEY,   -- surrogate key para la fact

    customer_key              BIGINT NOT NULL,         -- FK a DIM_CUSTOMER
    acquisition_date_key      INTEGER NOT NULL,        -- FK a DIM_DATE (YYYYMMDD)
    acquisition_channel_key    BIGINT NOT NULL,         -- FK a DIM_ACQUISITION_CHANNEL
    country_key               BIGINT NOT NULL,         -- FK a DIM_COUNTRY

    acquired_customers        INTEGER NOT NULL DEFAULT 1,  


    created_at                TIMESTAMP DEFAULT NOW()
);

INSERT INTO fact_customer_acquisition (
    fact_customer_acq_id, customer_key, acquisition_date_key,
    acquisition_channel_key, country_key, acquired_customers
)
SELECT 
    (SELECT COALESCE(MAX(fact_customer_acq_id), 0) + ROW_NUMBER() OVER (ORDER BY stg.customer_id)),
    dc.customer_key,
    TO_CHAR(stg.registration_date, 'YYYYMMDD')::INTEGER as acquisition_date_key,
    dc.acquisition_channel_key, 
    dc.country_key,
    1 as acquired_customers
FROM stg_customers stg
INNER JOIN DIM_CUSTOMER dc ON stg.customer_id = dc.customer_id 
    AND dc.effective_from_date = stg.registration_date
    AND dc.is_current = TRUE
WHERE stg.registration_date = CURRENT_DATE - 1
AND NOT EXISTS (
    SELECT 1 FROM fact_customer_acquisition f 
    WHERE f.customer_key = dc.customer_key
);