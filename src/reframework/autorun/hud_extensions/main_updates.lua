local core = require("hud_extensions/core")

local main_updates = {}

local previous_time       = os.clock()
local character           = nil
local map_proc            = false
local previous_map_intrct = false
local current_map_intrct  = false
local previous_table_sit  = false
local current_table_sit   = false
local previous_arm_wrest  = false
local previous_rest_open  = false
local current_rest_open   = false
local previous_camp_sit   = false
local current_camp_sit    = false
local slider_visible      = false
local radial_visible      = false
local fade                = 0
local out_speed           = 2.5
local in_speed            = 1
local delay_timer         = 0
local out_delay           = 0
local in_delay            = 0.15
local map_o_delay         = 0.25
local map_i_delay         = 0.1
local table_i_delay       = 0.05
local wrestle_i_delay     = 1.75
local rest_io_delay       = 0.18
local camp_i_delay        = 0.05

local situations = {
	arm_wrestling = 42,
	table_sitting = 43
}

local stage_idx = {
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

local environment_manager = sdk.get_managed_singleton("app.EnvironmentManager")
local mission_manager     = sdk.get_managed_singleton("app.MissionManager")
local fade_manager        = sdk.get_managed_singleton("app.FadeManager")
local gui_manager         = sdk.get_managed_singleton("app.GUIManager")
local player_manager      = sdk.get_managed_singleton("app.PlayerManager")
local minigame_manager    = sdk.get_managed_singleton("app.GameMiniEventManager")

function main_updates.time_delta()
	local current_time = os.clock()
	main_updates.dt = current_time - previous_time
	previous_time = current_time
end

function main_updates.is_active_player()
	local info_success, info = pcall(function() return player_manager:call("getMasterPlayerInfo") end)
	if not (info_success and info) then
		return false
	end
	local character_success, character_result = pcall(function() return info:get_field("<Character>k__BackingField") end)
	if not (character_success and character_result) then
		return false
	end
	character = character_result
	
	return true
end

function main_updates.get_midx()
	local moon_cont_success, moon_controller = pcall(function() return environment_manager:get_field("_MoonController") end)
	if not moon_cont_success then return end
	local moon_data_success, main_moon_data = pcall(function() return moon_controller:get_field("_MainData") end)
	local lmoon_data_success, lobby_moon_data = pcall(function() return moon_controller:get_field("_LobbyData") end)
	local qmoon_data_success, quest_moon_data = pcall(function() return moon_controller:get_field("_QuestData") end)
	--local smoon_data_success, story_moon_data = pcall(function() return moon_controller:get_field("_StoryData") end)
	local moon_idx = moon_data_success and main_moon_data:call("get_MoonIdx")
	local hubm_idx = lmoon_data_success and lobby_moon_data:call("get_MoonIdx")
	local qstm_idx = qmoon_data_success and quest_moon_data:call("get_MoonIdx")
	--local strm_idx = smoon_data_success and story_moon_data:call("get_MoonIdx")
	main_updates.midx = main_updates.quest_moon and qstm_idx or (main_updates.ghub_moon and core.config.ghub_moon == "Hub moon") and hubm_idx or moon_idx
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

function main_updates.get_fade()
	local config = core.config
	
	local current_hidden = fade_manager:call("get_IsVisibleStateAny")
	local current_fading = fade_manager:call("get_IsFadingAny")
	
	if current_fading and not main_updates.previous_fading then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= out_delay then
			fade = math.max(fade - out_speed * main_updates.dt, 0)
			if fade == 0 then
				main_updates.previous_fading = current_fading
				delay_timer = 0
			end
		end
	else
		main_updates.previous_fading = current_fading
	end
	
	if main_updates.previous_hidden and not current_hidden then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= in_delay then
			fade = math.min(fade + in_speed * main_updates.dt, 1)
			if fade == 1 then
				main_updates.previous_hidden = current_hidden
				delay_timer = 0
			end
		end
	else
		main_updates.previous_hidden = current_hidden
	end
	
	if not (current_fading or main_updates.previous_hidden) then
		fade = 1
	end
	
	if main_updates.previous_hidden and current_hidden then
		fade = 0
	end
	
	main_updates.fade_value   = config.auto_hide and fade or 1
	main_updates.fade_value_v = config.auto_hide_v and fade or 1
	main_updates.fade_value_c = config.auto_hide_c and fade or 1
	main_updates.fade_value_m = config.auto_hide_m and fade or 1
end

function main_updates.get_hidden()
	local config = core.config
	
	local map_controller     = gui_manager:get_field("<MAP3D>k__BackingField")
	local map_flow_manager   = map_controller:get_field("_Flow")
	local change_area        = map_flow_manager:call("checkChangeArea")
	
	local cur_map_flow = ""
	local cur_success, cur_flow = pcall(function() return map_flow_manager:get_field("_CurFlow") end)
	if cur_success and cur_flow then
		cur_map_flow = string.sub(cur_flow:get_type_definition():get_name(), #"cGUIMapFlow" + 1)
	end
	
	if cur_map_flow == "Active" then map_proc = true end
	if cur_map_flow == "RadarActive" then map_proc = false end
	
	if previous_map_intrct and not current_map_intrct then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= map_o_delay then
			previous_map_intrct = current_map_intrct
			delay_timer = 0
		end
	elseif current_map_intrct and not previous_map_intrct then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= map_i_delay then
			previous_map_intrct = current_map_intrct
			delay_timer = 0
		end
	else
		previous_map_intrct = current_map_intrct
	end
	
	if previous_table_sit and not current_table_sit then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= table_i_delay then
			previous_table_sit = current_table_sit
			delay_timer = 0
		end
	else
		previous_table_sit = current_table_sit
	end
	
	local current_arm_wrest  = is_active_situation("arm_wrestling")
	if previous_arm_wrest and not current_arm_wrest then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= wrestle_i_delay then
			previous_arm_wrest = current_arm_wrest
			delay_timer = 0
		end
	else
		previous_arm_wrest = current_arm_wrest
	end
	
	if previous_rest_open ~= current_rest_open then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= rest_io_delay then
			previous_rest_open = current_rest_open
			delay_timer = 0
		end
	else
		previous_rest_open = current_rest_open
	end
	
	if previous_camp_sit and not current_camp_sit then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= camp_i_delay then
			previous_camp_sit = current_camp_sit
			delay_timer = 0
		end
	else
		previous_camp_sit = current_camp_sit
	end
	
	local stage_id           = environment_manager:get_field("_CurrentStage")
	local is_in_tent         = character:call("get_IsInAllTent")
	local map_open           = (cur_map_flow == "Active" or cur_map_flow == "CloseModel")
	local in_training        = stage_id == stage_idx.training and not (is_in_tent or map_open)
	local radar_open         = (cur_map_flow == "RadarActive" or cur_map_flow == "WaitOpenReq" or cur_map_flow == "CloseRadarModel" or (cur_map_flow == "OpenRadar" and not map_proc)) and not (in_training or previous_arm_wrest)
	local active_quest       = mission_manager:call("get_IsActiveQuest")
	local quest_end          = mission_manager:call("get_IsQuestEndShowing")
	local in_base_camp       = character:call("get_IsInBaseCamp") and not (is_in_tent or map_open)
	local in_life_area       = character:call("get_IsInLifeArea") and not (is_in_tent or map_open or in_base_camp)
	local in_combat          = character:call("get_IsCombat")
	local half_combat        = character:call("get_IsHalfCombat")
	local is_bowling         = minigame_manager:get_field("_Bowling"):call("get_IsPlaying")
	local quest_combat       = active_quest and in_combat
	
	local draw_w_bowling     = is_bowling and radar_open and not config.hide_w_bowling
	local draw_w_wrestle     = previous_arm_wrest and not config.hide_w_wrestle
	local draw_at_table      = radar_open and previous_table_sit and not config.hide_at_table
	local draw_at_camp       = previous_camp_sit and not config.hide_at_camp
	
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
	local hide_w_hud         = config.hide_w_hud and not (slider_visible or draw_w_bowling or draw_w_wrestle or draw_at_table or draw_at_camp or is_in_tent or map_open)
	local auto_hide          = dont_show_hide or only_show_hide or hide_w_hud
	
	main_updates.alt_tracker   = map_open or is_in_tent
	main_updates.hide_tracker  = auto_hide and config.auto_hide and not (radial_visible and config.tr_radialMenu)
	main_updates.hide_ticker   = auto_hide and config.auto_hide_t and not (radial_visible and config.ti_radialMenu)
	main_updates.hide_voucher  = auto_hide and config.auto_hide_v and not (radial_visible and config.vo_radialMenu)
	main_updates.hide_clock    = auto_hide and config.auto_hide_c and not (radial_visible and config.ck_radialMenu)
	
	main_updates.mini_override = (main_updates.alt_tracker and config.mi_tent_map) or (radial_visible and config.mi_radialMenu)
	
	main_updates.hide_moon     = config.auto_hide_m and not ((radar_open and slider_visible) or (map_open and previous_map_intrct) or previous_rest_open)
	main_updates.moon_pos      = map_open and "map" or previous_rest_open and "rest" or "radar"
	main_updates.quest_moon    = active_quest
	
	main_updates.ghub_moon     = stage_id == stage_idx.g_hub
	
	if not config.auto_hide then main_updates.alt_tracker = false end
	if not config.auto_hide_m then main_updates.moon_pos = "radar" end
	
	current_map_intrct = false
	slider_visible = false
	radial_visible = false
end

function main_updates.register_hooks()
	sdk.hook(
		sdk.find_type_definition("app.GUI090302"):get_method("onOpen"),
		function(args) current_rest_open = true end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.GUI090302"):get_method("onClose"),
		function(args) current_rest_open = false end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.GUI060000"):get_method("setInteractButtonAssignPos"),
		function(args) current_map_intrct = true end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.GUI020006"):get_method("isItemAllSlider"),
		function(args) radial_visible = true end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.GUI020006PartsAllSliderItem"):get_method("update"),
		function(args) slider_visible = true end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.PlayerCommonAction.cLobbyChairBase"):get_method("doEnter"),
		function(args) current_table_sit = true end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.PlayerCommonAction.cLobbyChairBase"):get_method("doExit"),
		function(args) current_table_sit = false end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.PlayerCommonAction.cLobbyTentChairBase"):get_method("doEnter"),
		function(args) current_camp_sit = true end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.PlayerCommonAction.cLobbyTentChairBase"):get_method("doExit"),
		function(args) current_camp_sit = false end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.PlayerCommonAction.cCampfireBase"):get_method("doEnter"),
		function(args) current_camp_sit = true end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.PlayerCommonAction.cCampfireBase"):get_method("doExit"),
		function(args) current_camp_sit = false end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.PlayerCommonAction.cReclinerChairBase"):get_method("doEnter"),
		function(args) current_camp_sit = true end, nil
	)
	sdk.hook(
		sdk.find_type_definition("app.PlayerCommonAction.cReclinerChairBase"):get_method("doExit"),
		function(args) current_camp_sit = false end, nil
	)
end

return main_updates