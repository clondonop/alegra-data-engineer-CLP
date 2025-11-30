WITH cash_in AS (
    SELECT
        SUM(fp.amount_usd) AS inflows
    FROM fact_payments fp
    JOIN dim_date d
        ON fp.payment_date_key = d.date_key
    WHERE d.year = 2024
      AND d.month = 12
),
cash_out_exp AS (
    SELECT
        SUM(fe.amount_usd) AS outflows_expenses
    FROM fact_expenses fe
    JOIN dim_date d
        ON fe.date_key = d.date_key
    WHERE d.year = 2024
      AND d.month = 12
),
cash_out_emp AS (
    SELECT
        SUM(fec.salary_cost_usd) AS outflows_employee
    FROM fact_employee_cost fec
    JOIN dim_date d
        ON fec.month_date_key = d.date_key
    WHERE d.year = 2024
      AND d.month = 12
)
SELECT
    ci.inflows
    - COALESCE(coe.outflows_expenses, 0)
    - COALESCE(coemp.outflows_employee, 0) AS fcf_dec_2024
FROM cash_in ci
LEFT JOIN cash_out_exp  coe   ON 1 = 1
LEFT JOIN cash_out_emp  coemp ON 1 = 1;
