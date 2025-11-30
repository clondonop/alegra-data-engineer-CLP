WITH marketing_cost AS (
    SELECT
        SUM(fe.amount_usd) AS marketing_expenses_2024
    FROM fact_expenses fe
    JOIN dim_date d
        ON fe.date_key = d.date_key
    JOIN dim_expense_category c
        ON fe.expense_category_key = c.expense_category_key
    WHERE d.year = 2024
      AND c.category ILIKE 'Marketing'
),
new_customers AS (
    SELECT
        SUM(fca.acquired_customers) AS new_customers_2024
    FROM fact_customer_acquisition fca
    JOIN dim_date d
        ON fca.acquisition_date_key = d.date_key
    WHERE d.year = 2024
)
SELECT
    marketing_expenses_2024
    / NULLIF(new_customers_2024, 0) AS cac_promedio_anual_2024
FROM marketing_cost, new_customers;
