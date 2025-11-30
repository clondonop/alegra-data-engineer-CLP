{{ config(materialized='table') }}

select
    {{ dbt_utils.generate_surrogate_key(['subscription_id','dbt_valid_from']) }} as subscription_key,
    subscription_id,
    plan,
    status,
    monthly_price_usd,
    cast(to_char(start_date, 'YYYYMMDD') as int) as start_date_key,
    cast(to_char(end_date, 'YYYYMMDD') as int) as end_date_key,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to,
    case when dbt_valid_to is null then true else false end as is_current
from {{ ref('dim_subscription_s') }};
