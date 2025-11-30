CREATE TABLE IF NOT EXISTS dim_employee (
    employee_key       BIGSERIAL PRIMARY KEY,
    employee_id        VARCHAR(100) UNIQUE,
    area               VARCHAR(100),
    salary_usd         NUMERIC(18,2),
    hire_date_key      INTEGER,
    country_key        INTEGER
);

MERGE INTO dim_employee AS target
USING (
    SELECT 
        e.employee_id,
        e.area,
        e.salary_usd,
        TO_CHAR(e.hire_date, 'YYYYMMDD')::INTEGER as hire_date_key,
        c.country_key
    FROM stg_employees e
    LEFT JOIN dim_country  c ON e.country_code = c.country_code
) AS source
ON target.employee_id = source.employee_id
WHEN MATCHED THEN
    UPDATE SET
        area = source.area,
        salary_usd = source.salary_usd,
        country_key = source.country_key
WHEN NOT MATCHED THEN
    INSERT (employee_key, employee_id, area, salary_usd, hire_date_key, country_key)
    VALUES (
        (SELECT COALESCE(MAX(employee_key), 0) + 1 FROM dim_employee),
        source.employee_id, source.area, source.salary_usd, 
        source.hire_date_key, source.country_key
    );