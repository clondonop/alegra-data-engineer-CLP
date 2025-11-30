{{ config(materialized='table') }}

with base as (
    select distinct
        initcap(trim(payment_method)) as method
    from {{ ref('stg_payments') }}
    where payment_method is not null
)

select
    row_number() over (order by method) as payment_method_key,
    method
from base;
