SELECT
    *
FROM
    "dev"."prod_test"."ride_entity"
WHERE 
    DATE_TRUNC('day', CAST(create_time AS timestamp)) >= '2024-05-01 00:00:00' AND  
    DATE_TRUNC('day', CAST(create_time AS timestamp)) <= '2024-05-02 00:00:00'