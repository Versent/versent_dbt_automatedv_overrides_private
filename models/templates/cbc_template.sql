-- Core Business Concept (CBC) Template
-- This template demonstrates how to use the custom cbc macro
-- The cbc macro brings together hubs, pits and satellites to create a consolidated model
-- Set to true to enable this model

{{ config(
    materialized='table',
    enabled=false
) }}

-- YAML template configuration for CBC macr0
{%- set yaml_template -%}
cbc_config:
  hash_key: "hk_customer"
  hub: "hub_customer"
  pit: "pit_customer"

  satellites:                      # <- DICT, no hyphens
    sat_customer_details:
      pk: "hk_customer"
      ldts: "load_datetime"
      pit_ldts: "ldts_sat_customer_details"
      payload:
        - "customer_name"
        - "email"
        - "phone"
      lookups: {}
    sat_customer_address:
      pk: "hk_customer"
      ldts: "load_datetime"
      pit_ldts: "ldts_sat_customer_address"
      payload:
        - "address_line1"
        - "address_line2"
        - "city"
        - "state"
        - "postal_code"
      lookups: {}

  derivations:                     # your macro calls mac_payload() → expects a LIST
    - "CONCAT(first_name, ' ', last_name) AS full_name"
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