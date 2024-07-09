
{{
    config(
        materialized="incremental",
        unique_key ='ride_id'
    )
}}

select
    r.id as ride_id,
    --app_meter,
    assign_time::timestamp as assign_time_utc,
    (assign_time::timestamp + interval '1 hour' * rg.timezone) as assign_time_local,
    --assigned_point,
    cancel_reason,
    crt.name as cancel_reason_type,
    ct.name as car_type,
    --cashout_request_id,
    --chat_url,
    city,
    company_id,
    coupon_code,
    create_time::timestamp as create_time_utc,
    (create_time::timestamp + interval '1 hour' * rg.timezone) as create_time_local,
    credit_card_id,
    currency,
    --destination_point,
    ROUND(NULLIF(discount::numeric(19,2), 0), 2) as discount,
    --dispatch_config_id,
    ROUND(NULLIF(driver_application_fee::numeric(19,2), 0), 2) as driver_application_fee,
    driver_info,
    --driver_rated,
    drop_off_time::timestamp as drop_off_time_utc,
    (drop_off_time::timestamp + interval '1 hour' * rg.timezone) as drop_off_time_local,
    ROUND(NULLIF(estimated_price::numeric(19,2), 0), 2) as estimated_price,
    ROUND(NULLIF(etc_fee::numeric(19,2), 0), 2) as etc_fee,
    ps.name as pay_status,
    pmt.name as payment_method,
    pick_up_arrived_time::timestamp as pick_up_arrived_time_utc,
    (pick_up_arrived_time::timestamp + interval '1 hour' * rg.timezone) as pick_up_arrived_time_local,
    --pick_up_address,
    trunc(pick_up_distance_km, 2) as pick_up_distance_km,
    --pick_up_name, pick_up_point
    pick_up_start_time::timestamp as pick_up_start_time_utc,
    (pick_up_start_time::timestamp + interval '1 hour' * rg.timezone) as pick_up_start_time_local,
    pick_up_zone_id,
    --qr_code, qr_text,
    ROUND(NULLIF(refund_amount::numeric(19,2), 0), 2) as refund_amount,
    region,
    trunc(ride_distance_km, 2) as ride_distance_km,
    --ride_distance_update_time,
    ROUND(NULLIF(ride_price::numeric(19,2), 0), 2) as ride_price,
    rs.name as ride_status,
    ROUND(NULLIF(rider_application_fee::numeric(19,2), 0), 2) as rider_application_fee,
    rider_info,
    driver_uuid,
    rider_uuid,
    --rider_note, rider_rated,
    sd,
    start_time::timestamp as start_time_utc,
    (start_time::timestamp + interval '1 hour' * rg.timezone) as start_time_local,
    ROUND(NULLIF(toll_fee::numeric(19,2), 0), 2) as toll_fee,
    way_point,
    product_id,
    fraud,
    --map_matched_distance_km,
    destination_zone_id,
    equipments,
    rt.name as ride_type,
    --target_point_list, way_point_list
    trunc(estimated_distance_km, 2) as estimated_distance_km,
    price_distance_modifier,
    ad,
    destination,
    pick_up,
    target_points,
    additional_fares,
    ROUND(NULLIF(ride_option_fee::numeric(19,2), 0), 2) as ride_option_fee,
    branch_id,
    corporate_id,
    department_id,
    mdt,
    ROUND(NULLIF(driver_system_fee::numeric(19,2), 0), 2) as driver_system_fee,
    ROUND(NULLIF(rider_system_fee::numeric(19,2), 0), 2) as rider_system_fee,
    assigned_point_h3_address,
    destination_h3_address,
    pick_up_h3_address,
    --corp_onetime_code,
    creator_info,
    creator_uuid,
    --driver_replied_eta, car_info, simple_id,
    trunc(estimated_pick_up_distance_km, 2) as estimated_pick_up_distance_km,
    accident,
    --point_transaction_id, used_point, pick_up_postal_code,destination_postal_code, 
    business_purpose,
    ROUND(NULLIF(driver_cancellation_fee::numeric(19,2), 0), 2) as driver_cancellation_fee,
    ROUND(NULLIF(rider_cancellation_fee::numeric(19,2), 0), 2) as rider_cancellation_fee,
    rider_cancellation_reward,
    driver_cancellation_reward,
    --driver_point_payment_amount, driver_point_transaction_id, ride_type_data,
    reservation_ride_start_time::timestamp as reservation_ride_start_time_utc,
    (reservation_ride_start_time::timestamp + interval '1 hour' * rg.timezone) as reservation_ride_start_time_local,
    ROUND(NULLIF(reservation_fee::numeric(19,2), 0), 2) as reservation_fee,
    ROUND(NULLIF(driver_penalty_fee::numeric(19,2), 0), 2) as driver_penalty_fee,
    ROUND(NULLIF(rider_system_fee_tax::numeric(19,2), 0), 2) as rider_system_fee_tax,
    ROUND(NULLIF(driver_system_fee_tax::numeric(19,2), 0), 2) as driver_system_fee_tax,
    ROUND(NULLIF(creator_system_fee::numeric(19,2), 0), 2) as creator_system_fee,
    ROUND(NULLIF(creator_system_fee_tax::numeric(19,2), 0), 2) as creator_system_fee_tax,
    pick_up_h3_res15,
    destination_h3_res15,
    --pick_up_arrived_point, pick_up_arrived_point_h3_address, 
    --target_points_zone_id, target_points_h3_address,previous_ride_id,
    confirm_time::timestamp as confirm_time_utc,
    (confirm_time::timestamp + interval '1 hour' * rg.timezone) as confirm_time_local,
    payment_item_uuid,
    mdd,
    ROUND(NULLIF(rider_penalized_amount::numeric(19,2), 0), 2) as rider_penalized_amount
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
