{{ config(materialized='view') }}

select
    expense_id,
    date        as expense_date,
    provider,
    category,
    amount_usd,
    country,
    current_timestamp as load_timestamp
from {{ source('raw', 'expenses') }};
