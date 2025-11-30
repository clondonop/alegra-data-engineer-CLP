{{ config(materialized='view') }}

select
    payment_id,
    transaction_id,
    payment_date,
    method        as payment_method,
    amount_usd,
    current_timestamp as load_timestamp
from {{ source('raw', 'payments') }};
