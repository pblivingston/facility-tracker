local core = require("hud_extensions/core")

local config_helpers = { re_ui = {} }

config_helpers.caps = { "Top", "Bottom" }
config_helpers.sides = { "Left", "Right" }
config_helpers.corners = {
	"Top-Left",
	"Top-Right",
	"Bottom-Left",
	"Bottom-Right"
}

local hotkeys = {
	["facility"] = { message = core.config.facility.hotkey or "None", listening = false },
	["ticker"] = { message = core.config.ticker.hotkey or "None", listening = false },
	["voucher"] = { message = core.config.voucher.hotkey or "None", listening = false },
	["clock"] = { message = core.config.clock.hotkey or "None", listening = false },
	["moon"] = { message = core.config.moon.hotkey or "None", listening = false }
}

function config_helpers.get_new_hotkey(hk_name)
	for key_name, key_index in pairs(core.imgui_keys) do
		if imgui.is_key_pressed(key_index) then
			core.config[hk_name].hotkey = key_name
			hotkeys[hk_name].message = key_name
			hotkeys[hk_name].listening = false
			core.save_config()
			break
		end
	end
end

function config_helpers.hotkey_toggle()
	for _, hk_data in pairs(hotkeys) do
		if hk_data.listening then return end
	end
	
	for hk_name, _ in pairs(hotkeys) do
		local key = core.config[hk_name].hotkey
		if imgui.is_key_pressed(core.imgui_keys[key]) and key ~= "None" then
			core.config[hk_name].draw = not core.config[hk_name].draw
			core.save_config()
		end
	end
end

function config_helpers.calc_options_w(options)
    local widths = {}
    for i, option in ipairs(options) do
        local size = imgui.calc_text_size(option)
        widths[i] = size.x
    end
    if #widths == 0 then return 0 end
    return math.max(table.unpack(widths))
end

function config_helpers.alignedText(text)
	local cursor_pos = imgui.get_cursor_pos()
	local new_x = cursor_pos.x - 3.001
	imgui.set_cursor_pos(Vector2f.new(new_x, cursor_pos.y))
	imgui.push_item_width(0.001)
	imgui.input_text(text, nil)
	imgui.pop_item_width()
end

function config_helpers.alignNext(label)
	imgui.unindent(10)
	config_helpers.alignedText("##align_" .. label)
	imgui.indent(10)
	imgui.same_line()
end

function config_helpers.checkbox(label, setting)
    local current = core.get_nested(core.config, setting)
    local dCheck, check = imgui.checkbox(label, current)
    if dCheck then
        core.set_nested(core.config, setting, check)
        core.save_config()
    end
end

function config_helpers.checkboxes(checkboxes)
	for _, cb in ipairs(checkboxes) do
		local label, setting, pretext = cb[1], cb[2], cb[3]
		if pretext ~= nil then
			local cursor_pos = imgui.get_cursor_pos()
			local text_size = imgui.calc_text_size(pretext)
			local new_x = cursor_pos.x - text_size.x - 9
			imgui.set_cursor_pos(Vector2f.new(new_x, cursor_pos.y))
			config_helpers.alignedText(pretext)
			imgui.same_line()
		end
		config_helpers.checkbox(label, setting)
	end
end

function config_helpers.combo(label, setting, options)
    local current_value = core.get_nested(core.config, setting)
    local index = core.get_index(options, current_value)
    local lbl = string.format("%s##%s", label, setting)
    local dIdx, newIdx = imgui.combo(lbl, index, options)
    if dIdx then
        core.set_nested(core.config, setting, options[newIdx])
        core.save_config()
    end
end

function config_helpers.combos(combos)
	for _, cm in ipairs(combos) do
		local label, setting, options, pretext = cm[1], cm[2], cm[3], cm[4]
		if pretext ~= nil then
			local cursor_pos = imgui.get_cursor_pos()
			local text_size = imgui.calc_text_size(pretext)
			local new_x = cursor_pos.x - text_size.x - 9
			imgui.set_cursor_pos(Vector2f.new(new_x, cursor_pos.y))
			config_helpers.alignedText(pretext)
			imgui.same_line()
		end
		config_helpers.combo(label, setting, options)
	end
end

function config_helpers.all_combo()

end

function config_helpers.slider(label, setting, low, high)
    imgui.text(label .. ":")
    imgui.same_line()
    
    local cursor_pos = imgui.get_cursor_pos()
    local txtbox_w = config_helpers.re_ui.font_size * 2.5
    local txtbox_x = config_helpers.re_ui.window_w - txtbox_w + 23
    imgui.set_cursor_pos(Vector2f.new(txtbox_x, cursor_pos.y))
    imgui.push_item_width(txtbox_w)
    local txt_label = string.format(" (%.1f to %.1f)", low, high)
    local current_value = core.get_nested(core.config, setting)
    local dTxt, txt_string, _, _ = imgui.input_text(txt_label, tostring(current_value))
    local txt = math.min(high, math.max(low, tonumber(txt_string) or 1))
    if dTxt then
        core.set_nested(core.config, setting, txt)
        core.save_config()
    end
    imgui.pop_item_width()
    
    local sld_label = "##" .. setting
    local dSld, sld = imgui.slider_float(sld_label, core.get_nested(core.config, setting), low, high)
    if dSld then
        core.set_nested(core.config, setting, sld)
        core.save_config()
    end
