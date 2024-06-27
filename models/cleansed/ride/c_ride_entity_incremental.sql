{{
    config(
        materialized="incremental",
        unique_key ='ride_id'
    )
}}
select
    r.id as ride_id,
    assign_time::timestamp as assign_time_utc,
    (assign_time::timestamp + interval '1 hour' * rg.timezone) as assign_time_local,
    cancel_reason,
    crt.name as cancel_reason_type,
    ct.name as car_type,
    city,
    company_id,
    coupon_code,
    create_time::timestamp as create_time_utc,
    (create_time::timestamp + interval '1 hour' * rg.timezone) as create_time_local,
    credit_card_id,
    currency,
    ROUND(NULLIF(discount, 0)::numeric, 2) as discount,
    ROUND(NULLIF(driver_application_fee, 0)::numeric, 2) as driver_application_fee,
    driver_info,
    drop_off_time::timestamp as drop_off_time_utc,
    (drop_off_time::timestamp + interval '1 hour' * rg.timezone) as drop_off_time_local,
    ROUND(NULLIF(estimated_price, 0)::numeric, 2) as estimated_price,
    ROUND(NULLIF(etc_fee, 0)::numeric, 2) as etc_fee,
    ps.name as pay_status,
    pmt.name as payment_method,
    pick_up_arrived_time::timestamp as pick_up_arrived_time_utc,
    (pick_up_arrived_time::timestamp + interval '1 hour' * rg.timezone) as pick_up_arrived_time_local,
    --pick_up_distance_km,
    trunc(pick_up_distance_km, 2) as pick_up_distance_km,
    --ROUND(NULLIF(pick_up_distance_km, 0)::numeric, 2) AS pick_up_distance_km,
    pick_up_start_time::timestamp as pick_up_start_time_utc,
    (pick_up_start_time::timestamp + interval '1 hour' * rg.timezone) as pick_up_start_time_local,
    pick_up_zone_id,
    ROUND(NULLIF(refund_amount, 0)::numeric, 2) as refund_amount,
    region,
    --ride_distance_km,
    trunc(ride_distance_km, 2) as ride_distance_km,
    --ROUND(NULLIF(ride_distance_km, 0)::numeric, 2) AS ride_distance_km,
    ROUND(NULLIF(ride_price, 0)::numeric, 2) as ride_price,
    rs.name as ride_status,
    ROUND(NULLIF(rider_application_fee, 0)::numeric, 2) as rider_application_fee,
    rider_info,
    driver_uuid,
    rider_uuid,
    sd,
    start_time::timestamp as start_time_utc,
    (start_time::timestamp + interval '1 hour' * rg.timezone) as start_time_local,
    ROUND(NULLIF(toll_fee, 0)::numeric, 2) as toll_fee,
    way_point,
    fraud,
    destination_zone_id,
    equipments,
    rt.name as ride_type,
    --estimated_distance_km,
    trunc(estimated_distance_km, 2) as estimated_distance_km,
    --ROUND(NULLIF(estimated_distance_km, 0)::numeric, 2) AS estimated_distance_km,
    ad,
    destination,
    pick_up,
    additional_fares,
    ROUND(NULLIF(ride_option_fee, 0)::numeric, 2) as ride_option_fee,
    corporate_id,
    mdt,
    ROUND(NULLIF(driver_system_fee, 0)::numeric, 2) as driver_system_fee,
    ROUND(NULLIF(rider_system_fee, 0)::numeric, 2) as rider_system_fee,
    destination_h3_address,
    pick_up_h3_address,
    creator_info,
    creator_uuid,
    --estimated_pick_up_distance_km,
    trunc(estimated_pick_up_distance_km, 2) as estimated_pick_up_distance_km,
    --ROUND(NULLIF(estimated_pick_up_distance_km, 0)::numeric, 2) AS estimated_pick_up_distance_km,
    accident,
    ROUND(NULLIF(driver_cancellation_fee, 0)::numeric, 2) as driver_cancellation_fee,
    ROUND(NULLIF(rider_cancellation_fee, 0)::numeric, 2) as rider_cancellation_fee,
    rider_cancellation_reward,
    driver_cancellation_reward,
    reservation_ride_start_time::timestamp as reservation_ride_start_time_utc,
    (reservation_ride_start_time::timestamp + interval '1 hour' * rg.timezone) as reservation_ride_start_time_local,
    ROUND(NULLIF(reservation_fee, 0)::numeric, 2) as reservation_fee,
    ROUND(NULLIF(driver_penalty_fee, 0)::numeric, 2) as driver_penalty_fee,
    ROUND(NULLIF(rider_system_fee_tax, 0)::numeric, 2) as rider_system_fee_tax,
    ROUND(NULLIF(driver_system_fee_tax, 0)::numeric, 2) as driver_system_fee_tax,
    ROUND(NULLIF(creator_system_fee, 0)::numeric, 2) as creator_system_fee,
    ROUND(NULLIF(creator_system_fee_tax, 0)::numeric, 2) as creator_system_fee_tax,
    pick_up_h3_res15,
    destination_h3_res15,
    confirm_time::timestamp as confirm_time_utc,
    (confirm_time::timestamp + interval '1 hour' * rg.timezone) as confirm_time_local,
    payment_item_uuid,
    mdd,
    ROUND(NULLIF(rider_penalized_amount, 0)::numeric, 2) as rider_penalized_amount,
    --chat_url,
    --product_id,
    --promotion_id
from {{ ref("stg_ride_entity_refreshed") }} r
join {{ ref("ref_regions") }} rg on r.region = rg.country
left join {{ ref("ref_ride_status") }} rs on r.ride_status = rs.value
left join {{ ref("ref_cancel_reason_type") }} crt on r.cancel_reason_type = crt.value
left join {{ ref("ref_car_type") }} ct on r.car_type = ct.value
left join {{ ref("ref_pay_status") }} ps on r.pay_status = ps.value
left join {{ ref("ref_payment_method") }} pmt on r.payment_method = pmt.value
left join {{ ref("ref_ride_type") }} rt on r.ride_type = rt.value
--WHERE 
    --EXTRACT(YEAR FROM create_time::timestamp) < 2024
    --DATE_TRUNC('day', CAST(create_time AS timestamp)) >= '2024-05-01 00:00:00' AND  
    --DATE_TRUNC('day', CAST(create_time AS timestamp)) <= '2024-05-02 00:00:00'


{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  where create_time_utc >= (select max(create_time_utc)from {{ this }})
{% endif %}