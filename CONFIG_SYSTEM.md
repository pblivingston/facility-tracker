# Configuration System Refactoring

## Overview

The configuration system has been refactored to support:
- Main configuration stored in `facility_tracker.json`
- Subtable configurations stored in `hud_extensions/user_config/[subtable].json`
- Version management and automatic migration
- Graceful error handling

## Configuration Structure

### Main Configuration
- Contains all primitive values (strings, numbers, booleans)
- Stored in `facility_tracker.json` in the root directory
- Must include a `version` field for version management

### Subtable Configurations
- Contains nested table configurations (objects)
- Each subtable is stored separately in `hud_extensions/user_config/[subtable_name].json`
- Each subtable must include its own `version` field

## Version Management

### Version Comparison
The system uses semantic versioning (e.g., "1.0.0") and compares versions to determine if migration is needed.

### Migration Process
1. When loading a config file, the system compares the loaded version with the current default version
2. If the loaded version is older, it attempts to find a conversion table
3. Conversion tables are located at:
   - Main config: `hud_extensions/conversion/[old_version]_to_[new_version].json`
   - Subtables: `hud_extensions/conversion/[subtable]/[old_version]_to_[new_version].json`

### Conversion Table Format
```json
{
  "field_mappings": {
    "old_field_name": "new_field_name"
  },
  "value_transforms": {
    "field_name": {
      "old_value": "new_value"
    }
  }
}
```

## Error Handling

The system provides debug output for various failure scenarios:
- Missing conversion tables
- Failed migrations
- Invalid config files
- Version mismatches
- Missing default configurations

## Example Usage

### Basic Config (facility_tracker.json)
```json
{
  "version": "1.0.0",
  "draw_tracker": true,
  "tr_opacity": 1.0
}
```

### Subtable Config (hud_extensions/user_config/advanced_settings.json)
```json
{
  "version": "1.0.0",
  "debug_mode": false,
  "performance_monitoring": true
}
```

### Conversion Table (hud_extensions/conversion/0.9.0_to_1.0.0.json)
```json
{
  "field_mappings": {
    "old_setting_name": "new_setting_name"
  },
  "value_transforms": {
    "show_when": {
      "Hide when:": "Don't show when:"
    }
  }
}
```

## Functions

### `core.compare_versions(version1, version2)`
Compares two version strings. Returns -1, 0, or 1.

### `core.load_config()`
Main function that loads both main config and all subtables.

### `core.save_config()`
Saves the configuration, splitting main config and subtables appropriately.

### `core.migrate_config(config_data, from_version, to_version, subtable_name)`
Handles migration of configuration from one version to another using conversion tables.