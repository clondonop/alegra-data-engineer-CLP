CREATE TABLE IF NOT EXISTS dim_expense_category (
    expense_category_key   BIGSERIAL PRIMARY KEY,
    category               VARCHAR(200) UNIQUE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_expense_category
    ON dim_expense_category (category);

INSERT INTO dim_expense_category (
    category
)
SELECT DISTINCT
    INITCAP(TRIM(e.category)) AS category
FROM stg_expenses e
WHERE e.category IS NOT NULL
ON CONFLICT (category) DO NOTHING;
