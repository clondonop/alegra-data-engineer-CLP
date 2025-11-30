{{ config(
    materialized='incremental',
    unique_key='fact_employee_cost_id'
) }}

with month_ref as (
    select
        date_trunc('month', current_date - interval '1 month')::date as month_start
),

base as (
    select
        s.employee_id,
        m.month_start,
        e.employee_key,
        e.country_key,
        e.salary_usd
    from month_ref m
    join {{ ref('stg_employees') }} s
      on s.hire_date < m.month_start
    join {{ ref('dim_employee') }} e
      on s.employee_id = e.employee_id
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['employee_key','month_start']) }} as fact_employee_cost_id,
        cast(to_char(month_start, 'YYYYMMDD') as int) as month_date_key,
        employee_key,
        country_key,
        salary_usd as salary_cost_usd,
        extract(day from (month_start + interval '1 month' - interval '1 day'))::int as days_worked
    from base
)

select * from final
