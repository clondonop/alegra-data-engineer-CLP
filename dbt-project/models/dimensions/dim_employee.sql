{{ config(materialized='table') }}

with base as (
    select
        e.employee_id,
        e.area,
        e.salary_usd,
        e.hire_date,
        c.country_key
    from {{ ref('stg_employees') }} e
    left join {{ ref('dim_country') }} c
        on initcap(trim(e.country)) = c.country_name
)

select
    row_number() over (order by employee_id) as employee_key,
    employee_id,
    area,
    salary_usd,
    cast(to_char(hire_date, 'YYYYMMDD') as int) as hire_date_key,
    country_key
from base;
