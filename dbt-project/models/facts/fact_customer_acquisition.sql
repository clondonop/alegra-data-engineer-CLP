{{ config(
    materialized='incremental',
    unique_key='fact_customer_acq_id'
) }}

with base as (
    select
        c.customer_id,
        c.registration_date,
        dc.customer_key,
        dc.acquisition_channel_key,
        dc.country_key
    from {{ ref('stg_customers') }} c
    join {{ ref('dim_customer') }} dc
      on c.customer_id = dc.customer_id
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_key','registration_date']) }} as fact_customer_acq_id,
    customer_key,
    cast(to_char(registration_date, 'YYYYMMDD') as int) as acquisition_date_key,
    acquisition_channel_key,
    country_key,
    1 as acquired_customers
from base

{% if is_incremental() %}
where registration_date > (
    select coalesce(max(d.full_date), '1900-01-01'::date)
    from {{ this }} f
    join {{ ref('dim_date') }} d
      on f.acquisition_date_key = d.date_key
)
{% endif %}
;
