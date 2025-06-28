local core = require("ui_extensions/core")

local config_window = { open = false }

local re_ui = {}

local function re_ui_main(label, setting, hotkey)
	local dVal, newVal = imgui.checkbox(label, core.config[setting])
	if dVal then core.config[setting] = newVal; core.save_config() end
	imgui.same_line()
	
	local cursor_pos = imgui.get_cursor_pos()
	imgui.set_cursor_pos(Vector2f.new(re_ui.button_x, cursor_pos.y))
	if imgui.button("Hotkey##" .. hotkey, Vector2f.new(re_ui.button_w, re_ui.button_h)) then
		core.hotkeys[hotkey].listening = true
		core.hotkeys[hotkey].message = "press a key..."
	end
	if core.hotkeys[hotkey].listening then core.get_new_hotkey(hotkey) end
	imgui.same_line()
	imgui.text(core.hotkeys[hotkey].message)
end

local function re_ui_checkbox(label, setting)
	local dCheck, check = imgui.checkbox(label, core.config[setting])
	if dCheck then core.config[setting] = check; core.save_config() end
end

local function re_ui_checkboxes(checkboxes)
	for _, cb in ipairs(checkboxes) do
		local label, key = cb[1], cb[2]
		local dVal, newVal = imgui.checkbox(label, core.config[key])
		if dVal then
			core.config[key] = newVal
			core.save_config()
		end
	end
end

local function re_ui_slider(label, setting, low, high)
	imgui.text(label .. ":")
	imgui.same_line()
	
	local cursor_pos = imgui.get_cursor_pos()
	imgui.set_cursor_pos(Vector2f.new(re_ui.txtbox_x, cursor_pos.y))
	imgui.push_item_width(re_ui.txtbox_w)
	local txt_label = string.format(" (%.1f to %.1f)", low, high)
	local dTxt, txt_string, _, _ = imgui.input_text(txt_label, core.config[setting])
	local txt = math.min(high, math.max(low, tonumber(txt_string) or 1))
	if dTxt then core.config[setting] = txt; core.save_config() end
	imgui.pop_item_width()
	
	local sld_label = "##" .. setting
	local dSld, sld = imgui.slider_float(sld_label, core.config[setting], low, high)
	if dSld then core.config[setting] = sld; core.save_config() end
end

local function re_ui_combo(label, setting, options)
	local index = core.get_index(options, core.config[setting])
	local lbl = string.format("%s##%s", label, setting)
	local dIdx, newIdx = imgui.combo(lbl, index, options)
	if dIdx then core.config[setting] = options[newIdx]; core.save_config() end
end

