-- Ensure json library is imported correctly
local json = json 
local font = nil
local timer_value = 0.0
local previous_time = os.clock()
local ti_scroll_offset = 0

-- Colors (all in ARGB format)
local background_color   = 0x80000000    -- Semi-transparent black
local text_color         = 0xFFFFFFFF    -- White text
local red_text_color     = 0xFFFF0000    -- Red for full message text
local progress_bar_color = 0xFF00FF00  
local full_progress_color= 0xFFFF3300 
local border_color       = 0xFFAD9D75    -- Updated border color

-- Define config path and default config
local config_path = "facility_tracker.json"
local config = {
    ration_cap    = 10,
    ti_user_scale = 1.0,
    ti_speed_scale= 1.0,
    ti_opacity    = 1.0,
    tr_user_scale = 1.0,   -- Tracker scale
    tr_opacity    = 1.0    -- Tracker opacity
}

-- Load configuration from file
local function load_config()
    local loaded_config = json.load_file(config_path)
    if loaded_config then
        if loaded_config.ration_cap    then config.ration_cap     = loaded_config.ration_cap end
        if loaded_config.ti_user_scale then config.ti_user_scale  = loaded_config.ti_user_scale end
        if loaded_config.ti_speed_scale then config.ti_speed_scale = loaded_config.ti_speed_scale end
        if loaded_config.ti_opacity    ~= nil then config.ti_opacity    = loaded_config.ti_opacity end
        if loaded_config.tr_user_scale then config.tr_user_scale  = loaded_config.tr_user_scale end
        if loaded_config.tr_opacity    ~= nil then config.tr_opacity    = loaded_config.tr_opacity end
    else
        json.dump_file(config_path, config)
    end
end

-- Save configuration to file
local function save_config()
    json.dump_file(config_path, config)
end

load_config()

-- Helper function to apply opacity to an ARGB color.
local function apply_opacity(argb, opacity)
    local a   = (argb >> 24) & 0xFF
    local rgb = argb & 0x00FFFFFF
    local new_a = math.floor(a * opacity)
    return (new_a << 24) | rgb
end

-- Get timers from FacilityManager
local manager = sdk.get_managed_singleton("app.FacilityManager")
local timers  = manager:get_field("<_FacilityTimers>k__BackingField")
local dining_object = manager:get_field("<Dining>k__BackingField")  -- For ration count

-- Function to update timer value from timers list.
local function get_timer(timer_index)
    if not timers then
        return nil
    end
    local size = timers:get_field("_size")
    if timer_index >= size then
        return nil
    end
    local timer = timers:get_Item(timer_index)
    local get_time_func = timer:get_field("<GetTimeFunc>k__BackingField")
    if get_time_func then
        local success, value = pcall(function() return get_time_func:call("Invoke") end)
        if success then
            return value
        else
            print("Error invoking GetTimeFunc for index " .. timer_index)
        end
    end
    return nil
end

-- Format timer value as mm:ss.
local function format_time(timer_value)
    if timer_value == nil then return "" end
    local t = math.floor(timer_value)
    local minutes = math.floor(t / 60)
    local seconds = t % 60
    return string.format("%02d:%02d", minutes, seconds)
end

