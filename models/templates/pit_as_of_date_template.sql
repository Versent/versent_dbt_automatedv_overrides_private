-- Point in Time As Of Date Template
-- This template demonstrates how to use the pit_as_of_date macro
-- This macro captures all historical "as-of" dates for records from satellite tables

{{ config(
    materialized='table',
    enabled=false  -- Set to true to enable this model
) }}

-- YAML template configuration for pit_as_of_date macro
{%- set yaml_template -%}
pit_as_of_date_config:
  satellites:
    sat_customer_details:
      pk: "hk_customer"
      as_of_date: "load_datetime"
    sat_customer_address:
      pk: "hk_customer" 
      as_of_date: "load_datetime"
    sat_customer_preferences:
      pk: "hk_customer"
      as_of_date: "load_datetime"
{%- endset -%}

{%- set config_data = fromyaml(yaml_template) -%}

-- Example usage of the pit_as_of_date macro
{{ pit_as_of_date(
    satellites=config_data.pit_as_of_date_config.satellites
) }}

-- This macro will generate a union of all unique as_of_dates from the specified satellites
-- Typically used as input for the pit macro's as_of_dates_table parameter

-- Example output structure:
-- as_of_date (unique dates from all satellites)

-- Usage pattern in combination with PIT:
-- 1. First create pit_as_of_date model: 
--    {{ pit_as_of_date(satellites=['sat_customer_details', 'sat_customer_address']) }}
-- 2. Then reference it in pit macro:
--    as_of_dates_table='pit_customer_as_of_dates'