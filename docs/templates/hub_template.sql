-- Hub Template with Ghost Record Support
-- This template demonstrates how to use the custom hub macro
-- Override of automate_dv hub macro that automatically adds a 'ghost' record

{{ config(
    materialized='incremental',
    unique_key='hk_customer',
    enabled=false
) }}

-- YAML template configuration for HUB macro
{%- set yaml_template -%}
hub_config:
  src_pk: "hk_customer"
  src_nk: "customer_id"
  src_ldts: "load_datetime"
  src_source: "record_source"
  source_model: 
    - "staging_customer_raw"
{%- endset -%}

{%- set config_data = fromyaml(yaml_template) -%}

-- Example usage of the custom hub macro
{{ hub(
    src_pk=config_data.hub_config.src_pk,
    src_nk=config_data.hub_config.src_nk,
    src_extra_columns=config_data.hub_config.src_extra_columns,
    src_ldts=config_data.hub_config.src_ldts,
    src_source=config_data.hub_config.src_source,
    source_model=config_data.hub_config.source_model
) }}

-- Key differences from standard automate_dv hub macro:
-- 1. Automatically adds a 'ghost' record with bk_ghost variable value
-- 2. Ghost record uses current_timestamp() as load_datetime
-- 3. Ghost record has 'macros_hub' as record_source

-- Example output structure:
-- hk_customer (primary key - hash of business key)
-- customer_id (natural/business key)
-- load_datetime (when record was loaded)
-- record_source (source system identifier)
-- Plus the automatic ghost record:
-- - hk_customer: hash of bk_ghost variable
-- - customer_id: bk_ghost variable value  
-- - load_datetime: current_timestamp()
-- - record_source: 'macros_hub'