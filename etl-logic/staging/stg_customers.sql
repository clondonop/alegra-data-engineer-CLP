CREATE TABLE stg_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    segment VARCHAR(50),
    acquisition_channel VARCHAR(100),
    country VARCHAR(100),
    registration_date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);