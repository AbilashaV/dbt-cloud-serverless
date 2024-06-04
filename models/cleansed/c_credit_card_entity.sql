--{{config(materialized='table')}}

Select 
id as credit_card_id,
card_brand,
--card_last4,
country,
created_at as created_at_utc,
customer_id,
default_selected,
deleted_at as deleted_at_utc, 
exp_month,
exp_year,
--fingerprint,
fraud,
gateway,
issuer,
--source_id?
--threedsecured?,
updated_at as updated_at_utc,
--user_id
user_uuid,
uuid
--user_ip
--threedsecure_version?
--auth_flow_type
--bin
--corporate_id
from {{ ref("src_credit_card_entity")}}
