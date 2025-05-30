local re    = re
local sdk   = sdk
local d2d   = d2d
local json  = json
local imgui = imgui

local captured_args       = nil
local character           = nil
local first_run           = false
local hide_tracker        = false
local alt_tracker         = false
local hide_moon           = false
local map_moon            = false
local moon_pos            = "radar"
local menu_open           = false
local map_open            = false
local pugee_open          = false
local current_rest_open   = false
local previous_hidden     = false
local previous_fading     = false
local previous_hide_radar = false
local previous_table_sit  = false
local previous_arm_wrest  = false
local previous_rest_open  = false
local previous_time       = os.clock()
local dt                  = 0
local fade                = 0
local fade_value          = 0
local fade_value_m        = 0
local delay_timer         = 0
local in_delay            = 0.15
local in_speed            = 1
local out_delay           = 0
local out_speed           = 2.5
local map_i_delay         = 0.3
local menu_o_delay        = 0.15
local table_i_delay       = 0.05
local wrestle_i_delay     = 1.75
local rest_io_delay       = 0.18
local moon_idx            = nil
local stage_idx           = {
	plains   = 0,
	forest   = 1,
	basin    = 2,
	cliffs   = 3,
	ruins    = 4,
	trail    = 5,
	tunnel   = 6,
	l_path   = 7,
	approach = 8,
	arena    = 9,
	peak     = 10,
	suja     = 12,
	g_hub    = 14,
	training = 15
}

local situations = {
	arm_wrestling = 42,
	table_sitting = 43
}

local previous_timer_value = {}
local tidx                 = {
    ration  = 0,
    pugee   = 10,
    nest    = 11
}

local is_in_port              = false
local previous_in_port        = true
local is_near_departure       = false
local previous_near_departure = false
local previous_day_count      = 999
local countdown               = 3
local leaving                 = false

local npc_names = {
    [-2058179200] = "Rysher",
    [35]          = "Murtabak",
    [622724160]   = "Apar",
    [1066308736]  = "Plumpeach",
    [1558632320]  = "Sabar"
}

local table_scale      = 0.9
local timer_scale      = 0.42
local flag_scale       = 0.4
local ti_scroll_offset = 0
local tent_ui_scale    = 0.88
local color            = {}
local img              = {}