end

function config_helpers.sliders(sliders)
	for _, sld in ipairs(sliders) do
		local label, setting, low, high = sld[1], sld[2], sld[3], sld[4]
		config_helpers.slider(label, setting, low, high)
	end
end

function config_helpers.toggle_button(tbl)
	local nt = core.get_nested(core.config, tbl)
	local mode = core.get_mode(nt)
	local msg = mode and "Off" or "On"
	if imgui.button("Toggle All " .. msg .. "##" .. tbl) then
		for k, v in pairs(nt) do
			local nk = tbl .. "." .. k
			if type(v) == "boolean" then core.set_nested(core.config, nk, not mode) end
		end
		core.save_config()
	end
end

function config_helpers.main(label, setting, hotkey)
	config_helpers.checkbox(label, setting)
	imgui.same_line()
	
	local cursor_pos = imgui.get_cursor_pos()
	local text_size = imgui.calc_text_size("Hotkey")
	local button_w = text_size.x + 7
	local button_x = config_helpers.re_ui.window_w - button_w + 23
	imgui.set_cursor_pos(Vector2f.new(button_x, cursor_pos.y))
	if imgui.button("Hotkey##" .. hotkey, Vector2f.new(button_w, config_helpers.re_ui.button_h)) then
		hotkeys[hotkey].listening = true
		hotkeys[hotkey].message = "press a key..."
	end
	if hotkeys[hotkey].listening then config_helpers.get_new_hotkey(hotkey) end
	imgui.same_line()
	imgui.text(hotkeys[hotkey].message)
end

function config_helpers.hiding(label, mod_name, options)
	config_helpers.alignNext("hide_" .. mod_name)
	if imgui.tree_node(label .. "##" .. mod_name) then
		local general = {
			{ "On the Map",           mod_name .. ".hiding.map",    options },
			{ "In a Tent",            mod_name .. ".hiding.tent",   options },
			{ "In a Makeshift Tent",  mod_name .. ".hiding.temp",   options },
			{ "At Camp Gear",         mod_name .. ".hiding.camp",   options },
			{ "At Hub Tables",        mod_name .. ".hiding.tables", options },
			{ "While Arm Wrestling",  mod_name .. ".hiding.wrest",  options },
			{ "While Barrel Bowling", mod_name .. ".hiding.bowl",   options },
		}
		local radial = {
			{ { "In a Base Camp (Includes the Grand Hub)", mod_name .. ".hiding.base",     options },
				{ "With the Radial Menu",                  mod_name .. ".hiding.base_rad", options } },
			{ { "In a Village",           mod_name .. ".hiding.life",          options },
				{ "With the Radial Menu", mod_name .. ".hiding.life_rad",      options } },
			{ { "In the Training Area",   mod_name .. ".hiding.train",         options },
				{ "With the Radial Menu", mod_name .. ".hiding.train_rad",     options } },
			{ { "While Exploring",        mod_name .. ".hiding.field",         options },
				{ "With the Radial Menu", mod_name .. ".hiding.field_rad",     options } },
			{ { "In Combat",              mod_name .. ".hiding.combat",        options },
				{ "With the Radial Menu", mod_name .. ".hiding.combat_rad",    options } },
			{ { "While the Monster is Searching (Post-Combat)", mod_name .. ".hiding.h_combat",     options },
				{ "With the Radial Menu",                       mod_name .. ".hiding.h_combat_rad", options } },
			{ { "On a Quest",             mod_name .. ".hiding.quest",         options },
				{ "With the Radial Menu", mod_name .. ".hiding.quest_rad",     options } },
			{ { "In Combat on a Quest",   mod_name .. ".hiding.q_combat",      options },
				{ "With the Radial Menu", mod_name .. ".hiding.q_combat_rad",  options } },
			{ { "Post-Combat on a Quest", mod_name .. ".hiding.qh_combat",     options },
				{ "With the Radial Menu", mod_name .. ".hiding.qh_combat_rad", options } }
		}
		if options then
			local combo_w = config_helpers.calc_options_w(options)
			imgui.push_item_width(combo_w + config_helpers.re_ui.font_size * 1.1 + 10)
			
			-- all_combo here
			
			config_helpers.combos(general)
			for _, rads in ipairs(radial) do
				local main, rado = rads[1], rads[2]
				config_helpers.combo(main[1], main[2], main[3])
					imgui.indent(config_helpers.re_ui.indent_w)
					config_helpers.combo(rado[1], rado[2], rado[3])
					imgui.unindent(config_helpers.re_ui.indent_w)
			end
			imgui.pop_item_width()
		else
			config_helpers.toggle_button(mod_name .. ".hiding")
			imgui.text("")
			config_helpers.checkboxes(general)
			for _, rads in ipairs(radial) do
				local main, rado = rads[1], rads[2]
				config_helpers.checkbox(main[1], main[2])
					imgui.indent(config_helpers.re_ui.indent_w)
					config_helpers.checkbox(rado[1], rado[2])
					imgui.unindent(config_helpers.re_ui.indent_w)
			end
		end
		imgui.tree_pop()
	end
end

return config_helpers