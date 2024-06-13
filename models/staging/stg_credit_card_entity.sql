select *
from  -- "dev"."prod_test"."credit_card_entity"
    {{ source("ride_", "credit_card_entity") }}
