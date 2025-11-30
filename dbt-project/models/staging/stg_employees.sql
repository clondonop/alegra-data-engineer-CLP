{{ config(materialized='view') }}

select
    employee_id,
    area,
    salary_usd,
    hire_date,
    country,         -- asumiendo que viene así en raw
    current_timestamp as load_timestamp
from {{ source('raw', 'employees') }};
