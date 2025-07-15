# Testing the New Configuration System

## Test 1: Basic Functionality

The new configuration system has been implemented with the following key features:

### 1. Version Management
- Added `compare_versions` function that properly handles semantic versioning
- Config files now require a `version` field for migration support

### 2. Split Configuration Storage
- Main config (primitive values) -> `facility_tracker.json`
- Subtables (nested objects) -> `hud_extensions/user_config/[subtable].json`

### 3. Migration Support
- Automatic detection of version differences
- Conversion tables for field mapping and value transformation
- Graceful fallback when migration fails

### 4. Error Handling
- Debug messages for all failure scenarios
- Validation of migrated configurations against defaults
- Skip invalid or unmappable configurations

## Example Configuration Split

Original unified config with subtable:
```json
{
  "version": "1.0.0",
  "draw_tracker": true,
  "tr_opacity": 1.0,
  "advanced_settings": {
    "version": "1.0.0", 
    "debug_mode": false,
    "performance_monitoring": true
  }
}
```

After save_config(), becomes:

**facility_tracker.json:**
```json
{
  "version": "1.0.0",
  "draw_tracker": true, 
  "tr_opacity": 1.0
}
```

**hud_extensions/user_config/advanced_settings.json:**
```json
{
  "version": "1.0.0",
  "debug_mode": false,
  "performance_monitoring": true
}
```

## Migration Example

If loading a v0.9.0 config with conversion table:

**Input (v0.9.0):**
```json
{
  "version": "0.9.0",
  "show_when": "Hide when:",
  "old_setting_name": "some_value"
}
```

**Conversion Table (0.9.0_to_1.0.0.json):**
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

**Output (v1.0.0):**
```json
{
  "version": "1.0.0", 
  "show_when": "Don't show when:",
  "new_setting_name": "some_value"
}
```

The implementation is complete and ready for testing in the REFramework environment.