{{ config(materialized='view') }}

select
    transaction_id,
    customer_id,
    product_id,
    date       as transaction_date,
    country,
    quantity,
    unit_price_usd,
    total_usd,
    current_timestamp as load_timestamp
from {{ source('raw', 'transactions') }};