function config_window.draw_config()
	imgui.set_next_window_size(Vector2f.new(325, 500), 1 << 1)
	if imgui.begin_window("Facility Tracker and UI Extensions", true) then
		re_ui.font_size = imgui.get_default_font_size()
		re_ui.window_w = imgui.calc_item_width()
		re_ui.txtbox_w = re_ui.font_size * 2.5
		re_ui.txtbox_x = re_ui.window_w - re_ui.txtbox_w + 23
		re_ui.button_w = re_ui.font_size * 2.79 + 6
		re_ui.button_h = re_ui.font_size + 6
		re_ui.button_x = re_ui.window_w - re_ui.button_w + 23
		re_ui.indent_w = re_ui.font_size + 3

		if imgui.tree_node("Facility Tracker") then
			re_ui_main("Display Tracker", "draw_tracker", "tr_hotkey")
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
				re_ui_checkboxes(checkboxes)
					imgui.indent(re_ui.indent_w)
					imgui.text("(Overrides Auto-Hide)")
					imgui.unindent(re_ui.indent_w)
				imgui.separator()
				re_ui_main("Mini Tracker", "mini_tracker", "mi_hotkey")
				if imgui.tree_node("Options") then
					imgui.begin_disabled(not core.config.mini_tracker)
					re_ui_checkbox("right", "mini_right")
					imgui.end_disabled()
					imgui.tree_pop()
				end
				imgui.separator()
				re_ui_slider("Tracker Scale", "tr_user_scale", 0.0, 2.0)
				re_ui_slider("Tracker Opacity", "tr_opacity", 0.0, 1.0)
				imgui.separator()
				imgui.end_disabled()
			imgui.tree_pop()
		end
		
		if imgui.tree_node("Trades Ticker") then
			re_ui_main("Display Ticker", "draw_ticker", "ti_hotkey")
			imgui.separator()
				imgui.begin_disabled(not core.config.draw_ticker)
				local checkboxes = {
					{ "Include Ship",          "draw_ship"     },
					{ "Include Trades",        "draw_trades"   },
					{ "Automatic Hiding",      "auto_hide_t"   },
					{ "Show with Radial Menu", "ti_radialMenu" }
				}
				re_ui_checkboxes(checkboxes)
					imgui.indent(re_ui.indent_w)
					imgui.text("(Overrides Auto-Hide)")
					imgui.unindent(re_ui.indent_w)
				imgui.separator()
				re_ui_slider("Ticker Speed", "ti_speed_scale", 0.1, 3.0)
				re_ui_slider("Ticker Scale", "ti_user_scale", 0.0, 2.0)
				re_ui_slider("Ticker Opacity", "ti_opacity", 0.0, 1.0)
				imgui.separator()
				imgui.end_disabled()
			imgui.tree_pop()
		end
		
		if imgui.tree_node("Voucher Tracker") then
			re_ui_main("Display Vouchers", "draw_voucher", "vo_hotkey")
			imgui.separator()
				imgui.begin_disabled(not core.config.draw_voucher)
				local checkboxes = {
					{ "Automatic Hiding",      "auto_hide_v"   },
					{ "Show with Radial Menu", "vo_radialMenu" }
				}
				re_ui_checkboxes(checkboxes)
					imgui.indent(re_ui.indent_w)
					imgui.text("(Overrides Auto-Hide)")
					imgui.unindent(re_ui.indent_w)
				imgui.separator()
				re_ui_slider("Voucher Scale", "ti_user_scale", 0.0, 2.0)
				re_ui_slider("Voucher Opacity", "vo_opacity", 0.0, 1.0)
				imgui.separator()
				imgui.end_disabled()
			imgui.tree_pop()
		end
		
		if imgui.tree_node("System Clock") then
			re_ui_main("Display Clock", "draw_clock", "ck_hotkey")
			imgui.separator()
				imgui.begin_disabled(not core.config.draw_clock)
				local checkboxes = {
					{ "24-hour Clock",         "non_meridian_c" },
					{ "Automatic Hiding",      "auto_hide_c"    },
					{ "Show with Radial Menu", "ck_radialMenu"  }
				}
				re_ui_checkboxes(checkboxes)
					imgui.indent(re_ui.indent_w)
					imgui.text("(Overrides Auto-Hide)")
					imgui.unindent(re_ui.indent_w)
				imgui.separator()
				re_ui_slider("Clock Scale", "ti_user_scale", 0.0, 2.0)
				re_ui_slider("Clock Opacity", "ck_opacity", 0.0, 1.0)
				imgui.separator()
				imgui.end_disabled()
			imgui.tree_pop()
		end
		
		if imgui.tree_node("Automatic Hiding Options") then
			re_ui_checkbox("Hide with HUD", "hide_w_hud")
				imgui.begin_disabled(not core.config.hide_w_hud)
					imgui.indent(re_ui.indent_w)
					imgui.text("Partial HUD Options:")
					local hwh_checkboxes = {
						{ "Hide while bowling",       "hide_w_bowling" },
						{ "Hide while arm wrestling", "hide_w_wrestle" },
						{ "Hide at hub tables",       "hide_at_table"  },
						{ "Hide at camp gear",        "hide_at_camp"   }
					}
					re_ui_checkboxes(hwh_checkboxes)
					imgui.unindent(re_ui.indent_w)
				imgui.end_disabled()
			imgui.text("")
			local show_when = {
				"Don't show when:",
				"Only show when:"
			}
			imgui.push_item_width(re_ui.font_size * 8.5)
			re_ui_combo("", "show_when", show_when)
			imgui.pop_item_width()
				imgui.indent(re_ui.indent_w)
				if core.config.show_when == "Don't show when:" then
					re_ui_checkbox("in a tent", "hide_in_tent")
					re_ui_checkbox("viewing the map", "hide_on_map")
						imgui.begin_disabled(core.config.hide_in_qstcbt)
						re_ui_checkbox("in a quest", "hide_in_quest")
						re_ui_checkbox("in any combat", "hide_in_combat")
						imgui.end_disabled()
					re_ui_checkbox("in quest combat (exclusive)", "hide_in_qstcbt")
						imgui.begin_disabled(not (core.config.hide_in_combat or core.config.hide_in_qstcbt))
						re_ui_checkbox("monster is searching (post-combat)", "hide_in_hlfcbt")
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
					re_ui_checkboxes(only_checkboxes)
				end
				imgui.unindent(re_ui.indent_w)
			imgui.separator()
			imgui.tree_pop()
		end
		
		if imgui.tree_node("Moon Phase Tracker") then
			re_ui_main("Display Moon Phase", "draw_moon", "mo_hotkey")
			imgui.separator()
				imgui.begin_disabled(not core.config.draw_moon)
				imgui.text("In Grand Hub show:")
					imgui.indent(re_ui.indent_w)
					local hub_show = {
						"Hub moon",
						"Main moon",
						"Nothing"
					}
					imgui.push_item_width(re_ui.font_size * 6)
					re_ui_combo("", "ghub_moon", hub_show)
					imgui.pop_item_width()
					imgui.unindent(re_ui.indent_w)
				imgui.text("")
				local checkboxes = {
					{ "Show Numerals",    "draw_m_num"  },
					{ "Automatic Hiding", "auto_hide_m" }
				}
				re_ui_checkboxes(checkboxes)
					imgui.indent(re_ui.indent_w)
					imgui.text("(Hides with Time & Season)")
					imgui.unindent(re_ui.indent_w)
				imgui.separator()
				imgui.end_disabled()
			imgui.tree_pop()
		end
		
		imgui.end_window()
	else
		config_window.open = false
	end
end

return config_window