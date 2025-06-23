local core = { captured_args = nil }

local config_path = "facility_tracker.json"

core.config = {
	tr_hotkey        = "None",
	ti_hotkey        = "None",
	vo_hotkey        = "None",
	ck_hotkey        = "None",
	mo_hotkey        = "None",
	draw_tracker     = true,
	draw_bars        = true,
    draw_timers      = false,
	draw_flags       = true,
	old_icons        = true,
	auto_hide        = true,
	hide_w_hud       = true,
	hide_w_bowling   = false,
	hide_w_wrestle   = false,
	hide_at_table    = false,
	hide_at_camp     = false,
	show_when        = "Don't show when:",
	hide_in_tent     = false,
	hide_on_map      = false,
	hide_in_quest    = false,
	hide_in_combat   = false,
	hide_in_qstcbt   = false,
	hide_in_hlfcbt   = false,
	draw_in_tent     = true,
	draw_on_map      = true,
	draw_in_life     = true,
	draw_in_base     = true,
	draw_in_train    = false,
    draw_ticker      = false,
	draw_ship        = true,
	draw_trades      = true,
	auto_hide_t      = true,
	draw_voucher     = true,
	auto_hide_v      = true,
	draw_moon        = true,
	draw_m_num       = false,
	ghub_moon        = "Hub moon",
	auto_hide_m      = true,
	draw_clock       = true,
	auto_hide_c      = true,
	non_meridian_c   = false,
    tr_user_scale    = 1.0,
    tr_opacity       = 1.0,
    ti_speed_scale   = 1.0,
    ti_user_scale    = 1.0,
    ti_opacity       = 1.0,
	vo_opacity       = 1.0,
	ck_opacity       = 1.0,
    countdown 	     = 3,
	box_datas	     = {
		Rations   = { size = 10, timer = 600 },
		Shares    = { size = 100 },
		Nest      = { count = 0, size = 5, timer = 1200 },
		pugee     = { timer = 2520 },
		retrieval = { full = false },
		Rysher    = { count = 0, size = 16 },
		Murtabak  = { count = 0, size = 16 },
		Apar      = { count = 0, size = 16 },
		Plumpeach = { count = 0, size = 16 },
		Sabar     = { count = 0, size = 16 }
	}
}

function core.save_config()
    json.dump_file(config_path, core.config)
end

function core.load_config()
    local loaded_config = json.load_file(config_path)
    if loaded_config then
        for key, value in pairs(loaded_config) do
            if core.config[key] ~= nil then
                core.config[key] = value
            end
        end
    else
        core.save_config()
    end
end

function core.capture_args(args)
    core.captured_args = args
end

function core.get_index(indexed_table, value)
	for i, e in ipairs(indexed_table) do
		if e == value then
			return i
		end
	end
	return nil
end

