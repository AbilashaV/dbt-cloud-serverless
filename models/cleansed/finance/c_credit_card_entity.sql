{{ 
    config(
        materialized='incremental',
        unique_key ='credit_card_id'
        ) 
}}

Select 
cce.id as credit_card_id,
card_brand,
--card_last4,
cce.country,
cce.created_at::timestamp as created_at_utc,
(cce.created_at::timestamp+ interval '1 hour' * rg.timezone) as created_at_local,
customer_id,
default_selected,
cce.deleted_at::timestamp as deleted_at_utc, 
(cce.deleted_at::timestamp+ interval '1 hour' * rg.timezone) as deleted_at_local,
exp_month,
exp_year,
--fingerprint,
fraud,
gateway,
issuer,
--source_id?
--threedsecured?,
cce.updated_at::timestamp as updated_at_utc,
(cce.updated_at::timestamp+ interval '1 hour' * rg.timezone) as updated_at_local,
--user_id
user_uuid,
uuid
--user_ip
--threedsecure_version?
--auth_flow_type
--bin
--corporate_id
from {{ ref("stg_credit_card_entity")}}  cce
join {{ ref("ref_regions") }} rg on cce.country = rg.country

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  where created_at_utc >= (select max(created_at_utc)from {{ this }})
{% endif %}
