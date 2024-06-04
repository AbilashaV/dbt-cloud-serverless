WITH ride_entity_combi AS (
    SELECT 
    car_type,
coupon_code,
create_time_local,
creator_system_fee,
creator_system_fee_tax,
credit_card_id,
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
cce.customer_id, 
cce.source_id,
cce.gateway,
credit_card_id,
cce.created_at_utc,

cce.user_uuid,
cce.uuid
    FROM 
        {{ref("a_ride_entity")}} re
    LEFT JOIN 
        {{ref("c_credit_card_entity")}} cce ON (re.credit_card_id = cce.credit_card_id OR re.payment_item_uuid = cce.uuid)
    WHERE
        re.payment_method = 5
        AND re.ride_status = 70
        AND re.region = 'SG'
    GROUP BY 
        trip_day, re.id, re.rider_uuid, cce.customer_id, cce.source_id, cce.gateway,re.pay_status, re.ride_status
)

