{{ config(materialized='view') }}

select
    customer_id,
    segment,
    acquisition_channel,
    country,
    registration_date,
    current_timestamp as load_timestamp
from {{ source('raw', 'customers') }};
