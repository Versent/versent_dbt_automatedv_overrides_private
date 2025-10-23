# AutomateDataVault Override Macros - Usage Templates

This directory contains comprehensive usage templates for all custom macros in the AutomateDataVault overrides package. Each template demonstrates practical implementation with structured YAML configurations.

## 🚀 Quick Start

1. **Choose a Template**: Select the template that matches your data vault component
2. **Copy & Customize**: Copy the template to your models directory
3. **Update Configuration**: Modify the YAML configuration section
4. **Deploy**: Run your dbt model

## 📋 Available Templates

| Template | Purpose | Component Type |
|----------|---------|----------------|
| `cbc_template.sql` | Core Business Concept models | Business Layer |
| `hub_template.sql` | Hub tables with ghost records | Raw Vault |
| `sat_template.sql` | Satellites with business keys | Raw Vault |
| `pit_template.sql` | Point-in-Time tables | Business Vault |
| `t_link_template.sql` | Transactional links | Raw Vault |
| `hk_ghost_template.sql` | Hash key ghost handling | Staging |
| `mac_payload_template.sql` | Dynamic payload management | Utility |
| `pit_as_of_date_template.sql` | PIT date generation | Business Vault |
| `int_template.sql` | Integration layer | Staging |

## 🛠️ Template Structure

All templates follow a consistent YAML configuration pattern:

```sql
-- YAML template configuration
{%- set yaml_template -%}
macro_config:
  parameter1: "value1"
  parameter2: "value2"
  nested_config:
    sub_param: "sub_value"
{%- endset -%}

{%- set config_data = fromyaml(yaml_template) -%}

-- Macro usage with structured configuration
{{ macro_name(
    param1=config_data.macro_config.parameter1,
    param2=config_data.macro_config.parameter2
) }}
```

## 💡 Key Benefits

- **🔧 Maintainable**: Centralized configuration for easy updates
- **📖 Readable**: Self-documenting YAML structure
- **🔄 Reusable**: Extract configs to external files
- **✅ Validated**: Structured data with better error handling
- **🎯 Flexible**: Easy configuration switching

## 📚 Template Details

### Core Data Vault Components

#### Hub Template (`hub_template.sql`)
Creates hub tables with automatic ghost record insertion.
```yaml
hub_config:
  src_pk: "hk_customer"
  src_nk: "customer_id"
  src_ldts: "load_datetime"
  src_source: "record_source"
  source_model: "staging_customer_raw"
```

#### Satellite Template (`sat_template.sql`)
Enhanced satellites with business key support and ghost handling.
```yaml
sat_config:
  src_pk: "hk_customer"
  business_key: "customer_id"
  src_hashdiff: "hd_customer_details"
  src_payload: ["customer_name", "email", "bk_customer"]
```

#### Transactional Link Template (`t_link_template.sql`)
Transactional links with ghost record handling in foreign keys.
```yaml
t_link_config:
  src_pk: "hk_customer_order"
  src_fk: ["hk_customer", "hk_order"]
  src_payload: ["order_date", "order_amount"]
```

### Business Vault Components

#### Point-in-Time Template (`pit_template.sql`)
Advanced PIT tables with flexible date handling.
```yaml
pit_config:
  hub: "hub_customer"
  hash_key: "hk_customer"
  satellites:
    sat_customer_details:
      pk: "hk_customer"
      ldts: "load_datetime"
```

#### Core Business Concept Template (`cbc_template.sql`)
Consolidated business-friendly models.
```yaml
cbc_config:
  hash_key: "hk_customer"
  hub: "hub_customer"
  pit: "pit_customer"
  satellites: ["sat_customer_details"]
  derivations:
    full_name: "CONCAT(first_name, ' ', last_name)"
```

### Utility Templates

#### Ghost Handling Template (`hk_ghost_template.sql`)
Null hash key management with ghost values.
```yaml
hk_ghost_config:
  source_table: "raw_customer_data"
  columns:
    hash_keys:
      primary: "hk_customer"
```

#### Payload Management Template (`mac_payload_template.sql`)
Dynamic column transformations.
```yaml
payload_config:
  customer_payload:
    customer_name: "upper(customer_name)"
    email: "lower(email)"
    full_address: "concat(address_line1, ', ', city)"
```

## 🏗️ Implementation Patterns

### Basic Data Vault Flow
```
Raw Data → Staging (with hk_ghost) → Hub/Sat/Link → PIT → CBC
```

1. **Staging**: Use `hk_ghost_template.sql` for null handling
2. **Raw Vault**: Implement `hub_template.sql`, `sat_template.sql`, `t_link_template.sql`
3. **Business Vault**: Create `pit_template.sql` tables
4. **Information Marts**: Build `cbc_template.sql` models

### Configuration Management
- Keep configurations at the top of each model
- Extract common configs to separate files for reuse
- Use descriptive parameter names
- Document business logic in YAML comments

## ⚙️ Configuration Requirements

### Required Variables
```yaml
vars:
  bk_ghost: "ghost"  # Ghost record business key value
```

### Dependencies
- dbt >= 1.0.0
- automate_dv package
- Database-specific configurations

## 🎯 Best Practices

1. **Start Simple**: Begin with basic hub/satellite patterns
2. **Test Incrementally**: Validate each component before moving to the next
3. **Document Configs**: Add comments to your YAML configurations
4. **Use Consistent Naming**: Follow your organization's naming conventions
5. **Validate Ghost Records**: Ensure ghost handling works across all components

## 📖 Additional Resources

- **Main Repository README**: Overview of the entire package
- **Macro Documentation**: Detailed parameter descriptions in `macros/automate_dv_overrides/`
- **automate_dv Docs**: Reference for standard Data Vault patterns

---

*For more detailed information about the repository and its components, see the main README.md in the root directory.*

### PIT and CBC Pattern
1. Create `pit_as_of_date_template.sql` models for date generation
2. Use `pit_template.sql` for point-in-time tables
3. Use `cbc_template.sql` for business-friendly consolidated views

### Ghost Record Handling
- All macros support ghost records through the `bk_ghost` variable
- Use `hk_ghost_template.sql` patterns in staging for null handling
- Ghost records ensure referential integrity across the data vault


## Configuration Requirements

### Variables
Ensure these variables are defined in your `dbt_project.yml`:
```yaml
vars:
  bk_ghost: "ghost"  # or your preferred ghost value
```

### Dependencies
- automate_dv package
- Appropriate database permissions for incremental models

## Best Practices

1. **Ghost Records**: Always handle potential null values using ghost record patterns
2. **Business Keys**: Include business keys in both parameters and payload for satellite macros
3. **PIT Tables**: Use dedicated as_of_date models for better performance
4. **CBC Models**: Leverage CBC for business-friendly reporting views
5. **Incremental Models**: Use appropriate unique keys for incremental materialization

## Getting Started

1. Choose the appropriate template for your use case
2. Copy the template to your models directory
3. Modify the parameters to match your data sources
4. Update table and column names to match your naming conventions
5. Test with a small dataset before full implementation

For questions about specific macro usage, refer to the individual template files for detailed examples and explanations.