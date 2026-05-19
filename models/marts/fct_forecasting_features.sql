{{ config(
    materialized='table',
    tags=['forecasting']
) }}

WITH base AS (
    SELECT
        date,
        total_rentals as revenue,  -- This is what ARIMA will forecast
        
        -- Time features
        EXTRACT(YEAR FROM date) as year,
        EXTRACT(MONTH FROM date) as month,
        EXTRACT(QUARTER FROM date) as quarter,
        EXTRACT(DAYOFWEEK FROM date) as day_of_week,
        EXTRACT(WEEK FROM date) as week_number,
        
        -- Calendar flags
        CASE WHEN EXTRACT(DAYOFWEEK FROM date) IN (1, 7) THEN 1 ELSE 0 END as is_weekend,
        is_holiday,
        is_working_day,
        
        -- Weather features (for multivariate ARIMA)
        ROUND(temperature_normalized * 100, 2) as temperature,  -- Denormalized
        ROUND(humidity_normalized * 100, 2) as humidity,        -- Denormalized
        ROUND(windspeed_normalized * 100, 2) as windspeed,      -- Denormalized
        weather_code,
        
        -- Lagged features (autoregressive)
        rentals_lag_1,
        rentals_lag_7,
        rentals_lag_30,
        rentals_lag_365,
        
        -- Rolling averages
        rentals_7day_avg,
        rentals_7day_std,
        rentals_30day_avg,
        
        -- Growth rates
        rentals_daily_growth,
        rentals_weekly_growth,
        
        -- Outlier flag
        is_outlier,
        
        -- Metadata
        dbt_loaded_at
        
    FROM {{ ref('fct_daily_metrics') }}
    
    --WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH)  -- Last 2 years
),

final AS (
    SELECT
        *,
        'daily' as frequency,
        'bike_sharing' as dataset_name,
        ROW_NUMBER() OVER (ORDER BY date) as observation_id
        
    FROM base
)

SELECT * 
FROM final
ORDER BY date