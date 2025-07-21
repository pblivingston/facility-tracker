local core = {}

local config_path = "facility_tracker.json"
local user_config_dir = "hud_extensions\\user_config"

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

function core.get_mode(tbl)
    local counts = {}
    for k, v in pairs(tbl) do
        counts[v] = (counts[v] or 0) + 1
    end

    local mode, mode_count = nil, 0
    for v, count in pairs(counts) do
        if count > mode_count then
            mode, mode_count = v, count
        end
    end

    return mode
end

function core.keys_to_num(tbl)
	local new_tbl = {}
	for k, v in pairs(tbl) do
		k = tonumber(k) or k
		new_tbl[k] = v
	end
	return new_tbl
end

function core.get_nested(tbl, key)
    for part in string.gmatch(key, "[^%.]+") do
        if tbl == nil then return nil end
        tbl = tbl[part]
    end
    return tbl
end

function core.set_nested(tbl, key, value)
    local parts = {}
    for part in string.gmatch(key, "[^%.]+") do
        table.insert(parts, part)
    end
    for i = 1, #parts-1 do
        tbl = tbl[parts[i]]
        if tbl == nil then return end
    end
    tbl[parts[#parts]] = value
end

function core.load_data(folder)
	local dir = folder and "hud_extensions\\" .. folder or "hud_extensions"
	if folder then core[folder] = core[folder] or {} end
	for _, path in ipairs(fs.glob(dir .. [[\\[^\\]+\.*json]])) do
		local name = path:match(".+\\(.-)%.json$")
		if folder then
			core[folder][name] = core.keys_to_num(json.load_file(path))
		else
			core[name] = core.keys_to_num(json.load_file(path))
		end
	end
end

function core.save_config()
    local main = {}
    for k, v in pairs(core.config) do
        if type(v) ~= "table" then main[k] = v end
    end
    json.dump_file(config_path, main)
    for k, v in pairs(core.config) do
        if type(v) == "table" then
            json.dump_file(user_config_dir .. "/" .. k .. ".json", v)
        end
    end
end

local function compare_versions(a, b)
    local a_parts = {}
    for part in string.gmatch(a, "%d+") do table.insert(a_parts, tonumber(part)) end
    local b_parts = {}
    for part in string.gmatch(b, "%d+") do table.insert(b_parts, tonumber(part)) end

    for i = 1, math.max(#a_parts, #b_parts) do
        local a_num = a_parts[i] or 0
        local b_num = b_parts[i] or 0
        if a_num < b_num then return -1 end
        if a_num > b_num then return 1 end
    end
    return 0 -- versions are equal
end

local function migrate(loaded, name)
	local default = name and core.config[name] or core.config
	local v, dv = loaded.version or "0.0.0", default.version or "0.0.0"
	if compare_versions(v, dv) > 0 then return default end
	local conv_path = name and "hud_extensions/conversion/" .. name or "hud_extensions/conversion"
	local conv = compare_versions(v, dv) < 0 and json.load_file(conv_path .. "/" .. v .. ".json")
    
	local function process_table(tbl, pk)
		for k, val in pairs(tbl) do
			if k == "version" then goto continue end
			local bk = pk and (pk .. "." .. k) or k
			local ck = conv and conv[bk]
			if type(val) == "table" then
				process_table(val, bk)
			elseif ck and type(ck) == "table" then
				for _, nk in ipairs(ck) do
					if core.get_nested(core.config, nk) then
						core.set_nested(core.config, nk, val)
					end
				end
			elseif core.get_nested(default, ck or bk) then
				core.set_nested(default, ck or bk, val)
			end
			::continue::
		end
	end
    
	process_table(loaded)
	default.version = dv
    return default
end

function core.load_config()
    local lm = json.load_file(config_path)
    if lm then core.config = migrate(lm) end
    for _, path in ipairs(fs.glob(user_config_dir .. [[\.*json]])) do
        local n = path:match(".+\\(.-)%.json$")
        local lsub = json.load_file(path)
        if n and lsub and core.config[n] then
            core.config[n] = migrate(lsub, n)
        end
    end
    core.save_config()
end

function core.backup_config(mod_name, ts)
	ts = ts or os.date("%Y-%m-%d_%H-%M-%S")
	local dir = "hud_extensions/backups/" .. ts .. "/"
	if mod_name then
		local backup = dir .. user_config_dir .. "/" .. mod_name .. ".json"
		json.dump_file(backup, core.config[mod_name])
	else
		local backup = dir .. config_path
		local current = {}
		for k, v in pairs(core.config) do
			if type(v) ~= "table" then current[k] = v end
		end
		json.dump_file(backup, current)
	end
end

function core.reset_config(mod_name, ts)
	core.backup_config(mod_name, ts)
	local path = mod_name and "hud_extensions/config/" .. mod_name .. ".json" or "hud_extensions/config.json"
	local default = json.load_file(path)
	for k, v in pairs(default) do
		local nk = mod_name and string.format("%s.%s", mod_name, k) or k
		core.set_nested(core.config, nk, v)
	end
	core.save_config()
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