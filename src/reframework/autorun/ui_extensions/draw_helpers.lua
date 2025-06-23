local core = require("ui_extensions/core")

local draw_helpers = { color = {}, img = {} }

local table_scale = 0.9
local timer_scale = 0.42

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

function draw_helpers.measureElements(font, elements, gap, scale_elements)
    local totalWidth = 0
    local text_font = d2d.Font.new(font.name, font.size, font.bold, font.italic)
    local timer_font = d2d.Font.new(font.name, font.size * timer_scale, font.bold, font.italic)
    for i, elem in ipairs(elements) do
        if elem.type == "text" then
            elem.measured_width = text_font:measure(elem.value)
        elseif elem.type == "icon" then
			elem.measured_width = scale_elements and (elem.width * table_scale) or elem.width
		elseif elem.type == "bar" then
			elem.measured_width = 0 - gap
        elseif elem.type == "timer" then
            elem.width = timer_font:measure(elem.value)
            elem.measured_width = 0 - gap
        elseif elem.type == "table" then
            local table_font = {
                name   = font.name,
                size   = font.size * table_scale,
                bold   = font.bold,
                italic = font.italic
            }
            local table_gap = gap * table_scale
            elem.measured_width = draw_helpers.measureElements(table_font, elem.value, table_gap, true)
        end
        totalWidth = totalWidth + elem.measured_width + gap
    end
    return totalWidth - gap
end

function draw_helpers.drawElements(font, elements, start_x, y, icon_d, icon_y, gap, margin, alpha, scale_elements)
    local xPos = start_x
    local text_font = d2d.Font.new(font.name, font.size, font.bold, font.italic)
    local timer_font = d2d.Font.new(font.name, font.size * timer_scale, font.bold, font.italic)
    local ref_char_w, ref_char_h = text_font:measure("A")
    for i, elem in ipairs(elements) do
        if elem.type == "text" then
            d2d.text(text_font, elem.value, xPos, y, draw_helpers.apply_opacity(draw_helpers.color.text, alpha))
            xPos = xPos + elem.measured_width + gap
        elseif elem.type == "icon" then
            local drawW = scale_elements and (elem.width * table_scale) or elem.width
			if elem.frame then
				d2d.image(draw_helpers.img.frame_l, xPos, icon_y, drawW, icon_d, alpha)
			end
            d2d.image(elem.value, xPos, icon_y, drawW, icon_d, alpha)
			if elem.flag and core.config.draw_flags then
				local flagX = xPos - drawW / 2 + margin * 1.5
				local flagY = elem.alt_flag and icon_y - margin * 2.1 or icon_y - icon_d / 2 + margin * 1.2
				d2d.image(draw_helpers.img.flag, flagX, flagY, drawW, icon_d, alpha)
			end
            xPos = xPos + elem.measured_width + gap
		elseif elem.type == "bar" and core.config.draw_bars then
			local progress = 1 - math.max(0, math.min(1, elem.value / elem.max))
			local bar_w = icon_d * 0.75
			local bar_h = icon_d / 25
			local bar_x = xPos - gap - icon_d + (icon_d - bar_w) / 2
			local bar_y = alt_tracker and y + bar_h * 2 or y + icon_d - bar_h * 0.75
			local fill_w = bar_w * progress
			d2d.fill_rect(bar_x, bar_y, bar_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.background, alpha))
			if elem.flag then
				d2d.fill_rect(bar_x, bar_y, bar_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.full_bar, alpha))
			else
				d2d.fill_rect(bar_x, bar_y, fill_w, bar_h, draw_helpers.apply_opacity(draw_helpers.color.prog_bar, alpha))
			end
        elseif elem.type == "timer" and core.config.draw_timers then
            local timer_x = xPos - icon_d - margin * 3
            local timer_char_h = ref_char_h * timer_scale
            local timer_y = y + ref_char_h - timer_char_h - margin / 4
            local timer_bg_y = timer_y + margin * 0.8
            local timer_bg_w = elem.width
            local timer_bg_h = timer_char_h - margin
            d2d.fill_rect(timer_x, timer_bg_y, timer_bg_w, timer_bg_h, draw_helpers.apply_opacity(draw_helpers.color.background, alpha))
            d2d.text(timer_font, elem.value, timer_x, timer_y, draw_helpers.apply_opacity(draw_helpers.color.timer_text, alpha))
        elseif elem.type == "table" then
            local table_font = {
                name   = font.name,
                size   = font.size * table_scale,
                bold   = font.bold,
                italic = font.italic
            }
            local table_y = y + (ref_char_h - ref_char_h * table_scale) / 2
			local table_icon_d = icon_d * table_scale
            local table_icon_y = icon_y + (icon_d - table_icon_d) * 5/8
            local table_gap = gap * table_scale
            xPos = draw_helpers.drawElements(table_font, elem.value, xPos, table_y, table_icon_d, table_icon_y, table_gap, margin, alpha, true)
        end
    end
    return xPos
end

return draw_helpers