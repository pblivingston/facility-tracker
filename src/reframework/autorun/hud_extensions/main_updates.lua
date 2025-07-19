local core = require("hud_extensions/core")

local main_updates = {
	dt             = 0,
	fade           = 0,
	in_tent        = false,
	in_temp_tent   = false,
	in_any_tent    = false,
	in_base_camp   = false,
	in_life_area   = false,
	in_combat      = false,
	half_combat    = false,
	map_interact   = false,
	arm_wrestling  = false,
	table_sitting  = false,
	camp_sitting   = false,
	rest_open      = false,
	map_open       = false,
	radar_open     = false,
	in_training    = false,
	in_grand_hub   = false,
	active_quest   = false,
	quest_combat   = false,
	qhalf_combat   = false,
	is_bowling     = false,
	in_field       = false,
	hud_hidden     = false,
	radial_visible = false,
	slider_visible = false
}

local previous_time       = os.clock()
local map_proc            = false
local current_map_intrct  = false
local current_table_sit   = false
local current_rest_open   = false
local current_camp_sit    = false
local out_speed           = 2.5
local in_speed            = 1
local delay_timer         = 0
local out_delay           = 0
local in_delay            = 0.15
local map_o_delay         = 0.25
local map_i_delay         = 0.1
local wrestle_i_delay     = 1.75
local table_i_delay       = 0.05
local camp_i_delay        = 0.05
local rest_io_delay       = 0.18

local environment_manager = core.singletons.environment_manager
local mission_manager     = core.singletons.mission_manager
local fade_manager        = core.singletons.fade_manager
local gui_manager         = core.singletons.gui_manager
local player_manager      = core.singletons.player_manager
local minigame_manager    = core.singletons.minigame_manager

function main_updates.time_delta()
	local current_time = os.clock()
	main_updates.dt = current_time - previous_time
	previous_time = current_time
end

function main_updates.is_active_player()
	local success, character = pcall(function() return player_manager:call("getMasterPlayerInfo"):get_field("<Character>k__BackingField") end)
	if not (success and character) then
		return false
	end
	
	main_updates.in_tent      = character:call("get_IsInTent")
	main_updates.in_temp_tent = character:call("get_IsInTempTent")
	main_updates.in_any_tent  = character:call("get_IsInAllTent")
	main_updates.in_base_camp = character:call("get_IsInBaseCamp") and not (main_updates.in_any_tent or main_updates.map_open or main_updates.camp_sitting)
	main_updates.in_life_area = character:call("get_IsInLifeArea") and not (main_updates.in_any_tent or main_updates.map_open or main_updates.in_base_camp)
	main_updates.in_combat    = character:call("get_IsCombat")
	main_updates.half_combat  = character:call("get_IsHalfCombat")
	
	return true
end

local function is_active_situation(situation)
	local active_situations = gui_manager:get_field("<ContentsMaskModule>k__BackingField"):get_field("_CurrentActiveSituations"):get_field("_items")
	for _, element in ipairs(active_situations) do
		local success, value = pcall(function() return element:get_field("value__") end)
		if success and value == core.situations[situation] then
			return true
		end
	end
	return false
end

function main_updates.fading()
	local config = core.config
	
	local current_hidden = fade_manager:call("get_IsVisibleStateAny")
	local current_fading = fade_manager:call("get_IsFadingAny")
	
	if current_fading and not main_updates.previous_fading then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= out_delay then
			main_updates.fade = math.max(main_updates.fade - out_speed * main_updates.dt, 0)
			if main_updates.fade == 0 then
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
			main_updates.fade = math.min(main_updates.fade + in_speed * main_updates.dt, 1)
			if main_updates.fade == 1 then
				main_updates.previous_hidden = current_hidden
				delay_timer = 0
			end
		end
	else
		main_updates.previous_hidden = current_hidden
	end
	
	if not (current_fading or main_updates.previous_hidden) then
		main_updates.fade = 1
	end
	
	if main_updates.previous_hidden and current_hidden then
		main_updates.fade = 0
	end
end

-- function main_updates.get_hidden()
	-- local config = core.config
	
	-- local draw_w_bowling     = is_bowling and radar_open and not config.hide_w_bowling
	-- local draw_w_wrestle     = previous_arm_wrest and not config.hide_w_wrestle
	-- local draw_at_table      = radar_open and previous_table_sit and not config.hide_at_table
	-- local draw_at_camp       = previous_camp_sit and not config.hide_at_camp
	
	-- local dont_show          = config.show_when == "Don't show when:"
	-- local hide_in_tent       = main_updates.is_in_tent and config.hide_in_tent
	-- local hide_on_map        = map_open and config.hide_on_map
	-- local hide_in_quest      = core.active_quest and config.hide_in_quest and not config.hide_in_qstcbt
	-- local hide_in_combat     = in_combat and config.hide_in_combat and not config.hide_in_qstcbt
	-- local hide_in_qstcbt     = quest_combat and config.hide_in_qstcbt
	-- local hide_in_hlfcbt     = half_combat and config.hide_in_hlfcbt and (config.hide_in_combat or (core.active_quest and config.hide_in_qstcbt))

	-- local only_show          = config.show_when == "Only show when:"
	-- local draw_in_tent       = main_updates.is_in_tent and config.draw_in_tent
	-- local draw_on_map        = map_open and config.draw_on_map
	-- local draw_in_life       = in_life_area and config.draw_in_life
	-- local draw_in_base       = in_base_camp and config.draw_in_base
	-- local draw_in_train      = in_training and config.draw_in_train

	-- local dont_show_hide     = dont_show and (hide_in_tent or hide_on_map or hide_in_quest or hide_in_combat or hide_in_qstcbt or hide_in_hlfcbt)
	-- local only_show_hide     = only_show and not (draw_in_tent or draw_on_map or draw_in_life or draw_in_base or draw_in_train)
	-- local hide_w_hud         = config.hide_w_hud and not (slider_visible or draw_w_bowling or draw_w_wrestle or draw_at_table or draw_at_camp or main_updates.is_in_tent or map_open)
	-- local auto_hide          = dont_show_hide or only_show_hide or hide_w_hud
	
	-- main_updates.alt_tracker   = map_open or main_updates.is_in_tent
	-- main_updates.hide_tracker  = auto_hide and config.auto_hide and not (radial_visible and config.tr_radialMenu)
	-- main_updates.hide_ticker   = auto_hide and config.auto_hide_t and not (radial_visible and config.ti_radialMenu)
	-- main_updates.hide_voucher  = auto_hide and config.auto_hide_v and not (radial_visible and config.vo_radialMenu)
	-- main_updates.hide_clock    = auto_hide and config.auto_hide_c and not (radial_visible and config.ck_radialMenu)
	
	-- main_updates.mini_override = (main_updates.alt_tracker and config.mi_tent_map) or (radial_visible and config.mi_radialMenu)
	
	-- if not config.auto_hide then main_updates.alt_tracker = false end
