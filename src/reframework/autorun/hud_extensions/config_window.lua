local core           = require("hud_extensions/core")
local config_helpers = require("hud_extensions/config_helpers")

local config_window = { open = false }

local function facility_tracker()
	local re_ui = config_helpers.re_ui
	
	imgui.separator()
	if imgui.tree_node("Facility Tracker") then
		config_helpers.main("Display Facilities", "facility.draw", "facility.hotkey")
			imgui.begin_disabled(not core.config.facility.draw)
			
			imgui.separator()
			config_helpers.alignNext("f_mini")
			if imgui.tree_node("Mini Tracker") then
				local mini_checkboxes = {
					{ "Progress Bars", "facility.mini.bars" },
					{ "Timers",        "facility.mini.timers" },
					{ "Counts/Days",   "facility.mini.counts" },
					{ "Flags",         "facility.mini.flags" }
				}
				config_helpers.checkboxes(mini_checkboxes)
				
				imgui.text("")
				if imgui.tree_node("Include") then
					local inc_options = {
						"Never",
						"Always",
						"Available",
						"Full"
					}
					local include = {
						{ "Support Ship",       "facility.mini.ship",      { "Never", "Always", "In Port", "Near Departure" } },
						{ "Ingredient Center",  "facility.mini.ration",    inc_options },
						{ "Material Retrieval", "facility.mini.retrieval", inc_options },
						{ "Festival Shares",    "facility.mini.shares",    inc_options },
						{ "Crake Nest",         "facility.mini.nest",      inc_options },
						{ "Poogie",             "facility.mini.pugee",     { "Never", "Always", "Available" } },
					}
					local inc_options_w = config_helpers.calc_options_w(inc_options)
					imgui.push_item_width(inc_options_w + re_ui.font_size * 1.1 + 10)
					config_helpers.combos(include)
					imgui.pop_item_width()
					imgui.tree_pop()
				end
				
				imgui.text("")
				if imgui.tree_node("Position##facility.mini") then
					local positions = {
						{ "Default",     "facility.mini.pos.default", config_helpers.sides },
						{ "In any Tent", "facility.mini.pos.tent",    config_helpers.sides },
						{ "On the Map",  "facility.mini.pos.map",     config_helpers.sides }
					}
					imgui.push_item_width(re_ui.sides_w + re_ui.font_size * 1.1 + 10)
					config_helpers.combos(positions)
					imgui.pop_item_width()
					imgui.tree_pop()
				end
				
				imgui.text("")
				imgui.tree_pop()
			end
			
			imgui.separator()
			config_helpers.alignNext("f_full")
			if imgui.tree_node("Full Tracker") then
				local full_checkboxes = {
					{ "Progress Bars",     "facility.full.bars" },
					{ "Timers",            "facility.full.timers" },
					{ "Flags",             "facility.full.flags" },
					{ "Old Village Icons", "facility.full.old_icons" }
				}
				config_helpers.checkboxes(full_checkboxes)
				imgui.text("")
				
				local full_sliders = {
					{ "Oversize Scroll Speed", "facility.full.speed",   0.1, 3.0 },
					{ "Opacity",               "facility.full.opacity", 0.0, 1.0 }
				}
				config_helpers.sliders(full_sliders)
				imgui.text("")
				imgui.tree_pop()
			end
			
			imgui.separator()
			config_helpers.checkbox("Hide with HUD", "facility.auto_hide")
			
			imgui.separator()
			local hiding = {
				"Mini Tracker",
				"Full Tracker",
				"Hide"
			}
			config_helpers.hiding("Hiding/Swapping", "facility", hiding)
			
			imgui.text("")
			imgui.separator()
			if imgui.button("Back Up##facility") then core.backup_config("facility") end
			if imgui.button("Reset##facility") then core.reset_config("facility") end
			
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function trades_ticker()
	local re_ui = config_helpers.re_ui
	
	imgui.separator()
	if imgui.tree_node("Trades Ticker") then
		config_helpers.main("Display Ticker", "ticker.draw", "ticker.hotkey")
			imgui.begin_disabled(not core.config.ticker.draw)
			
			imgui.separator()
			local checkboxes = {
				{ "Include Ship",   "ticker.ship"   },
				{ "Include Trades", "ticker.trades" },
				{ "Hide with HUD",  "ticker.auto_hide" }
			}
			config_helpers.checkboxes(checkboxes)
			
			imgui.separator()
			local sliders = {
				{ "Scroll Speed",   "ticker.speed",    0.1, 3.0 },
				{ "Opacity",        "ticker.opacity",  0.0, 1.0 },
				{ "Tent/Map Scale", "ticker.tm_scale", 0.5, 2.0 }
			}
			config_helpers.sliders(sliders)
			
			imgui.separator()
			config_helpers.alignNext("t_pos")
			if imgui.tree_node("Position##ticker") then
				imgui.text("(Except with Full Facility Tracker)")
				local positions = {
					{ "Default",     "ticker.pos.default", config_helpers.caps },
					{ "In any Tent", "ticker.pos.tent",    config_helpers.caps },
					{ "On the Map",  "ticker.pos.map",     config_helpers.caps }
				}
				imgui.push_item_width(re_ui.caps_w + re_ui.font_size * 1.1 + 10)
				config_helpers.combos(positions)
				imgui.pop_item_width()
				imgui.tree_pop()
			end
			
			imgui.separator()
			config_helpers.hiding("Hiding", "ticker")
			
			imgui.text("")
			imgui.separator()
			if imgui.button("Back Up##ticker") then core.backup_config("ticker") end
			if imgui.button("Reset##ticker") then core.reset_config("ticker") end
			
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function voucher_tracker()
	local re_ui = config_helpers.re_ui
	
	imgui.separator()
	if imgui.tree_node("Voucher Tracker") then
		config_helpers.main("Display Vouchers", "voucher.draw", "voucher.hotkey")
			imgui.begin_disabled(not core.config.voucher.draw)
			
			imgui.separator()
			local checkboxes = {
				{ "Voucher Count on Mini Tracker", "voucher.mini_count" },
				{ "Voucher Flag on Mini Tracker",  "voucher.mini_flag" },
				{ "Login Bonus Count",             "voucher.dliv_count" },
				{ "Hide with HUD",                 "voucher.auto_hide" }
			}
			config_helpers.checkboxes(checkboxes)
			
			imgui.separator()
			config_helpers.alignNext("v_pos")
			if imgui.tree_node("Position##voucher") then
				local positions = {
					{ "Default",                    "voucher.pos.default", config_helpers.corners },
					{ "With Full Facility Tracker", "voucher.pos.full",    config_helpers.sides },
					{ "In any Tent",                "voucher.pos.tent",    config_helpers.sides },
					{ "On the Map",                 "voucher.pos.map",     config_helpers.sides }
				}
				imgui.push_item_width(re_ui.corners_w + re_ui.font_size * 1.1 + 10)
				config_helpers.combos(positions)
				imgui.pop_item_width()
				imgui.tree_pop()
			end
			
			imgui.separator()
			local hiding = {
				"Full Tracker",
				"Mini Tracker",
				"Login Bonuses Only",
				"Hide"
			}
			config_helpers.hiding("Hiding/Swapping", "voucher", hiding)
			
			imgui.text("")
			imgui.separator()
			if imgui.button("Back Up##voucher") then core.backup_config("voucher") end
			if imgui.button("Reset##voucher") then core.reset_config("voucher") end
			
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function system_clock()
	local re_ui = config_helpers.re_ui
	
	imgui.separator()
	if imgui.tree_node("System Clock") then
		config_helpers.main("Display Clock", "clock.draw", "clock.hotkey")
			imgui.begin_disabled(not core.config.clock.draw)
			
			imgui.separator()
			local checkboxes = {
				{ "24-hour Clock", "clock.non_meridian" },
				{ "Hide with HUD", "clock.auto_hide"    }
			}
			config_helpers.checkboxes(checkboxes)
			
			imgui.separator()
			config_helpers.alignNext("c_pos")
			if imgui.tree_node("Position##clock") then
				local positions = {
					{ "Default",                    "clock.pos.default", config_helpers.corners },
					{ "With Full Facility Tracker", "clock.pos.full",    config_helpers.sides },
					{ "In any Tent",                "clock.pos.tent",    config_helpers.sides },
					{ "On the Map",                 "clock.pos.map",     config_helpers.sides }
				}
				imgui.push_item_width(re_ui.corners_w + re_ui.font_size * 1.1 + 10)
				config_helpers.combos(positions)
				imgui.pop_item_width()
				imgui.tree_pop()
			end
			
			imgui.separator()
			config_helpers.hiding("Hiding", "clock")
			
			imgui.text("")
			imgui.separator()
			if imgui.button("Back Up##clock") then core.backup_config("clock") end
			if imgui.button("Reset##clock") then core.reset_config("clock") end
			
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function moon_tracker()
	local re_ui = config_helpers.re_ui
	
	imgui.separator()
	if imgui.tree_node("Moon Phase Tracker") then
		config_helpers.main("Display Moon Phase", "moon.draw", "moon.hotkey")
			imgui.begin_disabled(not core.config.moon.draw)
			
			imgui.separator()
			config_helpers.alignedText("In Hub show:")
			imgui.same_line()
			local hub_show = {
				"Hub moon",
				"Main moon",
				"Nothing"
			}
			local hub_show_w = config_helpers.calc_options_w(hub_show)
			imgui.push_item_width(hub_show_w + re_ui.font_size * 1.1 + 10)
			config_helpers.combo("", "moon.ghub", hub_show)
			imgui.pop_item_width()
			
			imgui.text("")
			local checkboxes = {
				{ "Show Numerals",           "moon.num"  },
				{ "Hide with Time & Season", "moon.auto_hide" }
			}
			config_helpers.checkboxes(checkboxes)
			
			imgui.text("")
			imgui.separator()
			if imgui.button("Back Up##moon") then core.backup_config("moon") end
			if imgui.button("Reset##moon") then core.reset_config("moon") end
			
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function globals()
	imgui.text("")
	imgui.separator()
	local global_sliders = {
		{ "Top Scale",            "top_scale",    0.5, 2.0 },
		{ "Bottom Scale",         "bottom_scale", 0.5, 2.0 },
		{ "Tent/Map Scale",       "tm_scale",     0.5, 2.0 },
		{ "Top-Left Opacity",     "tl_opacity",   0.0, 1.0 },
		{ "Top-Right Opacity",    "tr_opacity",   0.0, 1.0 },
		{ "Bottom-Left Opacity",  "bl_opacity",   0.0, 1.0 },
		{ "Bottom-Right Opacity", "br_opacity",   0.0, 1.0 }
	}
	config_helpers.sliders(global_sliders)
	
	imgui.separator()
	imgui.text("")
	if imgui.button("Back Up Globals") then core.backup_config() end
	if imgui.button("Reset Globals") then core.reset_config() end
	
	imgui.text("")
	local ts = os.date("%Y-%m-%d_%H-%M-%S")
	local mod_names = {
		"facility",
		"ticker",
		"voucher",
		"clock",
		"moon"
	}
	if imgui.button("Back Up All") then
		core.backup_config(nil, ts)
		for _, mod_name in ipairs(mod_names) do
			core.backup_config(mod_name, ts)
		end
	end
	if imgui.button("Reset All") then
		core.reset_config(nil, ts)
		for _, mod_name in ipairs(mod_names) do
			core.reset_config(mod_name, ts)
		end
	end
	
		imgui.begin_disabled(true)
		imgui.text("")
		imgui.text("A reset also creates a backup")
		imgui.text("reframework/data/hud_extensions/backups")
		imgui.end_disabled()
end

function config_window.draw_config()
	imgui.set_next_window_size(Vector2f.new(325, 500), 1 << 1)
	if imgui.begin_window("Facility Tracker and HUD Extensions", true) then
		config_helpers.re_ui.font_size = imgui.get_default_font_size()
		config_helpers.re_ui.window_w = imgui.calc_item_width()
		config_helpers.re_ui.button_h = config_helpers.re_ui.font_size + 6
		config_helpers.re_ui.indent_w = config_helpers.re_ui.font_size + 3
		config_helpers.re_ui.corners_w = config_helpers.calc_options_w(config_helpers.corners)
		config_helpers.re_ui.sides_w = config_helpers.calc_options_w(config_helpers.sides)
		config_helpers.re_ui.caps_w = config_helpers.calc_options_w(config_helpers.caps)
		
		facility_tracker()
		trades_ticker()
		voucher_tracker()
		system_clock()
		moon_tracker()
		
		globals()
		
		imgui.end_window()
	else
		imgui.end_window()
		config_window.open = false
	end
end

return config_window