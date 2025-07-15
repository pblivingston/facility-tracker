local core = {}

function core.lerp(a, b, t)
    return a + (b - a) * t
end

function core.ease_in_out(frac)
	return (frac^2) / (2 * (frac^2 - frac) + 1)
end

function core.get_index(indexed_table, value)
	for i, e in ipairs(indexed_table) do
		if e == value then
			return i
		end
	end
	return nil
end

function core.keys_to_num(tbl)
	local new_tbl = {}
	for k, v in pairs(tbl) do
		k = tonumber(k) or k
		new_tbl[k] = v
	end
	return new_tbl
end

function core.compare_versions(version1, version2)
	-- Compare two version strings (e.g., "1.2.3" vs "1.3.0")
	-- Returns: -1 if version1 < version2, 0 if equal, 1 if version1 > version2
	if version1 == version2 then
		return 0
	end
	
	local v1_parts = {}
	local v2_parts = {}
	
	-- Split version strings by dots
	for part in string.gmatch(version1 or "0.0.0", "([^%.]+)") do
		table.insert(v1_parts, tonumber(part) or 0)
	end
	
	for part in string.gmatch(version2 or "0.0.0", "([^%.]+)") do
		table.insert(v2_parts, tonumber(part) or 0)
	end
	
	-- Compare parts
	local max_parts = math.max(#v1_parts, #v2_parts)
	for i = 1, max_parts do
		local v1_part = v1_parts[i] or 0
		local v2_part = v2_parts[i] or 0
		
		if v1_part < v2_part then
			return -1
		elseif v1_part > v2_part then
			return 1
		end
	end
	
	return 0
end

function core.load_data(folder)
	local dir = folder and "hud_extensions\\" .. folder or "hud_extensions"
	for _, path in ipairs(fs.glob(dir .. [[\\.*json]])) do
		local name = path:sub(#dir + 2, -6)
		core[name] = core.keys_to_num(json.load_file(path))
	end
end

local config_path = "facility_tracker.json"

function core.save_config()
    if not core.config then
        re.msg("Debug: core.config is nil, cannot save")
        return
    end
    
    local main_config = {}
    local subtables = {}
    
    -- Separate main config (non-table elements) from subtables (table elements)
    for key, value in pairs(core.config) do
        if type(value) == "table" then
            subtables[key] = value
        else
            main_config[key] = value
        end
    end
    
    -- Save main config to facility_tracker.json
    json.dump_file(config_path, main_config)
    
    -- Save each subtable to hud_extensions/user_config/[subtable].json
    for subtable_name, subtable_data in pairs(subtables) do
        local subtable_path = "hud_extensions\\user_config\\" .. subtable_name .. ".json"
        json.dump_file(subtable_path, subtable_data)
    end
end

function core.load_config()
    if not core.config then
        re.msg("Debug: core.config is nil, cannot load config")
        return
    end
    
    -- Load main config from facility_tracker.json
    local loaded_main_config = json.load_file(config_path)
    if loaded_main_config then
        core.load_main_config(loaded_main_config)
    end
    
    -- Load subtables from hud_extensions/user_config/
    core.load_subtables()
    
    -- Save config if main config file didn't exist
    if not loaded_main_config then
        core.save_config()
    end
end

function core.load_main_config(loaded_config)
    -- Get current version for main config
    local current_version = core.config.version
    local loaded_version = loaded_config.version
    
    -- Check if version comparison and migration is needed
    if loaded_version and current_version then
        local version_diff = core.compare_versions(loaded_version, current_version)
        
        if version_diff < 0 then
            -- Loaded config is older, attempt migration
            loaded_config = core.migrate_config(loaded_config, loaded_version, current_version, "")
            if not loaded_config then
                re.msg("Debug: Failed to migrate main config from version " .. loaded_version .. " to " .. current_version)
                return
            end
        elseif version_diff > 0 then
            re.msg("Debug: Loaded main config version " .. loaded_version .. " is newer than current " .. current_version)
        end
    elseif loaded_version and not current_version then
        re.msg("Debug: Loaded config has version but current config doesn't have version field")
        return
    elseif not loaded_version and current_version then
        re.msg("Debug: Loaded config has no version field")
        return
    end
    
    -- Apply loaded config to current config (only for non-table elements)
    for key, value in pairs(loaded_config) do
        if core.config[key] ~= nil and type(core.config[key]) ~= "table" then
            core.config[key] = value
        end
    end
end

function core.load_subtables()
    -- Use fs.glob to enumerate user config files
    for _, path in ipairs(fs.glob("hud_extensions\\user_config\\*.json")) do
        local subtable_name = path:match("hud_extensions\\user_config\\([^\\]+)%.json")
        if subtable_name then
            local loaded_subtable = json.load_file(path)
            if loaded_subtable then
                -- Check if corresponding default subtable exists
                if core.config[subtable_name] and type(core.config[subtable_name]) == "table" then
                    core.load_subtable_config(subtable_name, loaded_subtable)
                else
                    re.msg("Debug: No corresponding default config subtable for " .. subtable_name .. ", skipping")
                end
            else
                re.msg("Debug: Failed to load config file " .. path .. ", skipping")
            end
        end
    end
end

function core.load_subtable_config(subtable_name, loaded_subtable)
    -- Get versions
    local current_version = core.config[subtable_name].version
    local loaded_version = loaded_subtable.version
    
    -- Check if version comparison and migration is needed
    if loaded_version and current_version then
        local version_diff = core.compare_versions(loaded_version, current_version)
        
        if version_diff < 0 then
            -- Loaded config is older, attempt migration
            loaded_subtable = core.migrate_config(loaded_subtable, loaded_version, current_version, subtable_name)
            if not loaded_subtable then
                re.msg("Debug: Failed to migrate subtable " .. subtable_name .. " from version " .. loaded_version .. " to " .. current_version)
                return
            end
        elseif version_diff > 0 then
            re.msg("Debug: Loaded subtable " .. subtable_name .. " version " .. loaded_version .. " is newer than current " .. current_version)
        end
    elseif loaded_version and not current_version then
        re.msg("Debug: Loaded subtable " .. subtable_name .. " has version but current config doesn't have version field")
        return
    elseif not loaded_version and current_version then
        re.msg("Debug: Loaded subtable " .. subtable_name .. " has no version field")
        return
    end
    
    -- Apply loaded subtable to current config
    for key, value in pairs(loaded_subtable) do
        if core.config[subtable_name][key] ~= nil then
            core.config[subtable_name][key] = value
        end
    end
end

function core.migrate_config(config_data, from_version, to_version, subtable_name)
    -- Determine conversion directory
    local conversion_dir = subtable_name == "" and "hud_extensions\\conversion\\" or "hud_extensions\\conversion\\" .. subtable_name .. "\\"
    
    -- Try to find a conversion table for this migration
    local conversion_file = conversion_dir .. from_version .. "_to_" .. to_version .. ".json"
    local conversion_table = json.load_file(conversion_file)
    
    if not conversion_table then
        re.msg("Debug: No conversion table found at " .. conversion_file)
        return nil
    end
    
    -- Apply conversion
    local migrated_config = {}
    for key, value in pairs(config_data) do
        migrated_config[key] = value
    end
    
    -- Apply field mappings if specified in conversion table
    if conversion_table.field_mappings then
        for old_key, new_key in pairs(conversion_table.field_mappings) do
            if migrated_config[old_key] ~= nil then
                migrated_config[new_key] = migrated_config[old_key]
                migrated_config[old_key] = nil
            end
        end
    end
    
    -- Apply value transformations if specified
    if conversion_table.value_transforms then
        for key, transform in pairs(conversion_table.value_transforms) do
            if migrated_config[key] ~= nil and transform[tostring(migrated_config[key])] then
                migrated_config[key] = transform[tostring(migrated_config[key])]
            end
        end
    end
    
    -- Set the new version
    migrated_config.version = to_version
    
    -- Check if migration result exists in default config
    local default_config = subtable_name == "" and core.config or core.config[subtable_name]
    if not default_config then
        re.msg("Debug: No default config found for validation after migration")
        return nil
    end
    
    -- Validate that all keys in migrated config exist in default
    for key, _ in pairs(migrated_config) do
        if default_config[key] == nil then
            re.msg("Debug: Migrated config contains key '" .. key .. "' that doesn't exist in default config")
            return nil
        end
    end
    
    -- Apply key conversions if needed (additional step after migration)
    if conversion_table.new_subtable then
        -- For key conversion, look for files in the new subtable directory
        local key_conversion_dir = "hud_extensions\\conversion\\" .. conversion_table.new_subtable .. "\\"
        local key_conversion_file = key_conversion_dir .. to_version .. ".json"
        local key_conversion_table = json.load_file(key_conversion_file)
        if key_conversion_table and key_conversion_table.key_renames then
            for old_key, new_key in pairs(key_conversion_table.key_renames) do
                if migrated_config[old_key] ~= nil then
                    migrated_config[new_key] = migrated_config[old_key]
                    migrated_config[old_key] = nil
                end
            end
        else
            re.msg("Debug: Key conversion table not found at " .. key_conversion_file)
        end
    end
    
    return migrated_config
end

core.singletons = {
	environment_manager = sdk.get_managed_singleton("app.EnvironmentManager"),
	mission_manager     = sdk.get_managed_singleton("app.MissionManager"),
	fade_manager        = sdk.get_managed_singleton("app.FadeManager"),
	gui_manager         = sdk.get_managed_singleton("app.GUIManager"),
	player_manager      = sdk.get_managed_singleton("app.PlayerManager"),
	minigame_manager    = sdk.get_managed_singleton("app.GameMiniEventManager"),
	facility_manager    = sdk.get_managed_singleton("app.FacilityManager"),
	savedata_manager    = sdk.get_managed_singleton("app.SaveDataManager"),
	network_manager     = sdk.get_managed_singleton("app.NetworkManager")
}

function core.get_savedata()
	local savedata_manager = core.singletons.savedata_manager
	local savedata_idx = savedata_manager:get_field("CurrentUserDataIndex")
	return savedata_manager:get_field("_UserSaveData"):get_field("_Data"):get_element(savedata_idx)
end

---------------------------------------------------
---------------------------------------------------

core.load_data()
core.load_config()

---------------------------------------------------
---------------------------------------------------

return core