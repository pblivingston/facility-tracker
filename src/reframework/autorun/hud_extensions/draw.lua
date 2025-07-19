local core             = require("hud_extensions/core")
local facility_helpers = require("hud_extensions/facility_helpers")
local facility_updates = require("hud_extensions/facility_updates")
local moon_updates     = require("hud_extensions/moon_updates")
local main_updates     = require("hud_extensions/main_updates")
local draw_helpers     = require("hud_extensions/draw_helpers")

local draw = {}

function draw.facility_tracker()
	local config = core.config
	local savedata = core.savedata
	local tidx = core.tidx
	local img = draw_helpers.img
	local tr = draw_helpers.tr
	
	local retrieval_elements = {
		{ type = "icon",  value = config.old_icons and img.sild or img.sild_b,
			flag = config.draw_flags and savedata.retrieval.Rysher.full,
			frame = img.frame },
		{ type = "text",  value = facility_helpers.get_box_msg("Rysher", "retrieval") },
		{ type = "icon",  value = config.old_icons and img.kunafa or img.kunafa_b,
			flag = config.draw_flags and savedata.retrieval.Murtabak.full,
			frame = img.frame },
		{ type = "text",  value = facility_helpers.get_box_msg("Murtabak", "retrieval") },
		{ type = "icon",  value = config.old_icons and img.suja or img.suja_b,
			flag = config.draw_flags and savedata.retrieval.Apar.full,
			frame = img.frame },
		{ type = "text",  value = facility_helpers.get_box_msg("Apar", "retrieval") },
		{ type = "icon",  value = config.old_icons and img.wudwuds or img.wudwuds_b,
			flag = config.draw_flags and savedata.retrieval.Plumpeach.full,
			frame = img.frame },
		{ type = "text",  value = facility_helpers.get_box_msg("Plumpeach", "retrieval") },
		{ type = "icon",  value = config.old_icons and img.azuz or img.azuz_b,
			flag = config.draw_flags and savedata.retrieval.Sabar.full,
			frame = img.frame },
		{ type = "text",  value = facility_helpers.get_box_msg("Sabar", "retrieval") },
	}
	
	local tracker_elements = {
		{ type = "icon",  value = img.ship,
			flag = config.draw_flags and savedata.ship.leaving },
		{ type = "text",  value = facility_helpers.get_ship_message() },
		{ type = "icon",  value = img.ship,
			flag = config.draw_flags and savedata.ship.leaving },
		{ type = "icon",  value = img.spacer },
		{ type = "icon",  value = img.rations,
			timer = tidx.ration,
			draw_timer = config.draw_timers,
			bar = config.draw_bars and savedata.Rations.timer,
			flag = config.draw_flags and savedata.Rations.full },
		{ type = "text",  value = facility_helpers.get_box_msg("Rations") },
		{ type = "icon",  value = img.rations,
			flag = config.draw_flags and savedata.Rations.full },
		{ type = "icon",  value = img.spacer },
		{ type = "icon",  value = img.retrieval,
			flag = config.draw_flags and savedata.retrieval.full },
		{ type = "table", value = retrieval_elements },
		{ type = "icon",  value = img.retrieval,
			flag = config.draw_flags and savedata.retrieval.full },
		{ type = "icon",  value = img.spacer },
		{ type = "icon",  value = img.workshop,
			flag = config.draw_flags and savedata.Shares.full },
		{ type = "text",  value = facility_helpers.get_box_msg("Shares") },
		{ type = "icon",  value = img.workshop,
			flag = config.draw_flags and savedata.Shares.full },
		{ type = "icon",  value = img.spacer },
		{ type = "icon",  value = img.nest,
			timer = tidx.nest,
			draw_timer = config.draw_timers,
			bar = config.draw_bars and savedata.Nest.timer,
			flag = config.draw_flags and savedata.Nest.full },
		{ type = "text",  value = facility_helpers.get_box_msg("Nest") },
		{ type = "icon",  value = img.nest,
			flag = config.draw_flags and savedata.Nest.full },
		{ type = "icon",  value = img.spacer },
		{ type = "icon",  value = img.pugee,
			timer = tidx.pugee,
			draw_timer = config.draw_timers,
			bar = config.draw_bars and savedata.pugee.timer,
			flag = config.draw_flags and savedata.pugee.full },
	}
	
	tr.totalWidth = draw_helpers.measureElements(tracker_elements, tr)
	
	-- Draw the tracker
	d2d.fill_rect(0, tr.bg_y, draw_helpers.screen_w, tr.bg_h, tr.bg_color)
	d2d.image(img.border_left, 0, tr.border_y, tr.end_border_w, tr.border_h, tr.opacity)
	d2d.image(img.border_right, tr.end_border_x, tr.border_y, tr.end_border_w, tr.border_h, tr.opacity)
	if tr.sect_border_w > 0 then
		d2d.image(img.border_section, tr.sect_border_x, tr.border_y, tr.sect_border_w, tr.border_h, tr.opacity)
	end
	if tr.scroll then
		while tr.start_x < draw_helpers.screen_w do
			local xPos = draw_helpers.drawElements(tracker_elements, tr)
			d2d.image(img.spacer, xPos, tr.icon_y, tr.icon_d, tr.icon_d, tr.opacity)
			tr.start_x = xPos + tr.icon_d + tr.gap
		end
	else
		draw_helpers.drawElements(tracker_elements, tr)
		tr.start_x = tr.start_x + tr.totalWidth + tr.gap
	end
