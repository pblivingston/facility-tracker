local core         = require("ui_extensions/core")
local main_updates = require("ui_extensions/main_updates")

local draw_helpers = { ti = { scroll_offset = 0 } }

local base_margin        = 4
local base_border_h      = 40
local base_end_border_w  = 34
local alt_scale          = 0.88

local table_scale = 0.9
local timer_scale = 0.42

draw_helpers.color = {
	background  = 0x882E2810,   -- Semi-transparent dark tan
	text        = 0xFFFFFFFF,   -- White
	timer_text  = 0xFFFCFFA6,   -- Light Yellow
	clock_text  = 0xFFF4DB8A,   -- Yellow
	red_text    = 0xFFFF0000,   -- Red
	prog_bar    = 0xFF00FF00,   -- Green
	full_bar    = 0xFFE6B00B,   -- Orange-yellow
	border      = 0xFFAD9D75    -- Tan
}

-- draw_helpers.img = {
		-- border_left    = d2d.Image.new("facility_tracker/border_left.png")
        -- border_right   = d2d.Image.new("facility_tracker/border_right.png")
        -- border_section = d2d.Image.new("facility_tracker/border_section.png")
        -- ph_icon        = d2d.Image.new("facility_tracker/ph_icon.png")
        -- error		  = d2d.Image.new("facility_tracker/error.png")
        -- spacer 	      = d2d.Image.new("facility_tracker/spacer.png")
        -- spacer_l 	  = d2d.Image.new("facility_tracker/spacer_l.png")
		-- frame_s        = d2d.Image.new("facility_tracker/frame_s.png")
		-- frame_l        = d2d.Image.new("facility_tracker/frame_l.png")
        -- flag 		  = d2d.Image.new("facility_tracker/flag.png")
        -- wilds 	      = d2d.Image.new("facility_tracker/wilds.png")
        -- rations	      = d2d.Image.new("facility_tracker/rations.png")
        -- ship   	      = d2d.Image.new("facility_tracker/ship.png")
        -- pugee          = d2d.Image.new("facility_tracker/pugee.png")
        -- nest		      = d2d.Image.new("facility_tracker/nest.png")
        -- nata 	      = d2d.Image.new("facility_tracker/nata.png")
        -- workshop       = d2d.Image.new("facility_tracker/workshop.png")
        -- retrieval      = d2d.Image.new("facility_tracker/retrieval.png")
        -- trader		  = d2d.Image.new("facility_tracker/trader.png")
        -- kunafa_b       = d2d.Image.new("facility_tracker/kunafa_b.png")
		-- kunafa         = d2d.Image.new("facility_tracker/kunafa.png")
        -- wudwuds_b 	  = d2d.Image.new("facility_tracker/wudwuds_b.png")
		-- wudwuds        = d2d.Image.new("facility_tracker/wudwuds.png")
        -- azuz_b 	 	  = d2d.Image.new("facility_tracker/azuz_b.png")
		-- azuz           = d2d.Image.new("facility_tracker/azuz.png")
        -- suja_b 	 	  = d2d.Image.new("facility_tracker/suja_b.png")
		-- suja           = d2d.Image.new("facility_tracker/suja.png")
        -- sild_b 	 	  = d2d.Image.new("facility_tracker/sild_b.png")
		-- sild           = d2d.Image.new("facility_tracker/sild.png")
		-- m_ring         = d2d.Image.new("moon_tracker/m_ring.png")
		-- moon_0         = d2d.Image.new("moon_tracker/moon_0.png")
		-- moon_1         = d2d.Image.new("moon_tracker/moon_1.png")
		-- moon_2         = d2d.Image.new("moon_tracker/moon_2.png")
		-- moon_3         = d2d.Image.new("moon_tracker/moon_3.png")
		-- moon_4         = d2d.Image.new("moon_tracker/moon_4.png")
		-- moon_5         = d2d.Image.new("moon_tracker/moon_5.png")
		-- moon_6         = d2d.Image.new("moon_tracker/moon_6.png")
		-- m_num_0        = d2d.Image.new("moon_tracker/m_num_0.png")
		-- m_num_1        = d2d.Image.new("moon_tracker/m_num_1.png")
		-- m_num_2        = d2d.Image.new("moon_tracker/m_num_2.png")
		-- m_num_3        = d2d.Image.new("moon_tracker/m_num_3.png")
		-- m_num_4        = d2d.Image.new("moon_tracker/m_num_4.png")
		-- m_num_5        = d2d.Image.new("moon_tracker/m_num_5.png")
		-- m_num_6        = d2d.Image.new("moon_tracker/m_num_6.png")
-- }

