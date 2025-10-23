# dbt AutomateDataVault Overrides

This repository contains custom dbt macros that override and extend functionalities from the [automate_dv](https://github.com/Datavault-UK/automate_dv) package. These overrides provide enhanced Data Vault 2.0 capabilities with additional features for ghost record handling, business key support, and advanced data vault pattern implementations.

## Repository Purpose

The AutomateDataVault overrides package addresses specific requirements and limitations found in the standard automate_dv package by providing:

- **Enhanced Ghost Record Handling**: Automatic insertion and management of ghost records for referential integrity
- **Business Key Support**: Extended satellite functionality with business key parameters
- **Advanced PIT Capabilities**: Enhanced Point-in-Time table generation with flexible date handling
- **Core Business Concept (CBC) Models**: Consolidated views that combine hubs, satellites, and PIT tables
- **Utility Macros**: Helper functions for payload management, hash key handling, and integration layers

## Key Features

### 🔧 **Extended Data Vault Macros**
- **Hub Override**: Automatically adds ghost records for missing business keys
- **Satellite Override**: Enhanced with business key support and ghost record handling
- **Transactional Link Override**: Handles ghost records in foreign key relationships
- **PIT Macros**: Advanced point-in-time table generation with flexible as-of-date handling
- **CBC Macro**: Creates business-friendly consolidated models

### 🛠️ **Utility Macros**
- **Ghost Key Handling**: `hk_ghost()` and `hk_ghost_default()` for null hash key management
- **Payload Management**: `mac_payload()` and `mac_payload_cols()` for dynamic column handling
- **Integration Layer**: `int()` macro for metadata-driven SQL generation

### 📊 **Data Vault 2.0 Patterns**
- Core Business Concepts (CBC) for business user consumption
- Point-in-Time (PIT) tables for temporal data joins
- Ghost record patterns for maintaining referential integrity
- Business key preservation and handling

## Architecture Overview

```
macros/
├── automate_dv_overrides/
│   ├── cbc.sql              # Core Business Concept macro
│   ├── hub.sql              # Hub with ghost records
│   ├── sat.sql              # Satellite with business key support
│   ├── t_lnk.sql            # Transactional link with ghost handling
│   ├── pit.sql              # Point-in-Time table generation
│   ├── pit_as_of_date.sql   # PIT as-of-date generation
│   ├── hk_ghost.sql         # Hash key ghost handling
│   ├── hk_ghost_default.sql # Default ghost hash value
│   ├── mac_payload.sql      # Payload transformation macro
│   ├── mac_payload_cols.sql # Payload column list macro
│   └── int.sql              # Integration layer macro
│models/
└── templates/               # Usage templates and examples
    ├── cbc_template.sql
    ├── hub_template.sql
    ├── sat_template.sql
    ├── pit_template.sql
    └── pit_as_of_date_template.sql
```

## 📚 Usage Templates

The `models/templates/` directory contains comprehensive usage examples for each macro, featuring:

- **YAML-based Configuration**: Structured parameter definitions using `set yaml_template` approach
- **Practical Examples**: Real-world usage scenarios with sample data
- **Best Practices**: Implementation guidelines and recommendations
- **Alternative Configurations**: Multiple parameter combinations for different use cases

### Available Templates:
1. **`cbc_template.sql`** - Core Business Concept implementation
2. **`hub_template.sql`** - Hub tables with ghost record support
3. **`sat_template.sql`** - Satellites with business key handling
4. **`pit_template.sql`** - Point-in-Time table generation
5. **`pit_as_of_date_template.sql`** - PIT as-of-date generation

## Getting Started

### Prerequisites
- dbt >= 1.0.0
- automate_dv package
- Appropriate data warehouse (Snowflake, BigQuery, Redshift, etc.)

### Installation

> **Note**: This repository is currently private. You will need to request a Personal Access Token (PAT) from the internal support team for the system account to access this repository.

1. **Request Access**: Contact the internal support team to obtain a system account PAT for accessing this private repository.

2. Add this package to your `packages.yml`:
```yaml
packages:
  - git: "https://{{env_var('')}}@github.com/Versent/versent_dbt_automatedv_overrides_private.git"
    revision: main  # or specific tag/branch
```

3. Configure your git credentials with the provided PAT before running `dbt deps`.

4. Run `dbt deps` to install the package

5. Configure required variables in your `dbt_project.yml`:
```yaml
vars:
  bk_ghost: "ghost"  # Ghost record business key value
```

### Quick Start
1. Browse the templates in `models/templates/` to understand usage patterns
2. Copy relevant templates to your project
3. Modify configurations to match your data sources
4. Implement the data vault patterns using the override macros

## Configuration

### Required Variables
```yaml
vars:
  bk_ghost: "ghost"  # Default ghost business key value
```

### Optional Variables
```yaml
vars:
  # Add any project-specific ghost or configuration values
  custom_ghost_value: "unknown"
```