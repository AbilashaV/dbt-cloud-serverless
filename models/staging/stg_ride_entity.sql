SELECT
    *
FROM
    --{{source('ride_','ride_entity_0619')}}
    "dev"."tada_ride_service"."ride_entity"
--WHERE 
    --EXTRACT(YEAR FROM create_time::timestamp) = 2024
    --DATE_TRUNC('day', CAST(create_time AS timestamp)) >= '2024-05-01 00:00:00' AND  
    --DATE_TRUNC('day', CAST(create_time AS timestamp)) <= '2024-05-02 00:00:00'
