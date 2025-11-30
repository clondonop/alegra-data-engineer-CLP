SELECT
    COALESCE(SUM(f.acquired_customers), 0) AS new_customers_q1_2024
FROM fact_customer_acquisition f
JOIN dim_date d
    ON f.acquisition_date_key = d.date_key
WHERE d.year = 2024
  AND d.quarter = 1;
