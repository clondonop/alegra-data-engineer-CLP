{% snapshot dim_customer_s %}
  {{ config(
      target_schema = 'analytics',         -- ajusta al schema destino
      unique_key    = 'customer_id',
      strategy      = 'check',
      check_cols    = ['segment', 'acquisition_channel', 'country']
  ) }}

  select
      customer_id,
      segment,
      acquisition_channel,
      country,
      registration_date
  from {{ ref('stg_customers') }}

{% endsnapshot %}
