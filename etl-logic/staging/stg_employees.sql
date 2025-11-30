CREATE TABLE stg_employees (
    employee_id VARCHAR(50) PRIMARY KEY,
    area VARCHAR(100),
    salary_usd DECIMAL(10,2),
    hire_date DATE,
    country VARCHAR(100),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);