end

function draw.mini_tracker()
	local config = core.config
	local tidx = core.tidx
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
		{ type = "icon",  value = img.ph_icon },
		{ type = "text",  value = "This is a scrolling ticker message." },
		{ type = "icon",  value = img.ph_icon },
		{ type = "text",  value = "This will eventually display support ship items available once I find them." },
		{ type = "icon",  value = img.ph_icon },
		{ type = "text",  value = "This is placeholder text for ship items." },
		{ type = "icon",  value = img.ph_icon }
	}

	local trades_elements = {
		{ type = "icon",  value = img.ph_icon },
		{ type = "text",  value = "The text just keeps on scrolling!" },
		{ type = "icon",  value = img.ph_icon },
		{ type = "text",  value = "Ideally, this will also list available trades, but those have been rather elusive." },
		{ type = "icon",  value = img.ph_icon },
		{ type = "text",  value = "Just placeholder text for now." },
		{ type = "icon",  value = img.ph_icon }
	}
	
	local ticker_elements = {
		{ type = "icon",  value = img.ph_icon },
		{ type = "text",  value = "Here's a ticker." },
		{ type = "icon",  value = img.ph_icon,
			draw = config.draw_ship },
		{ type = "table", value = ship_elements,
			draw = config.draw_ship },
		{ type = "icon",  value = img.ph_icon,
			draw = config.draw_trades },
		{ type = "table", value = trades_elements,
			draw = config.draw_trades },
		{ type = "icon",  value = img.ph_icon },
		{ type = "text",  value = "And we loop around again." }
	}
	
	ti.totalWidth = draw_helpers.measureElements(ticker_elements, ti) + ti.gap
		
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
	local config = core.config
	local savedata = core.savedata
	local color = draw_helpers.color
	local img = draw_helpers.img
	local tr = draw_helpers.tr
	local ti = draw_helpers.ti
	
	local vo_icon = {}
	for i = 0, savedata.vouchers.size - 1 do
		vo_icon[i] = i < savedata.vouchers.count and img.voucher_v
	end
	
	local elements = {
		{ type = "icon",  value = vo_icon[0],
			frame = img.frame_v,
			draw = not main_updates.is_in_tent },
		{ type = "icon",  value = vo_icon[1],
			frame = img.frame_v,
			draw = not main_updates.is_in_tent },
		{ type = "icon",  value = vo_icon[2],
			frame = img.frame_v,
			draw = not main_updates.is_in_tent },
		{ type = "icon",  value = vo_icon[3],
			frame = img.frame_v,
			draw = not main_updates.is_in_tent },
		{ type = "icon",  value = vo_icon[4],
			frame = img.frame_v,
			draw = not main_updates.is_in_tent },
		{ type = "icon",  value = img.spacer,
			draw = savedata.vouchers.ready and not main_updates.is_in_tent },
		{ type = "text",  value = savedata.vouchers.days,
			draw = savedata.vouchers.ready and not main_updates.alt_tracker },
		{ type = "icon",  value = img.delivery,
			count = main_updates.alt_tracker and savedata.vouchers.days,
			draw = savedata.vouchers.ready },
	}
	
	local vo = {
		opacity = config.vo_opacity * main_updates.fade_value_v,
		gap     = (main_updates.alt_tracker and tr.gap or ti.gap) * 0.5,
		margin  = main_updates.alt_tracker and tr.margin or ti.margin,
		txt_y   = main_updates.alt_tracker and tr.txt_y or ti.txt_y,
		icon_y  = main_updates.alt_tracker and tr.icon_y or ti.icon_y,
		icon_d  = main_updates.alt_tracker and tr.icon_d or ti.icon_d
	}
	
	vo.start_x = vo.margin
	vo.font = {
		name   = "Segoe UI",
		size   = main_updates.alt_tracker and tr.font.size or ti.font.size,
		bold   = true,
		italic = false
	}
	
	local totalWidth    = draw_helpers.measureElements(elements, vo)
	local bg_w          = totalWidth * 1.5
	local bg_h          = main_updates.alt_tracker and tr.bg_h or ti.bg_h
	local border_y      = main_updates.alt_tracker and tr.border_y or ti.border_y
	local end_border_w  = main_updates.alt_tracker and tr.end_border_w or ti.end_border_w
	local border_h      = main_updates.alt_tracker and tr.border_h or ti.border_h
	local border_neg    = end_border_w - vo.margin * 0.8
	
	-- Draw vouchers
	draw_helpers.drawRectAlphaGradient("right", 0.5, 0, color.background, 0, 0, bg_w, bg_h, vo.opacity)
	d2d.image(img.border_left, 0, border_y, end_border_w, border_h, vo.opacity)
	draw_helpers.drawRectAlphaGradient("right", 0.5, border_neg, img.border_section, 0, border_y, bg_w, border_h, vo.opacity)
	draw_helpers.drawElements(elements, vo)
