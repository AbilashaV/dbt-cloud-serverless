{{ config(materialized="table") }}

with
    ride_summary as (
        select
            ride_id,
            rider_uuid,
            customer_id,
            trip_day,
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
                    - rec.discount
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
                        - rec.discount
                    ) - (
                        rider_system_fee
                        + rider_application_fee
                        + coalesce(driver_system_fee, 0.0)
                    )::float
                )::float
            ) as total_amount_owed_to_drivers,
            sum(rider_application_fee) as rider_app_fee,
            sum(amount) as total_amount_received,
            gateway,
            pay_status,
            ride_status,
            bse.idempotency_key as ride_key
        from {{ ref("a_rideEntity_creditCard_SG") }} rec
        left join {{ ref("c_transactions") }} bse on (ride_id = bse.idempotency_key)
        where
            rec.payment_method = 5
            and ride_status = 70
            and rec.region = 'SG'
        group by
            trip_day,
            ride_id,
            rider_uuid,
            customer_id,
            gateway,
            pay_status,
            ride_status,
            bse.idempotency_key
    )

select
    trip_day,
    ride_id,
    rider_uuid,
    customer_id,
    total_amount_to_receive,
    case
        when gateway = 'stripe' then total_amount_to_receive else 0
    end as total_amount_to_receive_stripe,
    case
        when gateway = 'adyen' then total_amount_to_receive else 0
    end as total_amount_to_receive_adyen,
    total_amount_owed_to_drivers,
    total_amount_received,
    rider_app_fee,
    pay_status,
    ride_status,
    ride_key

from ride_summary
