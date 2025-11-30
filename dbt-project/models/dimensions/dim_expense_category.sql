{{ config(materialized='table') }}

with base as (
    select distinct
        initcap(trim(category)) as category
    from {{ ref('stg_expenses') }}
    where category is not null
)

select
    row_number() over (order by category) as expense_category_key,
    category
from base;