-- end

function main_updates.delays()
	if main_updates.map_interact and not current_map_intrct then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= map_o_delay then
			main_updates.map_interact = current_map_intrct
			delay_timer = 0
		end
	elseif current_map_intrct and not main_updates.map_interact then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= map_i_delay then
			main_updates.map_interact = current_map_intrct
			delay_timer = 0
		end
	else
		main_updates.map_interact = current_map_intrct
	end
	current_map_intrct = false
	
	local current_arm_wrest  = is_active_situation("arm_wrestling")
	if main_updates.arm_wrestling and not current_arm_wrest then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= wrestle_i_delay then
			main_updates.arm_wrestling = current_arm_wrest
			delay_timer = 0
		end
	else
		main_updates.arm_wrestling = current_arm_wrest
	end
	
	if main_updates.table_sitting and not current_table_sit then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= table_i_delay then
			main_updates.table_sitting = current_table_sit
			delay_timer = 0
		end
	else
		main_updates.table_sitting = current_table_sit
	end
	
	if main_updates.camp_sitting and not current_camp_sit then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= camp_i_delay then
			main_updates.camp_sitting = current_camp_sit
			delay_timer = 0
		end
	else
		main_updates.camp_sitting = current_camp_sit
	end
	
	if main_updates.rest_open ~= current_rest_open then
		delay_timer = delay_timer + main_updates.dt
		if delay_timer >= rest_io_delay then
			main_updates.rest_open = current_rest_open
			delay_timer = 0
		end
	else
		main_updates.rest_open = current_rest_open
	end
end

function main_updates.on_frame()
	local cur_flow = gui_manager:get_field("<MAP3D>k__BackingField"):get_field("_Flow"):get_field("_CurFlow")
	local cur_map_flow = cur_flow and string.sub(cur_flow:get_type_definition():get_name(), #"cGUIMapFlow" + 1) or ""
	map_proc = cur_map_flow == "Active" and true or cur_map_flow == "RadarActive" and false or map_proc
	
	main_updates.map_open     = (cur_map_flow == "Active" or cur_map_flow == "CloseModel")
	main_updates.radar_open   = (cur_map_flow == "RadarActive" or cur_map_flow == "WaitOpenReq" or cur_map_flow == "CloseRadarModel" or (cur_map_flow == "OpenRadar" and not map_proc)) and not (main_updates.in_training or main_updates.arm_wrestling)
	
	local stage_id = environment_manager:get_field("_CurrentStage")
	main_updates.in_training  = stage_id == core.stage_idx.training and not (main_updates.in_any_tent or main_updates.map_open)
	main_updates.in_grand_hub = stage_id == core.stage_idx.g_hub
	
	main_updates.active_quest = mission_manager:call("get_IsActiveQuest")
	main_updates.quest_combat = main_updates.active_quest and main_updates.in_combat
	main_updates.qhalf_combat = main_updates.active_quest and main_updates.half_combat
	
	main_updates.is_bowling   = minigame_manager:get_field("_Bowling"):call("get_IsPlaying")
	
	main_updates.in_field     = not (main_updates.in_any_tent or main_updates.in_base_camp or main_updates.in_life_area or main_updates.in_training or main_updates.active_quest or main_updates.in_combat or main_updates.half_combat)
	main_updates.hud_hidden   = not (main_updates.slider_visible or main_updates.radar_open or main_updates.in_any_tent or main_updates.map_open)
	-- hud_hidden might need camp_sitting, table_sitting, etc.
end

---------------------------------------------------
---------------------------------------------------

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
	sdk.find_type_definition("app.GUI020008"):get_method("onHudOpen"),
	function(args) main_updates.radial_visible = true end, nil
)
sdk.hook(
	sdk.find_type_definition("app.GUI020008"):get_method("onHudClose"),
	function(args) main_updates.radial_visible = false end, nil
)
sdk.hook(
	sdk.find_type_definition("app.GUI020006PartsAllSliderItem"):get_method("update"),
	function(args) main_updates.slider_visible = true end, nil
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

---------------------------------------------------
---------------------------------------------------

return main_updates