local imgui_keys = {
    ["Tab"] = 512,
    ["LeftArrow"] = 513,
    ["RightArrow"] = 514,
    ["UpArrow"] = 515,
    ["DownArrow"] = 516,
    ["PageUp"] = 517,
    ["PageDown"] = 518,
    ["Home"] = 519,
    ["End"] = 520,
    ["Insert"] = 521,
    ["Delete"] = 522,
    ["Backspace"] = 523,
    ["Space"] = 524,
    ["Enter"] = 525,
    ["None"] = 526,      -- Escape
    ["LeftCtrl"] = 527,
    ["LeftShift"] = 528,
    ["LeftAlt"] = 529,
    ["LeftSuper"] = 530,
    ["RightCtrl"] = 531,
    ["RightShift"] = 532,
    ["RightAlt"] = 533,
    ["RightSuper"] = 534,
    ["Menu"] = 535,
    ["Num0"] = 536,
    ["Num1"] = 537,
    ["Num2"] = 538,
    ["Num3"] = 539,
    ["Num4"] = 540,
    ["Num5"] = 541,
    ["Num6"] = 542,
    ["Num7"] = 543,
    ["Num8"] = 544,
    ["Num9"] = 545,
    ["A"] = 546,
    ["B"] = 547,
    ["C"] = 548,
    ["D"] = 549,
    ["E"] = 550,
    ["F"] = 551,
    ["G"] = 552,
    ["H"] = 553,
    ["I"] = 554,
    ["J"] = 555,
    ["K"] = 556,
    ["L"] = 557,
    ["M"] = 558,
    ["N"] = 559,
    ["O"] = 560,
    ["P"] = 561,
    ["Q"] = 562,
    ["R"] = 563,
    ["S"] = 564,
    ["T"] = 565,
    ["U"] = 566,
    ["V"] = 567,
    ["W"] = 568,
    ["X"] = 569,
    ["Y"] = 570,
    ["Z"] = 571,
    ["F1"] = 572,
    ["F2"] = 573,
    ["F3"] = 574,
    ["F4"] = 575,
    ["F5"] = 576,
    ["F6"] = 577,
    ["F7"] = 578,
    ["F8"] = 579,
    ["F9"] = 580,
    ["F10"] = 581,
    ["F11"] = 582,
    ["F12"] = 583,
    ["F13"] = 584,
    ["F14"] = 585,
    ["F15"] = 586,
    ["F16"] = 587,
    ["F17"] = 588,
    ["F18"] = 589,
    ["F19"] = 590,
    ["F20"] = 591,
    ["F21"] = 592,
    ["F22"] = 593,
    ["F23"] = 594,
    ["F24"] = 595,
    ["Apostrophe"] = 596,   -- '
    ["Comma"] = 597,        -- ,
    ["Minus"] = 598,        -- -
    ["Period"] = 599,       -- .
    ["Slash"] = 600,        -- /
    ["Semicolon"] = 601,    -- ;
    ["Equal"] = 602,        -- =
    ["LeftBracket"] = 603,  -- [
    ["Backslash"] = 604,    -- \
    ["RightBracket"] = 605, -- ]
    ["GraveAccent"] = 606,  -- `
    ["CapsLock"] = 607,
    ["ScrollLock"] = 608,
    ["NumLock"] = 609,
    ["PrintScreen"] = 610,
    ["Pause"] = 611,
    ["Keypad0"] = 612,
    ["Keypad1"] = 613,
    ["Keypad2"] = 614,
    ["Keypad3"] = 615,
    ["Keypad4"] = 616,
    ["Keypad5"] = 617,
    ["Keypad6"] = 618,
    ["Keypad7"] = 619,
    ["Keypad8"] = 620,
    ["Keypad9"] = 621,
    ["KeypadDecimal"] = 622,
    ["KeypadDivide"] = 623,
    ["KeypadMultiply"] = 624,
    ["KeypadSubtract"] = 625,
    ["KeypadAdd"] = 626,
    ["KeypadEnter"] = 627,
    ["KeypadEqual"] = 628
}

core.hotkeys = {
	["tr_hotkey"] = { message = core.config.tr_hotkey or "None", listening = false, draw = "draw_tracker" },
	["ti_hotkey"] = { message = core.config.ti_hotkey or "None", listening = false, draw = "draw_ticker"  },
	["vo_hotkey"] = { message = core.config.vo_hotkey or "None", listening = false, draw = "draw_voucher" },
	["ck_hotkey"] = { message = core.config.ck_hotkey or "None", listening = false, draw = "draw_clock"   },
	["mo_hotkey"] = { message = core.config.mo_hotkey or "None", listening = false, draw = "draw_moon"    }
}

function core.get_new_hotkey(hotkey)
	for key_name, key_index in pairs(imgui_keys) do
		if imgui.is_key_pressed(key_index) then
			core.config[hotkey] = key_name
			core.hotkeys[hotkey].message = key_name
			core.hotkeys[hotkey].listening = false
			core.save_config()
			break
		end
	end
end

function core.hotkey_toggle()
	for hk_name, hk_data in pairs(core.hotkeys) do
		local hotkey = core.config[hk_name]
		if imgui.is_key_pressed(imgui_keys[hotkey]) and hotkey ~= "None" then
			core.config[hk_data.draw] = not core.config[hk_data.draw]
			core.save_config()
		end
	end
end

return core