#!/bin/bash

echo "Running dbt models..."

# cd dbt_project

dbt run --profiles-dir .
dbt test --profiles-dir .

echo "Pipeline complete."