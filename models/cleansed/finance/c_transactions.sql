{{
    config(
        materialized="incremental",
        unique_key=["account_id", "created_at_utc"],
        incremental_strategy="delete+insert",
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
    -- cast(amount as float) as amount,
    round(nullif(amount::numeric(19, 2), 0), 2) as amount,
    channel,
    -- channel_account_name
    -- channel_identifier?
    -- channel_name
    currency,
    description,
    -- CAST(discount As float) as discount,
    round(nullif(discount::numeric(19, 2), 0), 2) as discount,
    fraud,
    pmt.name as payment_method,
    tr.region,
    ts.name as transaction_status,
    tt.name as transaction_type,
    -- cast(unpaid_amount AS float) as unpaid_amount,
    round(nullif(unpaid_amount::numeric(19, 2), 0), 2) as unpaid_amount,
    -- cash_out_synced_on_shb
    -- shb_detached
    -- admin_topup_category
    -- reason
    -- category_type                              
    -- external_transaction_id
    display_description_key,
    metadata
from {{ ref("stg_transactions") }} tr
join {{ ref("ref_regions") }} rg on tr.region = rg.country

left join {{ ref("ref_payment_method") }} pmt on tr.payment_method = pmt.value
left join {{ ref("ref_transaction_type") }} tt on tr.type = tt.value
left join {{ ref("ref_transaction_status") }} ts on tr.status = ts.value

{% if is_incremental() %}
  -- This filter will only be applied on an incremental run
  where created_at_utc >= (select max(created_at_utc) from {{ this }}) or created_at_utc >= current_date - interval '2 days'
{% endif %}
