SELECT * 
FROM --"dev"."prod_test"."transactions"
    {{source('ride_','transactions')}}