function draw_helpers.load_images(folder)
	draw_helpers.img = draw_helpers.img or {}
	for _, path in ipairs(fs.glob(folder .. [[\\.*png]], "$images")) do
		local name = path:sub(#folder + 2, -5)
		draw_helpers.img[name] = d2d.Image.new(path)
	end
end

function draw_helpers.facility_tracker()
	local tr = draw_helpers.tr or {}
	
	tr.opacity    = core.config.tr_opacity * main_updates.fade_value
	tr.user_scale = core.config.tr_user_scale
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
	tr.end_border_x  = draw_helpers.screen_w - tr.end_border_w
	tr.border_y      = main_updates.alt_tracker and tr.bg_y + tr.bg_h - (tr.border_h / 2) or tr.bg_y - (tr.border_h / 2)
	tr.sect_border_x = tr.end_border_w - (tr.margin / 2)
	tr.sect_border_w = draw_helpers.screen_w - tr.end_border_w - tr.sect_border_x + tr.margin
	
	draw_helpers.tr = tr
end

function draw_helpers.trades_ticker()
	local ti = draw_helpers.ti
	
	ti.opacity     = core.config.ti_opacity * main_updates.fade_value
	ti.user_scale  = core.config.ti_user_scale
	ti.eff_scale   = main_updates.alt_tracker and draw_helpers.screen_scale * ti.user_scale * alt_scale or draw_helpers.screen_scale * ti.user_scale
	ti.margin      = base_margin * ti.eff_scale
	ti.bg_h        = 28 * ti.eff_scale
	ti.icon_d      = ti.bg_h * 1.1
	ti.speed_scale = core.config.ti_speed_scale * ti.eff_scale
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
    alpha = alpha or 1

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

        if is_color then
            local line_color = draw_helpers.apply_opacity(element, grad_opacity)
            if is_vertical then
                d2d.line(pos_x, pos_y + i, pos_x + width, pos_y + i, 1.2, line_color)
            else
                d2d.line(pos_x + i, pos_y, pos_x + i, pos_y + height, 1.2, line_color)
            end
        elseif is_img then
            local img_opacity = grad_opacity * alpha
            if is_vertical then
                d2d.image(element, pos_x, pos_y + i, width, 1, img_opacity)
            else
                d2d.image(element, pos_x + i, pos_y, 1, height, img_opacity)
            end
        end
    end
end

function draw_helpers.measureElements(elements, data, scaling)
    local totalWidth = 0
    for i, elem in ipairs(elements) do
		local text_font = d2d.Font.new(data.font.name, data.font.size, data.font.bold, data.font.italic)
		local timer_font = d2d.Font.new(data.font.name, data.font.size * timer_scale, data.font.bold, data.font.italic)
        if elem.type == "text" then
            elem.measured_width = text_font:measure(elem.value)
        elseif elem.type == "icon" then
			elem.measured_width = scaling and elem.width * table_scale or elem.width
		elseif elem.type == "bar" then
			elem.measured_width = 0 - data.gap
        elseif elem.type == "timer" then
            elem.width = timer_font:measure(elem.value)
            elem.measured_width = 0 - data.gap
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
    end
    return totalWidth - data.gap
end

function draw_helpers.drawElements(elements, data, scaling)
	local xPos = data.start_x
    for i, elem in ipairs(elements) do
		local text_font = d2d.Font.new(data.font.name, data.font.size, data.font.bold, data.font.italic)
		local timer_font = d2d.Font.new(data.font.name, data.font.size * timer_scale, data.font.bold, data.font.italic)
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
			if elem.flag and core.config.draw_flags then
				local flagX = xPos - drawW / 2 + data.margin * 1.5
				local flagY = main_updates.alt_tracker and data.icon_y - data.margin * 2.1 or data.icon_y - data.icon_d / 2 + data.margin * 1.2
				d2d.image(draw_helpers.img.flag, flagX, flagY, drawW, data.icon_d, data.opacity)
			end
            xPos = xPos + elem.measured_width + data.gap
		elseif elem.type == "bar" and core.config.draw_bars then
			local progress = 1 - math.max(0, math.min(1, elem.value / elem.cap))
			local bar_w = data.icon_d * 0.75
			local bar_h = data.icon_d / 25
			local bar_x = xPos - data.gap - data.icon_d + (data.icon_d - bar_w) / 2
			local bar_y = main_updates.alt_tracker and data.txt_y + bar_h * 2 or data.txt_y + data.icon_d - bar_h * 0.75
			local fill_w = bar_w * progress
			d2d.fill_rect(bar_x, bar_y, bar_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.background, data.opacity))
			if elem.flag then
				d2d.fill_rect(bar_x, bar_y, bar_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.full_bar, data.opacity))
			else
				d2d.fill_rect(bar_x, bar_y, fill_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.prog_bar, data.opacity))
			end
        elseif elem.type == "timer" and core.config.draw_timers then
            local timer_x = xPos - data.icon_d - data.margin * 3
            local timer_char_h = ref_char_h * timer_scale
            local timer_y = data.txt_y + ref_char_h - timer_char_h - data.margin / 4
            local timer_bg_y = timer_y + data.margin * 0.8
            local timer_bg_w = elem.width
            local timer_bg_h = timer_char_h - data.margin
            d2d.fill_rect(timer_x, timer_bg_y, timer_bg_w, timer_bg_h, draw_helpers.apply_opacity(draw_helpers.color.background, data.opacity))
            d2d.text(timer_font, elem.value, timer_x, timer_y, draw_helpers.apply_opacity(draw_helpers.color.timer_text, data.opacity))
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
    end
    return xPos
end

return draw_helpers