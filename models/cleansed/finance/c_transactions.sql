{{ 
    config(
        materialized='table'
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
    --cast(amount as float) as amount,
    ROUND(NULLIF(amount::numeric(19,2), 0), 2) as amount,
    channel,
    -- channel_account_name
    -- channel_identifier?
    -- channel_name
    currency,
    -- description
    --CAST(discount As float) as discount,
    ROUND(NULLIF(discount::numeric(19,2), 0), 2) as discount,
    fraud,
    payment_method,
    tr.region,
    tr.status,
    type,
    --cast(unpaid_amount AS float) as unpaid_amount,
    ROUND(NULLIF(unpaid_amount::numeric(19,2), 0), 2) as unpaid_amount
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

