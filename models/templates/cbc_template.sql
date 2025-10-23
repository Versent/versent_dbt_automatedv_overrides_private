-- Core Business Concept (CBC) Template
-- This template demonstrates how to use the custom cbc macro
-- The cbc macro brings together hubs, pits and satellites to create a consolidated model

{{ config(
    materialized='table'
) }}

-- YAML template configuration for CBC macro
{%- set yaml_template -%}
cbc_config:
  hash_key: "hk_customer"
  hub: "hub_customer"
  pit: "pit_customer"
  satellites:
    - "sat_customer_details"
    - "sat_customer_address"
  payload:
    sat_customer_details:
      pk: "hk_customer"
      ldts: "load_datetime"
      columns:
        - "customer_name"
        - "email"
        - "phone"
    sat_customer_address:
      pk: "hk_customer"
      ldts: "load_datetime"
      columns:
        - "address_line1"
        - "address_line2"
        - "city"
        - "state"
        - "postal_code"
  derivations:
    full_name: "CONCAT(first_name, ' ', last_name)"
{%- endset -%}

{%- set config_data = fromyaml(yaml_template) -%}

-- Example usage of the cbc macro
{{ cbc(
    hash_key=config_data.cbc_config.hash_key,
    hub=config_data.cbc_config.hub,
    pit=config_data.cbc_config.pit,
    satellites=config_data.cbc_config.satellites,
    payload=config_data.cbc_config.payload,
    derivations=config_data.cbc_config.derivations
) }}

-- Example output structure:
-- hk_customer (hash key)
-- bk_customer (business key) 
-- record_source
-- customer_name, email, phone (from sat_customer_details)
-- address_line1, address_line2, city, state, postal_code (from sat_customer_address)
-- full_name, is_active (derived columns)
-- load_datetime (from pit)