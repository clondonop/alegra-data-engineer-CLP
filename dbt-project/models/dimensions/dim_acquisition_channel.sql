{{ config(materialized='table') }}

with base as (
    select distinct
        initcap(trim(acquisition_channel)) as channel_name
    from {{ ref('stg_customers') }}
    where acquisition_channel is not null
)

select
    row_number() over (order by channel_name) as channel_key,
    channel_name,
    null::varchar(100)  as channel_category,
    null::numeric(18,2) as cost_per_acquisition_avg
from base;
