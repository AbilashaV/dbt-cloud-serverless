{{ config(materialized="table") }}


select
    account_id,
    idempotency_key,
    tr.created_at as created_at_utc,
    (tr.created_at::timestamp + interval '1 hour' * rg.timezone) as created_at_local,
    tr.updated_at as updated_at_utc,
    (tr.updated_at::timestamp + interval '1 hour' * rg.timezone) as updated_at_local,
    -- last_event_id,
    account_model,
    amount::NUMERIC(10, 2) as amount,
    channel,
    -- channel_account_name
    -- channel_identifier?
    -- channel_name
    currency,
    -- description
    discount::NUMERIC(10, 2) as discount,
    fraud,
    payment_method,
    tr.region,
    tr.status,
    type,
    unpaid_amount::NUMERIC(10, 2) as unpaid_amount
-- cash_out_synced_on_shb
-- shb_detached
-- admin_topup_category
-- reason
-- category_type
-- external_transaction_id
-- display_description_key
-- metadata
from {{ ref("src_transactions") }} tr
join {{ ref("regions") }} rg on tr.region = rg.country

