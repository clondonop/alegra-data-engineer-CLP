{{ config(materialized='table') }}

with dates as (
    select
        day::date as full_date
    from generate_series('2020-01-01'::date, '2030-12-31'::date, interval '1 day') as day
)

select
    extract(year  from full_date)::int * 10000 +
    extract(month from full_date)::int * 100 +
    extract(day   from full_date)::int      as date_key,
    full_date,
    extract(year  from full_date)::int      as year,
    extract(month from full_date)::int      as month,
    to_char(full_date, 'YYYY-MM')           as year_month,
    to_char(full_date, 'Mon')               as month_name,
    extract(quarter from full_date)::int    as quarter
from dates;
