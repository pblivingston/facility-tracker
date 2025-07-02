local core             = require("hud_extensions/core")
local main_updates     = require("hud_extensions/main_updates")
local facility_helpers = require("hud_extensions/facility_helpers")
local facility_updates = require("hud_extensions/facility_updates")
local draw_helpers     = require("hud_extensions/draw_helpers")

local draw = {}

function draw.facility_tracker()
	local config = core.config
	local tidx = facility_updates.tidx
	local img = draw_helpers.img
	local tr = draw_helpers.tr
	
	local v_icon = {
		sild    = config.old_icons and img.sild or img.sild_b,
		kunafa  = config.old_icons and img.kunafa or img.kunafa_b,
		suja    = config.old_icons and img.suja or img.suja_b,
		wudwuds = config.old_icons and img.wudwuds or img.wudwuds_b,
		azuz    = config.old_icons and img.azuz or img.azuz_b
	}
	
	local retrieval_elements = {
		{ type = "icon",  value = v_icon.sild, width = tr.icon_d, flag = config.box_datas.Rysher.full, frame = true },
		{ type = "text",  value = facility_helpers.get_box_msg("Rysher") },
		{ type = "icon",  value = v_icon.kunafa, width = tr.icon_d, flag = config.box_datas.Murtabak.full, frame = true },
		{ type = "text",  value = facility_helpers.get_box_msg("Murtabak") },
		{ type = "icon",  value = v_icon.suja, width = tr.icon_d, flag = config.box_datas.Apar.full, frame = true },
		{ type = "text",  value = facility_helpers.get_box_msg("Apar") },
		{ type = "icon",  value = v_icon.wudwuds, width = tr.icon_d, flag = config.box_datas.Plumpeach.full, frame = true },
		{ type = "text",  value = facility_helpers.get_box_msg("Plumpeach") },
		{ type = "icon",  value = v_icon.azuz, width = tr.icon_d, flag = config.box_datas.Sabar.full, frame = true },
		{ type = "text",  value = facility_helpers.get_box_msg("Sabar") }
	}
	
	local tracker_elements = {
		{ type = "icon",  value = img.ship, width = tr.icon_d, flag = facility_updates.leaving },
		{ type = "text",  value = facility_helpers.get_ship_message() },
		{ type = "icon",  value = img.ship, width = tr.icon_d, flag = facility_updates.leaving },
		{ type = "icon",  value = img.spacer_l, width = tr.icon_d },
		{ type = "icon",  value = img.rations, width = tr.icon_d, timer = tidx.ration, cap = config.box_datas.Rations.timer, flag = config.box_datas.Rations.full },
		{ type = "text",  value = facility_helpers.get_box_msg("Rations") },
		{ type = "icon",  value = img.rations, width = tr.icon_d, flag = config.box_datas.Rations.full },
		{ type = "icon",  value = img.spacer_l, width = tr.icon_d },
		{ type = "icon",  value = img.retrieval, width = tr.icon_d, flag = config.box_datas.retrieval.full },
		{ type = "table", value = retrieval_elements },
		{ type = "icon",  value = img.retrieval, width = tr.icon_d, flag = config.box_datas.retrieval.full },
		{ type = "icon",  value = img.spacer_l, width = tr.icon_d },
		{ type = "icon",  value = img.workshop, width = tr.icon_d, flag = config.box_datas.Shares.full },
		{ type = "text",  value = facility_helpers.get_box_msg("Shares") },
		{ type = "icon",  value = img.workshop, width = tr.icon_d, flag = config.box_datas.Shares.full },
		{ type = "icon",  value = img.spacer_l, width = tr.icon_d },
		{ type = "icon",  value = img.nest, width = tr.icon_d, timer = tidx.nest, cap = config.box_datas.Nest.timer, flag = config.box_datas.Nest.full },
		{ type = "text",  value = facility_helpers.get_box_msg("Nest") },
		{ type = "icon",  value = img.nest, width = tr.icon_d, flag = config.box_datas.Nest.full },
		{ type = "icon",  value = img.spacer_l, width = tr.icon_d },
		{ type = "icon",  value = img.pugee, width = tr.icon_d, timer = tidx.pugee, cap = config.box_datas.pugee.timer, flag = config.box_datas.pugee.full }
	}
	
	tr.totalWidth = draw_helpers.measureElements(tracker_elements, tr)
	tr.start_x    = (draw_helpers.screen_w - tr.totalWidth) / 2
	
	-- Draw the tracker
	d2d.fill_rect(0, tr.bg_y, draw_helpers.screen_w, tr.bg_h, tr.bg_color)
	d2d.image(img.border_left, 0, tr.border_y, tr.end_border_w, tr.border_h, tr.opacity)
	d2d.image(img.border_right, tr.end_border_x, tr.border_y, tr.end_border_w, tr.border_h, tr.opacity)
	if tr.sect_border_w > 0 then
		d2d.image(img.border_section, tr.sect_border_x, tr.border_y, tr.sect_border_w, tr.border_h, tr.opacity)
	end
	draw_helpers.drawElements(tracker_elements, tr, false)
