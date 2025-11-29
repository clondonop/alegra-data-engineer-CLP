INSERT INTO FACT_SUBSCRIPTION_MRR (
    fact_subscription_mrr_id, date_key, customer_key, subscription_key, 
    country_key, mrr_usd, is_active_flag, is_new_flag, is_churned_flag
)
SELECT 
    (SELECT COALESCE(MAX(fact_subscription_mrr_id), 0) + ROW_NUMBER() OVER (ORDER BY stg.subscription_id)),
    TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month'), 'YYYYMMDD')::INTEGER as date_key,
    dc.customer_key,
    ds.subscription_key,
    dc.country_key,
    ds.monthly_price_usd as mrr_usd,
    CASE WHEN stg.status = 'active' THEN 1 ELSE 0 END as is_active_flag,
    CASE 
        WHEN DATE_TRUNC('month', stg.start_date) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
        THEN 1 ELSE 0 
    END as is_new_flag,
    CASE 
        WHEN stg.status = 'cancelled' 
        AND DATE_TRUNC('month', stg.end_date) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
        THEN 1 ELSE 0 
    END as is_churned_flag
FROM stg_subscriptions stg
INNER JOIN DIM_CUSTOMER dc ON stg.customer_id = dc.customer_id AND dc.is_current = TRUE
INNER JOIN DIM_SUBSCRIPTION ds ON stg.subscription_id = ds.subscription_id AND ds.is_current = TRUE
WHERE stg.start_date < DATE_TRUNC('month', CURRENT_DATE);