-- Preload images.
local border_left, border_right, border_section, ph_icon = nil, nil, nil
d2d.register(
    function()
        border_left    = d2d.Image.new("facility_tracker/border_left.png")
        border_right   = d2d.Image.new("facility_tracker/border_right.png")
        border_section = d2d.Image.new("facility_tracker/border_section.png")
        ph_icon        = d2d.Image.new("facility_tracker/ph_icon.png")
        print("Images loaded")
    end,
    function()
        -- === Time and ticker delta ===
        local current_time = os.clock()
        local dt = current_time - previous_time
        previous_time = current_time

        -- === Measurement and drawing helper functions ===
        local function measureElements(font, elements, icon_d, gap)
            local totalWidth = 0
            for i, elem in ipairs(elements) do
                if elem.type == "text" then
                    local w, _ = font:measure(elem.value)
                    elem.measured_width = w
                elseif elem.type == "icon" then
                    local baseWidth = elem.custom_width or icon_d
                    elem.measured_width = baseWidth
                end
                totalWidth = totalWidth + elem.measured_width + gap
            end
            return totalWidth
        end

        local function drawElements(font, elements, start_x, y, icon_d, icon_y, gap, color, alpha)
            local xPos = start_x
            local ref_char_w, ref_char_h = font:measure("A")  -- reference character for vertical centering
            for i, elem in ipairs(elements) do
                if elem.type == "text" then
                    d2d.text(font, elem.value, xPos, y, apply_opacity(color, alpha))
                elseif elem.type == "icon" then
                    local drawW = (elem.custom_width or icon_d)
                    local drawH = (elem.custom_height or icon_d)
                    d2d.image(elem.value, xPos, icon_y, drawW, drawH, alpha)
                end
                xPos = xPos + elem.measured_width + gap
            end
        end

        -- === Define ticker elements (mixed text and icons) ===
        local ticker_elements = {
            { type = "icon", value = ph_icon },
			{ type = "text", value = "This is a scrolling ticker message." },
            { type = "icon", value = ph_icon },
            { type = "text", value = "Gotta make this really long." },
            { type = "icon", value = ph_icon },
            { type = "text", value = "And some more text." }
        }

        -- === Pre-draw definitions for Ticker ===
        local screen_w, screen_h = d2d.surface_size()
        local screen_scale = screen_h / 2160.0  -- Base scale: 1.0 for 2160p
        local base_margin = 4  -- base margin in pixels

        -- Ticker (Trades Ticker) definitions (ti_*)
        local ti_user_scale = config.ti_user_scale
        local ti_eff_scale  = screen_scale * ti_user_scale
        local ti_margin     = base_margin * ti_eff_scale
        local ti_bg_height  = 28 * ti_eff_scale
        local ti_font_size  = math.floor(ti_bg_height - (2 * ti_margin))
        local ticker_font   = d2d.Font.new("Segoe UI", ti_font_size, false, false)
        local ti_icon_d     = ti_bg_height * 1.1
        local ti_speed_scale= config.ti_speed_scale * ti_eff_scale
        local ticker_speed  = 90 * ti_speed_scale
		local ti_bg_color   = apply_opacity(background_color, config.ti_opacity)
		local ticker_gap    = 10 * ti_eff_scale
		local ti_ex_gap     = 0 * ti_eff_scale
        local ti_bg_y       = 0
		local ti_icon_y     = (ti_bg_height - ti_icon_d) / 2
		
		d2d.fill_rect(0, ti_bg_y, screen_w, ti_bg_height, ti_bg_color)

        -- Update scrolling offset
        ti_scroll_offset = ti_scroll_offset + ticker_speed * dt

        -- Measure full ticker width.
        local totalTickerWidth = measureElements(ticker_font, ticker_elements, ti_icon_d, ticker_gap)

        if ti_scroll_offset > (screen_w + totalTickerWidth + ti_ex_gap) then
            ti_scroll_offset = screen_w
        end

        local ticker_start_x = screen_w - ti_scroll_offset

        -- To roughly center vertically within ticker area, use the height of a reference character ("A")
        local ref_char_w, ref_char_h = ticker_font:measure("A")
        local ticker_txt_y = ti_bg_y + ti_bg_height - ref_char_h - ti_margin

        -- Debug prints for ticker:
        -- print("Ticker start_x:", ticker_start_x, "Total width:", totalTickerWidth)

        -- Draw first instance of ticker elements.
        drawElements(ticker_font, ticker_elements, ticker_start_x, ticker_txt_y, ti_icon_d, ti_icon_y, ticker_gap, text_color, config.ti_opacity)
        -- Draw second instance if needed.
        if ticker_start_x + totalTickerWidth < screen_w then
            drawElements(ticker_font, ticker_elements, ticker_start_x + totalTickerWidth + ti_ex_gap, ticker_txt_y, ti_icon_d, ti_icon_y, ticker_gap, text_color, config.ti_opacity)
        end

        -------------------------------------------------------------------
        -- Factilities Tracker Section
        -------------------------------------------------------------------
        local timer0_val = get_timer(0)
        local ration_time = format_time(timer0_val)
        local ration_count = dining_object:getSuppliableFoodNum()
        local ration_is_max = dining_object:isSuppliableFoodMax()
        local supply_timer_active = dining_object:supplyTimerContinuation()

        local ration_message = ""
        if not ration_is_max and supply_timer_active then
            ration_message = ration_time .. " -> " .. ration_count .. "/" .. config.ration_cap
        elseif ration_is_max and not supply_timer_active then
            ration_message = "Full!"
        end
        if ration_count > config.ration_cap then
            config.ration_cap = ration_count
            save_config()
        end

		-- === Define tracker elements (mixed text and icons) ===
		local tracker_elements = {
            { type = "icon", value = ph_icon },
			{ type = "text", value = ration_message },
            { type = "icon", value = ph_icon },
            { type = "text", value = "Gotta make this really long." },
            { type = "icon", value = ph_icon },
            { type = "text", value = "And some more text." }
        }

        -- Tracker (ration message) definitions (tr_*)
        -- Tracker (tr_*) definitions
        local tr_user_scale = config.tr_user_scale                   -- User-controlled factor for tracker
        local tr_eff_scale  = screen_scale * tr_user_scale             -- Combined scaling factor
        local tr_margin     = base_margin * tr_eff_scale
        local tr_bg_height  = 50 * tr_eff_scale
        local tr_font_size  = math.floor(tr_bg_height - (2 * tr_margin))
        local tracker_font  = d2d.Font.new("Segoe UI", tr_font_size, true, false)
        local tr_bg_y       = screen_h - tr_bg_height
        local tr_bg_color   = apply_opacity(background_color, config.tr_opacity)
        local tr_icon_d     = tr_bg_height * 1.1
		local tracker_gap   = 18 * tr_eff_scale
		local tr_icon_y     = tr_bg_y + (tr_bg_height - tr_icon_d) / 2
		
		d2d.fill_rect(0, tr_bg_y, screen_w, tr_bg_height, tr_bg_color)

        -- Measure the total width of the tracker elements.
        local totalTrackerWidth = measureElements(tracker_font, tracker_elements, tr_icon_d, tracker_gap)
        -- To center the line, compute starting x so that:
        --   start_x + totalTrackerWidth is centered relative to screen width.
        local tracker_start_x = (screen_w - totalTrackerWidth) / 2

        -- Choose vertical position for the tracker text.
        -- Here we align the elements roughly in the vertical center of the tracker background.
        local ref_char = "A"
        local _, ref_char_height = tracker_font:measure(ref_char)
        local tracker_txt_y = tr_bg_y + tr_bg_height - ref_char_height - tr_margin

        -- Draw the full line of tracker elements.
        drawElements(tracker_font, tracker_elements, tracker_start_x, tracker_txt_y, tr_icon_d, tr_icon_y, tracker_gap, text_color, config.tr_opacity)

        -------------------------------------------------------------------
        -- IMAGE DRAWS (Borders)
        -------------------------------------------------------------------
        local base_border_h     = 40
        local base_end_border_w = 34
        local ti_border_h       = base_border_h * 0.56 * ti_eff_scale
        local ti_end_border_w   = base_end_border_w * ti_eff_scale
        local tr_border_h       = base_border_h * tr_eff_scale
        local tr_end_border_w   = base_end_border_w * tr_eff_scale
        local ti_border_y       = ti_bg_y + ti_bg_height - (ti_border_h / 2)
        local tr_border_y       = tr_bg_y - (tr_border_h / 2)

        d2d.image(border_left, 0, ti_border_y, ti_end_border_w, ti_border_h, config.ti_opacity)
        d2d.image(border_left, 0, tr_border_y, tr_end_border_w, tr_border_h, config.tr_opacity)
        d2d.image(border_right, screen_w - ti_end_border_w, ti_border_y, ti_end_border_w, ti_border_h, config.ti_opacity)
        d2d.image(border_right, screen_w - tr_end_border_w, tr_border_y, tr_end_border_w, tr_border_h, config.tr_opacity)

        local ti_sect_border_x = ti_end_border_w - (ti_margin / 2)
        local ti_sect_border_w = screen_w - ti_end_border_w - ti_sect_border_x + ti_margin
        if ti_sect_border_w > 0 then
            d2d.image(border_section, ti_sect_border_x, ti_border_y, ti_sect_border_w, ti_border_h, config.ti_opacity)
        end

        local tr_sect_border_x = tr_end_border_w - (tr_margin / 2)
        local tr_sect_border_w = screen_w - tr_end_border_w - tr_sect_border_x + tr_margin
        if tr_sect_border_w > 0 then
            d2d.image(border_section, tr_sect_border_x, tr_border_y, tr_sect_border_w, tr_border_h, config.tr_opacity)
        end

    end
)