end

function draw.mini_tracker()
	local config = core.config
	local tidx = facility_updates.tidx
	local color = draw_helpers.color
	local img = draw_helpers.img
	local tr = draw_helpers.tr
	local mi = draw_helpers.mi
	
	local direction    = config.mini_right and "left" or "right"
	local bg_w         = mi.totalWidth * 1.75
	local bg_x         = config.mini_right and draw_helpers.screen_w - bg_w + mi.margin * 0.5 or 0
	local border_end   = config.mini_right and img.border_right or img.border_left
	local end_border_x = config.mini_right and tr.end_border_x or 0
	local border_neg   = tr.end_border_w - mi.margin * 0.283
	
	if tr.end_border_w < bg_w * 0.5 then
		-- Draw the mini tracker
		draw_helpers.drawRectAlphaGradient(direction, 0.5, 0, color.background, bg_x, tr.bg_y, bg_w, tr.bg_h, mi.opacity) -- background
		d2d.image(border_end, end_border_x, tr.border_y, tr.end_border_w, tr.border_h, mi.opacity) -- border end
		draw_helpers.drawRectAlphaGradient(direction, 0.5, border_neg, img.border_section, bg_x, tr.border_y, bg_w, tr.border_h, mi.opacity) -- border section
		draw_helpers.drawElements(mi.elements, mi)
	end
end

function draw.trades_ticker()
	local config = core.config
	local img = draw_helpers.img
	local ti = draw_helpers.ti
	
	local ship_elements = {
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d },
		{ type = "text",  value = "This is a scrolling ticker message." },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d },
		{ type = "text",  value = "This will eventually display support ship items available once I find them." },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d },
		{ type = "text",  value = "This is placeholder text for ship items." },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d }
	}

	local trades_elements = {
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d },
		{ type = "text",  value = "The text just keeps on scrolling!" },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d },
		{ type = "text",  value = "Ideally, this will also list available trades, but those have been rather elusive." },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d },
		{ type = "text",  value = "Just placeholder text for now." },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d }
	}
	
	local ticker_elements = {
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d },
		{ type = "text",  value = "Here's a ticker." },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d, draw = config.draw_ship },
		{ type = "table", value = ship_elements, draw = config.draw_ship },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d, draw = config.draw_trades },
		{ type = "table", value = trades_elements, draw = config.draw_trades },
		{ type = "icon",  value = img.ph_icon, width = ti.icon_d },
		{ type = "text",  value = "And we loop around again." }
	}
	
	ti.totalWidth = draw_helpers.measureElements(ticker_elements, ti) + ti.ex_gap
	if ti.scroll_offset > (draw_helpers.screen_w + ti.totalWidth) then
		ti.scroll_offset = draw_helpers.screen_w
	end
	ti.scroll_x = draw_helpers.screen_w - ti.scroll_offset
	ti.start_x = ti.scroll_x
		
	-- Draw the ticker
	d2d.fill_rect(0, ti.bg_y, draw_helpers.screen_w, ti.bg_h, ti.bg_color)
	d2d.image(img.border_left, 0, ti.border_y, ti.end_border_w, ti.border_h, ti.opacity)
	d2d.image(img.border_right, ti.end_border_x, ti.border_y, ti.end_border_w, ti.border_h, ti.opacity)
	if ti.sect_border_w > 0 then
		d2d.image(img.border_section, ti.sect_border_x, ti.border_y, ti.sect_border_w, ti.border_h, ti.opacity)
	end
	while ti.start_x < draw_helpers.screen_w do
		draw_helpers.drawElements(ticker_elements, ti)
		ti.start_x = ti.start_x + ti.totalWidth
	end
