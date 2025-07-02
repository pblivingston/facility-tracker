local core             = require("hud_extensions/core")
local main_updates     = require("hud_extensions/main_updates")
local facility_helpers = require("hud_extensions/facility_helpers")
local facility_updates = require("hud_extensions/facility_updates")

local draw_helpers = {}

local base_margin        = 4
local base_border_h      = 40
local base_end_border_w  = 34
local alt_scale          = 0.88

local table_scale = 0.9
local timer_scale = 0.42
local count_scale = 0.68

-- function draw_helpers.load_images(folder)
	-- draw_helpers.img = draw_helpers.img or {}
	-- for _, path in ipairs(fs.glob(folder .. [[\\.*png]], "$images")) do
		-- local name = path:sub(#folder + 2, -5)
		-- draw_helpers.img[name] = d2d.Image.new(path)
	-- end
-- end

function draw_helpers.facility_tracker()
	local config = core.config
	local tr = draw_helpers.tr or {}
	
	tr.opacity    = config.tr_opacity * main_updates.fade_value
	tr.user_scale = config.tr_user_scale
	tr.eff_scale  = main_updates.alt_tracker and draw_helpers.screen_scale * tr.user_scale * alt_scale or draw_helpers.screen_scale * tr.user_scale
	tr.margin     = base_margin * tr.eff_scale
	tr.bg_h       = 50 * tr.eff_scale
	tr.bg_y       = main_updates.alt_tracker and 0 or draw_helpers.screen_h - tr.bg_h
	tr.bg_color   = draw_helpers.apply_opacity(draw_helpers.color.background, tr.opacity)
	tr.icon_d     = tr.bg_h * 1.1
	tr.gap        = 18 * tr.eff_scale
	tr.icon_y     = main_updates.alt_tracker and tr.bg_y + (tr.bg_h - tr.icon_d) / 2 or tr.bg_y + (tr.bg_h - tr.icon_d + tr.margin) / 2
	
	tr.font       = {
		name   = "Segoe UI",
		size   = math.floor(tr.bg_h - tr.margin * 2),
		bold   = false,
		italic = false
	}
	
	tr.ref_font = d2d.Font.new(tr.font.name, tr.font.size, tr.font.bold, tr.font.italic)
	tr.char_w, tr.char_h = tr.ref_font:measure("A")
	tr.txt_y = tr.bg_y + tr.bg_h - tr.char_h
	
	tr.border_h      = base_border_h * tr.eff_scale
	tr.end_border_w  = base_end_border_w * tr.eff_scale
	tr.end_border_x  = draw_helpers.screen_w - tr.end_border_w + tr.margin * 0.6
	tr.border_y      = main_updates.alt_tracker and tr.bg_y + tr.bg_h - (tr.border_h / 2) or tr.bg_y - (tr.border_h / 2)
	tr.sect_border_x = tr.end_border_w - (tr.margin / 2)
	tr.sect_border_w = draw_helpers.screen_w - tr.end_border_w - tr.sect_border_x + tr.margin
	
	draw_helpers.tr = tr
end

function draw_helpers.mini_tracker()
	local config = core.config
	local tidx = facility_updates.tidx
	local img = draw_helpers.img
	local tr = draw_helpers.tr
	local mi = draw_helpers.mi or { ck_opacity = 1, ck_x = 0 }
	
	mi.font    = tr.font
	mi.txt_y   = tr.txt_y
	mi.opacity = (main_updates.alt_tracker and config.draw_clock) and mi.ck_opacity or tr.opacity
	mi.gap     = tr.gap
	mi.icon_d  = tr.icon_d
	mi.icon_y  = tr.icon_y
	mi.margin  = tr.margin
	
	local npc_counts = {
		config.box_datas.Rysher.count,
		config.box_datas.Murtabak.count,
		config.box_datas.Apar.count,
		config.box_datas.Plumpeach.count,
		config.box_datas.Sabar.count
	}
	local retrieval_count = math.max(table.unpack(npc_counts))
	
	local draw_ship = config.mini_ship == "Always" or (config.mini_ship == "In Port" and facility_helpers.is_in_port) or (config.mini_ship == "Near Departure" and facility_updates.leaving)
	local draw_ration = config.mini_ration == "Always" or (config.mini_ration == "Available" and config.box_datas.Rations.count > 0) or (config.mini_ration == "Full" and config.box_datas.Rations.full)
	local draw_retrieval = config.mini_retrieval == "Always" or (config.mini_retrieval == "Available" and retrieval_count > 0) or (config.mini_retrieval == "Full" and config.box_datas.retrieval.full)
	local draw_shares = config.mini_shares == "Always" or (config.mini_shares == "Available" and config.box_datas.Shares.count > 0) or (config.mini_shares == "Full" and config.box_datas.Shares.full)
	local draw_nest = config.mini_nest == "Always" or (config.mini_nest == "Available" and config.box_datas.Nest.count > 0) or (config.mini_nest == "Full" and config.box_datas.Nest.full)
	local draw_pugee = config.mini_pugee == "Always" or (config.mini_pugee == "Available" and config.box_datas.pugee.full)
	
	mi.elements = {
		{ type = "icon",  value = img.ship, width = mi.icon_d, count = config.countdown, flag = facility_updates.leaving, draw = draw_ship },
		{ type = "icon",  value = img.rations, width = mi.icon_d, count = config.box_datas.Rations.count, timer = tidx.ration, cap = config.box_datas.Rations.timer, flag = config.box_datas.Rations.full, draw = draw_ration },
		{ type = "icon",  value = img.retrieval, width = mi.icon_d, count = retrieval_count, flag = config.box_datas.retrieval.full, draw = draw_retrieval },
		{ type = "icon",  value = img.workshop, width = mi.icon_d, count = config.box_datas.Shares.count, flag = config.box_datas.Shares.full, draw = draw_shares },
		{ type = "icon",  value = img.nest, width = mi.icon_d, timer = tidx.nest, cap = config.box_datas.Nest.timer, count = config.box_datas.Nest.count, flag = config.box_datas.Nest.full, draw = draw_nest },
		{ type = "icon",  value = img.pugee, width = mi.icon_d, timer = tidx.pugee, cap = config.box_datas.pugee.timer, flag = config.box_datas.pugee.full, draw = draw_pugee }
	}
	
	mi.totalWidth = draw_helpers.measureElements(mi.elements, mi)
	
	local right_start = draw_helpers.screen_w - mi.totalWidth - mi.margin
	local altTr_start = config.draw_clock and mi.ck_x - mi.totalWidth - mi.gap or right_start
	mi.start_x = main_updates.alt_tracker and altTr_start or config.mini_right and right_start or mi.margin
	
	draw_helpers.mi = mi
end

function draw_helpers.trades_ticker()
	local config = core.config
	local ti = draw_helpers.ti or { scroll_offset = 0 }
	
	ti.opacity     = config.ti_opacity * main_updates.fade_value
	ti.user_scale  = config.ti_user_scale
	ti.eff_scale   = main_updates.alt_tracker and draw_helpers.screen_scale * ti.user_scale * alt_scale or draw_helpers.screen_scale * ti.user_scale
	ti.margin      = base_margin * ti.eff_scale
	ti.bg_h        = 28 * ti.eff_scale
	ti.icon_d      = ti.bg_h * 1.1
	ti.speed_scale = config.ti_speed_scale * ti.eff_scale
	ti.speed       = 90 * ti.speed_scale
	ti.bg_color    = draw_helpers.apply_opacity(draw_helpers.color.background, ti.opacity)
	ti.gap         = 10 * ti.eff_scale
	ti.ex_gap      = ti.gap
	ti.bg_y        = main_updates.alt_tracker and draw_helpers.screen_h - ti.bg_h or 0
	ti.icon_y      = main_updates.alt_tracker and ti.bg_y + (ti.bg_h - ti.icon_d + ti.margin) / 2 or ti.bg_y + (ti.bg_h - ti.icon_d) / 2
	
	ti.font        = {
		name   = "Segoe UI",
		size   = math.floor(ti.bg_h - ti.margin * 2),
		bold   = false,
		italic = true
	}
	
	ti.ref_font = d2d.Font.new(ti.font.name, ti.font.size, ti.font.bold, ti.font.italic)
	ti.char_w, ti.char_h = ti.ref_font:measure("A")
	ti.txt_y = ti.bg_y + ti.bg_h - ti.char_h - ti.margin
	
	ti.scroll_offset = ti.scroll_offset + ti.speed * main_updates.dt
	
	ti.border_h      = base_border_h * 0.56 * ti.eff_scale
	ti.end_border_w  = base_end_border_w * 0.56 * ti.eff_scale
	ti.end_border_x  = draw_helpers.screen_w - ti.end_border_w
	ti.border_y      = main_updates.alt_tracker and ti.bg_y - (ti.border_h / 2) or ti.bg_y + ti.bg_h - (ti.border_h / 2)
	ti.sect_border_x = ti.end_border_w - (ti.margin / 2)
	ti.sect_border_w = draw_helpers.screen_w - ti.end_border_w - ti.sect_border_x + ti.margin
	
	draw_helpers.ti = ti
end

function draw_helpers.apply_opacity(argb, opacity)
    local a     = (argb >> 24) & 0xFF
    local rgb   = argb & 0x00FFFFFF
    local new_a = math.floor(a * opacity)
    return (new_a << 24) | rgb
end

function draw_helpers.drawRectAlphaGradient(direction, offset, negative, element, pos_x, pos_y, width, height, alpha)
    local is_vertical = (direction == "up" or direction == "down")
    local is_reverse = (direction == "up" or direction == "left")
    local rect_len = is_vertical and height or width
    local neg = negative / (rect_len - 1)

    local is_color = type(element) == "number" and element >= 0 and element <= 0xFFFFFFFF

    local is_img = false
    if not is_color and draw_helpers.img then
        for _,v in pairs(draw_helpers.img) do
            if v == element then is_img = true break end
        end
    end

    if not (is_color or is_img) then
        print("drawRectAlphaGradient error: element is not a color or an image!")
        return
    end

    for i = 0, rect_len - 1 do
        local frac = i / (rect_len - 1)
        if is_reverse then frac = 1 - frac end
        local grad_frac = (frac - offset) / (1 - offset)
        local grad_opacity = frac < neg and 0 or frac < offset and 1 or 1 - grad_frac^2 / (2 * (grad_frac^2 - grad_frac) + 1)
		local opacity = grad_opacity * alpha

        if is_color then
            local line_color = draw_helpers.apply_opacity(element, opacity)
            if is_vertical then
                d2d.line(pos_x, pos_y + i, pos_x + width, pos_y + i, 1.2, line_color)
            else
                d2d.line(pos_x + i, pos_y, pos_x + i, pos_y + height, 1.2, line_color)
            end
        elseif is_img then
            if is_vertical then
                d2d.image(element, pos_x, pos_y + i, width, 1, opacity)
            else
                d2d.image(element, pos_x + i, pos_y, 1, height, opacity)
            end
        end
    end
end

function draw_helpers.measureElements(elements, data, scaling)
    local totalWidth = 0
    for i, elem in ipairs(elements) do
		if elem.draw == false then goto continue end
		local text_font = d2d.Font.new(data.font.name, data.font.size, data.font.bold, data.font.italic)
		local timer_font = d2d.Font.new(data.font.name, data.font.size * timer_scale, data.font.bold, data.font.italic)
        if elem.type == "text" then
            elem.measured_width = text_font:measure(elem.value)
        elseif elem.type == "icon" then
			elem.measured_width = scaling and elem.width * table_scale or elem.width
		elseif elem.type == "table" then
			local tbl_data = {}
            tbl_data.font = {
				name   = data.font.name,
				size   = data.font.size * table_scale,
				bold   = data.font.bold,
				italic = data.font.italic
			}
            tbl_data.gap = data.gap * table_scale
            elem.measured_width = draw_helpers.measureElements(elem.value, tbl_data, true)
        end
        totalWidth = totalWidth + elem.measured_width + data.gap
		::continue::
    end
    return totalWidth - data.gap
end

function draw_helpers.drawElements(elements, data, scaling)
	local config = core.config
	local xPos = data.start_x
    for i, elem in ipairs(elements) do
		if elem.draw == false then goto continue end
		local text_font = d2d.Font.new(data.font.name, data.font.size, data.font.bold, data.font.italic)
		local timer_font = d2d.Font.new(data.font.name, data.font.size * timer_scale, false, false)
		local count_font = d2d.Font.new(data.font.name, data.font.size * count_scale, true, false)
		local ref_char_w, ref_char_h = text_font:measure("A")
        if elem.type == "text" then
            d2d.text(text_font, elem.value, xPos, data.txt_y, draw_helpers.apply_opacity(draw_helpers.color.text, data.opacity))
            xPos = xPos + elem.measured_width + data.gap
        elseif elem.type == "icon" then
            local drawW = scaling and elem.width * table_scale or elem.width
			if elem.frame then
				d2d.image(draw_helpers.img.frame_l, xPos, data.icon_y, drawW, data.icon_d, data.opacity)
			end
            d2d.image(elem.value, xPos, data.icon_y, drawW, data.icon_d, data.opacity)
			if elem.flag and config.draw_flags then
				local flagX = xPos - drawW / 2 + data.margin * 1.5
				local flagY = main_updates.alt_tracker and data.icon_y - data.margin * 2.1 or data.icon_y - data.icon_d / 2 + data.margin * 1.2
				d2d.image(draw_helpers.img.flag, flagX, flagY, drawW, data.icon_d, data.opacity)
			end
			if elem.count ~= nil and config.mini_counts then
				local count = tostring(elem.count)
				local count_w = count_font:measure(count)
				local count_h = ref_char_h * count_scale
				local count_x = xPos + data.icon_d - data.margin * 1.5 - count_w * 0.5
				local count_y = main_updates.alt_tracker and data.txt_y + data.margin * 0.5 or data.txt_y + data.margin * 2.2 - count_h * 0.5
				local count_bg_w = count_w + data.margin * 0.3
				local count_bg_h = count_h - data.margin * 3.8
				local count_bg_x = count_x - data.margin * 0.15
				local count_bg_y = count_y + data.margin * 2.4
				local count_color = elem.flag and draw_helpers.color.full_text or draw_helpers.color.count_text
				d2d.fill_rect(count_bg_x, count_bg_y, count_bg_w, count_bg_h, draw_helpers.apply_opacity(draw_helpers.color.background, data.opacity))
				d2d.text(count_font, count, count_x, count_y, draw_helpers.apply_opacity(count_color, data.opacity))
			end
			if elem.timer ~= nil and config.draw_timers then	
				local timer_x = xPos + data.margin * 1.5
				local timer_char_h = ref_char_h * timer_scale
				local timer_y = data.txt_y + ref_char_h - timer_char_h - data.margin * 0.25
				local timer_bg_y = timer_y + data.margin * 0.8
				local timer_msg = facility_helpers.get_timer_msg(elem.timer)
				local timer_bg_w = timer_font:measure(timer_msg)
				local timer_bg_h = timer_char_h - data.margin
				d2d.fill_rect(timer_x, timer_bg_y, timer_bg_w, timer_bg_h, draw_helpers.apply_opacity(draw_helpers.color.background, data.opacity))
				d2d.text(timer_font, timer_msg, timer_x, timer_y, draw_helpers.apply_opacity(draw_helpers.color.timer_text, data.opacity))
			end
			if elem.timer ~= nil and elem.cap ~= nil and config.draw_bars then
				local timer_value = facility_helpers.get_timer(elem.timer)
				local progress = 1 - math.max(0, math.min(1, timer_value / elem.cap))
				local bar_w = data.icon_d * 0.75
				local bar_h = data.icon_d * 0.05
				local bar_x = xPos + data.margin * 1.6
				local bar_y = main_updates.alt_tracker and data.txt_y + bar_h * 2.5 or data.txt_y + data.icon_d - bar_h * 1.5
				local fill_w = bar_w * progress
				d2d.fill_rect(bar_x, bar_y, bar_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.background, data.opacity))
				if elem.flag then
					d2d.fill_rect(bar_x, bar_y, bar_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.full_bar, data.opacity))
				else
					d2d.fill_rect(bar_x, bar_y, fill_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.prog_bar, data.opacity))
				end
			end
            xPos = xPos + elem.measured_width + data.gap
		elseif elem.type == "table" then
			local tbl_data = {}
			tbl_data.font = {
				name   = data.font.name,
				size   = data.font.size * table_scale,
				bold   = data.font.bold,
				italic = data.font.italic
			}
			tbl_data.start_x = xPos
            tbl_data.txt_y   = data.txt_y + (ref_char_h - ref_char_h * table_scale) / 2
			tbl_data.opacity = data.opacity
            tbl_data.gap     = data.gap * table_scale
			tbl_data.icon_d  = data.icon_d * table_scale
            tbl_data.icon_y  = data.icon_y + (data.icon_d - tbl_data.icon_d) * 5/8
			tbl_data.margin  = data.margin * table_scale
            xPos = draw_helpers.drawElements(elem.value, tbl_data, true)
        end
		::continue::
    end
    return xPos
end

return draw_helpers