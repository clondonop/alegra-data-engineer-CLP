{{ config(materialized='table') }}

with base as (
    select distinct
        trim(product_id) as product_id
    from {{ ref('stg_transactions') }}
    where product_id is not null
)

select
    row_number() over (order by product_id) as product_key,
    product_id,
    initcap(product_id)         as product_name,
    null::varchar(100)          as product_type,
    null::varchar(100)          as product_category,
    null::numeric(18,2)         as unit_cost_usd,
    true                        as is_active
from base;
