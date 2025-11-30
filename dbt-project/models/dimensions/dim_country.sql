{{ config(materialized='table') }}

with union_countries as (
    select country from {{ ref('stg_customers') }}
    union
    select country from {{ ref('stg_employees') }}
    union
    select country from {{ ref('stg_transactions') }}
    union
    select country from {{ ref('stg_expenses') }}
),

cleaned as (
    select distinct
        initcap(trim(country)) as country_name
    from union_countries
    where country is not null
)

select
    row_number() over (order by country_name) as country_key,
    country_name,
    null::varchar(10)  as country_code,
    null::varchar(100) as region,
    null::varchar(50)  as continent
from cleaned;
