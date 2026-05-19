# Economic Sales Forecasting Pipeline

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![dbt](https://img.shields.io/badge/dbt-1.0+-orange.svg)](https://www.getdbt.com/)
[![BigQuery](https://img.shields.io/badge/BigQuery-GCP-lightblue.svg)](https://cloud.google.com/bigquery)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An end-to-end analytics engineering pipeline for time series forecasting on Google Cloud Platform. Uses BigQuery for data warehousing, dbt for transformation, and Python ARIMA models for 12-month revenue forecasting.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Setup Instructions](#setup-instructions)
- [File Structure](#file-structure)
- [Usage](#usage)
- [Key Features](#key-features)
- [Model Selection](#model-selection)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

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
        ↓
    forecast_results
    Table in BigQuery
        ↓
    Looker Studio
    Dashboard (Optional)
```

### Technology Stack

| Component | Tool | Purpose |
|-----------|------|---------|
| **Data Warehouse** | BigQuery | Scalable analytics database |
| **Transformation** | dbt | SQL-based data modeling |
| **Forecasting** | Python (statsmodels) | ARIMA time series models |
| **Orchestration** | Docker | Containerized pipeline execution |
| **Version Control** | Git | Code management |

## 🚀 Quick Start

### Prerequisites

- Google Cloud Platform (GCP) account with BigQuery access
- Python 3.8+
- Docker (optional, for containerized execution)
- dbt CLI installed
- gcloud CLI configured

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/economic-sales-forecasting.git
cd economic-sales-forecasting
```

### 2. Set Up GCP Authentication

```bash
# Authenticate with Google Cloud
gcloud auth application-default login

# Or use a service account (recommended for production)
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure dbt

Edit `profiles.yml` with your GCP project details:

```yaml
forecasting_project:
  target: dev
  outputs:
    dev:
      type: bigquery
      project: your-gcp-project-id
      dataset: forecasting_demo
      method: oauth  # or service-account
      location: US
```

### 5. Run the Pipeline

```bash
# Run dbt models
cd dbt_project
dbt run --profiles-dir .
dbt test --profiles-dir .

# Or use the provided script
../run_pipeline.sh
```

### 6. Run Forecasting Model

```bash
# Open ARIMA_Model_Selection_Colab.ipynb in Google Colab
# Update project ID: client = bigquery.Client(project='your-project-id')
# Run all cells
```

## 📁 File Structure

```
economic-sales-forecasting/
├── README.md                           # This file
├── requirements.txt                    # Python dependencies
├── docker-compose.yml                  # Docker configuration
├── run_pipeline.sh                     # Pipeline execution script
├── profiles.yml                        # dbt BigQuery configuration (TEMPLATE)
├── dbt_project.yml                     # dbt project settings
├── ARIMA_Model_Selection_Colab.ipynb   # Forecasting notebook
│
├── dbt/
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_raw_bike_data.sql          # Data cleaning & type casting
│   │   └── marts/
│   │       ├── fct_daily_metrics.sql          # Daily KPIs & rolling features
│   │       └── fct_forecasting_features.sql   # ARIMA-ready features
│   │
│   ├── tests/
│   ├── macros/
│   └── snapshots/
│
└── .gitignore                          # Git ignore file (DO NOT COMMIT SENSITIVE DATA)
```

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

## 🔧 Setup Instructions

### Step 1: GCP Project Setup

```bash
# Create a new GCP project (or use existing)
gcloud projects create economic-forecast-demo

# Enable BigQuery API
gcloud services enable bigquery.googleapis.com

# Create a dataset
bq mk --dataset --location=US economic-forecast-demo:forecasting_demo
```

### Step 2: Load Sample Data

```bash
# Create raw data table
bq mk --table \
  economic-forecast-demo:forecasting_demo.raw_bike_data \
  schema.json

# Load CSV data (replace with your data source)
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  economic-forecast-demo:forecasting_demo.raw_bike_data \
  gs://your-bucket/bike_sharing_data.csv \
  schema.json
```

### Step 3: Run dbt

```bash
dbt deps                    # Install dbt packages
dbt run                     # Run all models
dbt test                    # Run data tests
dbt docs generate           # Generate documentation
dbt docs serve              # View docs locally (http://localhost:8000)
```

### Step 4: Forecasting

1. Open `ARIMA_Model_Selection_Colab.ipynb` in Google Colab
2. Update your GCP project ID
3. Run cells sequentially to:
   - Load data from BigQuery
   - Test stationarity (ADF/KPSS tests)
   - Analyze ACF/PACF patterns
   - Compare ARIMA models (AIC, BIC, RMSE)
   - Generate 12-month forecasts
   - Visualize results with confidence intervals

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

## 🐳 Docker Setup

### Build and Run with Docker

```bash
# Build the Docker image
docker-compose build

# Run the pipeline
docker-compose up forecasting_pipeline

# Run with environment variables
docker-compose run forecasting_pipeline \
  -e GOOGLE_APPLICATION_CREDENTIALS=/app/keys/gcp-key.json
```

### Docker Configuration

The `docker-compose.yml` includes:
- Python 3.8+ environment
- dbt and required packages pre-installed
- Google Cloud authentication via service account
- Volume mounts for secrets and config

## 🚢 Deployment

### Local Development

```bash
# Activate virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run dbt
dbt run --profiles-dir .
dbt test --profiles-dir .

# Run forecasting
python -c "import pandas; print('Ready to forecast!')"
```

### Production Deployment (GCP Cloud Run)

```bash
# Create a Dockerfile (see docker-compose.yml as reference)
# Push to Google Artifact Registry
# Deploy to Cloud Run
gcloud run deploy forecasting-pipeline \
  --image gcr.io/your-project/forecasting-pipeline:latest \
  --platform managed \
  --region us-central1
```

### Scheduled Execution (Cloud Scheduler)

Create a Cloud Scheduler job to run the pipeline monthly:

```bash
gcloud scheduler jobs create app-engine monthly-forecast \
  --schedule="0 1 1 * *" \
  --time-zone="UTC" \
  --http-method=POST \
  --uri=https://your-cloud-run-url/trigger
```

## 🔐 Security & Best Practices

### Files NOT to Commit ⚠️

**NEVER upload these files to GitHub**:
- `keys/gcp-key.json` (service account credentials)
- `.env` or `.env.local` (API keys, secrets)
- `profiles.yml` (if it contains actual project IDs or credentials)

### Use `.gitignore`

```
# Secrets and credentials
keys/
*.json
.env
.env.local

# dbt artifacts
target/
dbt_packages/
logs/
dbt.log

# Python
__pycache__/
*.pyc
*.egg-info/
venv/
.venv/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Jupyter
.ipynb_checkpoints/
```

### Configuration Template

Instead of committing `profiles.yml`, use a template:

**profiles.yml.template**:
```yaml
forecasting_project:
  target: dev
  outputs:
    dev:
      type: bigquery
      project: YOUR_GCP_PROJECT_ID_HERE
      dataset: forecasting_demo
      method: oauth
      location: US
```

Users copy and fill it in:
```bash
cp profiles.yml.template profiles.yml
# Edit with your project ID
```

## 📖 Usage Examples

### Load Data from BigQuery in Python

```python
from google.cloud import bigquery

client = bigquery.Client(project='your-project-id')

query = """
SELECT *
FROM forecasting_demo.fct_forecasting_features
ORDER BY month
"""

df = client.query(query).to_dataframe()
print(df.head())
```

### Run dbt with Specific Profiles

```bash
# Use dev profile
dbt run --profiles-dir . --target dev

# Use prod profile
dbt run --profiles-dir . --target prod

# Run specific model
dbt run -s fct_daily_metrics

# Run only tests
dbt test
```

### Generate dbt Documentation

```bash
dbt docs generate
dbt docs serve  # Launches http://localhost:8000
```

## 📝 Forecast Output Schema

The forecasting model generates a table with this schema:

```sql
SELECT
  month,                  -- Date of forecast
  business_unit,          -- Sales division
  forecast,               -- Point estimate
  lower_ci,              -- 95% lower bound
  upper_ci,              -- 95% upper bound
  arima_order,           -- e.g., (1,1,1)
  model_aic,             -- Akaike Information Criterion
  forecast_date          -- When forecast was generated
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/your-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow dbt best practices: [dbt Style Guide](https://docs.getdbt.com/guides/legacy/best-practices)
- Use meaningful SQL comments
- Test all new models with `dbt test`
- Update documentation in `schema.yml` for new columns
- Keep Python code PEP 8 compliant

## 📚 Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [statsmodels ARIMA](https://www.statsmodels.org/stable/tsa.html)
- [Time Series Forecasting Best Practices](https://otexts.com/fpp2/)
- [Google Cloud BigQuery Guide](https://cloud.google.com/bigquery/docs/quickstarts)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ✉️ Support

For questions or issues:
- Open a GitHub Issue
- Check existing documentation
- Review the Jupyter notebook for detailed explanations

## 🎓 Learning Outcomes

This project teaches:
- **Analytics Engineering**: dbt modeling best practices
- **Data Warehousing**: BigQuery schema design
- **SQL**: Window functions, CTEs, aggregations
- **Time Series Analysis**: Stationarity, ACF/PACF, ARIMA models
- **Python Data Science**: Pandas, statsmodels, sklearn
- **Cloud Platforms**: GCP, BigQuery, authentication
- **DevOps**: Docker, CI/CD with dbt
- **Data Visualization**: Plotly, Matplotlib, Seaborn

---

**Last Updated**: 2024
**Maintained By**: Your Team Name
**Status**: ✅ Active Development
