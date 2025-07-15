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

-- function core.load_data(folder)
	-- local dir = folder and "hud_extensions\\" .. folder or "hud_extensions"
	-- for _, path in ipairs(fs.glob(dir .. [[\\.*json]])) do
		-- local name = path:sub(#dir + 2, -6)
		-- core[name] = core.keys_to_num(json.load_file(path))
	-- end
-- end

function core.load_data(folder)
	local dir = folder and "hud_extensions\\" .. folder or "hud_extensions"
	if folder then core[folder] = core[folder] or {} end
	for _, path in ipairs(fs.glob(dir .. [[\\.*json]])) do
		local name = path:sub(#dir + 2, -6)
		if folder then
			core[folder][name] = core.keys_to_num(json.load_file(path))
		else
			core[name] = core.keys_to_num(json.load_file(path))
		end
	end
end

local config_path = "facility_tracker.json"

function core.save_config()
    json.dump_file(config_path, core.config)
end

function core.load_config()
    local loaded_config = json.load_file(config_path)
    if loaded_config then
        for key, value in pairs(loaded_config) do
            if core.config[key] ~= nil then
                core.config[key] = value
            end
        end
    else
        core.save_config()
    end
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
core.load_data("config")
core.load_config()

---------------------------------------------------
---------------------------------------------------

return core