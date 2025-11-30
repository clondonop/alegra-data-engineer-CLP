{{ config(
    materialized='incremental',
    unique_key='fact_expense_id'
) }}

with base as (
    select
        e.expense_id,
        e.expense_date,
        e.amount_usd,
        p.provider_key,
        c.expense_category_key,
        co.country_key
    from {{ ref('stg_expenses') }} e
    join {{ ref('dim_provider') }} p
      on initcap(trim(e.provider)) = p.provider
    join {{ ref('dim_expense_category') }} c
      on initcap(trim(e.category)) = c.category
    left join {{ ref('dim_country') }} co
      on initcap(trim(e.country)) = co.country_name
    where c.category <> 'Payroll'
)

select
    {{ dbt_utils.generate_surrogate_key(['expense_id','provider_key','expense_category_key']) }} as fact_expense_id,
    cast(to_char(expense_date, 'YYYYMMDD') as int) as date_key,
    provider_key,
    expense_category_key,
    country_key,
    amount_usd
from base

{% if is_incremental() %}
where expense_date > (
    select coalesce(max(d.full_date), '1900-01-01'::date)
    from {{ this }} f
    join {{ ref('dim_date') }} d
      on f.date_key = d.date_key
)
{% endif %}
;
