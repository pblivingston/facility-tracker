local core = require("hud_extensions/core")

local config_helpers = { re_ui = {} }

function config_helpers.alignedText(text)
	local cursor_pos = imgui.get_cursor_pos()
	local new_x = cursor_pos.x - 3.001
	imgui.set_cursor_pos(Vector2f.new(new_x, cursor_pos.y))
	imgui.push_item_width(0.001)
	imgui.input_text(text, nil)
	imgui.pop_item_width()
end

function config_helpers.checkbox(label, setting)
	local dCheck, check = imgui.checkbox(label, core.config[setting])
	if dCheck then core.config[setting] = check; core.save_config() end
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
	local index = core.get_index(options, core.config[setting])
	local lbl = string.format("%s##%s", label, setting)
	local dIdx, newIdx = imgui.combo(lbl, index, options)
	if dIdx then core.config[setting] = options[newIdx]; core.save_config() end
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

function config_helpers.main(label, setting, hotkey)
	config_helpers.checkbox(label, setting)
	imgui.same_line()
	
	local cursor_pos = imgui.get_cursor_pos()
	local text_size = imgui.calc_text_size("Hotkey")
	local button_w = text_size.x + 7
	local button_x = config_helpers.re_ui.window_w - button_w + 23
	imgui.set_cursor_pos(Vector2f.new(button_x, cursor_pos.y))
	if imgui.button("Hotkey##" .. hotkey, Vector2f.new(button_w, config_helpers.re_ui.button_h)) then
		core.hotkeys[hotkey].listening = true
		core.hotkeys[hotkey].message = "press a key..."
	end
	if core.hotkeys[hotkey].listening then core.get_new_hotkey(hotkey) end
	imgui.same_line()
	imgui.text(core.hotkeys[hotkey].message)
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
	local dTxt, txt_string, _, _ = imgui.input_text(txt_label, core.config[setting])
	local txt = math.min(high, math.max(low, tonumber(txt_string) or 1))
	if dTxt then core.config[setting] = txt; core.save_config() end
	imgui.pop_item_width()
	
	local sld_label = "##" .. setting
	local dSld, sld = imgui.slider_float(sld_label, core.config[setting], low, high)
	if dSld then core.config[setting] = sld; core.save_config() end
end

return config_helpers