local core           = require("hud_extensions/core")
local main_updates   = require("hud_extensions/main_updates")
local config_helpers = require("hud_extensions/config_helpers")

local config_window = { open = false }

local function facility_tracker()
	local re_ui = config_helpers.re_ui
	if imgui.tree_node("Facility Tracker") then
		config_helpers.main("Display Tracker", "draw_tracker", "tr_hotkey")
			imgui.begin_disabled(not core.config.draw_tracker)
			imgui.separator()
			local checkboxes = {
				{ "Progress Bars",         "draw_bars"     },
				{ "Timers",                "draw_timers"   },
				{ "Flags",                 "draw_flags"    },
				{ "Old Village Icons",     "old_icons"     },
				{ "Automatic Hiding",      "auto_hide"     },
				{ "Show with Radial Menu", "tr_radialMenu" }
			}
			config_helpers.checkboxes(checkboxes)
				imgui.indent(re_ui.indent_w)
				imgui.text("(Overrides Auto-Hide)")
				imgui.unindent(re_ui.indent_w)
			imgui.separator()
			imgui.unindent(10)
			config_helpers.alignedText("##mini_align")
			imgui.indent(10)
			imgui.same_line()
			if imgui.tree_node("Mini Tracker Settings") then
				config_helpers.main("Use Mini Tracker", "mini_tracker", "mi_hotkey")
				imgui.separator()
					imgui.begin_disabled(not core.config.mini_tracker)
					local mini_cbs = {
						{ "Item Counts/Ship Countdown",     "mini_counts"   },
						{ "Full Tracker in Tent/on Map",    "mi_tent_map"   },
						{ "Full Tracker with Radial Menu",  "mi_radialMenu" }
					}
					config_helpers.checkboxes(mini_cbs)
					imgui.text("")
					local inc_options = {
						"Never",
						"Always",
						"Available",
						"Full"
					}
					local include = {
						{ "Support Ship",       "mini_ship",      { "Never", "Always", "In Port", "Near Departure" } },
						{ "Ingredient Center",  "mini_ration",    inc_options },
						{ "Material Retrieval", "mini_retrieval", inc_options },
						{ "Festival Shares",    "mini_shares",    inc_options },
						{ "Crake Nest",         "mini_nest",      inc_options },
						{ "Poogie",             "mini_pugee",     { "Never", "Always", "Available" } },
					}
					local inc_size = imgui.calc_text_size("Available")
					imgui.text("When to include:")
					imgui.push_item_width(inc_size.x + re_ui.font_size * 1.1 + 10)
					config_helpers.combos(include)
					imgui.pop_item_width()
					imgui.text("")
					local cursor_pos = imgui.get_cursor_pos()
					local side = core.config.mini_right and "right" or "left"
					config_helpers.alignedText("Shows in bottom-" .. side)
					imgui.same_line()
					local text_size = imgui.calc_text_size("Switch")
					local button_w = text_size.x + 7
					local button_x = re_ui.window_w - button_w + 23
					imgui.set_cursor_pos(Vector2f.new(button_x, cursor_pos.y))
					if imgui.button("Switch##mini_right", Vector2f.new(button_w, re_ui.button_h)) then
						core.config.mini_right = not core.config.mini_right; core.save_config()
					end
					imgui.text("(Shows in top-right in tent/on map)")
					imgui.end_disabled()
				imgui.tree_pop()
			end
			imgui.separator()
			config_helpers.slider("Tracker Scale", "tr_user_scale", 0.5, 2.0)
			config_helpers.slider("Tracker Opacity", "tr_opacity", 0.0, 1.0)
			imgui.separator()
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function trades_ticker()
	local re_ui = config_helpers.re_ui
	if imgui.tree_node("Trades Ticker") then
		config_helpers.main("Display Ticker", "draw_ticker", "ti_hotkey")
		imgui.separator()
			imgui.begin_disabled(not core.config.draw_ticker)
			local checkboxes = {
				{ "Include Ship",          "draw_ship"     },
				{ "Include Trades",        "draw_trades"   },
				{ "Automatic Hiding",      "auto_hide_t"   },
				{ "Show with Radial Menu", "ti_radialMenu" }
			}
			config_helpers.checkboxes(checkboxes)
				imgui.indent(re_ui.indent_w)
				imgui.text("(Overrides Auto-Hide)")
				imgui.unindent(re_ui.indent_w)
			imgui.separator()
			config_helpers.slider("Ticker Speed", "ti_speed_scale", 0.1, 3.0)
			config_helpers.slider("Ticker Scale", "ti_user_scale", 0.5, 2.0)
			config_helpers.slider("Ticker Opacity", "ti_opacity", 0.0, 1.0)
			imgui.separator()
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function voucher_tracker()
	local re_ui = config_helpers.re_ui
	if imgui.tree_node("Voucher Tracker") then
		config_helpers.main("Display Vouchers", "draw_voucher", "vo_hotkey")
		imgui.separator()
			imgui.begin_disabled(not core.config.draw_voucher)
			local checkboxes = {
				{ "Automatic Hiding",      "auto_hide_v"   },
				{ "Show with Radial Menu", "vo_radialMenu" }
			}
			config_helpers.checkboxes(checkboxes)
				imgui.indent(re_ui.indent_w)
				imgui.text("(Overrides Auto-Hide)")
				imgui.unindent(re_ui.indent_w)
			imgui.separator()
			local vouch_label = main_updates.alt_tracker and "Voucher (Tracker) Scale" or "Voucher Scale"
			local vouch_scale = main_updates.alt_tracker and "tr_user_scale" or "ti_user_scale"
			config_helpers.slider(vouch_label, vouch_scale, 0.5, 2.0)
			config_helpers.slider("Voucher Opacity", "vo_opacity", 0.0, 1.0)
			imgui.separator()
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function system_clock()
	local re_ui = config_helpers.re_ui
	if imgui.tree_node("System Clock") then
		config_helpers.main("Display Clock", "draw_clock", "ck_hotkey")
		imgui.separator()
			imgui.begin_disabled(not core.config.draw_clock)
			local checkboxes = {
				{ "24-hour Clock",         "non_meridian_c" },
				{ "Automatic Hiding",      "auto_hide_c"    },
				{ "Show with Radial Menu", "ck_radialMenu"  }
			}
			config_helpers.checkboxes(checkboxes)
				imgui.indent(re_ui.indent_w)
				imgui.text("(Overrides Auto-Hide)")
				imgui.unindent(re_ui.indent_w)
			imgui.separator()
			local clock_label = main_updates.alt_tracker and "Clock (Tracker) Scale" or "Clock Scale"
			local clock_scale = main_updates.alt_tracker and "tr_user_scale" or "ti_user_scale"
			config_helpers.slider(clock_label, clock_scale, 0.5, 2.0)
			config_helpers.slider("Clock Opacity", "ck_opacity", 0.0, 1.0)
			imgui.separator()
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

