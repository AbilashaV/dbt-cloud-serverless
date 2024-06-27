{{ 
    config(
        materialized='incremental',
        unique_key ='account_id'
        ) 
}}

select
    account_id,
    idempotency_key,
    tr.created_at as created_at_utc,
    (tr.created_at::timestamp + interval '1 hour' * rg.timezone) as created_at_local,
    tr.updated_at as updated_at_utc,
    (tr.updated_at::timestamp + interval '1 hour' * rg.timezone) as updated_at_local,
    -- last_event_id,
    account_model,
    cast(amount as float) as amount,
    channel,
    -- channel_account_name
    -- channel_identifier?
    -- channel_name
    currency,
    -- description
    CAST(discount As float) as discount,
    fraud,
    payment_method,
    tr.region,
    tr.status,
    type,
    cast(unpaid_amount AS float) as unpaid_amount
-- cash_out_synced_on_shb
-- shb_detached
-- admin_topup_category
-- reason
-- category_type
-- external_transaction_id
-- display_description_key
-- metadata
from {{ ref("stg_transactions") }} tr
join {{ ref("ref_regions") }} rg on tr.region = rg.country


{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  where created_at_utc >= (select max(created_at_utc)from {{ this }})
{% endif %}
