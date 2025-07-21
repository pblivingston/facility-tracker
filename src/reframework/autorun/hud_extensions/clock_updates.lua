local core         = require("hud_extensions/core")
local main_updates = require("hud_extensions/main_updates")

local clock_updates = {}

function clock_updates.hide()
	local config = core.config.clock
	if (main_updates.hud_hidden and config.auto_hide)
		or () then 
		return true
	end
	return false
end

return clock_updates