local imgui_keys = {
    ["Tab"] = 512,
    ["LeftArrow"] = 513,
    ["RightArrow"] = 514,
    ["UpArrow"] = 515,
    ["DownArrow"] = 516,
    ["PageUp"] = 517,
    ["PageDown"] = 518,
    ["Home"] = 519,
    ["End"] = 520,
    ["Insert"] = 521,
    ["Delete"] = 522,
    ["Backspace"] = 523,
    ["Space"] = 524,
    ["Enter"] = 525,
    ["None"] = 526,      -- Escape
    ["LeftCtrl"] = 527,
    ["LeftShift"] = 528,
    ["LeftAlt"] = 529,
    ["LeftSuper"] = 530,
    ["RightCtrl"] = 531,
    ["RightShift"] = 532,
    ["RightAlt"] = 533,
    ["RightSuper"] = 534,
    ["Menu"] = 535,
    ["Num0"] = 536,
    ["Num1"] = 537,
    ["Num2"] = 538,
    ["Num3"] = 539,
    ["Num4"] = 540,
    ["Num5"] = 541,
    ["Num6"] = 542,
    ["Num7"] = 543,
    ["Num8"] = 544,
    ["Num9"] = 545,
    ["A"] = 546,
    ["B"] = 547,
    ["C"] = 548,
    ["D"] = 549,
    ["E"] = 550,
    ["F"] = 551,
    ["G"] = 552,
    ["H"] = 553,
    ["I"] = 554,
    ["J"] = 555,
    ["K"] = 556,
    ["L"] = 557,
    ["M"] = 558,
    ["N"] = 559,
    ["O"] = 560,
    ["P"] = 561,
    ["Q"] = 562,
    ["R"] = 563,
    ["S"] = 564,
    ["T"] = 565,
    ["U"] = 566,
    ["V"] = 567,
    ["W"] = 568,
    ["X"] = 569,
    ["Y"] = 570,
    ["Z"] = 571,
    ["F1"] = 572,
    ["F2"] = 573,
    ["F3"] = 574,
    ["F4"] = 575,
    ["F5"] = 576,
    ["F6"] = 577,
    ["F7"] = 578,
    ["F8"] = 579,
    ["F9"] = 580,
    ["F10"] = 581,
    ["F11"] = 582,
    ["F12"] = 583,
    ["F13"] = 584,
    ["F14"] = 585,
    ["F15"] = 586,
    ["F16"] = 587,
    ["F17"] = 588,
    ["F18"] = 589,
    ["F19"] = 590,
    ["F20"] = 591,
    ["F21"] = 592,
    ["F22"] = 593,
    ["F23"] = 594,
    ["F24"] = 595,
    ["Apostrophe"] = 596,   -- '
    ["Comma"] = 597,        -- ,
    ["Minus"] = 598,        -- -
    ["Period"] = 599,       -- .
    ["Slash"] = 600,        -- /
    ["Semicolon"] = 601,    -- ;
    ["Equal"] = 602,        -- =
    ["LeftBracket"] = 603,  -- [
    ["Backslash"] = 604,    -- \
    ["RightBracket"] = 605, -- ]
    ["GraveAccent"] = 606,  -- `
    ["CapsLock"] = 607,
    ["ScrollLock"] = 608,
    ["NumLock"] = 609,
    ["PrintScreen"] = 610,
    ["Pause"] = 611,
    ["Keypad0"] = 612,
    ["Keypad1"] = 613,
    ["Keypad2"] = 614,
    ["Keypad3"] = 615,
    ["Keypad4"] = 616,
    ["Keypad5"] = 617,
    ["Keypad6"] = 618,
    ["Keypad7"] = 619,
    ["Keypad8"] = 620,
    ["Keypad9"] = 621,
    ["KeypadDecimal"] = 622,
    ["KeypadDivide"] = 623,
    ["KeypadMultiply"] = 624,
    ["KeypadSubtract"] = 625,
    ["KeypadAdd"] = 626,
    ["KeypadEnter"] = 627,
    ["KeypadEqual"] = 628
}

local config_path = "facility_tracker.json"
local config = {
    countdown 	   = 3,
	tr_hotkey      = "None",
	mo_hotkey      = "None",
    draw_ticker    = false,
	draw_tracker   = true,
	draw_bars      = true,
    draw_timers    = false,
	draw_flags     = true,
	auto_hide      = true,
	hide_w_hud     = true,
	hide_w_bowling = false,
	hide_w_wrestle = false,
	hide_at_table  = false,
	show_when      = "Don't show when:",
	hide_in_tent   = false,
	hide_on_map    = false,
	hide_in_quest  = false,
	hide_in_combat = false,
	hide_in_qstcbt = false,
	hide_in_hlfcbt = false,
	draw_in_tent   = true,
	draw_on_map    = true,
	draw_in_life   = true,
	draw_in_base   = true,
	draw_in_train  = false,
    ti_user_scale  = 1.0,
    ti_speed_scale = 1.0,
    ti_opacity     = 1.0,
    tr_user_scale  = 1.0,
    tr_opacity     = 1.0,
	draw_moon      = true,
	draw_m_num     = false,
	auto_hide_m    = true,
	box_datas	   = {
		Rations   = { size = 10, timer = 600 },
		Shares    = { size = 100 },
		Nest      = { count = 0, size = 5, timer = 1200 },
		pugee     = { timer = 2520 },
		retrieval = { full = false },
		Rysher    = { count = 0, size = 16 },
		Murtabak  = { count = 0, size = 16 },
		Apar      = { count = 0, size = 16 },
		Plumpeach = { count = 0, size = 16 },
		Sabar     = { count = 0, size = 16 }
	}
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

local function capture_args(args)
    captured_args = args
end

local function get_index(indexed_table, value)
	for i, e in ipairs(indexed_table) do
		if e == value then
			return i
		end
	end
	return nil
end

local hotkey_listening = {
	tr_hotkey = false,
	mo_hotkey = false
}

local hotkey_messages  = {
	tr_hotkey = config.tr_hotkey or "None",
	mo_hotkey = config.mo_hotkey or "None"
}

local function get_new_hotkey(hotkey)
	for key_name, key_index in pairs(imgui_keys) do
		if imgui.is_key_pressed(key_index) then
			config[hotkey] = key_name
			hotkey_messages[hotkey] = key_name
			hotkey_listening[hotkey] = false
			save_config()
			break
		end
	end
end

local facility_manager    = sdk.get_managed_singleton("app.FacilityManager")
local environment_manager = sdk.get_managed_singleton("app.EnvironmentManager")
local mission_manager     = sdk.get_managed_singleton("app.MissionManager")
local fade_manager        = sdk.get_managed_singleton("app.FadeManager")
local gui_manager         = sdk.get_managed_singleton("app.GUIManager")
local player_manager      = sdk.get_managed_singleton("app.PlayerManager")
local npc_manager         = sdk.get_managed_singleton("app.NpcManager")
local minigame_manager    = sdk.get_managed_singleton("app.GameMiniEventManager")

local function is_active_player()
	local info_success, info = pcall(function() return player_manager:call("getMasterPlayerInfo") end)
	if not (info_success and info) then
		return false
	end
	local character_success, character_result = pcall(function() return info:get_field("<Character>k__BackingField") end)
	if not (character_success and character_result) then
		return false
	end
	character = character_result
	
	local moon_cont_success, moon_controller = pcall(function() return environment_manager:get_field("_MoonController") end)
	if not (moon_cont_success and moon_controller) then
		return false
	end
	local moon_data_success, active_moon_data = pcall(function() return moon_controller:get_field("_MainData") end)
	if not (moon_data_success and active_moon_data) then
		return false
	end
	moon_idx = active_moon_data:call("get_MoonIdx")
	
	return true
end

local function is_active_situation(situation)
	local mask_manager = gui_manager:get_field("<ContentsMaskModule>k__BackingField")
	local active_situations = mask_manager:get_field("_CurrentActiveSituations"):get_field("_items")
	for _, element in ipairs(active_situations) do
		local success, value = pcall(function() return element:get_field("value__") end)
		if success and value == situations[situation] then
			return true
		end
	end
	return false
end

sdk.hook(
	npc_manager:get_type_definition():get_method("openFacilityFromNpc"),
	function(args)
		local npc_address = sdk.to_int64(args[3])
		pugee_open = npc_address == 46
	end,
	nil
)

sdk.hook(
	sdk.find_type_definition("app.GUI090302"):get_method("onOpen"),
	function(args)
		current_rest_open = true
	end,
	nil
)

sdk.hook(
	sdk.find_type_definition("app.GUI090302"):get_method("onClose"),
	function(args)
		current_rest_open = false
	end,
	nil
)

local function get_hidden()
	local map_controller     = gui_manager:get_field("<MAP3D>k__BackingField")
	local active_quest       = mission_manager:call("get_IsActiveQuest")
	local quest_end          = mission_manager:call("get_IsQuestEndShowing")
	local is_in_tent         = character:call("get_IsInAllTent")
	local in_base_camp       = character:call("get_IsInBaseCamp") and not (is_in_tent or map_open)
	local in_life_area       = character:call("get_IsInLifeArea") and not (is_in_tent or map_open or in_base_camp)
	local in_combat          = character:call("get_IsCombat")
	local half_combat        = character:call("get_IsHalfCombat")
	local current_hide_radar = map_controller:call("isCheckHideRadar")
	local radar_visible      = map_controller:call("isRadarVisible")
	local map_flow_manager   = map_controller:get_field("_Flow")
	local change_area        = map_flow_manager:call("checkChangeArea")
	local is_bowling         = minigame_manager:get_field("_Bowling"):call("get_IsPlaying")
	local stage_id           = environment_manager:get_field("_CurrentStage")
	local current_table_sit  = is_active_situation("table_sitting")
	local current_arm_wrest  = is_active_situation("arm_wrestling")
	local in_training        = stage_id == stage_idx.training and not (is_in_tent or map_open)
	local quest_combat       = active_quest and in_combat
	
	local hide_w_bowling     = is_bowling and config.hide_w_bowling
	local hide_w_wrestle     = previous_arm_wrest and config.hide_w_wrestle
	local hide_at_table      = previous_table_sit and config.hide_at_table
	
	local dont_show          = config.show_when == "Don't show when:"
	local hide_in_tent       = is_in_tent and config.hide_in_tent
	local hide_on_map        = map_open and config.hide_on_map
	local hide_in_quest      = active_quest and config.hide_in_quest and not config.hide_in_qstcbt
	local hide_in_combat     = in_combat and config.hide_in_combat and not config.hide_in_qstcbt
	local hide_in_qstcbt     = quest_combat and config.hide_in_qstcbt
	local hide_in_hlfcbt     = half_combat and config.hide_in_hlfcbt and (config.hide_in_combat or (active_quest and config.hide_in_qstcbt))

	local only_show          = config.show_when == "Only show when:"
	local draw_in_tent       = is_in_tent and config.draw_in_tent
	local draw_on_map        = map_open and config.draw_on_map
	local draw_in_life       = in_life_area and config.draw_in_life
	local draw_in_base       = in_base_camp and config.draw_in_base
	local draw_in_train      = in_training and config.draw_in_train

	local dont_show_hide     = dont_show and (hide_in_tent or hide_on_map or hide_in_quest or hide_in_combat or hide_in_qstcbt or hide_in_hlfcbt)
	local only_show_hide     = only_show and not (draw_in_tent or draw_on_map or draw_in_life or draw_in_base or draw_in_train)
	local hide_w_hud         = config.hide_w_hud and (pugee_open or quest_end or hide_w_bowling or hide_w_wrestle or hide_at_table)
	
	local hide_tr_cond       = map_open or dont_show_hide or only_show_hide or (config.hide_w_hud and (menu_open or not (is_in_tent or in_training)))
	local hide_mo_cond       = map_open or quest_end or pugee_open or is_bowling or previous_table_sit or previous_arm_wrest or in_training
	
	local cur_map_flow = ""
	local cur_success, cur_flow = pcall(function() return map_flow_manager:get_field("_CurFlow") end)
	if cur_success and cur_flow then
		cur_map_flow = string.sub(cur_flow:get_type_definition():get_name(), #"cGUIMapFlow" + 1)
	end
	
	local next_map_flow = ""
	local next_success, next_flow = pcall(function() return map_flow_manager:get_field("_NextFlow") end)
	if next_success and next_flow then
		next_map_flow = string.sub(next_flow:get_type_definition():get_name(), #"cGUIMapFlow" + 1)
	end
	
	if previous_table_sit and not current_table_sit then
		delay_timer = delay_timer + dt
		if delay_timer >= table_i_delay then
			previous_table_sit = current_table_sit
			delay_timer = 0
		end
	else
		previous_table_sit = current_table_sit
	end
	
	if previous_arm_wrest and not current_arm_wrest then
		delay_timer = delay_timer + dt
		if delay_timer >= wrestle_i_delay then
			previous_arm_wrest = current_arm_wrest
			delay_timer = 0
		end
	else
		previous_arm_wrest = current_arm_wrest
	end
	
	if previous_rest_open ~= current_rest_open then
		delay_timer = delay_timer + dt
		if delay_timer >= rest_io_delay then
			previous_rest_open = current_rest_open
			delay_timer = 0
		end
	else
		previous_rest_open = current_rest_open
	end

	if cur_map_flow == "Wait" then
		hide_tracker = hide_tr_cond
		alt_tracker = is_in_tent or map_open
		hide_moon = not previous_rest_open
		moon_pos = is_in_tent and "rest" or "radar"
	end
	
	if cur_map_flow == "OpenMask" then
	
	end
	
	if cur_map_flow == "OpenModel" then
		alt_tracker = true
		map_moon = true
		moon_pos = "map"
	end
	
	if cur_map_flow == "Active" then
		hide_tracker = (dont_show and config.hide_on_map) or (only_show and not config.draw_on_map)
		alt_tracker = true
		hide_moon = change_area
		map_moon = true
		moon_pos = "map"
	end
	
	if cur_map_flow == "CloseModel" then
	
	end
	
	if cur_map_flow == "CloseMask" then
		hide_tracker = true
		alt_tracker = true
		hide_moon = true
		map_moon = true
		moon_pos = "map"
	end
	
	if cur_map_flow == "OpenRadarMask" then
		alt_tracker = false
		map_moon = false
		moon_pos = "radar"
	end
	
	if cur_map_flow == "OpenRadar" then
		hide_tracker = map_open or dont_show_hide or only_show_hide or hide_w_hud
		alt_tracker = false
		hide_moon = hide_mo_cond
		map_moon = false
		moon_pos = "radar"
	end
	
	if cur_map_flow == "RadarActive" then
		hide_tracker = dont_show_hide or only_show_hide or hide_w_hud
		alt_tracker = false
		hide_moon = hide_mo_cond
		map_moon = false
		moon_pos = "radar"
		map_open = false
		menu_open = false
	end
	
	if cur_map_flow == "WaitOpenReq" then
		map_open = true
	end
	
	if cur_map_flow == "CloseRadarModel" then
	
	end
	
	if cur_map_flow == "CloseRadarMask" then
		hide_tracker = hide_tr_cond
		alt_tracker = is_in_tent
		hide_moon = true
		map_moon = false
		moon_pos = is_in_tent and "rest" or "radar"
	end
	
	if cur_map_flow == "" then
	
	end
	
	if stage_id == stage_idx.training then
		if not (map_open or is_in_tent) and previous_hide_radar and not current_hide_radar then
			menu_open = true
			delay_timer = delay_timer + dt
			if delay_timer >= menu_o_delay then
				previous_hide_radar = current_hide_radar
				hide_tracker = (dont_show and hide_in_combat) or (only_show and not draw_in_train) or config.hide_w_hud
				delay_timer = 0
			end
		elseif map_open and current_hide_radar and not previous_hide_radar then
			delay_timer = delay_timer + dt
			if delay_timer >= map_i_delay then
				previous_hide_radar = current_hide_radar
				hide_tracker = (dont_show and hide_in_combat) or (only_show and not draw_in_train)
				alt_tracker = false
				map_open = false
				delay_timer = 0
			end
		else
			previous_hide_radar = current_hide_radar
		end
	end
	
	if radar_visible then pugee_open = false end
	if not config.auto_hide then alt_tracker = false end
	if not config.auto_hide_m then map_moon = false end -- moon_pos = "radar"
end

local function get_fade()
	local current_hidden = fade_manager:call("get_IsVisibleStateAny")
	local current_fading = fade_manager:call("get_IsFadingAny")
	
	if current_fading and not previous_fading then
		delay_timer = delay_timer + dt
		if delay_timer >= out_delay then
			fade = math.max(fade - out_speed * dt, 0)
			if fade == 0 then
				previous_fading = current_fading
				delay_timer = 0
			end
		end
	else
		previous_fading = current_fading
	end
	
	if previous_hidden and not current_hidden then
		delay_timer = delay_timer + dt
		if delay_timer >= in_delay then
			fade = math.min(fade + in_speed * dt, 1)
			if fade == 1 then
				previous_hidden = current_hidden
				delay_timer = 0
			end
		end
	else
		previous_hidden = current_hidden
	end
	
	if not current_fading and not previous_hidden then
		fade = 1
	end
	
	if previous_hidden and current_hidden then
		fade = 0
	end
	
	fade_value = config.auto_hide and fade or 1
	fade_value_m = config.auto_hide_m and fade or 1
end

-- === Facility helper functions ===

local function get_timer(timer_index)
	local timers = facility_manager:get_field("<_FacilityTimers>k__BackingField")
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

local function get_timer_msg(timer_index)
    local timer_value = get_timer(timer_index)
    if timer_value and timer_value == previous_timer_value[timer_index] then
        return "00:00"
    end
    if timer_value then
        previous_timer_value[timer_index] = timer_value
        return format_time(timer_value)
    end
    return "ERR"
end

local function get_box_msg(box)
	local count = config.box_datas[box].count
	local size  = config.box_datas[box].size
	return string.format("%s: %d/%d", box, count, size)
end

local function is_box_full(box)
	return config.box_datas[box].full
end

-- === Ingredient Center ===

local function get_ration_state()
	local dining = facility_manager:get_field("<Dining>k__BackingField")
	if not dining then return end
    local timer = get_timer(0)
    config.box_datas.Rations.count = dining:getSuppliableFoodNum()
    config.box_datas.Rations.full = dining:isSuppliableFoodMax()
	if timer > config.box_datas.Rations.timer then
		config.box_datas.Rations.timer = timer
	end
    if config.box_datas.Rations.count > config.box_datas.Rations.size then
        config.box_datas.Rations.size = config.box_datas.Rations.count
    end
    save_config()
end

-- === Support Ship ===

local function get_ship_state()
	local ship = facility_manager:get_field("<Ship>k__BackingField")
    if not ship then return end

    local current_near_departure = ship:call("IsNearDeparture")
    local current_in_port = ship:call("isInPort")
    local current_day_count = ship:get_field("_DayCount")

    if current_in_port then
        if first_run then
			countdown = config.countdown == 0 and 3 or config.countdown
		else
			countdown = previous_in_port and config.countdown or 3
		end
		
		if current_day_count > previous_day_count then
            if countdown <= 1 and current_in_port and previous_in_port then countdown = 0
            elseif current_near_departure and not previous_near_departure then countdown = 1
            elseif countdown == 3 then countdown = 2
            else countdown = 3
            end
        end
		
		config.countdown = countdown
		save_config()
		
		leaving = countdown <= 1
    else
		leaving = false
	end
	previous_in_port = current_in_port
	previous_near_departure = current_near_departure
	previous_day_count = current_day_count
	is_near_departure = current_near_departure
	is_in_port = current_in_port
end

local function get_ship_message()
    if is_in_port then
        if config.countdown == 0 then return "Casting off!" end
		if config.countdown == 1 then return "Leaving soon!" end
		return "In port: " .. config.countdown .. " days"
    end
    return "Away from port"
end

-- === Festival Shares ===

local function get_shares_state()
	local workshop = facility_manager:get_field("<LargeWorkshop>k__BackingField")
    if not workshop then return end
    local reward_items = workshop:call("getRewardItems")
    if not reward_items then return end
    config.box_datas.Shares.count = reward_items:get_field("_size") or 0
    config.box_datas.Shares.full  = workshop:call("isFullRewardItems")
    config.box_datas.Shares.ready = workshop:call("canReceiveRewardItems")

    if config.box_datas.Shares.count > config.box_datas.Shares.size then
        config.box_datas.Shares.size = config.box_datas.Shares.count
    end
    save_config()
end

-- === Material Retrieval ===

local function get_retrieval_state()
	local retrieval = facility_manager:get_field("<Collection>k__BackingField")
	if not retrieval then return end
	config.box_datas.retrieval.full = retrieval:call("isAnyFullCollectionItems")
end

-- Update box_datas on addCollectionItem
sdk.hook(
    sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("addCollectionItem"),
    capture_args,
    function(retval, args)
        local args = captured_args
        local npc = sdk.to_managed_object(args[2])
        if not npc then
            print("Debug: NPC object is nil.")
            return retval
        end
    
        local npc_fixed_id = npc:get_field("NPCFixedId")
        if not npc_fixed_id then
            print("Debug: NPCFixedId is nil.")
            return retval
        end
    
        local npc_name = npc_names[npc_fixed_id]
        if not npc_name then
            print(string.format("Debug: NPCFixedId %d not found in npc_names table.", npc_fixed_id))
            return retval
        end
    
        local success_items, collection_items = pcall(function() return npc:call("getCollectionItems") end)
        if success_items and collection_items and collection_items.get_size then
            local size = collection_items:get_size()
            local valid_count = 0
    
            for i = 0, size - 1 do
                local item = collection_items:get_element(i)
                if item then
                    local num = item:get_field("Num")
                    if num and num > 0 then
                        valid_count = valid_count + 1
                    end
                end
            end

            if not config.box_datas[npc_name] then
                config.box_datas[npc_name] = {}
            end

            config.box_datas[npc_name].size  = size
            config.box_datas[npc_name].count = valid_count
            config.box_datas[npc_name].full  = valid_count == size
            save_config()
        else
            print(string.format("Debug: Failed to retrieve collection items for NPC ID %d.", npc_fixed_id))
        end
        captured_args = nil
        return retval
    end
)

-- Clear count on clearCollectionItem
sdk.hook(
    sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("clearCollectionItem"),
    function(args)
        local npc = sdk.to_managed_object(args[2])
        if not npc then
            print("Debug: NPC object is nil.")
            return
        end
    
        local npc_fixed_id = npc:get_field("NPCFixedId")
        if not npc_fixed_id then
            print("Debug: NPCFixedId is nil.")
            return
        end
    
        local npc_name = npc_names[npc_fixed_id]
        if not npc_name then
            print(string.format("Debug: NPCFixedId %d not found in npc_names table.", npc_fixed_id))
            return
        end

        if not config.box_datas[npc_name] then
            config.box_datas[npc_name] = {}
        end

        config.box_datas[npc_name].count = 0
        config.box_datas[npc_name].full  = false
        save_config()
    end,
    nil
)

-- === Bird Nest ===

local function get_nest_state()
	local rallus = facility_manager:get_field("<Rallus>k__BackingField")
	if not rallus then return end
	local timer = get_timer(11)
	config.box_datas.Nest.count = rallus:get_field("_SupplyNum")
	config.box_datas.Nest.full  = rallus:call("isStockMax")
	if timer > config.box_datas.Nest.timer then
		config.box_datas.Nest.timer = timer
	end
	if config.box_datas.Nest.count > config.box_datas.Nest.size then
		config.box_datas.Nest.size = config.box_datas.Nest.count
	end
    save_config()
end

-- === Poogie ===

local function get_pugee_state()
	local timer = get_timer(tidx.pugee)
	if timer > config.box_datas.pugee.timer then
		config.box_datas.pugee.timer = timer
	end
	config.box_datas.pugee.full = timer < 0
	save_config()
end

-- === Draw helper functions ===

local function apply_opacity(argb, opacity)
    local a     = (argb >> 24) & 0xFF
    local rgb   = argb & 0x00FFFFFF
    local new_a = math.floor(a * opacity)
    return (new_a << 24) | rgb
end

local function measureElements(font, elements, gap, scale_elements)
    local totalWidth = 0
    local text_font = d2d.Font.new(font.name, font.size, font.bold, font.italic)
    local timer_font = d2d.Font.new(font.name, font.size * timer_scale, font.bold, font.italic)
    for i, elem in ipairs(elements) do
        if elem.type == "text" then
            elem.measured_width = text_font:measure(elem.value)
        elseif elem.type == "icon" then
			elem.measured_width = scale_elements and (elem.width * table_scale) or elem.width
		elseif elem.type == "bar" then
			elem.measured_width = 0 - gap
        elseif elem.type == "timer" then
            elem.width = timer_font:measure(elem.value)
            elem.measured_width = 0 - gap
        elseif elem.type == "table" then
            local table_font = {
                name   = font.name,
                size   = font.size * table_scale,
                bold   = font.bold,
                italic = font.italic
            }
            local table_gap = gap * table_scale
            elem.measured_width = measureElements(table_font, elem.value, table_gap, true)
        end
        totalWidth = totalWidth + elem.measured_width + gap
    end
    return totalWidth - gap
end

local function drawElements(font, elements, start_x, y, icon_d, icon_y, gap, margin, color, alpha, scale_elements)
    local xPos = start_x
    local text_font = d2d.Font.new(font.name, font.size, font.bold, font.italic)
    local timer_font = d2d.Font.new(font.name, font.size * timer_scale, font.bold, font.italic)
    local ref_char_w, ref_char_h = text_font:measure("A")
    for i, elem in ipairs(elements) do
        if elem.type == "text" then
            d2d.text(text_font, elem.value, xPos, y, apply_opacity(color.text, alpha))
            xPos = xPos + elem.measured_width + gap
        elseif elem.type == "icon" then
            local drawW = scale_elements and (elem.width * table_scale) or elem.width
            d2d.image(elem.value, xPos, icon_y, drawW, icon_d, alpha)
			if elem.flag and config.draw_flags then
				local flagX = xPos - drawW / 2 + margin * 1.5
				local flagY = alt_tracker and icon_y - margin * 2.1 or icon_y - icon_d / 2 + margin * 1.2 -- is_in_tent
				d2d.image(img.flag, flagX, flagY, drawW, icon_d, alpha)
			end
            xPos = xPos + elem.measured_width + gap
		elseif elem.type == "bar" and config.draw_bars then
			local progress = 1 - math.max(0, math.min(1, elem.value / elem.max))
			local bar_w = icon_d * 0.75
			local bar_h = icon_d / 25
			local bar_x = xPos - gap - icon_d + (icon_d - bar_w) / 2
			local bar_y = alt_tracker and y + bar_h * 2 or y + icon_d - bar_h * 0.75 -- is_in_tent
			local fill_w = bar_w * progress
			d2d.fill_rect(bar_x, bar_y, bar_w, bar_h, apply_opacity(color.background, alpha))
			if elem.flag then
				d2d.fill_rect(bar_x, bar_y, bar_w, bar_h, apply_opacity(color.full_bar, alpha))
			else
				d2d.fill_rect(bar_x, bar_y, fill_w, bar_h, apply_opacity(color.prog_bar, alpha))
			end
        elseif elem.type == "timer" and config.draw_timers then
            local timer_x = xPos - icon_d - margin * 3
            local timer_char_h = ref_char_h * timer_scale
            local timer_y = y + ref_char_h - timer_char_h - margin / 4
            local timer_bg_y = timer_y + margin * 0.8
            local timer_bg_w = elem.width
            local timer_bg_h = timer_char_h - margin
            d2d.fill_rect(timer_x, timer_bg_y, timer_bg_w, timer_bg_h, apply_opacity(color.background, alpha))
            d2d.text(timer_font, elem.value, timer_x, timer_y, apply_opacity(color.timer_text, alpha))
        elseif elem.type == "table" then
            local table_font = {
                name   = font.name,
                size   = font.size * table_scale,
                bold   = font.bold,
                italic = font.italic
            }
            local table_y = y + (ref_char_h - ref_char_h * table_scale) / 2
			local table_icon_d = icon_d * table_scale
            local table_icon_y = icon_y + (icon_d - table_icon_d) * 5/8
            local table_gap = gap * table_scale
            xPos = drawElements(table_font, elem.value, xPos, table_y, table_icon_d, table_icon_y, table_gap, margin, color, alpha, true)
        end
    end
    return xPos
end

-----------------------------------------------------------
-- ON-FRAME UPDATE
-----------------------------------------------------------

re.on_frame(
    function()
        local current_time = os.clock()
        dt = current_time - previous_time
        previous_time = current_time
		
		if imgui.is_key_pressed(imgui_keys[config.tr_hotkey]) and config.tr_hotkey ~= "None" then
			config.draw_tracker = not config.draw_tracker
			save_config()
		end
		
		if imgui.is_key_pressed(imgui_keys[config.mo_hotkey]) and config.mo_hotkey ~= "None" then
			config.draw_moon = not config.draw_moon
			save_config()
		end
		
        if not is_active_player() then
            first_run = true
			previous_hidden = true
			previous_fading = true
            save_config()
            return
        end
		
		-- print("starting on-frame updates!")
		
		get_fade()
		get_hidden()
        get_ration_state()
        get_ship_state()
        get_shares_state()
		get_retrieval_state()
        get_nest_state()
		get_pugee_state()
		
        first_run = false
    end
)

-----------------------------------------------------------
-- REGISTER DRAW
-----------------------------------------------------------

d2d.register(
    function()
        color.background  = 0x882E2810   -- Semi-transparent dark tan
        color.text        = 0xFFFFFFFF   -- White
        color.timer_text  = 0xFFFCFFA6   -- Light Yellow
		color.yellow_text = 0xFFF4DB8A   -- Yellow
        color.red_text    = 0xFFFF0000   -- Red
        color.prog_bar    = 0xFF00FF00   -- Green
        color.full_bar    = 0xFFE6B00B   -- Orange-yellow
        color.border      = 0xFFAD9D75   -- Tan
    
        img.border_left    = d2d.Image.new("facility_tracker/border_left.png")
        img.border_right   = d2d.Image.new("facility_tracker/border_right.png")
        img.border_section = d2d.Image.new("facility_tracker/border_section.png")
        img.ph_icon        = d2d.Image.new("facility_tracker/ph_icon.png")
        img.error		   = d2d.Image.new("facility_tracker/error.png")
        img.spacer 	       = d2d.Image.new("facility_tracker/spacer.png")
        img.spacer_l 	   = d2d.Image.new("facility_tracker/spacer_l.png")
        img.flag 		   = d2d.Image.new("facility_tracker/flag.png")
        img.wilds 	       = d2d.Image.new("facility_tracker/wilds.png")
        img.rations	       = d2d.Image.new("facility_tracker/rations.png")
        img.ship   		   = d2d.Image.new("facility_tracker/ship.png")
        img.pugee          = d2d.Image.new("facility_tracker/pugee.png")
        img.nest		   = d2d.Image.new("facility_tracker/nest.png")
        img.nata 		   = d2d.Image.new("facility_tracker/nata.png")
        img.workshop       = d2d.Image.new("facility_tracker/workshop.png")
        img.retrieval      = d2d.Image.new("facility_tracker/retrieval.png")
        img.trader		   = d2d.Image.new("facility_tracker/trader.png")
        img.kunafa         = d2d.Image.new("facility_tracker/kunafa.png")
        img.wudwuds 	   = d2d.Image.new("facility_tracker/wudwuds.png")
        img.azuz 	 	   = d2d.Image.new("facility_tracker/azuz.png")
        img.suja 	 	   = d2d.Image.new("facility_tracker/suja.png")
        img.sild 	 	   = d2d.Image.new("facility_tracker/sild.png")
		img.m_ring         = d2d.Image.new("moon_tracker/ring.png")
		img.moon_0         = d2d.Image.new("moon_tracker/moon_0.png")
		img.moon_1         = d2d.Image.new("moon_tracker/moon_1.png")
		img.moon_2         = d2d.Image.new("moon_tracker/moon_2.png")
		img.moon_3         = d2d.Image.new("moon_tracker/moon_3.png")
		img.moon_4         = d2d.Image.new("moon_tracker/moon_4.png")
		img.moon_5         = d2d.Image.new("moon_tracker/moon_5.png")
		img.moon_6         = d2d.Image.new("moon_tracker/moon_6.png")
		img.m_num_0        = d2d.Image.new("moon_tracker/num_0.png")
		img.m_num_1        = d2d.Image.new("moon_tracker/num_1.png")
		img.m_num_2        = d2d.Image.new("moon_tracker/num_2.png")
		img.m_num_3        = d2d.Image.new("moon_tracker/num_3.png")
		img.m_num_4        = d2d.Image.new("moon_tracker/num_4.png")
		img.m_num_5        = d2d.Image.new("moon_tracker/num_5.png")
		img.m_num_6        = d2d.Image.new("moon_tracker/num_6.png")
    end,
    function()
        if not is_active_player() then return end
		-- print("starting draw!")
    
        local screen_w, screen_h = d2d.surface_size()
        local screen_scale       = screen_h / 2160.0
        local base_margin        = 4
        local base_border_h      = 40
        local base_end_border_w  = 34
        
        -------------------------------------------------------------------
        -- Ship/Trades Ticker
        -------------------------------------------------------------------

        local ti_opacity     = config.ti_opacity * fade_value
		local ti_user_scale  = config.ti_user_scale
        local ti_eff_scale   = screen_scale * ti_user_scale
        local ti_margin      = base_margin * ti_eff_scale
        local ti_bg_height   = 28 * ti_eff_scale
        local ti_icon_d      = ti_bg_height * 1.1
        local ti_speed_scale = config.ti_speed_scale * ti_eff_scale
        local ticker_speed   = 90 * ti_speed_scale
		local ti_bg_color    = apply_opacity(color.background, ti_opacity)
		local ticker_gap     = 10 * ti_eff_scale
		local ti_ex_gap      = ticker_gap
        local ti_bg_y        = 0
		local ti_icon_y      = (ti_bg_height - ti_icon_d) / 2
        local ti_font_size   = math.floor(ti_bg_height - ti_margin * 2)
        local ticker_font    = {
            name   = "Segoe UI",
            size   = ti_font_size,
            bold   = false,
            italic = true
        }
        
        local ship_elements = {
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
			{ type = "text",  value = "This is a scrolling ticker message." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "This will eventually display support ship items available once I find them." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "This is placeholder text for ship items." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d }
        }

        local trades_elements = {
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "The text just keeps on scrolling!" },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "Ideally, this will also list available trades, but those have been rather elusive." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "Just placeholder text for now." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d }
        }
        
        local ticker_elements = {
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "Here's a ticker." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
			{ type = "table", value = ship_elements   },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
            { type = "table", value = trades_elements },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "And we loop around again." }
        }
        
        ti_scroll_offset = ti_scroll_offset + ticker_speed * dt
        local totalTickerWidth = measureElements(ticker_font, ticker_elements, ticker_gap) + ti_ex_gap
        if ti_scroll_offset > (screen_w + totalTickerWidth) then
            ti_scroll_offset = screen_w
        end
        local ticker_start_x = screen_w - ti_scroll_offset
        local current_x = ticker_start_x
        local ti_ref_font = d2d.Font.new(ticker_font.name, ticker_font.size, ticker_font.bold, ticker_font.italic)
        local ref_char_w, ref_char_h = ti_ref_font:measure("A")
        local ticker_txt_y = ti_bg_y + ti_bg_height - ref_char_h - ti_margin
        
        local ti_border_h      = base_border_h * 0.56 * ti_eff_scale
        local ti_end_border_w  = base_end_border_w * ti_eff_scale
        local ti_border_y      = ti_bg_y + ti_bg_height - (ti_border_h / 2)
        local ti_sect_border_x = ti_end_border_w - (ti_margin / 2)
        local ti_sect_border_w = screen_w - ti_end_border_w - ti_sect_border_x + ti_margin
		
        -------------------------------------------------------------------
        -- Factilities Tracker
        -------------------------------------------------------------------

        local tr_opacity    = config.tr_opacity * fade_value
		local tr_user_scale = config.tr_user_scale
        local tr_eff_scale  = alt_tracker and screen_scale * tr_user_scale * tent_ui_scale or screen_scale * tr_user_scale -- is_in_tent
        local tr_margin     = base_margin * tr_eff_scale
        local tr_bg_height  = 50 * tr_eff_scale
        local tr_bg_y       = alt_tracker and 0 or screen_h - tr_bg_height -- is_in_tent
        local tr_bg_color   = apply_opacity(color.background, tr_opacity)
        local tr_icon_d     = tr_bg_height * 1.1
		local tracker_gap   = 18 * tr_eff_scale
		local tr_icon_y     = alt_tracker and tr_bg_y + (tr_bg_height - tr_icon_d) / 2 or tr_bg_y + (tr_bg_height - tr_icon_d + tr_margin) / 2 -- is_in_tent
        local tr_font_size  = math.floor(tr_bg_height - tr_margin * 2)
        local tracker_font  = {
            name   = "Segoe UI",
            size   = tr_font_size,
            bold   = false,
            italic = false
        }
        local retrieval_elements = {
            { type = "icon",  value = img.sild, width = tr_icon_d, flag = is_box_full("Rysher")      },
            { type = "text",  value = get_box_msg("Rysher")    },
            { type = "icon",  value = img.kunafa, width = tr_icon_d, flag = is_box_full("Murtabak")    },
            { type = "text",  value = get_box_msg("Murtabak")  },
            { type = "icon",  value = img.suja, width = tr_icon_d, flag = is_box_full("Apar")      },
            { type = "text",  value = get_box_msg("Apar")      },
            { type = "icon",  value = img.wudwuds, width = tr_icon_d, flag = is_box_full("Plumpeach")   },
            { type = "text",  value = get_box_msg("Plumpeach") },
            { type = "icon",  value = img.azuz, width = tr_icon_d, flag = is_box_full("Sabar")      },
            { type = "text",  value = get_box_msg("Sabar")     }
        }
        
        local tracker_elements = {
            { type = "icon",  value = img.ship, width = tr_icon_d, flag = leaving      },
			{ type = "text",  value = get_ship_message()         },
            { type = "icon",  value = img.ship, width = tr_icon_d, flag = leaving      },
            { type = "icon",  value = img.spacer_l, width = tr_icon_d  },
            { type = "icon",  value = img.rations, width = tr_icon_d, flag = is_box_full("Rations")   },
			{ type = "bar",   value = get_timer(tidx.ration), max = config.box_datas.Rations.timer, flag = is_box_full("Rations") },
            { type = "timer", value = get_timer_msg(tidx.ration) },
			{ type = "text",  value = get_box_msg("Rations")       },
            { type = "icon",  value = img.rations, width = tr_icon_d, flag = is_box_full("Rations")   },
            { type = "icon",  value = img.spacer_l, width = tr_icon_d  },
            { type = "icon",  value = img.retrieval, width = tr_icon_d, flag = is_box_full("retrieval") },
            { type = "table", value = retrieval_elements         },
            { type = "icon",  value = img.retrieval, width = tr_icon_d, flag = is_box_full("retrieval") },
            { type = "icon",  value = img.spacer_l , width = tr_icon_d },
            { type = "icon",  value = img.workshop, width = tr_icon_d, flag = is_box_full("Shares")  },
            { type = "text",  value = get_box_msg("Shares")       },
            { type = "icon",  value = img.workshop, width = tr_icon_d, flag = is_box_full("Shares")  },
            { type = "icon",  value = img.spacer_l, width = tr_icon_d  },
            { type = "icon",  value = img.nest, width = tr_icon_d, flag = is_box_full("Nest")      },
			{ type = "bar",   value = get_timer(tidx.nest), max = config.box_datas.Nest.timer, flag = is_box_full("Nest") },
            { type = "timer", value = get_timer_msg(tidx.nest)   },
            { type = "text",  value = get_box_msg("Nest")         },
            { type = "icon",  value = img.nest, width = tr_icon_d, flag = is_box_full("Nest")      },
            { type = "icon",  value = img.spacer_l, width = tr_icon_d  },
            { type = "icon",  value = img.pugee, width = tr_icon_d, flag = is_box_full("pugee")     },
			{ type = "bar",   value = get_timer(tidx.pugee), max = config.box_datas.pugee.timer, flag = is_box_full("pugee") },
            { type = "timer", value = get_timer_msg(tidx.pugee)  }
        }
        
        local totalTrackerWidth = measureElements(tracker_font, tracker_elements, tracker_gap)
        local tracker_start_x = (screen_w - totalTrackerWidth) / 2
		
        local tr_ref_font = d2d.Font.new(tracker_font.name, tracker_font.size, tracker_font.bold, tracker_font.italic)
        local _, ref_char_height = tr_ref_font:measure("A")
        local tracker_txt_y = tr_bg_y + tr_bg_height - ref_char_height
        
        local tr_border_h      = base_border_h * tr_eff_scale
        local tr_end_border_w  = base_end_border_w * tr_eff_scale
        local tr_border_y      = alt_tracker and tr_bg_height - (tr_border_h / 2) or tr_bg_y - (tr_border_h / 2) -- is_in_tent
        local tr_sect_border_x = tr_end_border_w - (tr_margin / 2)
        local tr_sect_border_w = screen_w - tr_end_border_w - tr_sect_border_x + tr_margin
		
		-------------------------------------------------------------------
		-- Moon Tracker
		-------------------------------------------------------------------
		
		local moon   = img["moon_" .. tostring(moon_idx)]
		local m_num  = img["m_num_" .. tostring(moon_idx)]
		local moon_x = (moon_pos == "map" and 16 or moon_pos == "rest" and 4 or 4) * screen_scale -- (map_moon and 16 or 4) * screen_scale
		local moon_y = (moon_pos == "map" and 202 or moon_pos == "rest" and 1722 or 1922) * screen_scale -- (map_moon and 202 or 1922) * screen_scale
		local moon_w = 140 * screen_scale
		local moon_h = 140 * screen_scale
		local moon_a = (map_moon and 0.9 or 1) * fade_value_m

        -------------------------------------------------------------------
        -- DRAWS
        -------------------------------------------------------------------
		
		if not (config.auto_hide and hide_tracker) then
			-- Draw the ticker
			if config.draw_ticker then
				d2d.fill_rect(0, ti_bg_y, screen_w, ti_bg_height, ti_bg_color)
				d2d.image(img.border_left, 0, ti_border_y, ti_end_border_w, ti_border_h, ti_opacity)
				d2d.image(img.border_right, screen_w - ti_end_border_w, ti_border_y, ti_end_border_w, ti_border_h, ti_opacity)
				if ti_sect_border_w > 0 then
					d2d.image(img.border_section, ti_sect_border_x, ti_border_y, ti_sect_border_w, ti_border_h, ti_opacity)
				end
				while current_x < screen_w do
					drawElements(ticker_font, ticker_elements, current_x, ticker_txt_y, ti_icon_d, ti_icon_y, ticker_gap, ti_margin, color, ti_opacity)
					current_x = current_x + totalTickerWidth
				end
			end
			
			-- Draw the tracker
			if config.draw_tracker then
				d2d.fill_rect(0, tr_bg_y, screen_w, tr_bg_height, tr_bg_color)
				d2d.image(img.border_left, 0, tr_border_y, tr_end_border_w, tr_border_h, tr_opacity)
				d2d.image(img.border_right, screen_w - tr_end_border_w, tr_border_y, tr_end_border_w, tr_border_h, tr_opacity)
				if tr_sect_border_w > 0 then
					d2d.image(img.border_section, tr_sect_border_x, tr_border_y, tr_sect_border_w, tr_border_h, tr_opacity)
				end
				drawElements(tracker_font, tracker_elements, tracker_start_x, tracker_txt_y, tr_icon_d, tr_icon_y, tracker_gap, tr_margin, color, tr_opacity)
			end
		end
		
		-- Draw the moon
		if config.draw_moon and not (config.auto_hide_m and hide_moon) then
			d2d.image(img.m_ring, moon_x, moon_y, moon_w, moon_h, moon_a)
            d2d.image(moon, moon_x, moon_y, moon_w, moon_h, moon_a)
			if config.draw_m_num then
				d2d.image(m_num, moon_x, moon_y, moon_w, moon_h, moon_a)
			end
		end
    end
)

----------------------------------------------------------------
-- CONFIG MENU
----------------------------------------------------------------

re.on_draw_ui(
	function()
		local font_size = imgui.get_default_font_size()
		local window_w = imgui.calc_item_width()
		local txtbox_w = font_size * 2.5
		local txtbox_x = window_w - txtbox_w + 23
		local button_w = font_size * 2.79 + 6
		local button_h = font_size + 6
		local button_x = window_w - button_w + 23
		local indent_w = font_size + 3

		if imgui.tree_node("Facility Tracker") then
			local changed_draw, draw = imgui.checkbox("Display Tracker     ", config.draw_tracker)
			if changed_draw then config.draw_tracker = draw; save_config() end
			imgui.same_line()
			
			local cursor_pos1 = imgui.get_cursor_pos()
			imgui.set_cursor_pos(Vector2f.new(button_x, cursor_pos1.y))
			if imgui.button("Hotkey", Vector2f.new(button_w, button_h)) then
				hotkey_listening.tr_hotkey = true
				hotkey_messages.tr_hotkey = "press a key..."
			end
			if hotkey_listening.tr_hotkey then get_new_hotkey("tr_hotkey") end
			imgui.same_line()
			imgui.text(hotkey_messages.tr_hotkey)
			
			imgui.separator()
			
				imgui.begin_disabled(not config.draw_tracker)
				
				local checkboxes = {
					{ "Progress Bars", "draw_bars"   },
					{ "Timers",        "draw_timers" },
					{ "Flags",         "draw_flags"  }
				}
				for _, cb in ipairs(checkboxes) do
					local label, key = cb[1], cb[2]
					local changedBox, newVal = imgui.checkbox(label, config[key])
					if changedBox then
						config[key] = newVal
						save_config()
					end
				end
				imgui.separator()
				
				local changed_auto, auto = imgui.checkbox("Automatic Hiding", config.auto_hide)
				if changed_auto then config.auto_hide = auto; save_config() end
				imgui.text("")
				
					imgui.begin_disabled(not config.auto_hide)
					
					local changed_hwh, hwh = imgui.checkbox("Hide with HUD", config.hide_w_hud)
					if changed_hwh then config.hide_w_hud = hwh; save_config() end
					local hwh_checkboxes = {
						{ "Hide while bowling",       "hide_w_bowling" },
						{ "Hide while arm wrestling", "hide_w_wrestle" },
						{ "Hide at hub tables",       "hide_at_table"  }
					}
					if config.hide_w_hud then
						imgui.indent(indent_w)
						imgui.text("Options:")
						for _, cb in ipairs(hwh_checkboxes) do
							local label, key = cb[1], cb[2]
							local changedBox, newVal = imgui.checkbox(label, config[key])
							if changedBox then
								config[key] = newVal
								save_config()
							end
						end
						imgui.unindent(indent_w)
					end
					imgui.text("")
					
					local show_when = {
						"Don't show when:",
						"Only show when:"
					}
					local show_index = get_index(show_when, config.show_when)
					imgui.push_item_width(font_size * 8.5)
					local changed_idx, index = imgui.combo("##show_when", show_index, show_when)
					if changed_idx then config.show_when = show_when[index]; save_config() end
					imgui.pop_item_width()
					
						imgui.indent(indent_w)
						
						if config.show_when == "Don't show when:" then
							local changed_tent, tent = imgui.checkbox("in a tent", config.hide_in_tent)
							if changed_tent then config.hide_in_tent = tent; save_config() end
							
							local changed_map, map = imgui.checkbox("viewing the map", config.hide_on_map)
							if changed_map then config.hide_on_map = map; save_config() end
							
								imgui.begin_disabled(config.hide_in_qstcbt)
								
								local changed_quest, quest = imgui.checkbox("in a quest", config.hide_in_quest)
								if changed_quest then config.hide_in_quest = quest; save_config() end
								
								local changed_combat, combat = imgui.checkbox("in any combat", config.hide_in_combat)
								if changed_combat then config.hide_in_combat = combat; save_config() end
								
								imgui.end_disabled()
							
							local changed_qstcbt, qstcbt = imgui.checkbox("in quest combat (exclusive)", config.hide_in_qstcbt)
							if changed_qstcbt then config.hide_in_qstcbt = qstcbt; save_config() end
							
							if config.hide_in_combat or config.hide_in_qstcbt then
								local changed_hlfcbt, hlfcbt = imgui.checkbox("monster is searching (post-combat)", config.hide_in_hlfcbt)
								if changed_hlfcbt then config.hide_in_hlfcbt = hlfcbt; save_config() end
							end
						end
						
						local only_checkboxes = {
							{ "in a tent",            "draw_in_tent"  },
							{ "viewing the map",      "draw_on_map"   },
							{ "in a village",         "draw_in_life"  },
							{ "in a base camp",       "draw_in_base"  },
							{ "in the training area", "draw_in_train" }
						}
						if config.show_when == "Only show when:" then
							for _, cb in ipairs(only_checkboxes) do
								local label, key = cb[1], cb[2]
								local changedBox, newVal = imgui.checkbox(label, config[key])
								if changedBox then
									config[key] = newVal
									save_config()
								end
							end
						end
						
						imgui.unindent(indent_w)
					
					imgui.separator()
					
					imgui.end_disabled()
				
				imgui.text("Tracker Scale:")
				imgui.same_line()
				
				local cursor_pos2 = imgui.get_cursor_pos()
				imgui.set_cursor_pos(Vector2f.new(txtbox_x, cursor_pos2.y))
				imgui.push_item_width(txtbox_w)
				local chg_scale_txt, scale_string, _, _ = imgui.input_text(" (0.0 to 2.0)", config.tr_user_scale)
				local scale_txt = math.min(2, math.max(0, tonumber(scale_string) or 1))
				if chg_scale_txt then config.tr_user_scale = scale_txt; save_config() end
				imgui.pop_item_width()
				
				local chg_scale_sld, scale_sld = imgui.slider_float("##scale", config.tr_user_scale, 0.0, 2.0)
				if chg_scale_sld then config.tr_user_scale = scale_sld; save_config() end
				
				imgui.text("Tracker Opacity:")
				imgui.same_line()
				
				local cursor_pos3 = imgui.get_cursor_pos()
				imgui.set_cursor_pos(Vector2f.new(txtbox_x, cursor_pos3.y))
				imgui.push_item_width(txtbox_w)
				local chg_opac_txt, opacity_string, _, _ = imgui.input_text(" (0.0 to 1.0)", config.tr_opacity)
				local opac_txt = math.min(1, math.max(0, tonumber(opacity_string) or 1))
				if chg_opac_txt then config.tr_opacity = opac_txt; save_config() end
				imgui.pop_item_width()
				
				
				local chg_opac_sld, opac_sld = imgui.slider_float("##opacity", config.tr_opacity, 0.0, 1.0)
				if chg_opac_sld then config.tr_opacity = opac_sld; save_config() end
				imgui.separator()
				
				imgui.end_disabled()
			
			imgui.tree_pop()
		end
		
		if imgui.tree_node("Moon Phase Tracker") then
			local changed_draw, draw = imgui.checkbox("Display Moon Phase", config.draw_moon)
			if changed_draw then config.draw_moon = draw; save_config() end
			imgui.same_line()
			
			local cursor_pos1 = imgui.get_cursor_pos()
			imgui.set_cursor_pos(Vector2f.new(button_x, cursor_pos1.y))
			if imgui.button("Hotkey", Vector2f.new(button_w, button_h)) then
				hotkey_listening.mo_hotkey = true
				hotkey_messages.mo_hotkey = "press a key..."
			end
			if hotkey_listening.mo_hotkey then get_new_hotkey("mo_hotkey") end
			imgui.same_line()
			imgui.text(hotkey_messages.mo_hotkey)
			
			imgui.separator()
			
				imgui.begin_disabled(not config.draw_moon)
				
				local checkboxes = {
					{ "Numerals",         "draw_m_num"  },
					{ "Automatic Hiding", "auto_hide_m" }
				}
				for _, cb in ipairs(checkboxes) do
					local label, key = cb[1], cb[2]
					local changedBox, newVal = imgui.checkbox(label, config[key])
					if changedBox then
						config[key] = newVal
						save_config()
					end
				end
				imgui.separator()
				
				imgui.end_disabled()
			
			imgui.tree_pop()
		end
		
		-- if imgui.tree_node("Tracker Data DELETE ME") then
			-- imgui.text("arm wrestling: " .. tostring(is_active_situation("arm_wrestling")))
			-- imgui.text("table sitting: " .. tostring(is_active_situation("table_sitting")))
			-- imgui.text("map open: " .. tostring(map_open))
			-- imgui.text("menu open: " .. tostring(menu_open))
			-- imgui.text("hide tracker: " .. tostring(hide_tracker))
			-- imgui.text("hide moon: " .. tostring(hide_moon))
			-- imgui.text("fade: " .. tostring(fade_value))
			-- imgui.text("previous hidden: " .. tostring(previous_hidden))
			-- imgui.text("current hidden: " .. tostring(fade_manager:call("get_IsVisibleStateAny")))
			-- imgui.text("previous fading: " .. tostring(previous_fading))
			-- imgui.text("current fading: " .. tostring(fade_manager:call("get_IsFadingAny")))
			-- imgui.tree_pop()
		-- end
		
		-- if imgui.tree_node("Trades Ticker") then
			-- local changed_ti_speed_scale, newVal2 = imgui.slider_float("Ticker Speed", config.ti_speed_scale, 0.1, 3.0)
			-- if changed_ti_speed_scale then config.ti_speed_scale = newVal2; save_config() end

			-- local changed_ti_scale, newVal = imgui.slider_float("Ticker Scale", config.ti_user_scale, 0.0, 2.0)
			-- if changed_ti_scale then config.ti_user_scale = newVal; save_config() end

			-- local changed_ti_opacity, newVal3 = imgui.slider_float("Ticker Opacity", config.ti_opacity, 0.0, 1.0)
			-- if changed_ti_opacity then config.ti_opacity = newVal3; save_config() end

			-- local checkboxes = {
				-- { "Display Ticker", "draw_ticker" },
				-- { "Include Ship",   "draw_ship"   },
				-- { "Include Trades", "draw_trades" }
			-- }
			-- for _, cb in ipairs(checkboxes) do
				-- local label, key = cb[1], cb[2]
				-- local changedBox, newVal = imgui.checkbox(label, config[key])
				-- if changedBox then
					-- config[key] = newVal
					-- save_config()
				-- end
			-- end

			-- imgui.tree_pop()
		-- end
	end
)
