CREATE TABLE stg_subscriptions (
    subscription_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    plan VARCHAR(50),
    status VARCHAR(20), -- 'active', 'cancelled', 'paused'
    monthly_price_usd DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);