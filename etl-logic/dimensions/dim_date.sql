CREATE TABLE IF NOT EXISTS dim_date (
    date_key        INTEGER PRIMARY KEY,     -- YYYYMMDD
    full_date       DATE NOT NULL,
    day             INTEGER,
    month           INTEGER,
    month_name      VARCHAR(20),
    quarter         INTEGER,
    year            INTEGER,
    week_of_year    INTEGER,
    is_month_end    BOOLEAN,
    is_weekend      BOOLEAN
);

INSERT INTO dim_date (date_key, full_date, year, month, day, quarter)
SELECT 
    TO_CHAR(date_value, 'YYYYMMDD')::INTEGER as date_key,
    date_value as full_date,
    EXTRACT(YEAR FROM date_value) as year,
    EXTRACT(MONTH FROM date_value) as month,
    EXTRACT(DAY FROM date_value) as day,
    CEIL(EXTRACT(MONTH FROM date_value) / 3.0) as quarter
FROM generate_series(
    '2020-01-01'::DATE,  #Modificable
    '2030-12-31'::DATE,  #Modificable
    '1 day'::INTERVAL
) as date_value;
