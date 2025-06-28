local core             = require("ui_extensions/core")
local config_window    = require("ui_extensions/config_window")
local main_updates     = require("ui_extensions/main_updates")
local facility_helpers = require("ui_extensions/facility_helpers")
local facility_updates = require("ui_extensions/facility_updates")
local draw_helpers     = require("ui_extensions/draw_helpers")
local draw             = require("ui_extensions/draw")

core.load_config()                -- Load the config file
main_updates.register_hooks()     -- Register main update hooks
facility_updates.register_hooks() -- Register facility update hooks

-----------------------------------------------------------
-- ON-FRAME UPDATE
-----------------------------------------------------------

re.on_frame(
    function()
		-- print("starting on-frame updates!")
		
		main_updates.time_delta()
		
		local re_ui_open = reframework:is_drawing_ui()
		if config_window.open and re_ui_open then config_window.draw_config() end
		
		core.hotkey_toggle()
		
        if not main_updates.is_active_player() then
            facility_updates.first_run = true
			main_updates.previous_hidden = true
			main_updates.previous_fading = true
            core.save_config()
            return
        end
		
		-- print("starting active-player updates!")
		
		main_updates.get_fade()
		main_updates.get_hidden()
        facility_updates.get_ration_state()
        facility_updates.get_ship_state()
        facility_updates.get_shares_state()
		facility_updates.get_retrieval_state()
        facility_updates.get_nest_state()
		facility_updates.get_pugee_state()
		
        facility_updates.first_run = false
    end
)

----------------------------------------------------------------
-- CONFIG MENU
----------------------------------------------------------------

re.on_draw_ui(
	function()
		if imgui.button("Facility Tracker and UI Extensions") then
			config_window.open = true 
		end
		
		-- if imgui.tree_node("Tracker Data DELETE ME") then
			-- imgui.text("hide tracker: " .. tostring(main_updates.hide_tracker))
			-- imgui.text("hide moon: " .. tostring(main_updates.hide_moon))
			-- imgui.text("fade: " .. tostring(main_updates.fade_value))
			-- imgui.text("previous hidden: " .. tostring(main_updates.previous_hidden))
			-- imgui.text("previous fading: " .. tostring(main_updates.previous_fading))
			-- imgui.tree_pop()
		-- end
	end
)

-----------------------------------------------------------
-- REGISTER DRAW
-----------------------------------------------------------

d2d.register(
    function()
		draw_helpers.load_images("facility_tracker")
		draw_helpers.load_images("moon_tracker")
    end,
    function()
        if not main_updates.is_active_player() then return end
		-- print("starting draw!")
    
        draw_helpers.screen_w, draw_helpers.screen_h = d2d.surface_size()
        draw_helpers.screen_scale = draw_helpers.screen_h / 2160.0
		
		draw_helpers.facility_tracker()
		draw_helpers.mini_tracker()
		print("progress")
		draw_helpers.trades_ticker()
		
		if core.config.draw_tracker and not main_updates.hide_tracker then
			if core.config.mini_tracker then
				if not (core.config.draw_clock and main_updates.alt_tracker) then
					draw.mini_tracker()
				end
			else
				draw.facility_tracker()
			end
		end
		if core.config.draw_ticker and not main_updates.hide_ticker then
			draw.trades_ticker()
		end
		if core.config.draw_voucher and not main_updates.hide_voucher then
			draw.voucher_tracker()
		end
		if core.config.draw_clock and not main_updates.hide_clock then
			draw.system_clock()
		end
		if core.config.draw_moon and not main_updates.hide_moon then
			draw.moon_tracker()
		end
    end
)
