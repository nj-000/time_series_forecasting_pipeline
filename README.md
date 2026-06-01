# Economic Sales Forecasting Pipeline

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![dbt](https://img.shields.io/badge/dbt-1.0+-orange.svg)](https://www.getdbt.com/)
[![BigQuery](https://img.shields.io/badge/BigQuery-GCP-lightblue.svg)](https://cloud.google.com/bigquery)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An end-to-end analytics engineering pipeline for time series forecasting on Google Cloud Platform. Uses BigQuery for data warehousing, dbt for transformation, and Python ARIMA models for 12-month revenue forecasting.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Key Features](#key-features)
- [Model Selection](#model-selection)

## 🎯 Project Overview

This project demonstrates a complete analytics workflow for business forecasting:

- **Data Ingestion**: Raw economic and sales data loaded into BigQuery
- **Data Transformation**: dbt models for staging, cleaning, and feature engineering
- **Feature Engineering**: SQL window functions for rolling averages, lag variables, and trend indicators
- **Time Series Forecasting**: ARIMA models trained on historical sales data
- **Macroeconomic Integration**: Incorporates inflation, unemployment, and seasonal patterns
- **Output**: 12-month forward sales forecasts with confidence intervals

**Use Case**: Forecast monthly business unit sales using historical revenue, moving averages, lagged features, seasonality, and macroeconomic indicators.

## 🏗️ Architecture

```
Synthetic/Real CSV Data
        ↓
    BigQuery
    Raw Tables
        ↓
    dbt Staging
    (stg_raw_bike_data)
        ↓
    dbt Mart Models
    (fct_daily_metrics)
        ↓
    Feature Engineering
    (fct_forecasting_features)
        ↓
    Python ARIMA
    Forecasting

```

### Technology Stack

| Component | Tool | Purpose |
|-----------|------|---------|
| **Data Warehouse** | BigQuery | Scalable analytics database |
| **Transformation** | dbt | SQL-based data modeling |
| **Forecasting** | Python (statsmodels) | ARIMA time series models |
| **Orchestration** | Docker | Containerized pipeline execution |
| **Version Control** | Git | Code management |

### Key Files Explained

**dbt Models**:
- `stg_raw_bike_data.sql` - Staging layer: cleans, types, and validates raw data
- `fct_daily_metrics.sql` - Fact table: daily metrics with 7/30-day rolling averages, lag features
- `fct_forecasting_features.sql` - Mart layer: ARIMA-ready features with lags, trends, weather

**Python**:
- `ARIMA_Model_Selection_Colab.ipynb` - Stationarity tests, ACF/PACF analysis, model comparison, forecasting

**Configuration**:
- `profiles.yml` - dbt connection to BigQuery (contains your project ID)
- `dbt_project.yml` - dbt project metadata and model configurations
- `docker-compose.yml` - Docker setup for pipeline containerization

## 📊 Key Features

### dbt Models

**Staging (`stg_raw_bike_data`)**
- Data type casting and validation
- Null value handling
- Column renaming for clarity

**Daily Metrics (`fct_daily_metrics`)**
- 7-day and 30-day rolling averages
- 1, 7, 30, 365-day lag features
- Daily/weekly growth rates
- Outlier detection (>2σ from rolling mean)
- Seasonality flags (day of week, holidays, working days)

**Forecasting Features (`fct_forecasting_features`)**
- Aggregated to monthly level
- Weather features (temperature, humidity, windspeed)
- Calendar features (year, month, quarter, week)
- Lagged revenue (1, 7, 30, 365 days)
- Rolling statistics
- Ready for ARIMA modeling

### ARIMA Forecasting

**Model Selection Process**:
1. **Stationarity Testing**: ADF and KPSS tests to determine differencing order (d)
2. **ACF/PACF Analysis**: Visual inspection to identify AR (p) and MA (q) orders
3. **Grid Search**: Test candidate models: ARIMA(1,0,0), ARIMA(0,1,1), ARIMA(1,1,1), etc.
4. **Model Comparison**: Evaluate using AIC, BIC, R², RMSE, MAPE
5. **Diagnostic Checks**: Validate residuals are white noise

**Forecasting Output**:
- 12-month point forecasts
- 95% confidence intervals
- Model diagnostics (residual plots, ACF, Q-Q plots)

## 📈 Model Selection

The notebook provides comprehensive model selection:

### Information Criteria (Preferred)
- **AIC (Akaike Information Criterion)**: Balances fit and complexity
- **BIC (Bayesian Information Criterion)**: Stronger penalty for complexity

### Performance Metrics
- **R² / Adjusted R²**: Goodness of fit
- **RMSE**: Root Mean Squared Error
- **MAE**: Mean Absolute Error
- **MAPE**: Mean Absolute Percentage Error

### Example Output

```
Model Comparison Results:
ARIMA Order | AIC    | BIC    | R²    | RMSE     | MAPE
ARIMA(1,1,1)| 45230  | 45262  | 0.892 | 1245.67  | 3.2%
ARIMA(0,1,1)| 45245  | 45268  | 0.881 | 1289.45  | 3.5%
ARIMA(2,1,1)| 45238  | 45278  | 0.893 | 1238.92  | 3.1%
```

---

