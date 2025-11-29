MERGE INTO DIM_EMPLOYEE AS target
USING (
    SELECT 
        e.employee_id,
        e.area,
        e.salary_usd,
        TO_CHAR(e.hire_date, 'YYYYMMDD')::INTEGER as hire_date_key,
        c.country_key
    FROM stg_employees e
    LEFT JOIN DIM_COUNTRY c ON e.country_code = c.country_code
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
        (SELECT COALESCE(MAX(employee_key), 0) + 1 FROM DIM_EMPLOYEE),
        source.employee_id, source.area, source.salary_usd, 
        source.hire_date_key, source.country_key
    );