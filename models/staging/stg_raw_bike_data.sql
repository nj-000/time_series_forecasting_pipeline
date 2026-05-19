{{ config(
    materialized='view',
    tags=['staging']
) }}

SELECT
    -- Primary key & dates
    dteday as date,
    CAST(dteday AS DATE) as date_key,
    
    -- Metrics
    CAST(cnt AS INT64) as total_rentals,
    CAST(casual AS INT64) as casual_users,
    CAST(registered AS INT64) as registered_users,
    
    -- Features
    CAST(temp AS FLOAT64) as temperature_normalized,
    CAST(atemp AS FLOAT64) as feels_like_temp_normalized,
    CAST(hum AS FLOAT64) as humidity_normalized,
    CAST(windspeed AS FLOAT64) as windspeed_normalized,
    CAST(weathersit AS INT64) as weather_code,
    CAST(holiday AS INT64) as is_holiday,
    CAST(weekday AS INT64) as day_of_week,
    CAST(workingday AS INT64) as is_working_day,
    CAST(yr AS INT64) as year,
    CAST(mnth AS INT64) as month,
    CAST(season AS INT64) as season_code,
    
    -- Metadata
    CURRENT_TIMESTAMP() as loaded_at

FROM {{ source('dev', 'raw_bike_data') }}

WHERE dteday IS NOT NULL
  AND cnt IS NOT NULL
  AND cnt > 0