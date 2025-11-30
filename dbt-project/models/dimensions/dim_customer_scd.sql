{{ config(materialized='table') }}

with scd as (
    select
        customer_id,
        segment,
        acquisition_channel,
        country,
        registration_date,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('dim_customer_s') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'dbt_valid_from']) }} as customer_key,
    customer_id,
    segment,
    acquisition_channel,
    country,
    cast(to_char(registration_date, 'YYYYMMDD') as int) as registration_date_key,
    dbt_valid_from as valid_from,
    dbt_valid_to   as valid_to,
    case when dbt_valid_to is null then true else false end as is_current
from scd;
