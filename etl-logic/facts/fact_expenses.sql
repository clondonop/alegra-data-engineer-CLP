INSERT INTO FACT_EXPENSES (
    fact_expense_id, date_key, provider_key, expense_category_key,
    country_key, channel_key, amount_usd
)
SELECT 
    (SELECT COALESCE(MAX(fact_expense_id), 0) + ROW_NUMBER() OVER (ORDER BY stg.expense_id)),
    TO_CHAR(stg.expense_date, 'YYYYMMDD')::INTEGER as date_key,
    dp.provider_key,
    dec.expense_category_key,
    dco.country_key,
    dac.channel_key,
    stg.amount_usd
FROM stg_expenses stg
INNER JOIN DIM_PROVIDER dp ON stg.provider_name = dp.provider_name
INNER JOIN DIM_EXPENSE_CATEGORY dec ON stg.category = dec.category
LEFT JOIN DIM_COUNTRY dco ON stg.country_code = dco.country_code
LEFT JOIN DIM_ACQUISITION_CHANNEL dac ON stg.channel_name = dac.channel_name
WHERE stg.expense_date BETWEEN CURRENT_DATE - 7 AND CURRENT_DATE - 1
AND NOT EXISTS (
    SELECT 1 FROM FACT_EXPENSES f 
    WHERE f.date_key = TO_CHAR(stg.expense_date, 'YYYYMMDD')::INTEGER
    AND f.provider_key = dp.provider_key
    AND f.expense_category_key = dec.expense_category_key
);