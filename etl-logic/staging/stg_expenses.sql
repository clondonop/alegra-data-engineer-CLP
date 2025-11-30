CREATE TABLE stg_expenses (
    expense_id VARCHAR(50) PRIMARY KEY,
    expense_date DATE,
    provider_name VARCHAR(200),
    category VARCHAR(100),
    country VARCHAR(100),
    amount_usd DECIMAL(12,2),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);