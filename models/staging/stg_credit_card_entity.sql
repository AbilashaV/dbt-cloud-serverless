select *
from   {{ source("ride_", "credit_card_entity") }}
