-- Satellite Template with Business Key Support
-- This template demonstrates how to use the custom sat macro
-- Override of automate_dv satellite macro with business key support and ghost record handling

{{ config(
    materialized='incremental',
    unique_key='h_customer',
    enabled=false  -- Set to true to enable this model
) }}

-- YAML template configuration for SAT macro
{%- set yaml_template -%}
sat_config:
  src_pk: "h_customer"
  business_key: "customer_id"
  src_hashdiff: "hd_customer_details"
  src_payload:
    - "customer_name"
    - "email"
    - "phone"
    - "status"
    - "bk_customer"  # Business key must be included in payload as well
  src_eff: "effective_from"
  src_ldts: "load_datetime"
  src_source: "record_source"
  source_model: "staging_customer_details"
{%- endset -%}

{%- set config_data = fromyaml(yaml_template) -%}

-- Example usage of the custom sat macro
{{ sat(
    src_pk=config_data.sat_config.src_pk,
    business_key=config_data.sat_config.business_key,
    src_hashdiff=config_data.sat_config.src_hashdiff,
    src_payload=config_data.sat_config.src_payload,
    src_eff=config_data.sat_config.src_eff,
    src_ldts=config_data.sat_config.src_ldts,
    src_source=config_data.sat_config.src_source,
    source_model=ref(config_data.sat_config.source_model)
) }}

-- Key differences from standard automate_dv sat macro:
-- 1. business_key parameter - specifies the business key column name
-- 2. Business key must also be included in src_payload (e.g., 'bk_customer')
-- 3. Handles ghost records by casting null business keys to bk_ghost value

-- Example output structure:
-- hk_customer (primary key - hash key)
-- hd_customer_details (hash diff)
-- customer_name, email, phone, status, bk_customer (payload columns)
-- effective_from (effective date)
-- load_datetime (load date time)
-- record_source (source system identifier)