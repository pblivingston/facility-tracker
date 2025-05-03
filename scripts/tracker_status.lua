local config_path = "tracker_status.json"
local config = {

}

local function load_config()
    local loaded_config = json.load_file(config_path)
    if loaded_config then
        for key, value in pairs(loaded_config) do
            if config[key] ~= nil then
                config[key] = value
            end
        end
    else
        json.dump_file(config_path, config)
    end
end
-- Load the config file
load_config()

local function save_config()
    json.dump_file(config_path, config)
end

local facility_manager = sdk.get_managed_singleton("app.FacilityManager")
local dining_object = facility_manager and facility_manager:get_field("<Dining>k__BackingField")
local timers = facility_manager and facility_manager:get_field("<_FacilityTimers>k__BackingField")
local barter_object = facility_manager and facility_manager:call("get_Barter")
local large_workshop = facility_manager and facility_manager:get_field("<LargeWorkshop>k__BackingField")
local environment_manager = sdk.get_managed_singleton("app.EnvironmentManager")
local fade_manager        = sdk.get_managed_singleton("app.FadeManager")
local player_manager = sdk.get_managed_singleton("app.PlayerManager")
local gui_manager = sdk.get_managed_singleton("app.GUIManager")
local mission_manager = sdk.get_managed_singleton("app.MissionManager")
local field_manager = sdk.get_managed_singleton("app.MasterFieldManager")
local camera_manager = sdk.get_managed_singleton("app.CameraManager")

local character_methods = {
    { label = "Life Area", method = "get_IsInLifeArea" },
    { label = "Base Camp", method = "get_IsInBaseCamp" },
	{ label = "Riding", method = "get_IsPorterRiding" },
	{ label = "In saddle", method = "get_IsPorterRidingConstSaddle" },
    { label = "In any", method = "get_IsInAllTent" },
    { label = "In tent", method = "get_IsInTent" },
    { label = "In temp", method = "get_IsInTempTent" },
    { label = "Combat", method = "get_IsCombat" },
    { label = "Half Combat", method = "get_IsHalfCombat" },
    { label = "Combat Cage", method = "get_IsCombatCageLight" },
	{ label = "Draw off", method = "get_IsDrawOff" }
}

re.on_draw_ui(function()
	if imgui.tree_node("Event Cam") then
		local event = camera_manager and camera_manager:get_field("_IsEventCamera")
		imgui.text("Event: " .. tostring(event))
		imgui.tree_pop()
	end
	
	if imgui.tree_node("Mission") then
		local success, result = pcall(function() return mission_manager:call("isFastTravel") end)
		imgui.text("result: " .. tostring(result))
		imgui.tree_pop()
	end
	
	if imgui.tree_node("Stage") then
		local stage = environment_manager and environment_manager:get_field("_CurrentStage")
		imgui.text("Stage: " .. tostring(stage))
		imgui.tree_pop()
	end
	
	if imgui.tree_node("GUI Methods") then
		if gui_manager then
			local success, result = pcall(function() return gui_manager:get_field("<TitleAfterLogin>k__BackingField") end)
			imgui.text("Result: " .. tostring(result))
		else
			imgui.text("GUI not found.")
		end

        imgui.tree_pop()
	end
	
    if imgui.tree_node("Player") then
        if player_manager then
            local info = player_manager:call("getMasterPlayerInfo")
            local character = info and info:get_field("<Character>k__BackingField")

            if character then
                for _, entry in ipairs(character_methods) do
                    local success, result = pcall(function() return character:call(entry.method) end)
                    if success then
                        imgui.text(string.format("%s: %s", entry.label, tostring(result)))
                    else
                        imgui.text(string.format("%s: Error calling %s", entry.label, entry.method))
                    end
                end
            else
                imgui.text("Character not found.")
            end
        else
            imgui.text("Player Manager not found.")
        end
        imgui.tree_pop()
    end

    if imgui.tree_node("Facility Timer Info") then
        if timers then
            local size = timers:get_field("_size")
            imgui.text("Timer count: " .. tostring(size))

            for i = 0, size - 1 do
                local timer = timers:get_Item(i)
                local get_time_func = timer:get_field("<GetTimeFunc>k__BackingField")

                if get_time_func ~= nil then
                    local success, value = pcall(function() return get_time_func:call("Invoke") end)
                    if success then
                        imgui.text(string.format("Timer %d Remaining Time: %.2f", i, value))
                    else
                        imgui.text(string.format("Timer %d -> Failed to invoke: %s", i, value))
                    end
                else
                    imgui.text(string.format("Timer %d -> No GetTimeFunc", i))
                end
            end
        else
            imgui.text("Timers not found.")
        end
        imgui.tree_pop()
    end
	
    if imgui.tree_node("Support Ship") then
        if facility_manager then
            local ship = facility_manager:get_field("<Ship>k__BackingField")
            if ship then
                -- Check if the ship is in port
                local success_in_port, is_in_port = pcall(function() return ship:call("isInPort") end)
                if success_in_port then
                    imgui.text("Is in port: " .. tostring(is_in_port))
                else
                    imgui.text("Failed to check ship status.")
                end

                -- Check if the ship is near departure
                local success_near_departure, is_near_departure = pcall(function() return ship:call("IsNearDeparture") end)
                if success_near_departure then
                    imgui.text("Is near departure: " .. tostring(is_near_departure))
                else
                    imgui.text("Failed to check departure status.")
                end

                -- Display _DayCount
                local day_count = ship:get_field("_DayCount")
                if day_count then
                    imgui.text("Day Count: " .. tostring(day_count))
                else
                    imgui.text("Day Count: Unknown")
                end

            else
                imgui.text("Ship object not found.")
            end
        else
            imgui.text("Facility Manager not found.")
        end
        imgui.tree_pop()
    end
end)
