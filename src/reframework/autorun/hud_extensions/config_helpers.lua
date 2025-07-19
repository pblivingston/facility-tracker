local core = require("hud_extensions/core")

local config_helpers = { re_ui = {} }

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

function config_helpers.alignedText(text)
	local cursor_pos = imgui.get_cursor_pos()
	local new_x = cursor_pos.x - 3.001
	imgui.set_cursor_pos(Vector2f.new(new_x, cursor_pos.y))
	imgui.push_item_width(0.001)
	imgui.input_text(text, nil)
	imgui.pop_item_width()
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

return config_helpers