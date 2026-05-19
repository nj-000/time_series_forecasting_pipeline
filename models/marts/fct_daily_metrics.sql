{{ config(
    materialized='table',
    tags=['mart', 'forecasting']
) }}

WITH staging AS (
    SELECT * FROM {{ ref('stg_raw_bike_data') }}
),

daily_data AS (
    SELECT
        -- Keys
        date,
        DATE(date) as date_key,
        
        -- Metrics
        total_rentals,
        casual_users,
        registered_users,
        ROUND(casual_users / NULLIF(total_rentals, 0), 4) as casual_pct,
        ROUND(registered_users / NULLIF(total_rentals, 0), 4) as registered_pct,
        
        -- Features
        temperature_normalized,
        feels_like_temp_normalized,
        humidity_normalized,
        windspeed_normalized,
        weather_code,
        is_holiday,
        day_of_week,
        is_working_day,
        year,
        month,
        season_code,
        
        -- 7-day rolling metrics
        ROUND(
            AVG(total_rentals) OVER (
                ORDER BY date 
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ),
            2
        ) as rentals_7day_avg,
        
        ROUND(
            STDDEV(total_rentals) OVER (
                ORDER BY date 
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ),
            2
        ) as rentals_7day_std,
        
        -- 30-day rolling metrics
        ROUND(
            AVG(total_rentals) OVER (
                ORDER BY date 
                ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
            ),
            2
        ) as rentals_30day_avg,
        
        -- Lag features (previous periods)
        LAG(total_rentals, 1) OVER (ORDER BY date) as rentals_lag_1,
        LAG(total_rentals, 7) OVER (ORDER BY date) as rentals_lag_7,
        LAG(total_rentals, 30) OVER (ORDER BY date) as rentals_lag_30,
        LAG(total_rentals, 365) OVER (ORDER BY date) as rentals_lag_365,
        
        -- Trend
        ROW_NUMBER() OVER (ORDER BY date) as day_number,
        
        -- Data quality
        CURRENT_TIMESTAMP() as dbt_loaded_at
        
    FROM staging
),

final AS (
    SELECT
        *,
        
        -- Growth rates
        ROUND(
            (total_rentals - rentals_lag_1) / NULLIF(rentals_lag_1, 0),
            4
        ) as rentals_daily_growth,
        
        ROUND(
            (total_rentals - rentals_lag_7) / NULLIF(rentals_lag_7, 0),
            4
        ) as rentals_weekly_growth,
        
        -- Detect outliers (>2 std devs from 7-day mean)
        CASE
            WHEN ABS(total_rentals - rentals_7day_avg) > (2 * rentals_7day_std)
            THEN 1
            ELSE 0
        END as is_outlier
        
    FROM daily_data
)

SELECT * FROM final