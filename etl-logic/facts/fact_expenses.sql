CREATE TABLE IF NOT EXISTS fact_expenses (
    fact_expense_id        BIGSERIAL PRIMARY KEY,     -- surrogate key
    
    date_key               INTEGER NOT NULL,          -- FK a DIM_DATE (YYYYMMDD)
    provider_key           BIGINT NOT NULL,           -- FK a DIM_PROVIDER
    expense_category_key   BIGINT NOT NULL,           -- FK a DIM_EXPENSE_CATEGORY
    country_key            BIGINT,                    -- FK a DIM_COUNTRY (NULL si no aplica)

    amount_usd             NUMERIC(18,2) NOT NULL,    -- monto del gasto

    created_at             TIMESTAMP DEFAULT NOW()    -- auditoría opcional
);

INSERT INTO fact_expenses ( 
    fact_expense_id, date_key, provider_key, expense_category_key,
    country_key, amount_usd
)
SELECT 
    (SELECT COALESCE(MAX(fact_expense_id), 0)
            + ROW_NUMBER() OVER (ORDER BY stg.expense_id)
    ) AS fact_expense_id,
    TO_CHAR(stg.expense_date, 'YYYYMMDD')::INTEGER AS date_key,
    dp.provider_key,
    dec.expense_category_key,
    dco.country_key,
    stg.amount_usd
FROM stg_expenses stg
INNER JOIN dim_provider dp
    ON stg.provider = dp.provider
INNER JOIN dim_expense_category dec
    ON stg.category = dec.category
LEFT JOIN dim_country dco
    ON stg.country = dco.country_name
WHERE stg.expense_date BETWEEN CURRENT_DATE - INTERVAL '7 days'
                           AND CURRENT_DATE - INTERVAL '1 day'
  AND dec.category <> 'Payroll'; 