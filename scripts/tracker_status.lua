local previous_time = 1200
local config_path = "tracker_status.json"
local config = {
    nest_count = 0
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

local function get_timer(timer_index)
    if not timers then return nil end

    local size = timers:get_field("_size")
    if timer_index >= size then return nil end

    local timer = timers:get_Item(timer_index)
    local get_time_func = timer:get_field("<GetTimeFunc>k__BackingField")
    
    if get_time_func then
        local success, value = pcall(function() return get_time_func:call("Invoke") end)
        if not success then
            print("Error invoking GetTimeFunc for index " .. timer_index)
            return nil    
        end
        return value
    end
    return nil
end

local function format_time(timer_value)
    if timer_value == nil then return "" end
    local t = math.floor(timer_value)
    local minutes = math.floor(t / 60)
    local seconds = t % 60
    return string.format("%02d:%02d", minutes, seconds)
end

sdk.hook(
    sdk.find_type_definition("app.Gm262"):get_method("successButtonEvent"),
    function(args)
        config.nest_count = 0
        save_config()
    end,
    nil
)

re.on_draw_ui(function()
    if imgui.tree_node("Player") then
		if player_manager then
			local info = player_manager:call("getMasterPlayerInfo")
			local character = info:get_field("<Character>k__BackingField")
			local draw_off = character:call("get_IsDrawOff")
			local combat = character:call("get_IsCombat")
			local half_combat = character:call("get_IsHalfCombat")
			local combat_cage = character:call("get_IsCombatCageLight")
			local life_area = character:call("get_IsInLifeArea")
			local base_camp = character:call("get_IsInBaseCamp")
			local camp_layout = character:call("get_IsCampLayoutMode")
			local in_all  = character:call("get_IsInAllTent")
			local in_tent = character:call("get_IsInTent")
			local in_temp = character:call("get_IsInTempTent")
			local climb_wall = character:call("get_IsClimbWall")
			local dam = character:call("get_IsInDam")
			local muddy_stream = character:call("get_IsInMuddyStream")
			local enemy_wave = character:call("get_IsInEnemyWave")
			local hot_area = character:call("get_IsInHotArea")
			local cold_area = character:call("get_IsInColdArea")
			local select_area = character:call("IsInSelectArea")
			local gimmick_cancel = character:call("get_IsGimmickPullCancel")
			local strong_sling = character:call("get_IsCanShootStrongSringer")
			local riding = character:call("get_IsPorterRiding")
			local riding_saddle = character:call("get_IsPorterRidingConstSaddle")
			local call_ride = character:call("isEnablePorterCall")
			
			imgui.text("Draw off: " .. tostring(draw_off))
			imgui.text("Combat: " .. tostring(combat))
			imgui.text("Half Combat: " .. tostring(half_combat))
			imgui.text("Combat Cage: " .. tostring(combat_cage))
			imgui.text("Life Area: " .. tostring(life_area))
			imgui.text("Base Camp: " .. tostring(base_camp))
			imgui.text("Camp Layout: " .. tostring(camp_layout))
			imgui.text("In any: " .. tostring(in_all))
			imgui.text("In tent: " .. tostring(in_tent))
			imgui.text("In temp: " .. tostring(in_temp))
			imgui.text("Climbing: " .. tostring(climb_wall))
			imgui.text("In dam: " .. tostring(dam))
			imgui.text("In stream: " .. tostring(muddy_stream))
			imgui.text("In wave: " .. tostring(enemy_wave))
			imgui.text("In hot area: " .. tostring(hot_area))
			imgui.text("In cold area: " .. tostring(cold_area))
			imgui.text("In select area: " .. tostring(select_area))
			imgui.text("Gimmick Cancel: " .. tostring(gimmick_cancel))
			imgui.text("Strong slinger: " .. tostring(strong_sling))
			imgui.text("Riding: " .. tostring(riding))
			imgui.text("Riding saddle: " .. tostring(riding_saddle))
			imgui.text("Can call ride: " .. tostring(call_ride))
		else
			imgui.text("Player Manager not found.")
		end
		imgui.tree_pop()
	end
	
	if imgui.tree_node("Fading") then
		if fade_manager then
			local hidden = fade_manager:call("get_IsVisibleStateAny")
			local fading = fade_manager:call("get_IsFadingAny")
			
			imgui.text("Hidden: " .. tostring(hidden))
			imgui.text("Fading: " .. tostring(fading))
		else
			imgui.text("Fade Manager not found.")
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