-- REFramework GUI configuration.
re.on_draw_ui(function()
    if imgui.tree_node("Facility Tracker") then
        local changed_tr_scale, newVal = imgui.slider_float("Tracker Scale", config.tr_user_scale, 0.0, 2.0)
        if changed_tr_scale then config.tr_user_scale = newVal; save_config() end

        local changed_tr_opacity, newVal2 = imgui.slider_float("Tracker Opacity", config.tr_opacity, 0.0, 1.0)
        if changed_tr_opacity then config.tr_opacity = newVal2; save_config() end
        imgui.tree_pop()
    end
    if imgui.tree_node("Trades Ticker") then
        local changed_ti_scale, newVal = imgui.slider_float("Ticker Scale", config.ti_user_scale, 0.0, 2.0)
        if changed_ti_scale then config.ti_user_scale = newVal; save_config() end

        local changed_ti_speed_scale, newVal2 = imgui.slider_float("Ticker Speed", config.ti_speed_scale, 0.1, 3.0)
        if changed_ti_speed_scale then config.ti_speed_scale = newVal2; save_config() end

        local changed_ti_opacity, newVal3 = imgui.slider_float("Ticker Opacity", config.ti_opacity, 0.0, 1.0)
        if changed_ti_opacity then config.ti_opacity = newVal3; save_config() end
        imgui.tree_pop()
    end
end)
