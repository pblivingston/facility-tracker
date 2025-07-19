local core         = require("hud_extensions/core")
local main_updates = require("hud_extensions/main_updates")

local moon_updates = {}

local environment_manager = core.singletons.environment_manager

function moon_updates.midx()
	local moon_cont_success, moon_controller = pcall(function() return environment_manager:get_field("_MoonController") end)
	if not moon_cont_success then return end
	local moon_data_success, main_moon_data = pcall(function() return moon_controller:get_field("_MainData") end)
	local lmoon_data_success, lobby_moon_data = pcall(function() return moon_controller:get_field("_LobbyData") end)
	local qmoon_data_success, quest_moon_data = pcall(function() return moon_controller:get_field("_QuestData") end)
	local smoon_data_success, story_moon_data = pcall(function() return moon_controller:get_field("_StoryData") end)
	local moon_idx = moon_data_success and main_moon_data:call("get_MoonIdx")
	local hubm_idx = lmoon_data_success and lobby_moon_data:call("get_MoonIdx")
	local qstm_idx = qmoon_data_success and quest_moon_data:call("get_MoonIdx")
	local strm_idx = smoon_data_success and story_moon_data:call("get_MoonIdx")
	return (main_updates.active_quest and strm_idx >= 0) and strm_idx or main_updates.active_quest and qstm_idx or (main_updates.in_grand_hub and core.config.moon.ghub == "Hub moon") and hubm_idx or moon_idx
end

function moon_updates.hide()
	if not core.config.moon.auto_hide then return false end
	if main_updates.radar_open and main_updates.slider_visible then return false end
	if main_updates.map_open and main_updates.map_interact then return false end
	if main_updates.rest_open return false end
	return true
end

return moon_updates