local core             = require("hud_extensions/core")
local config_window    = require("hud_extensions/config_window")
local main_updates     = require("hud_extensions/main_updates")
local facility_helpers = require("hud_extensions/facility_helpers")
local facility_updates = require("hud_extensions/facility_updates")
local draw_helpers     = require("hud_extensions/draw_helpers")
local draw             = require("hud_extensions/draw")

core.load_config()                -- Load the config file
main_updates.register_hooks()     -- Register main update hooks
facility_updates.register_hooks() -- Register facility update hooks

-----------------------------------------------------------
-- ON-FRAME UPDATE
-----------------------------------------------------------

re.on_frame(
    function()
		-- print("starting on-frame updates!")
		
		local re_ui_open = reframework:is_drawing_ui()
		if config_window.open and re_ui_open then config_window.draw_config() end
		
		core.hotkey_toggle()
		
		main_updates.time_delta()
		
		main_updates.get_midx()
		main_updates.get_fade()
		main_updates.get_hidden()
		
        if main_updates.is_active_player() then
			-- print("starting active-player updates!")
			facility_updates.get_ration_state()
			facility_updates.get_ship_state()
			facility_updates.get_shares_state()
			facility_updates.get_retrieval_state()
			facility_updates.get_nest_state()
			facility_updates.get_pugee_state()
			
			facility_updates.first_run = false
		else
            facility_updates.first_run = true
			main_updates.previous_hidden = true
			main_updates.previous_fading = true
            core.save_config()
        end
    end
)

----------------------------------------------------------------
-- CONFIG MENU
----------------------------------------------------------------

re.on_draw_ui(
	function()
		if imgui.button("Facility Tracker and HUD Extensions") then
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
		draw_helpers.color = {
			background  = 0x882E2810,   -- Semi-transparent dark tan
			text        = 0xFFFFFFFF,   -- White
			timer_text  = 0xFFFCFFA6,   -- Light Yellow
			clock_text  = 0xFFF4DB8A,   -- Yellow
			count_text  = 0xFFFCFFA6,   -- Light Yellow
			full_text   = 0xFFFACC41,   -- Dark Yellow
			red_text    = 0xFFFF0000,   -- Red
			prog_bar    = 0xFF00FF00,   -- Green
			full_bar    = 0xFFE6B00B,   -- Orange-yellow
			border      = 0xFFAD9D75    -- Tan
		}
		
		-- draw_helpers.load_images("facility_tracker")
		-- draw_helpers.load_images("moon_tracker")

		draw_helpers.img = {
			border_left    = d2d.Image.new("facility_tracker/border_left.png"),
			border_right   = d2d.Image.new("facility_tracker/border_right.png"),
			border_section = d2d.Image.new("facility_tracker/border_section.png"),
			ph_icon        = d2d.Image.new("facility_tracker/ph_icon.png"),
			error		  = d2d.Image.new("facility_tracker/error.png"),
			spacer 	      = d2d.Image.new("facility_tracker/spacer.png"),
			spacer_l 	  = d2d.Image.new("facility_tracker/spacer_l.png"),
			frame_s        = d2d.Image.new("facility_tracker/frame_s.png"),
			frame_l        = d2d.Image.new("facility_tracker/frame_l.png"),
			flag 		  = d2d.Image.new("facility_tracker/flag.png"),
			wilds 	      = d2d.Image.new("facility_tracker/wilds.png"),
			rations	      = d2d.Image.new("facility_tracker/rations.png"),
			ship   	      = d2d.Image.new("facility_tracker/ship.png"),
			pugee          = d2d.Image.new("facility_tracker/pugee.png"),
			nest		      = d2d.Image.new("facility_tracker/nest.png"),
			nata 	      = d2d.Image.new("facility_tracker/nata.png"),
			workshop       = d2d.Image.new("facility_tracker/workshop.png"),
			retrieval      = d2d.Image.new("facility_tracker/retrieval.png"),
			trader		  = d2d.Image.new("facility_tracker/trader.png"),
			kunafa_b       = d2d.Image.new("facility_tracker/kunafa_b.png"),
			kunafa         = d2d.Image.new("facility_tracker/kunafa.png"),
			wudwuds_b 	  = d2d.Image.new("facility_tracker/wudwuds_b.png"),
			wudwuds        = d2d.Image.new("facility_tracker/wudwuds.png"),
			azuz_b 	 	  = d2d.Image.new("facility_tracker/azuz_b.png"),
			azuz           = d2d.Image.new("facility_tracker/azuz.png"),
			suja_b 	 	  = d2d.Image.new("facility_tracker/suja_b.png"),
			suja           = d2d.Image.new("facility_tracker/suja.png"),
			sild_b 	 	  = d2d.Image.new("facility_tracker/sild_b.png"),
			sild           = d2d.Image.new("facility_tracker/sild.png"),
			m_ring         = d2d.Image.new("moon_tracker/m_ring.png"),
			moon_0         = d2d.Image.new("moon_tracker/moon_0.png"),
			moon_1         = d2d.Image.new("moon_tracker/moon_1.png"),
			moon_2         = d2d.Image.new("moon_tracker/moon_2.png"),
			moon_3         = d2d.Image.new("moon_tracker/moon_3.png"),
			moon_4         = d2d.Image.new("moon_tracker/moon_4.png"),
			moon_5         = d2d.Image.new("moon_tracker/moon_5.png"),
			moon_6         = d2d.Image.new("moon_tracker/moon_6.png"),
			m_num_0        = d2d.Image.new("moon_tracker/m_num_0.png"),
			m_num_1        = d2d.Image.new("moon_tracker/m_num_1.png"),
			m_num_2        = d2d.Image.new("moon_tracker/m_num_2.png"),
			m_num_3        = d2d.Image.new("moon_tracker/m_num_3.png"),
			m_num_4        = d2d.Image.new("moon_tracker/m_num_4.png"),
			m_num_5        = d2d.Image.new("moon_tracker/m_num_5.png"),
			m_num_6        = d2d.Image.new("moon_tracker/m_num_6.png")
		}
    end,
    function()
		-- print("starting draw!")
		
		draw_helpers.screen_w, draw_helpers.screen_h = d2d.surface_size()
        draw_helpers.screen_scale = draw_helpers.screen_h / 2160.0
		
		if core.config.draw_clock and not main_updates.hide_clock then
			draw.system_clock()
		end
		if core.config.draw_moon and not (main_updates.hide_moon or main_updates == nil) then
			draw.moon_tracker()
		end
		
		if main_updates.is_active_player() then
			draw_helpers.facility_tracker()
			draw_helpers.mini_tracker()
			draw_helpers.trades_ticker()
			
			if core.config.draw_tracker and not main_updates.hide_tracker then
				if core.config.mini_tracker and not main_updates.mini_override then
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
		end
    end
)
