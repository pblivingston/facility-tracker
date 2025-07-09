local core = { captured_args = nil }

local config_path = "facility_tracker.json"

core.config = {
	tr_hotkey        = "None",
	mi_hotkey        = "None",
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
	tr_radialMenu    = true,
	mini_tracker     = false,
	mini_counts      = true,
	mi_tent_map      = true,
	mi_radialMenu    = true,
	mini_right       = false,
	mini_ship        = "Always",
	mini_ration      = "Always",
	mini_retrieval   = "Always",
	mini_shares      = "Always",
	mini_nest        = "Always",
	mini_pugee       = "Always",
    draw_ticker      = false,
	draw_ship        = true,
	draw_trades      = true,
	auto_hide_t      = true,
	ti_radialMenu    = true,
	draw_voucher     = true,
	auto_hide_v      = true,
	vo_radialMenu    = true,
	draw_clock       = true,
	auto_hide_c      = true,
	non_meridian_c   = false,
	ck_radialMenu    = true,
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
	draw_moon        = true,
	draw_m_num       = false,
	ghub_moon        = "Hub moon",
	auto_hide_m      = true,
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
		Sabar     = { count = 0, size = 16 },
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

function core.lerp(a, b, t)
    return a + (b - a) * t
end

function core.ease_in_out(frac)
	return (frac^2) / (2 * (frac^2 - frac) + 1)
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

core.singletons = {
	environment_manager = sdk.get_managed_singleton("app.EnvironmentManager"),
	mission_manager     = sdk.get_managed_singleton("app.MissionManager"),
	fade_manager        = sdk.get_managed_singleton("app.FadeManager"),
	gui_manager         = sdk.get_managed_singleton("app.GUIManager"),
	player_manager      = sdk.get_managed_singleton("app.PlayerManager"),
	minigame_manager    = sdk.get_managed_singleton("app.GameMiniEventManager"),
	facility_manager    = sdk.get_managed_singleton("app.FacilityManager"),
	savedata_manager    = sdk.get_managed_singleton("app.SaveDataManager")
}

core.situations = {
	arm_wrestling = 42,
	table_sitting = 43
}

core.stage_idx = {
	plains   = 0,
	forest   = 1,
	basin    = 2,
	cliffs   = 3,
	ruins    = 4,
	trail    = 5,
	tunnel   = 6,
	l_path   = 7,
	approach = 8,
	arena    = 9,
	peak     = 10,
	suja     = 12,
	g_hub    = 14,
	training = 15
}

core.tidx = {
    ration = 0,
    pugee  = 10,
    nest   = 11
}

core.npc_names = {
    [-2058179200] = "Rysher",
    [35]          = "Murtabak",
    [622724160]   = "Apar",
    [1066308736]  = "Plumpeach",
    [1558632320]  = "Sabar"
}

core.savedata = {
	vouchers  = { size = 5 },
	Rations   = { size = 10, timer = 600 },
	ship      = {  },
	Shares    = { size = 100 },
	Nest      = { count = 0, size = 5, full = false, timer = 1200 },
	pugee     = { timer = 2520 },
	retrieval = {
		Rysher    = {  },
		Murtabak  = {  },
		Apar      = {  },
		Plumpeach = {  },
		Sabar     = {  }
	},
}

function core.get_savedata()
	local savedata_manager = core.singletons.savedata_manager
	local savedata_idx = savedata_manager:get_field("CurrentUserDataIndex")
	return savedata_manager:get_field("_UserSaveData"):get_field("_Data"):get_element(savedata_idx)
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
	["mi_hotkey"] = { message = core.config.mi_hotkey or "None", listening = false, draw = "mini_tracker" },
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