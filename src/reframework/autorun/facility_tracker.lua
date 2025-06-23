local core             = require("ui_extensions/core")
core.load_config()                -- Load the config file
local config_window    = require("ui_extensions/config_window")
local main_updates     = require("ui_extensions/main_updates")
main_updates.register_hooks()     -- Register main update hooks
local facility_helpers = require("ui_extensions/facility_helpers")
local facility_updates = require("ui_extensions/facility_updates")
facility_updates.register_hooks() -- Register facility update hooks
local draw_helpers     = require("ui_extensions/draw_helpers")

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

local ti_scroll_offset = 0
d2d.register(
    function()
        draw_helpers.color.background  = 0x882E2810   -- Semi-transparent dark tan
        draw_helpers.color.text        = 0xFFFFFFFF   -- White
        draw_helpers.color.timer_text  = 0xFFFCFFA6   -- Light Yellow
		draw_helpers.color.clock_text  = 0xFFF4DB8A   -- Yellow
        draw_helpers.color.red_text    = 0xFFFF0000   -- Red
        draw_helpers.color.prog_bar    = 0xFF00FF00   -- Green
        draw_helpers.color.full_bar    = 0xFFE6B00B   -- Orange-yellow
        draw_helpers.color.border      = 0xFFAD9D75   -- Tan
    
        draw_helpers.img.border_left    = d2d.Image.new("facility_tracker/border_left.png")
        draw_helpers.img.border_right   = d2d.Image.new("facility_tracker/border_right.png")
        draw_helpers.img.border_section = d2d.Image.new("facility_tracker/border_section.png")
        draw_helpers.img.ph_icon        = d2d.Image.new("facility_tracker/ph_icon.png")
        draw_helpers.img.error		    = d2d.Image.new("facility_tracker/error.png")
        draw_helpers.img.spacer 	    = d2d.Image.new("facility_tracker/spacer.png")
        draw_helpers.img.spacer_l 	    = d2d.Image.new("facility_tracker/spacer_l.png")
		draw_helpers.img.frame_s        = d2d.Image.new("facility_tracker/frame_s.png")
		draw_helpers.img.frame_l        = d2d.Image.new("facility_tracker/frame_l.png")
        draw_helpers.img.flag 		    = d2d.Image.new("facility_tracker/flag.png")
        draw_helpers.img.wilds 	        = d2d.Image.new("facility_tracker/wilds.png")
        draw_helpers.img.rations	    = d2d.Image.new("facility_tracker/rations.png")
        draw_helpers.img.ship   	    = d2d.Image.new("facility_tracker/ship.png")
        draw_helpers.img.pugee          = d2d.Image.new("facility_tracker/pugee.png")
        draw_helpers.img.nest		    = d2d.Image.new("facility_tracker/nest.png")
        draw_helpers.img.nata 		    = d2d.Image.new("facility_tracker/nata.png")
        draw_helpers.img.workshop       = d2d.Image.new("facility_tracker/workshop.png")
        draw_helpers.img.retrieval      = d2d.Image.new("facility_tracker/retrieval.png")
        draw_helpers.img.trader		    = d2d.Image.new("facility_tracker/trader.png")
        draw_helpers.img.kunafa         = d2d.Image.new("facility_tracker/kunafa_b.png")
		draw_helpers.img.kunafa_old     = d2d.Image.new("facility_tracker/kunafa.png")
        draw_helpers.img.wudwuds 	    = d2d.Image.new("facility_tracker/wudwuds_b.png")
		draw_helpers.img.wudwuds_old    = d2d.Image.new("facility_tracker/wudwuds.png")
        draw_helpers.img.azuz 	 	    = d2d.Image.new("facility_tracker/azuz_b.png")
		draw_helpers.img.azuz_old       = d2d.Image.new("facility_tracker/azuz.png")
        draw_helpers.img.suja 	 	    = d2d.Image.new("facility_tracker/suja_b.png")
		draw_helpers.img.suja_old       = d2d.Image.new("facility_tracker/suja.png")
        draw_helpers.img.sild 	 	    = d2d.Image.new("facility_tracker/sild_b.png")
		draw_helpers.img.sild_old       = d2d.Image.new("facility_tracker/sild.png")
		draw_helpers.img.m_ring         = d2d.Image.new("moon_tracker/ring.png")
		draw_helpers.img.moon_0         = d2d.Image.new("moon_tracker/moon_0.png")
		draw_helpers.img.moon_1         = d2d.Image.new("moon_tracker/moon_1.png")
		draw_helpers.img.moon_2         = d2d.Image.new("moon_tracker/moon_2.png")
		draw_helpers.img.moon_3         = d2d.Image.new("moon_tracker/moon_3.png")
		draw_helpers.img.moon_4         = d2d.Image.new("moon_tracker/moon_4.png")
		draw_helpers.img.moon_5         = d2d.Image.new("moon_tracker/moon_5.png")
		draw_helpers.img.moon_6         = d2d.Image.new("moon_tracker/moon_6.png")
		draw_helpers.img.m_num_0        = d2d.Image.new("moon_tracker/num_0.png")
		draw_helpers.img.m_num_1        = d2d.Image.new("moon_tracker/num_1.png")
		draw_helpers.img.m_num_2        = d2d.Image.new("moon_tracker/num_2.png")
		draw_helpers.img.m_num_3        = d2d.Image.new("moon_tracker/num_3.png")
		draw_helpers.img.m_num_4        = d2d.Image.new("moon_tracker/num_4.png")
		draw_helpers.img.m_num_5        = d2d.Image.new("moon_tracker/num_5.png")
		draw_helpers.img.m_num_6        = d2d.Image.new("moon_tracker/num_6.png")
    end,
    function()
        if not main_updates.is_active_player() then return end
		-- print("starting draw!")
    
        local screen_w, screen_h = d2d.surface_size()
        local screen_scale       = screen_h / 2160.0
		local tent_ui_scale      = 0.88
        local base_margin        = 4
        local base_border_h      = 40
        local base_end_border_w  = 34
		
        -------------------------------------------------------------------
        -- Factilities Tracker
        -------------------------------------------------------------------

        local tr_opacity    = core.config.tr_opacity * main_updates.fade_value
		local tr_user_scale = core.config.tr_user_scale
        local tr_eff_scale  = main_updates.alt_tracker and screen_scale * tr_user_scale * tent_ui_scale or screen_scale * tr_user_scale
        local tr_margin     = base_margin * tr_eff_scale
        local tr_bg_height  = 50 * tr_eff_scale
        local tr_bg_y       = main_updates.alt_tracker and 0 or screen_h - tr_bg_height
        local tr_bg_color   = draw_helpers.apply_opacity(draw_helpers.color.background, tr_opacity)
        local tr_icon_d     = tr_bg_height * 1.1
		local tracker_gap   = 18 * tr_eff_scale
		local tr_icon_y     = main_updates.alt_tracker and tr_bg_y + (tr_bg_height - tr_icon_d) / 2 or tr_bg_y + (tr_bg_height - tr_icon_d + tr_margin) / 2
        local tracker_font  = {
            name   = "Segoe UI",
            size   = math.floor(tr_bg_height - tr_margin * 2),
            bold   = false,
            italic = false
        }
		
		local v_icon = {
			sild    = core.config.old_icons and draw_helpers.img.sild_old or draw_helpers.img.sild,
			kunafa  = core.config.old_icons and draw_helpers.img.kunafa_old or draw_helpers.img.kunafa,
			suja    = core.config.old_icons and draw_helpers.img.suja_old or draw_helpers.img.suja,
			wudwuds = core.config.old_icons and draw_helpers.img.wudwuds_old or draw_helpers.img.wudwuds,
			azuz    = core.config.old_icons and draw_helpers.img.azuz_old or draw_helpers.img.azuz
		}
		
        local retrieval_elements = {
            { type = "icon",  value = v_icon.sild, width = tr_icon_d, flag = facility_helpers.is_box_full("Rysher"), alt_flag = main_updates.alt_tracker, frame = true },
            { type = "text",  value = facility_helpers.get_box_msg("Rysher") },
            { type = "icon",  value = v_icon.kunafa, width = tr_icon_d, flag = facility_helpers.is_box_full("Murtabak"), alt_flag = main_updates.alt_tracker, frame = true },
            { type = "text",  value = facility_helpers.get_box_msg("Murtabak") },
            { type = "icon",  value = v_icon.suja, width = tr_icon_d, flag = facility_helpers.is_box_full("Apar"), alt_flag = main_updates.alt_tracker, frame = true },
            { type = "text",  value = facility_helpers.get_box_msg("Apar") },
            { type = "icon",  value = v_icon.wudwuds, width = tr_icon_d, flag = facility_helpers.is_box_full("Plumpeach"), alt_flag = main_updates.alt_tracker, frame = true },
            { type = "text",  value = facility_helpers.get_box_msg("Plumpeach") },
            { type = "icon",  value = v_icon.azuz, width = tr_icon_d, flag = facility_helpers.is_box_full("Sabar"), alt_flag = main_updates.alt_tracker, frame = true },
            { type = "text",  value = facility_helpers.get_box_msg("Sabar") }
        }
        
        local tracker_elements = {
            { type = "icon",  value = draw_helpers.img.ship, width = tr_icon_d, flag = facility_updates.leaving, alt_flag = main_updates.alt_tracker },
			{ type = "text",  value = facility_helpers.get_ship_message() },
            { type = "icon",  value = draw_helpers.img.ship, width = tr_icon_d, flag = facility_updates.leaving, alt_flag = main_updates.alt_tracker },
            { type = "icon",  value = draw_helpers.img.spacer_l, width = tr_icon_d },
            { type = "icon",  value = draw_helpers.img.rations, width = tr_icon_d, flag = facility_helpers.is_box_full("Rations"), alt_flag = main_updates.alt_tracker },
			{ type = "bar",   value = facility_helpers.get_timer(facility_updates.tidx.ration), max = core.config.box_datas.Rations.timer, flag = facility_helpers.is_box_full("Rations") },
            { type = "timer", value = facility_helpers.get_timer_msg(facility_updates.tidx.ration) },
			{ type = "text",  value = facility_helpers.get_box_msg("Rations") },
            { type = "icon",  value = draw_helpers.img.rations, width = tr_icon_d, flag = facility_helpers.is_box_full("Rations"), alt_flag = main_updates.alt_tracker },
            { type = "icon",  value = draw_helpers.img.spacer_l, width = tr_icon_d },
            { type = "icon",  value = draw_helpers.img.retrieval, width = tr_icon_d, flag = facility_helpers.is_box_full("retrieval"), alt_flag = main_updates.alt_tracker },
            { type = "table", value = retrieval_elements },
            { type = "icon",  value = draw_helpers.img.retrieval, width = tr_icon_d, flag = facility_helpers.is_box_full("retrieval"), alt_flag = main_updates.alt_tracker },
            { type = "icon",  value = draw_helpers.img.spacer_l , width = tr_icon_d },
            { type = "icon",  value = draw_helpers.img.workshop, width = tr_icon_d, flag = facility_helpers.is_box_full("Shares"), alt_flag = main_updates.alt_tracker },
            { type = "text",  value = facility_helpers.get_box_msg("Shares") },
            { type = "icon",  value = draw_helpers.img.workshop, width = tr_icon_d, flag = facility_helpers.is_box_full("Shares"), alt_flag = main_updates.alt_tracker },
            { type = "icon",  value = draw_helpers.img.spacer_l, width = tr_icon_d },
            { type = "icon",  value = draw_helpers.img.nest, width = tr_icon_d, flag = facility_helpers.is_box_full("Nest"), alt_flag = main_updates.alt_tracker },
			{ type = "bar",   value = facility_helpers.get_timer(facility_updates.tidx.nest), max = core.config.box_datas.Nest.timer, flag = facility_helpers.is_box_full("Nest") },
            { type = "timer", value = facility_helpers.get_timer_msg(facility_updates.tidx.nest) },
            { type = "text",  value = facility_helpers.get_box_msg("Nest") },
            { type = "icon",  value = draw_helpers.img.nest, width = tr_icon_d, flag = facility_helpers.is_box_full("Nest"), alt_flag = main_updates.alt_tracker },
            { type = "icon",  value = draw_helpers.img.spacer_l, width = tr_icon_d },
            { type = "icon",  value = draw_helpers.img.pugee, width = tr_icon_d, flag = facility_helpers.is_box_full("pugee"), alt_flag = main_updates.alt_tracker },
			{ type = "bar",   value = facility_helpers.get_timer(facility_updates.tidx.pugee), max = core.config.box_datas.pugee.timer, flag = facility_helpers.is_box_full("pugee") },
            { type = "timer", value = facility_helpers.get_timer_msg(facility_updates.tidx.pugee) }
        }
        
        local totalTrackerWidth = draw_helpers.measureElements(tracker_font, tracker_elements, tracker_gap)
        local tracker_start_x = (screen_w - totalTrackerWidth) / 2
		
        local tr_ref_font = d2d.Font.new(tracker_font.name, tracker_font.size, tracker_font.bold, tracker_font.italic)
        local _, ref_char_height = tr_ref_font:measure("A")
        local tracker_txt_y = tr_bg_y + tr_bg_height - ref_char_height
        
        local tr_border_h      = base_border_h * tr_eff_scale
        local tr_end_border_w  = base_end_border_w * tr_eff_scale
        local tr_border_y      = main_updates.alt_tracker and tr_bg_y + tr_bg_height - (tr_border_h / 2) or tr_bg_y - (tr_border_h / 2)
        local tr_sect_border_x = tr_end_border_w - (tr_margin / 2)
        local tr_sect_border_w = screen_w - tr_end_border_w - tr_sect_border_x + tr_margin
        
        -------------------------------------------------------------------
        -- Ship/Trades Ticker
        -------------------------------------------------------------------

        local ti_opacity     = core.config.ti_opacity * main_updates.fade_value
		local ti_user_scale  = core.config.ti_user_scale
        local ti_eff_scale   = main_updates.alt_tracker and screen_scale * ti_user_scale * tent_ui_scale or screen_scale * ti_user_scale
        local ti_margin      = base_margin * ti_eff_scale
        local ti_bg_height   = 28 * ti_eff_scale
        local ti_icon_d      = ti_bg_height * 1.1
        local ti_speed_scale = core.config.ti_speed_scale * ti_eff_scale
        local ticker_speed   = 90 * ti_speed_scale
		local ti_bg_color    = draw_helpers.apply_opacity(draw_helpers.color.background, ti_opacity)
		local ticker_gap     = 10 * ti_eff_scale
		local ti_ex_gap      = ticker_gap
        local ti_bg_y        = main_updates.alt_tracker and screen_h - ti_bg_height or 0
		local ti_icon_y      = main_updates.alt_tracker and ti_bg_y + (ti_bg_height - ti_icon_d + ti_margin) / 2 or ti_bg_y + (ti_bg_height - ti_icon_d) / 2
        local ticker_font    = {
            name   = "Segoe UI",
            size   = math.floor(ti_bg_height - ti_margin * 2),
            bold   = false,
            italic = true
        }
        
        local ship_elements = {
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
			{ type = "text",  value = "This is a scrolling ticker message." },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "This will eventually display support ship items available once I find them." },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "This is placeholder text for ship items." },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d }
        }

        local trades_elements = {
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "The text just keeps on scrolling!" },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "Ideally, this will also list available trades, but those have been rather elusive." },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "Just placeholder text for now." },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d }
        }
        
        local ticker_elements = {
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "Here's a ticker." },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
			{ type = "table", value = ship_elements },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
            { type = "table", value = trades_elements },
            { type = "icon",  value = draw_helpers.img.ph_icon, width = ti_icon_d },
            { type = "text",  value = "And we loop around again." }
        }
        
        ti_scroll_offset = ti_scroll_offset + ticker_speed * main_updates.dt
        local totalTickerWidth = draw_helpers.measureElements(ticker_font, ticker_elements, ticker_gap) + ti_ex_gap
        if ti_scroll_offset > (screen_w + totalTickerWidth) then
            ti_scroll_offset = screen_w
        end
        local ticker_start_x = screen_w - ti_scroll_offset
        local current_x = ticker_start_x
        local ti_ref_font = d2d.Font.new(ticker_font.name, ticker_font.size, ticker_font.bold, ticker_font.italic)
        local ref_char_w, ref_char_h = ti_ref_font:measure("A")
        local ticker_txt_y = ti_bg_y + ti_bg_height - ref_char_h - ti_margin
        
        local ti_border_h      = base_border_h * 0.56 * ti_eff_scale
        local ti_end_border_w  = base_end_border_w * 0.56 * ti_eff_scale
        local ti_border_y      = main_updates.alt_tracker and ti_bg_y - (ti_border_h / 2) or ti_bg_y + ti_bg_height - (ti_border_h / 2)
        local ti_sect_border_x = ti_end_border_w - (ti_margin / 2)
        local ti_sect_border_w = screen_w - ti_end_border_w - ti_sect_border_x + ti_margin

		-------------------------------------------------------------------
		-- Voucher Tracker
		-------------------------------------------------------------------
		
		

		-------------------------------------------------------------------
		-- System Clock
		-------------------------------------------------------------------
		
		local ck_opacity       = core.config.ck_opacity * main_updates.fade_value_c
		local clock_text       = core.config.non_meridian_c and os.date("%H:%M") or os.date("%I:%M")
		local ck_margin        = main_updates.alt_tracker and tr_margin or ti_margin
		local clock_font_size  = main_updates.alt_tracker and tracker_font.size or ticker_font.size
		local clock_font       = d2d.Font.new("Segoe UI", clock_font_size, true, false)
		local clock_txt_w      = clock_font:measure(clock_text)
		local clock_txt_x      = screen_w - clock_txt_w - ck_margin
		local clock_txt_y      = main_updates.alt_tracker and tracker_txt_y or ticker_txt_y
		local ck_text_color    = draw_helpers.apply_opacity(draw_helpers.color.clock_text, ck_opacity)
		local ck_bg_w          = clock_txt_w * 1.5
		local ck_bg_h          = main_updates.alt_tracker and tr_bg_height or ti_bg_height
		local ck_bg_x          = screen_w - ck_bg_w + ck_margin * 0.5
		local ck_bg_color      = draw_helpers.apply_opacity(draw_helpers.color.background, ck_opacity)
		local ck_end_border_w  = main_updates.alt_tracker and tr_end_border_w or ti_end_border_w
		local ck_border_y      = main_updates.alt_tracker and tr_border_y or ti_border_y
		local ck_border_h      = main_updates.alt_tracker and tr_border_h or ti_border_h
		local ck_border_neg    = ck_end_border_w - ck_margin * 0.283
		
		-------------------------------------------------------------------
		-- Moon Tracker
		-------------------------------------------------------------------
		
		local midx   = main_updates.get_midx()
		local moon   = draw_helpers.img["moon_" .. tostring(midx)]
		local m_num  = draw_helpers.img["m_num_" .. tostring(midx)]
		local moon_x = (main_updates.moon_pos == "map" and 16 or main_updates.moon_pos == "rest" and 4 or 4) * screen_scale
		local moon_y = (main_updates.moon_pos == "map" and 202 or main_updates.moon_pos == "rest" and 1722 or 1922) * screen_scale
		local moon_w = 140 * screen_scale
		local moon_h = 140 * screen_scale
		local moon_a = (main_updates.moon_pos == "map" and 0.9 or 1) * main_updates.fade_value_m

        -------------------------------------------------------------------
        -- DRAWS
        -------------------------------------------------------------------
			
		if core.config.draw_tracker and not (core.config.auto_hide and main_updates.hide_tracker) then
			-- Draw the tracker
			d2d.fill_rect(0, tr_bg_y, screen_w, tr_bg_height, tr_bg_color)
			d2d.image(draw_helpers.img.border_left, 0, tr_border_y, tr_end_border_w, tr_border_h, tr_opacity)
			d2d.image(draw_helpers.img.border_right, screen_w - tr_end_border_w, tr_border_y, tr_end_border_w, tr_border_h, tr_opacity)
			if tr_sect_border_w > 0 then
				d2d.image(draw_helpers.img.border_section, tr_sect_border_x, tr_border_y, tr_sect_border_w, tr_border_h, tr_opacity)
			end
			draw_helpers.drawElements(tracker_font, tracker_elements, tracker_start_x, tracker_txt_y, tr_icon_d, tr_icon_y, tracker_gap, tr_margin, tr_opacity)
		end
		
		if core.config.draw_ticker and not (core.config.auto_hide_t and main_updates.hide_tracker) then
			-- Draw the ticker
			d2d.fill_rect(0, ti_bg_y, screen_w, ti_bg_height, ti_bg_color)
			d2d.image(draw_helpers.img.border_left, 0, ti_border_y, ti_end_border_w, ti_border_h, ti_opacity)
			d2d.image(draw_helpers.img.border_right, screen_w - ti_end_border_w, ti_border_y, ti_end_border_w, ti_border_h, ti_opacity)
			if ti_sect_border_w > 0 then
				d2d.image(draw_helpers.img.border_section, ti_sect_border_x, ti_border_y, ti_sect_border_w, ti_border_h, ti_opacity)
			end
			while current_x < screen_w do
				draw_helpers.drawElements(ticker_font, ticker_elements, current_x, ticker_txt_y, ti_icon_d, ti_icon_y, ticker_gap, ti_margin, ti_opacity)
				current_x = current_x + totalTickerWidth
			end
		end
		
		if core.config.draw_voucher and not (core.config.auto_hide_v and main_updates.hide_tracker) then
			-- Draw vouchers
		end
		
		if core.config.draw_clock and not (core.config.auto_hide_c and main_updates.hide_tracker) then
			-- Draw the clock
			draw_helpers.drawRectAlphaGradient("left", 0.5, 0, ck_bg_color, ck_bg_x, 0, ck_bg_w, ck_bg_h)
			d2d.image(draw_helpers.img.border_right, screen_w - ck_end_border_w, ck_border_y, ck_end_border_w, ck_border_h, ck_opacity * 0.82)
			if ck_end_border_w < ck_bg_w then
				draw_helpers.drawRectAlphaGradient("left", 0.5, ck_border_neg, draw_helpers.img.border_section, ck_bg_x, ck_border_y, ck_bg_w, ck_border_h, ck_opacity)
			end
			d2d.text(clock_font, clock_text, clock_txt_x, clock_txt_y, ck_text_color)
		end
		
		if core.config.draw_moon and not (core.config.auto_hide_m and main_updates.hide_moon) then
			-- Draw the moon
			d2d.image(draw_helpers.img.m_ring, moon_x, moon_y, moon_w, moon_h, moon_a)
			if not (main_updates.ghub_moon and core.config.ghub_moon == "Nothing") then
				d2d.image(moon, moon_x, moon_y, moon_w, moon_h, moon_a)
				if core.config.draw_m_num then
					d2d.image(m_num, moon_x, moon_y, moon_w, moon_h, moon_a)
				end
			end
		end
    end
)
