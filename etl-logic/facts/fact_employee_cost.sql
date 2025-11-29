INSERT INTO FACT_EMPLOYEE_COST (
    fact_employee_cost_id, month_date_key, employee_key, country_key,
    salary_cost_usd, days_worked
)
SELECT 
    (SELECT COALESCE(MAX(fact_employee_cost_id), 0) + ROW_NUMBER() OVER (ORDER BY stg.employee_id)),
    TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month'), 'YYYYMMDD')::INTEGER as month_date_key,
    de.employee_key,
    de.country_key,
    de.salary_usd as salary_cost_usd,
    EXTRACT(DAY FROM DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month') 
        + INTERVAL '1 month' - INTERVAL '1 day') as days_worked
FROM stg_employees stg
INNER JOIN DIM_EMPLOYEE de ON stg.employee_id = de.employee_id
WHERE stg.status = 'active'
AND stg.hire_date < DATE_TRUNC('month', CURRENT_DATE);