{{ config(materialized='table') }}

with base as (
    select distinct
        initcap(trim(provider)) as provider
    from {{ ref('stg_expenses') }}
    where provider is not null
)

select
    row_number() over (order by provider) as provider_key,
    provider
from base;