end

function draw.system_clock()
	local config = core.config
	local color = draw_helpers.color
	local img = draw_helpers.img
	local tr = draw_helpers.tr
	local mi = draw_helpers.mi
	local ti = draw_helpers.ti
	
	local mini_on_clock = main_updates.alt_tracker and config.draw_tracker and config.mini_tracker and not config.mi_tent_map
	
	local font = {
		name   = "Segoe UI",
		size   = main_updates.alt_tracker and tr.font.size or ti.font.size,
		bold   = true,
		italic = false
	}

	local text          = config.non_meridian_c and os.date("%H:%M") or os.date("%I:%M")
	local margin        = main_updates.alt_tracker and tr.margin or ti.margin
	local ref_font      = d2d.Font.new(font.name, font.size, font.bold, font.italic)
	local txt_w         = ref_font:measure(text)
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
	local end_border_a  = 0.82
	
	mi.ck_opacity = config.ck_opacity * main_updates.fade_value_c
	mi.ck_x       = draw_helpers.screen_w - txt_w - margin
	
	local text_color = draw_helpers.apply_opacity(color.clock_text, mi.ck_opacity)
	local shad_color = draw_helpers.apply_opacity(color.shadow, mi.ck_opacity)
	
	-- Draw the clock
	draw_helpers.drawRectAlphaGradient("left", 0.5, 0, color.background, bg_x, 0, bg_w, bg_h, mi.ck_opacity)
	d2d.image(img.border_right, end_border_x, border_y, end_border_w, border_h, mi.ck_opacity * end_border_a)
	draw_helpers.drawRectAlphaGradient("left", 0.5, border_neg, img.border_section, bg_x, border_y, bg_w, border_h, mi.ck_opacity)
	draw_helpers.shadow_text(font, text, mi.ck_x, txt_y, text_color, shad_color)
	if mini_on_clock then
		draw_helpers.drawElements(mi.elements, mi)
	end
end

function draw.moon_tracker()
	local config = core.config.moon
	local img = draw_helpers.img
	local midx = moon_updates.midx()
	if midx == nil then print("midx is nil!"); return end
	local pos = main_updates.map_open and "map" or main_updates.rest_open and "rest"
	
	local moon   = img["moon_" .. tostring(midx)]
	local m_num  = img["m_num_" .. tostring(midx)]
	local moon_x = (pos == "map" and 16 or pos == "rest" and 4 or 4) * draw_helpers.screen_scale
	local moon_y = (pos == "map" and 202 or pos == "rest" and 1722 or 1922) * draw_helpers.screen_scale
	local moon_w = 140 * draw_helpers.screen_scale
	local moon_h = 140 * draw_helpers.screen_scale
	local moon_f = config.auto_hide and main_updates.fade or 1
	local moon_a = (pos == "map" and 0.9 or 1) * moon_f
	
	-- Draw the moon
	d2d.image(img.m_ring, moon_x, moon_y, moon_w, moon_h, moon_a)
	if not (main_updates.in_grand_hub and config.ghub == "Nothing") and midx >= 0 then
		d2d.image(moon, moon_x, moon_y, moon_w, moon_h, moon_a)
		if config.num then
			d2d.image(m_num, moon_x, moon_y, moon_w, moon_h, moon_a)
		end
	end
end

return draw