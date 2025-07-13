local core             = require("hud_extensions/core")
local main_updates     = require("hud_extensions/main_updates")
local facility_updates = require("hud_extensions/facility_updates")
local voucher_updates  = require("hud_extensions/voucher_updates")
local moon_updates     = require("hud_extensions/moon_updates")
local bridge           = require("hud_extensions/bridge")
local config_helpers   = require("hud_extensions/config_helpers")
local config_window    = require("hud_extensions/config_window")
local draw_helpers     = require("hud_extensions/draw_helpers")
local draw             = require("hud_extensions/draw")

-----------------------------------------------------------
-- ON-FRAME UPDATES
-----------------------------------------------------------

re.on_frame(
    function()
		-- print("starting on-frame updates!")
		
		local re_ui_open = reframework:is_drawing_ui()
		if config_window.open and re_ui_open then config_window.draw_config() end
		
		config_helpers.hotkey_toggle()
		
		main_updates.time_delta()
		
		if not main_updates.is_active_player() then
			core.first_run = true
			main_updates.previous_hidden = true
			main_updates.previous_fading = true
			return
        end
		
		-- print("starting active-player updates!")
		
		main_updates.get_fade()
		main_updates.get_hidden()
		
		moon_updates.get_midx()
		facility_updates.get_pugee_state()
		
		core.first_run = false
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
			shadow      = 0xFF000000,   -- Black
			text        = 0xFFFFFFFF,   -- White
			timer_text  = 0xFFFDFFA8,   -- Light Yellow
			clock_text  = 0xFFF4DB8A,   -- Yellow
			count_text  = 0xFFFCFFA0,   -- Light Yellow
			full_text   = 0xFFFACC41,   -- Dark Yellow
			red_text    = 0xFFFF0000,   -- Red
			prog_bar    = 0xFF00FF00,   -- Green
			full_bar    = 0xFFE6B00B,   -- Orange-yellow
			border      = 0xFFAD9D75    -- Tan
		}
		
		-- draw_helpers.load_images("common")
		-- draw_helpers.load_images("facility")
		-- draw_helpers.load_images("ticker")
		-- draw_helpers.load_images("voucher")
		-- draw_helpers.load_images("moon")

		draw_helpers.img = {
			border_left    = d2d.Image.new("hud_extensions/common/border_left.png"),
			border_right   = d2d.Image.new("hud_extensions/common/border_right.png"),
			border_section = d2d.Image.new("hud_extensions/common/border_section.png"),
			error          = d2d.Image.new("hud_extensions/common/error.png"),
			flag           = d2d.Image.new("hud_extensions/common/flag.png"),
			frame          = d2d.Image.new("hud_extensions/common/frame.png"),
			frame_v        = d2d.Image.new("hud_extensions/common/frame_v.png"),
			nata           = d2d.Image.new("hud_extensions/common/nata.png"),
			ph_icon        = d2d.Image.new("hud_extensions/common/ph_icon.png"),
			spacer         = d2d.Image.new("hud_extensions/common/spacer.png"),
			wilds          = d2d.Image.new("hud_extensions/common/wilds.png"),
			azuz           = d2d.Image.new("hud_extensions/facility/azuz.png"),
			azuz_b         = d2d.Image.new("hud_extensions/facility/azuz_b.png"),
			kunafa         = d2d.Image.new("hud_extensions/facility/kunafa.png"),
			kunafa_b       = d2d.Image.new("hud_extensions/facility/kunafa_b.png"),
			nest           = d2d.Image.new("hud_extensions/facility/nest.png"),
			pugee          = d2d.Image.new("hud_extensions/facility/pugee.png"),
			rations        = d2d.Image.new("hud_extensions/facility/rations.png"),
			retrieval      = d2d.Image.new("hud_extensions/facility/retrieval.png"),
			ship           = d2d.Image.new("hud_extensions/facility/ship.png"),
			sild           = d2d.Image.new("hud_extensions/facility/sild.png"),
			sild_b         = d2d.Image.new("hud_extensions/facility/sild_b.png"),
			suja           = d2d.Image.new("hud_extensions/facility/suja.png"),
			suja_b         = d2d.Image.new("hud_extensions/facility/suja_b.png"),
			workshop       = d2d.Image.new("hud_extensions/facility/workshop.png"),
			wudwuds        = d2d.Image.new("hud_extensions/facility/wudwuds.png"),
			wudwuds_b      = d2d.Image.new("hud_extensions/facility/wudwuds_b.png"),
			m_num_0        = d2d.Image.new("hud_extensions/moon/m_num_0.png"),
			m_num_1        = d2d.Image.new("hud_extensions/moon/m_num_1.png"),
			m_num_2        = d2d.Image.new("hud_extensions/moon/m_num_2.png"),
			m_num_3        = d2d.Image.new("hud_extensions/moon/m_num_3.png"),
			m_num_4        = d2d.Image.new("hud_extensions/moon/m_num_4.png"),
			m_num_5        = d2d.Image.new("hud_extensions/moon/m_num_5.png"),
			m_num_6        = d2d.Image.new("hud_extensions/moon/m_num_6.png"),
			m_ring         = d2d.Image.new("hud_extensions/moon/m_ring.png"),
			moon_0         = d2d.Image.new("hud_extensions/moon/moon_0.png"),
			moon_1         = d2d.Image.new("hud_extensions/moon/moon_1.png"),
			moon_2         = d2d.Image.new("hud_extensions/moon/moon_2.png"),
			moon_3         = d2d.Image.new("hud_extensions/moon/moon_3.png"),
			moon_4         = d2d.Image.new("hud_extensions/moon/moon_4.png"),
			moon_5         = d2d.Image.new("hud_extensions/moon/moon_5.png"),
			moon_6         = d2d.Image.new("hud_extensions/moon/moon_6.png"),
			trader         = d2d.Image.new("hud_extensions/ticker/trader.png"),
			delivery       = d2d.Image.new("hud_extensions/voucher/delivery.png"),
			voucher        = d2d.Image.new("hud_extensions/voucher/voucher.png"),
			voucher_v      = d2d.Image.new("hud_extensions/voucher/voucher_v.png"),
		}
    end,
    function()
		if not main_updates.is_active_player() then return end
		
		-- print("starting draw!")
		
		draw_helpers.screen_w, draw_helpers.screen_h = d2d.surface_size()
        draw_helpers.screen_scale = draw_helpers.screen_h / 2160.0
		
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
		if core.config.draw_clock and not main_updates.hide_clock then
			draw.system_clock()
		end
		if core.config.draw_moon and not (main_updates.hide_moon or moon_updates.midx == nil) then
			draw.moon_tracker()
		end
    end
)