local function hiding_options()
	local re_ui = config_helpers.re_ui
	if imgui.tree_node("Automatic Hiding Options") then
		config_helpers.checkbox("Hide with HUD", "hide_w_hud")
			imgui.begin_disabled(not core.config.hide_w_hud)
				imgui.indent(re_ui.indent_w)
				imgui.text("Partial HUD Options:")
				local hwh_checkboxes = {
					{ "Hide while bowling",       "hide_w_bowling" },
					{ "Hide while arm wrestling", "hide_w_wrestle" },
					{ "Hide at hub tables",       "hide_at_table"  },
					{ "Hide at camp gear",        "hide_at_camp"   }
				}
				config_helpers.checkboxes(hwh_checkboxes)
				imgui.unindent(re_ui.indent_w)
			imgui.end_disabled()
		imgui.text("")
		local show_when = {
			"Don't show when:",
			"Only show when:"
		}
		local show_when_size = imgui.calc_text_size("Don't show when:")
		imgui.push_item_width(show_when_size.x + re_ui.font_size * 1.2 + 10)
		config_helpers.combo("", "show_when", show_when)
		imgui.pop_item_width()
			imgui.indent(re_ui.indent_w)
			if core.config.show_when == "Don't show when:" then
				config_helpers.checkbox("in a tent", "hide_in_tent")
				config_helpers.checkbox("viewing the map", "hide_on_map")
					imgui.begin_disabled(core.config.hide_in_qstcbt)
					config_helpers.checkbox("in a quest", "hide_in_quest")
					config_helpers.checkbox("in any combat", "hide_in_combat")
					imgui.end_disabled()
				config_helpers.checkbox("in quest combat (exclusive)", "hide_in_qstcbt")
					imgui.begin_disabled(not (core.config.hide_in_combat or core.config.hide_in_qstcbt))
					config_helpers.checkbox("monster is searching (post-combat)", "hide_in_hlfcbt")
					imgui.end_disabled()
			end
			if core.config.show_when == "Only show when:" then
				local only_checkboxes = {
					{ "in a tent",            "draw_in_tent"  },
					{ "viewing the map",      "draw_on_map"   },
					{ "in a village",         "draw_in_life"  },
					{ "in a base camp",       "draw_in_base"  },
					{ "in the training area", "draw_in_train" }
				}
				config_helpers.checkboxes(only_checkboxes)
				config_helpers.alignedText("##space")
			end
			imgui.unindent(re_ui.indent_w)
		imgui.separator()
		imgui.tree_pop()
	end
end

local function moon_tracker()
	local re_ui = config_helpers.re_ui
	if imgui.tree_node("Moon Phase Tracker") then
		config_helpers.main("Display Moon Phase", "moon.draw", "moon.hotkey")
		imgui.separator()
			imgui.begin_disabled(not core.config.moon.draw)
			config_helpers.alignedText("In Hub show:")
				imgui.same_line()
				local hub_show = {
					"Hub moon",
					"Main moon",
					"Nothing"
				}
				local hub_show_size = imgui.calc_text_size("Main moon")
				imgui.push_item_width(hub_show_size.x + re_ui.font_size * 1.08 + 10)
				config_helpers.combo("", "moon.ghub_moon", hub_show)
				imgui.pop_item_width()
			imgui.text("")
			local checkboxes = {
				{ "Show Numerals",           "moon.draw_num"  },
				{ "Hide with Time & Season", "moon.auto_hide" }
			}
			config_helpers.checkboxes(checkboxes)
			imgui.separator()
			imgui.end_disabled()
		imgui.tree_pop()
	end
end

function config_window.draw_config()
	imgui.set_next_window_size(Vector2f.new(325, 500), 1 << 1)
	if imgui.begin_window("Facility Tracker and HUD Extensions", true) then
		config_helpers.re_ui.font_size = imgui.get_default_font_size()
		config_helpers.re_ui.window_w = imgui.calc_item_width()
		config_helpers.re_ui.button_h = config_helpers.re_ui.font_size + 6
		config_helpers.re_ui.indent_w = config_helpers.re_ui.font_size + 3
		
		facility_tracker()
		trades_ticker()
		voucher_tracker()
		system_clock()
		hiding_options()
		moon_tracker()
		
		imgui.end_window()
	else
		imgui.end_window()
		config_window.open = false
	end
end

return config_window