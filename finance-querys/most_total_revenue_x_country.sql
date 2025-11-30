SELECT
    c.country_name,
    SUM(fs.total_usd) AS total_revenue_2024
FROM fact_sales fs
JOIN dim_date d
    ON fs.transaction_date_key = d.date_key
JOIN dim_country c
    ON fs.country_key = c.country_key
WHERE d.year = 2024
GROUP BY c.country_name
ORDER BY total_revenue_2024 DESC
LIMIT 1;
