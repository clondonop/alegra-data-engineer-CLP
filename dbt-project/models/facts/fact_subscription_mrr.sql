{{ config(
    materialized = 'incremental',
    unique_key   = ['date_key', 'subscription_key']
) }}

with snapshot_month as (
    select
        date_trunc('month', current_date - interval '1 month')::date as month_start
),

base as (
    select
        stg.subscription_id,
        stg.customer_id,
        stg.plan,
        stg.status,
        stg.start_date,
        stg.end_date,
        stg.monthly_price_usd,
        sm.month_start,

        -- date_key = YYYYMMDD del primer día del mes snapshot
        cast(to_char(sm.month_start, 'YYYYMMDD') as int) as date_key,

        -- Dimensiones SCD2 (versión vigente)
        dc.customer_key,
        dc.country_key,
        ds.subscription_key,

        -- MRR desde la suscripción
        stg.monthly_price_usd as mrr_usd,

        -- Flags:
        -- Activa en el snapshot
        case
            when stg.status = 'active' then 1
            else 0
        end as is_active_flag,

        -- Nueva en el mes del snapshot
        case
            when date_trunc('month', stg.start_date) = sm.month_start
            then 1 else 0
        end as is_new_flag,

        -- Churn en el mes del snapshot
        case
            when stg.status = 'cancelled'
             and stg.end_date is not null
             and date_trunc('month', stg.end_date) = sm.month_start
            then 1 else 0
        end as is_churned_flag

    from {{ ref('stg_subscriptions') }} stg
    cross join snapshot_month sm

    -- Dimensión cliente SCD2 (solo la versión vigente)
    inner join {{ ref('dim_customer_scd') }} dc
        on stg.customer_id = dc.customer_id
       and dc.dbt_valid_to is null

    -- Dimensión suscripción SCD2 (solo la versión vigente)
    inner join {{ ref('dim_subscription_scd') }} ds
        on stg.subscription_id = ds.subscription_id
       and ds.dbt_valid_to is null

    -- Misma condición del WHERE original:
    where stg.start_date < sm.month_start
),

final as (
    select
        date_key,
        customer_key,
        subscription_key,
        country_key,
        mrr_usd,
        is_active_flag,
        is_new_flag,
        is_churned_flag
    from base
)

select * from final

{% if is_incremental() %}
where date_key > coalesce(
    (select max(date_key) from {{ this }}),
    0
)
{% endif %}
;
