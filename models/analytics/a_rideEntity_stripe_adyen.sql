WITH ride_summary AS (
    SELECT 
        ride_id, 
        rider_uuid,
        customer_id, 
        trip_day,
        SUM(
            (
                (ride_price + etc_fee + toll_fee + ride_option_fee + rider_system_fee + rider_application_fee + COALESCE(reservation_fee, 0.0) + rider_cancellation_fee) - discount
            )::float
        ) AS total_amount_to_receive,
        SUM(
            (
                ((ride_price + etc_fee + toll_fee + ride_option_fee + rider_system_fee + rider_application_fee + COALESCE(reservation_fee, 0.0) + rider_cancellation_fee) - discount) 
                - (rider_system_fee + rider_application_fee + COALESCE(driver_system_fee, 0.0))::float
            )::float
        ) AS total_amount_owed_to_drivers,
        SUM(rider_application_fee) AS rider_app_fee,
        SUM(amount) AS total_amount_received,
        gateway,
        pay_status, ride_status, bse.idempotency_key as ride_key
    FROM 
        {{ref("a_rideEntity_creditCard_SG")}} rec
    LEFT JOIN 
        {{ref("c_transactions")}} bse ON (ride_id = bse.idempotency_key)
    WHERE
        payment_method = 5
        AND ride_status = 70
        AND rec.region = 'SG'
        AND EXTRACT(YEAR FROM (re.create_time + INTERVAL '8 hour')) = 2024
    GROUP BY 
        trip_day, ride_id, rider_uuid, customer_id, gateway,pay_status, ride_status, bse.idempotency_key
)

SELECT 
    ride_id, 
    rider_uuid,
    customer_id, 
    source_id,
    trip_day,
    total_amount_to_receive,
    total_amount_owed_to_drivers,
    CASE 
        WHEN gateway = 'stripe' THEN total_amount_to_receive
        ELSE 0
    END AS total_amount_to_receive_stripe,
    CASE 
        WHEN gateway = 'adyen' THEN total_amount_to_receive
        ELSE 0
    END AS total_amount_to_receive_adyen,
    total_amount_received,
    rider_app_fee,
    pay_status, 
    ride_status,
    ride_key

FROM 
    ride_summary
