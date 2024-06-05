{{config(materialized='table')}}

select
    create_time_local,
    car_type,
    coupon_code,
    creator_system_fee,
    creator_system_fee_tax,
    re.credit_card_id,
    discount,
    driver_application_fee,
    driver_cancellation_fee,
    driver_cancellation_reward,
    driver_system_fee,
    driver_system_fee_tax,
    re.driver_uuid,
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
    cce.customer_id,
    cce.gateway,
    --cce.created_at_utc,
    cce.user_uuid,
    cce.uuid
from {{ ref("c_ride_entity") }} re
left join
    {{ ref("c_credit_card_entity") }} cce
    on (re.credit_card_id = cce.credit_card_id or re.payment_item_uuid = cce.uuid)
where re.payment_method = 5 and re.ride_status = 70 and re.region = 'SG'

