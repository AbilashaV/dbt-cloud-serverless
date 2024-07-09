
{{
    config(
        materialized="incremental",
        unique_key ='ride_id'
    )
}}

with _ridefinance as (
select distinct
    create_time_local,
    car_type,
    coupon_code,
    --promotion_id,
    sum(creator_system_fee) as creator_system_fee,
    sum(creator_system_fee_tax) as creator_system_fee_tax,
    credit_card_id,
    sum(discount) as discount,
    sum(driver_application_fee) as driver_application_fee,
    sum(driver_cancellation_fee) as driver_cancellation_fee,
    driver_cancellation_reward,
    sum(driver_system_fee) as driver_system_fee,
    sum(driver_system_fee_tax) as driver_system_fee_tax,
    driver_uuid,
    drop_off_time_local,
    sum(estimated_price) as estimated_price,
    sum(etc_fee) as etc_fee,
    ride_id,
    pay_status,
    payment_item_uuid,
    payment_method,
    region,
    sum(reservation_fee) as reservation_fee,
    sum(ride_option_fee) as ride_option_fee,
    sum(ride_price) as ride_price,
    ride_status,
    ride_type,
    sum(rider_application_fee) as rider_application_fee,
    sum(rider_cancellation_fee) as rider_cancellation_fee,
    sum(rider_system_fee) as rider_system_fee,
    sum(rider_system_fee_tax) as rider_system_fee_tax,
    rider_uuid,
    sum(toll_fee) as toll_fee,
    sum(
        (
            (
                ride_price
                + etc_fee
                + toll_fee
                + ride_option_fee
                + rider_system_fee
                + rider_application_fee
                + coalesce(reservation_fee, 0.0)
                + rider_cancellation_fee
            )
            - re.discount
        )::float
    ) as total_amount_to_receive,
    sum(
        (
            (
                (
                    ride_price
                    + etc_fee
                    + toll_fee
                    + ride_option_fee
                    + rider_system_fee
                    + rider_application_fee
                    + coalesce(reservation_fee, 0.0)
                    + rider_cancellation_fee
                )
                - re.discount
            ) - (
                rider_system_fee
                + rider_application_fee
                + coalesce(driver_system_fee, 0.0)
            )::float
        )::float
    ) as total_amount_owed_to_drivers

from {{ ref("c_ride_entity_incremental") }} re
where 
re.rider_uuid is not null
and re.driver_uuid is not null
and drop_off_time_local is not null
group by 
create_time_local,
    car_type,
    coupon_code,
    credit_card_id,
    driver_uuid,
    drop_off_time_local,
    ride_id,
    pay_status,
    payment_item_uuid,
    payment_method,
    region,
    ride_status,
    ride_type,
rider_uuid,
driver_cancellation_reward
)

select * from _ridefinance

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  where create_time_local >= (select max(create_time_local)from {{ this }})
{% endif %}
