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
local gui_manager = sdk.get_managed_singleton("app.GUIManager")

local character_methods = {
    { label = "Draw off", method = "get_IsDrawOff" },
    { label = "Combat", method = "get_IsCombat" },
    { label = "Half Combat", method = "get_IsHalfCombat" },
    { label = "Combat Cage", method = "get_IsCombatCageLight" },
    { label = "Life Area", method = "get_IsInLifeArea" },
    { label = "Base Camp", method = "get_IsInBaseCamp" },
    { label = "Camp Layout", method = "get_IsCampLayoutMode" },
    { label = "In any", method = "get_IsInAllTent" },
    { label = "In tent", method = "get_IsInTent" },
    { label = "In temp", method = "get_IsInTempTent" },
    { label = "Climbing", method = "get_IsClimbWall" },
    { label = "In dam", method = "get_IsInDam" },
    { label = "In stream", method = "get_IsInMuddyStream" },
    { label = "In wave", method = "get_IsInEnemyWave" },
    { label = "In hot area", method = "get_IsInHotArea" },
    { label = "In cold area", method = "get_IsInColdArea" },
    { label = "In select area", method = "IsInSelectArea" },
    { label = "Gimmick Cancel", method = "get_IsGimmickPullCancel" },
    { label = "Strong slinger", method = "get_IsCanShootStrongSringer" },
    { label = "Riding", method = "get_IsPorterRiding" },
    { label = "Riding saddle", method = "get_IsPorterRidingConstSaddle" },
    { label = "Can call ride", method = "isEnablePorterCall" },
}

local element_fields = {
	{ label = "Vertical Type", field = "<VerticalType>k__BackingField" },
	{ label = "All Slider", field = "<IsAllSliderMode>k__BackingField" },
	{ label = "Slinger Ammo", field = "<LoadedSlingerAmmo>k__BackingField" },
	{ label = "Pouch Changed", field = "<_IsPouchChanged>k__BackingField" },
	{ label = "Initialized", field = "<_Initialized>k__BackingField" },
	{ label = "Init cursor", field = "<_RequestInitCursor>k__BackingField" },
	{ label = "Selected Item", field = "<SelectedItemId>k__BackingField" },
	{ label = "Custom Shortcut", field = "<IsCustomShortcutActive>k__BackingField" },
	{ label = "Input", field = "<IsInput>k__BackingField" },
	{ label = "Last Input Device", field = "<_LastInputDevice>k__BackingField" },
	{ label = "Slinger Set", field = "<IsSlingerSet>k__BackingField" },
	{ label = "Button option", field = "<_DKEY_AND_BUTTON_OP>k__BackingField" },
	{ label = "Item Slider", field = "<IsItemSliderMode>k__BackingField" },
	{ label = "Slinger Aim", field = "<_IsSlingerAimMode>k__BackingField" },
	{ label = "Toggle", field = "<_IsToggle>k__BackingField" },
	{ label = "Direct", field = "<_IsDirect>k__BackingField" },
	{ label = "Kinoko Level", field = "<_KinokoLevel>k__BackingField" },
	{ label = "Open Button", field = "_OpenButton" },
	{ label = "Open Button Reset", field = "_ForceOpenButtonReset" },
	{ label = "Open Time", field = "OPEN_TIME" },
	{ label = "Open Timer", field = "<_OpenTimer>k__BackingField" },
	{ label = "Don't Select", field = "<DontSelect>k__BackingField" },
	{ label = "Input Item All Old", field = "<_InputItemAllOld>k__BackingField" }
}

