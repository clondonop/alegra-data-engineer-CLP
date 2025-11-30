{{ config(materialized='view') }}

select
    subscription_id,
    customer_id,
    plan,
    status,
    start_date,
    end_date,
    monthly_price_usd,
    current_timestamp as load_timestamp
from {{ source('raw', 'subscriptions') }};
