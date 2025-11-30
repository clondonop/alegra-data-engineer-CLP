CREATE TABLE stg_payments (
    payment_id VARCHAR(50) PRIMARY KEY,
    transaction_id VARCHAR(50),
    payment_date DATE,
    method VARCHAR(50),
    amount_usd DECIMAL(12,2),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);