local fading_methods = {
	{ label = "fading any", method = "get_IsFadingAny" },
	{ label = "fading complete all", method = "get_IsFadingCompleteAll" },
	{ label = "invisible any", method = "get_IsVisibleStateAny" },
	{ label = "fading app", method = "get_IsFadingApp" },
	{ label = "fading app 2nd", method = "get_IsFadingApp2nd" },
	{ label = "fading scene", method = "get_IsFadingScene" },
	{ label = "fading story", method = "get_IsFadingStory" },
	{ label = "fading story white", method = "get_IsFadingStoryWhite" },
	{ label = "fading event", method = "get_IsFadingEvent" },
	{ label = "fading event raw UI", method = "get_IsFadingEventRawUI" },
	{ label = "fade out app", method = "get_IsFadeOutApp" },
	{ label = "fade out app 2nd", method = "get_IsFadeOutApp2nd" },
	{ label = "fade out scene", method = "get_IsFadeOutScene" },
	{ label = "fade out story", method = "get_IsFadeOutStory" },
	{ label = "fade out story white", method = "get_IsFadeOutStoryWhite" },
	{ label = "fade in app", method = "get_IsFadeInApp" },
	{ label = "fade in app 2nd", method = "get_IsFadeInApp2nd" },
	{ label = "fade in scene", method = "get_IsFadeInScene" },
	{ label = "fade in story", method = "get_IsFadeInStory" },
	{ label = "fade in story white", method = "get_IsFadeInStoryWhite" },
	{ label = "invisible app", method = "get_IsVisibleStateApp" },
	{ label = "invisible app 2nd", method = "get_IsVisibleStateApp2nd" },
	{ label = "invisible scene", method = "get_IsVisibleStateScene" },
	{ label = "invisible story", method = "get_IsVisibleStateStory" },
	{ label = "invisible story white", method = "get_IsVisibleStateStoryWhite" },
	{ label = "invisible event", method = "get_IsVisibleStateEvent" },
	{ label = "invisible event raw UI", method = "get_IsVisibleStateEventRawUI" },
}

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

local function get_Item_GUI()
	if gui_manager then
		local gui_accessor = gui_manager and gui_manager:get_field("<GUI020006Accessor>k__BackingField")
		local guis_field = gui_accessor and gui_accessor:get_field("GUIs")
		local enumerator = guis_field and guis_field:call("GetEnumerator")
		local mArray = enumerator and enumerator:get_field("mArray")
		local element = mArray and mArray:get_element(0)
	end
	return element
end

re.on_draw_ui(function()
	if imgui.tree_node("GUI Methods") then
		if gui_manager then
			local success, result = pcall(function() return gui_manager:call("isNpcMenuOpen") end)
			imgui.text("Result: " .. tostring(result))
		else
			imgui.text("GUI not found.")
		end
		imgui.tree_pop()
	end
	
	if imgui.tree_node("Item GUI Methods") then
		local gui_accessor = gui_manager and gui_manager:get_field("<GUI020006Accessor>k__BackingField")
		local guis_field = gui_accessor and gui_accessor:get_field("GUIs")
		local enumerator = guis_field and guis_field:call("GetEnumerator")
		local mArray = enumerator and enumerator:get_field("mArray")
		local element = mArray and mArray:get_element(0)
		if element then
			local hud_visible = element:call("isHudVisible")
			local visible = element:call("isVisible")
			local awake_0 = element:call("<guiHudAwake>b__139_0")
			local awake_1 = element:call("<guiHudAwake>b__139_1")
			
			imgui.text("HUD Visible: " .. tostring(hud_visible))
			imgui.text("Visible: " .. tostring(visible))
			imgui.text("Awake 0: " .. tostring(awake_0))
			imgui.text("Awake 1: " .. tostring(awake_1))
		else
			imgui.text("Element not found.")
		end
		imgui.tree_pop()
	end
	
	if imgui.tree_node("Item GUI Fields") then
		local gui_accessor = gui_manager and gui_manager:get_field("<GUI020006Accessor>k__BackingField")
		local guis_field = gui_accessor and gui_accessor:get_field("GUIs")
		local enumerator = guis_field and guis_field:call("GetEnumerator")
		local mArray = enumerator and enumerator:get_field("mArray")
		local element = mArray and mArray:get_element(0)
		if element then
            for _, entry in ipairs(element_fields) do
                local success, result = pcall(function() return element:get_field(entry.field) end)
                if success then
                    imgui.text(string.format("%s: %s", entry.label, tostring(result)))
                else
                    imgui.text(string.format("%s: Error getting %s", entry.label, entry.field))
                end
            end
        else
            imgui.text("Element not found.")
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
	
	if imgui.tree_node("Fading") then
		if fade_manager then
			for _, entry in ipairs(fading_methods) do
				local success, result = pcall(function() return fade_manager:call(entry.method) end)
				if success then
					imgui.text(string.format("%s: %s", entry.label, tostring(result)))
				else
					imgui.text(string.format("%s: Error calling %s", entry.label, entry.method))
				end
			end
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
