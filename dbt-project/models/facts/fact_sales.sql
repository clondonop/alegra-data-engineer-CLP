{{ config(
    materialized='incremental',
    unique_key='fact_sales_id'
) }}

with base as (
    select
        t.transaction_id,
        t.transaction_date,
        t.customer_id,
        t.product_id,
        t.quantity,
        t.unit_price_usd,
        t.total_usd,
        c.customer_key,
        p.product_key,
        co.country_key
    from {{ ref('stg_transactions') }} t
    join {{ ref('dim_customer') }} c
      on t.customer_id = c.customer_id
    join {{ ref('dim_product') }} p
      on t.product_id = p.product_id
    left join {{ ref('dim_country') }} co
      on initcap(trim(t.country)) = co.country_name
)

select
    {{ dbt_utils.generate_surrogate_key(['transaction_id', 'product_key', 'customer_key']) }} as fact_sales_id,
    cast(to_char(transaction_date, 'YYYYMMDD') as int) as transaction_date_key,
    customer_key,
    product_key,
    country_key,
    quantity,
    unit_price_usd,
    total_usd
from base

{% if is_incremental() %}
where transaction_date > (
    select coalesce(max(d.full_date), '1900-01-01'::date)
    from {{ this }} f
    join {{ ref('dim_date') }} d
      on f.transaction_date_key = d.date_key
)
{% endif %}
;
