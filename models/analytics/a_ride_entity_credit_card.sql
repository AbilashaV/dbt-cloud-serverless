{{ 
    config(
        materialized='incremental',
        unique_key ='ride_id'
        ) 
}}


with rides_ as (
select
    create_time_local,
    car_type,
    coupon_code,
    --promotion_id,
    --product_id,
    creator_system_fee,
    creator_system_fee_tax,
    re.credit_card_id,
    discount,
    driver_application_fee,
    driver_cancellation_fee,
    driver_cancellation_reward,
    driver_system_fee,
    driver_system_fee_tax,
    driver_uuid,
    drop_off_time_local,
    estimated_price,
    etc_fee,
    ride_id,
    pay_status,
    payment_item_uuid,
    payment_method,
    region,
    reservation_fee,
    ride_option_fee,
    ride_price,
    ride_status,
    ride_type,
    rider_application_fee,
    rider_cancellation_fee,
    rider_system_fee,
    rider_system_fee_tax,
    rider_uuid,
    toll_fee,
    total_amount_to_receive,
    total_amount_owed_to_drivers,
    cce.customer_id,
    cce.gateway,
    cce.created_at_utc,
    cce.user_uuid,
    cce.uuid

from {{ ref("a_ride_entity_finance") }} re
left join
    {{ ref("c_credit_card_entity") }} cce
    on (re.credit_card_id = cce.credit_card_id or re.payment_item_uuid = cce.uuid)

where 
    re.payment_method = 'CREDITCARD' 
    and re.region ='SG'
    and re.ride_status = 'FINISHED'
    and EXTRACT(YEAR FROM create_time_local::timestamp) = 2024 
    and EXTRACT(MONTH FROM create_time_local::timestamp) = 5
)

select * from rides_

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  where create_time_local >= (select max(create_time_local)from {{ this }})
{% endif %}