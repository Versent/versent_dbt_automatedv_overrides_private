-- Point in Time (PIT) Template  
-- This template demonstrates how to use the custom pit macro
-- The pit macro identifies relevant records from satellites for specific dates/timestamps

{{ config(
    materialized='table',
    enabled  = false  -- Set to true to enable this model
) }}

-- YAML template configuration for PIT macro
{%- set yaml_template -%}
pit_config:
  hub: "hub_customer"
  hash_key: "hk_customer"
  business_key: "customer_id"
  as_of_dates_table: "pit_customer_as_of_dates" -- optional
  as_of_date: "as_of_date" -- optional
  record_source: "source_system"
  load_datetime: "load_datetime"
  satellites:
    sat_customer_details:
      pk: "hk_customer"
      ldts: "load_datetime"
    sat_customer_address:
      pk: "hk_customer"
      ldts: "load_datetime"
{%- endset -%}

{%- set config_data = fromyaml(yaml_template) -%}

-- Example usage of the pit macro with external as_of_dates table
{{ pit(
    hub=config_data.pit_config.hub,
    hash_key=config_data.pit_config.hash_key,
    business_key=config_data.pit_config.business_key,
    as_of_dates_table=config_data.pit_config.as_of_dates_table,
    as_of_date=config_data.pit_config.as_of_date,
    satellites=config_data.pit_config.satellites,
    record_source=config_data.pit_config.record_source,
    load_datetime=config_data.pit_config.load_datetime
) }}
