CREATE TABLE IF NOT EXISTS fact_employee_cost (
    fact_employee_cost_id   BIGSERIAL PRIMARY KEY,   -- surrogate key de la fact

    month_date_key          INTEGER NOT NULL,        -- FK a DIM_DATE (primer día del mes, YYYYMMDD)
    employee_key            BIGINT NOT NULL,         -- FK a DIM_EMPLOYEE
    country_key             BIGINT NOT NULL,         -- FK a DIM_COUNTRY

    salary_cost_usd         NUMERIC(18,2) NOT NULL,  -- costo mensual del empleado
    days_worked             INTEGER NOT NULL,        -- días del mes considerados (28-31 típicamente)

    created_at              TIMESTAMP DEFAULT NOW()  -- auditoría opcional
);

INSERT INTO fact_employee_cost (
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
INNER JOIN dim_employee de ON stg.employee_id = de.employee_id
WHERE stg.hire_date < DATE_TRUNC('month', CURRENT_DATE);