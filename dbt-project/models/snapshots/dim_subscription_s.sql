{% snapshot dim_subscription_s %}
  {{ config(
      target_schema='analytics',
      unique_key='subscription_id',
      strategy='check',
      check_cols=['plan','status','monthly_price_usd']
  ) }}

  select
      subscription_id,
      plan,
      status,
      monthly_price_usd,
      start_date,
      end_date
  from {{ ref('stg_subscriptions') }}

{% endsnapshot %}
