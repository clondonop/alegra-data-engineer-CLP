SELECT
    SUM(fe.amount_usd) AS marketing_expenses_h1_2024
FROM fact_expenses fe
JOIN dim_date d
    ON fe.date_key = d.date_key
JOIN dim_expense_category c
    ON fe.expense_category_key = c.expense_category_key
WHERE d.year = 2024
  AND d.month BETWEEN 1 AND 6
  AND c.category ILIKE 'Marketing';