end

function draw.voucher_tracker()
	-- Draw vouchers
end

function draw.system_clock()
	local config = core.config
	local color = draw_helpers.color
	local img = draw_helpers.img
	local tr = draw_helpers.tr
	local mi = draw_helpers.mi
	local ti = draw_helpers.ti
	
	local mini_on_clock = main_updates.alt_tracker and config.draw_tracker and config.mini_tracker and not config.mi_tent_map

	local text          = config.non_meridian_c and os.date("%H:%M") or os.date("%I:%M")
	local margin        = main_updates.alt_tracker and tr.margin or ti.margin
	local font_size     = main_updates.alt_tracker and tr.font.size or ti.font.size
	local font          = d2d.Font.new("Segoe UI", font_size, true, false)
	local txt_w         = font:measure(text)
	local txt_y         = main_updates.alt_tracker and tr.txt_y or ti.txt_y
	local mini_ck_w     = txt_w + mi.totalWidth + mi.gap
	local bg_w          = mini_on_clock and mini_ck_w * 1.5 or txt_w * 1.5
	local bg_h          = main_updates.alt_tracker and tr.bg_h or ti.bg_h
	local bg_x          = draw_helpers.screen_w - bg_w + margin * 0.6
	local end_border_w  = main_updates.alt_tracker and tr.end_border_w or ti.end_border_w
	local end_border_x  = main_updates.alt_tracker and tr.end_border_x or ti.end_border_x
	local border_y      = main_updates.alt_tracker and tr.border_y or ti.border_y
	local border_h      = main_updates.alt_tracker and tr.border_h or ti.border_h
	local border_neg    = mini_on_clock and end_border_w - margin * 0.557 or end_border_w - margin * 0.297
	local end_border_a  = mini_on_clock and 0.9 or 0.82
	
	mi.ck_opacity = config.ck_opacity * main_updates.fade_value_c
	mi.ck_x       = draw_helpers.screen_w - txt_w - margin
	
	local border_opacity = (main_updates.alt_tracker and config.draw_tracker and not config.mini_tracker) and mi.ck_opacity * 1 or mi.ck_opacity
	
	-- Draw the clock
	draw_helpers.drawRectAlphaGradient("left", 0.5, 0, color.background, bg_x, 0, bg_w, bg_h, mi.ck_opacity)
	d2d.image(img.border_right, end_border_x, border_y, end_border_w, border_h, mi.ck_opacity * end_border_a)
	draw_helpers.drawRectAlphaGradient("left", 0.5, border_neg, img.border_section, bg_x, border_y, bg_w, border_h, mi.ck_opacity)
	d2d.text(font, text, mi.ck_x, txt_y, draw_helpers.apply_opacity(color.clock_text, mi.ck_opacity))
	if mini_on_clock then
		draw_helpers.drawElements(mi.elements, mi)
	end
end

function draw.moon_tracker()
	if main_updates.midx == nil then print("midx is nil!"); return end
	local config = core.config
	local img = draw_helpers.img
	local moon   = img["moon_" .. tostring(main_updates.midx)]
	local m_num  = img["m_num_" .. tostring(main_updates.midx)]
	local moon_x = (main_updates.moon_pos == "map" and 16 or main_updates.moon_pos == "rest" and 4 or 4) * draw_helpers.screen_scale
	local moon_y = (main_updates.moon_pos == "map" and 202 or main_updates.moon_pos == "rest" and 1722 or 1922) * draw_helpers.screen_scale
	local moon_w = 140 * draw_helpers.screen_scale
	local moon_h = 140 * draw_helpers.screen_scale
	local moon_a = (main_updates.moon_pos == "map" and 0.9 or 1) * main_updates.fade_value_m
	
	-- Draw the moon
	d2d.image(img.m_ring, moon_x, moon_y, moon_w, moon_h, moon_a)
	if not (main_updates.in_grand_hub and config.ghub_moon == "Nothing") and main_updates.midx >= 0 then
		d2d.image(moon, moon_x, moon_y, moon_w, moon_h, moon_a)
		if config.draw_m_num then
			d2d.image(m_num, moon_x, moon_y, moon_w, moon_h, moon_a)
		end
	end
end

return draw