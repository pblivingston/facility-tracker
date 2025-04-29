local json = json

local captured_args        = nil
local previous_timer_value = {}
local tidx                 = {
    ration  = 0,
    pugee   = 10,
    nest    = 11
}

local ration_timer        = 0
local supply_timer_active = false

local is_in_port              = false
local previous_in_port        = true
local is_near_departure       = false
local previous_near_departure = false
local previous_day_count      = 999
local countdown               = 3
local leaving                 = false

local npc_names = {
    [-2058179200] = "Rysher",
    [35]          = "Murtabak",
    [622724160]   = "Apar",
    [1066308736]  = "Plumpeach",
    [1558632320]  = "Sabar"
}

local previous_nest_time = 1200
local nest_timer_reset   = false
local nest_state_reset   = false

local first_run        = false
local previous_time    = os.clock()
local dt               = 0
local table_scale      = 0.9
local timer_scale      = 0.42
local flag_scale       = 0.4
local ti_scroll_offset = 0
local color            = {}
local img              = {}

local config_path = "facility_tracker.json"
local config = {
    countdown 	   = 3,
    shares_cap     = 100,
    draw_ticker    = false,
    ti_user_scale  = 1.0,
    ti_speed_scale = 1.0,
    ti_opacity     = 1.0,
    tr_user_scale  = 1.0,
    tr_opacity     = 1.0,
    draw_timers    = false,
	draw_flags     = true,
	draw_moon      = true,
	moons          = true,
	moons_txt      = false,
	box_datas	   = {
		ration = { size = 10 },
		shares = { size = 100 },
		nest = { count = 0, size = 5 },
		pugee = {},
		retrieval = {},
		Rysher = { count = 0, size = 16 },
		Murtabak = { count = 0, size = 16 },
		Apar = { count = 0, size = 16 },
		Plumpeach = { count = 0, size = 16 },
		Sabar = { count = 0, size = 16 }
	}
}

local function load_config()
    local loaded_config = json.load_file(config_path)
    if loaded_config then
        for key, value in pairs(loaded_config) do
            if config[key] ~= nil then
                config[key] = value
            end
        end
    else
        json.dump_file(config_path, config)
    end
end
-- Load the config file
load_config()

local function save_config()
    json.dump_file(config_path, config)
end

local facility_manager    = sdk.get_managed_singleton("app.FacilityManager")
local environment_manager = sdk.get_managed_singleton("app.EnvironmentManager")
local timers              = facility_manager:get_field("<_FacilityTimers>k__BackingField")
local dining              = facility_manager:get_field("<Dining>k__BackingField")
local ship                = facility_manager:get_field("<Ship>k__BackingField")
local workshop            = facility_manager:get_field("<LargeWorkshop>k__BackingField")
local retrieval           = facility_manager:get_field("<Collection>k__BackingField")

local function capture_args(args)
    captured_args = args
end

-- Update timer
local function get_timer(timer_index)
    if not timers then return nil end

    local size = timers:get_field("_size")
    if timer_index >= size then return nil end

    local timer = timers:get_Item(timer_index)
    local get_time_func = timer:get_field("<GetTimeFunc>k__BackingField")
    
    if get_time_func then
        local success, value = pcall(function() return get_time_func:call("Invoke") end)
        if not success then
            print("Error invoking GetTimeFunc for index " .. timer_index)
            return nil    
        end
        return value
    end
    return nil
end

-- Format as mm:ss
local function format_time(timer_value)
    if timer_value == nil then return "" end
    local t = math.floor(timer_value)
    local minutes = math.floor(t / 60)
    local seconds = t % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function get_timer_msg(timer_index)
    local timer_value = get_timer(timer_index)
    if timer_value and timer_value == previous_timer_value[timer_index] then
        return "00:00"
    end
    if timer_value then
        previous_timer_value[timer_index] = timer_value
        return format_time(timer_value)
    end
    return "ERR"
end

local function get_count_msg(facility)
    
end

local function is_box_full(facility)
	if not config.box_datas[facility] then
		config.box_datas[facility] = {}
	end
	return config.box_datas[facility].full
end

-- === Ingredient Center ===

local function get_ration_state()
	if not dining then return end
    ration_timer = get_timer(0)
    config.box_datas.ration.count = dining:getSuppliableFoodNum()
    config.box_datas.ration.full = dining:isSuppliableFoodMax()
    supply_timer_active = dining:supplyTimerContinuation()
    if config.box_datas.ration.count > config.box_datas.ration.size then
        config.box_datas.ration.size = config.box_datas.ration.count
    end
    save_config()
end

local function get_ration_message()
    -- if config.box_datas.ration.full then
        -- return "Rations: Full!"
    -- end
    return "Rations: " .. config.box_datas.ration.count .. "/" .. config.box_datas.ration.size
end

-- === Support Ship ===

local function get_ship_state()
    if not ship then return end

    local current_near_departure = ship:call("IsNearDeparture")
    local current_in_port = ship:call("isInPort")
    local current_day_count = ship:get_field("_DayCount")

    if current_in_port then
        if first_run then
			countdown = config.countdown == 0 and 3 or config.countdown
		else
			countdown = previous_in_port and config.countdown or 3
		end
		
		if current_day_count > previous_day_count then
            if countdown <= 1 and current_in_port and previous_in_port then countdown = 0
            elseif current_near_departure and not previous_near_departure then countdown = 1
            elseif countdown == 3 then countdown = 2
            else countdown = 3
            end
        end
		
		config.countdown = countdown
		save_config()
		
		leaving = countdown <= 1
    else
		leaving = false
	end
	previous_in_port = current_in_port
	previous_near_departure = current_near_departure
	previous_day_count = current_day_count
	is_near_departure = current_near_departure
	is_in_port = current_in_port
end

local function get_ship_message()
    if is_in_port then
        if config.countdown == 0 then return "Casting off!" end
		if config.countdown == 1 then return "Leaving soon!" end
		return "In port: " .. config.countdown .. " days"
    end
    return "Away from port"
end

-- === Festival Shares ===

local function get_shares_state()
    if not workshop then return end
    local reward_items = workshop:call("getRewardItems")
    if not reward_items then return end
    config.box_datas.shares.count = reward_items:get_field("_size") or 0
    config.box_datas.shares.full = workshop:call("isFullRewardItems")
    config.box_datas.shares.ready = workshop:call("canReceiveRewardItems")

    if config.box_datas.shares.count > config.box_datas.shares.size then
        config.box_datas.shares.size = config.box_datas.shares.count
    end
    save_config()
end

local function get_shares_message()
    if config.box_datas.shares.count == 0 then
        return config.box_datas.shares.full and "Shares error!" or "No Festival Shares"
    end
	if config.box_datas.shares.full then
        return "Shares: Full!"
    end
	if not config.box_datas.shares.ready then
        return "Unavailable!"
    end
    return string.format("Shares: %d/%d ", config.box_datas.shares.count, config.box_datas.shares.size)
end

-- === Material Retrieval ===

local function get_retrieval_state()
	if not retrieval then return end
	config.box_datas.retrieval.full = retrieval:call("isAnyFullCollectionItems")
end

-- Update box_datas on addCollectionItem
sdk.hook(
    sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("addCollectionItem"),
    capture_args,
    function(retval, args)
        local args = captured_args
        local npc = sdk.to_managed_object(args[2])
        if not npc then
            print("Debug: NPC object is nil.")
            return retval
        end
    
        local npc_fixed_id = npc:get_field("NPCFixedId")
        if not npc_fixed_id then
            print("Debug: NPCFixedId is nil.")
            return retval
        end
    
        local npc_name = npc_names[npc_fixed_id]
        if not npc_name then
            print(string.format("Debug: NPCFixedId %d not found in npc_names table.", npc_fixed_id))
            return retval
        end
    
        local success_items, collection_items = pcall(function() return npc:call("getCollectionItems") end)
        if success_items and collection_items and collection_items.get_size then
            local size = collection_items:get_size()
            local valid_count = 0
    
            for i = 0, size - 1 do
                local item = collection_items:get_element(i)
                if item then
                    local num = item:get_field("Num")
                    if num and num > 0 then
                        valid_count = valid_count + 1
                    end
                end
            end

            if not config.box_datas[npc_name] then
                config.box_datas[npc_name] = {}
            end

            config.box_datas[npc_name].size  = size
            config.box_datas[npc_name].count = valid_count
            config.box_datas[npc_name].full  = valid_count == size
            save_config()
        else
            print(string.format("Debug: Failed to retrieve collection items for NPC ID %d.", npc_fixed_id))
        end
        captured_args = nil
        return retval
    end
)

-- Clear count on clearCollectionItem
sdk.hook(
    sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("clearCollectionItem"),
    function(args)
        local npc = sdk.to_managed_object(args[2])
        if not npc then
            print("Debug: NPC object is nil.")
            return
        end
    
        local npc_fixed_id = npc:get_field("NPCFixedId")
        if not npc_fixed_id then
            print("Debug: NPCFixedId is nil.")
            return
        end
    
        local npc_name = npc_names[npc_fixed_id]
        if not npc_name then
            print(string.format("Debug: NPCFixedId %d not found in npc_names table.", npc_fixed_id))
            return
        end

        if not config.box_datas[npc_name] then
            config.box_datas[npc_name] = {}
        end

        config.box_datas[npc_name].count = 0
        config.box_datas[npc_name].full = false
        save_config()
    end,
    nil
)

local function get_npc_message(npc_name)
    local npc_count = config.box_datas[npc_name].count
    if not npc_count then
        print(string.format("Debug: No count available for NPC '%s'!", npc_name))
        return string.format("%s: ERR", npc_name)
    end

    local npc_size = config.box_datas[npc_name].size
    if not npc_size then
        print(string.format("Debug: No size available for NPC '%s'!", npc_name))
        return string.format("%s: ERR", npc_name)
    end

    -- if npc_count == npc_size then
        -- return string.format("%s: Full!", npc_name)
    -- end
    return string.format("%s: %d/%d", npc_name, npc_count, npc_size)
end

-- === Bird Nest ===

local function get_nest_state()
    local current_nest_time = get_timer(11)
    if current_nest_time then
        if previous_nest_time < 1 and current_nest_time > 1199 then
            config.box_datas.nest.count = config.box_datas.nest.count + 1
		end
        if config.box_datas.nest.count > config.box_datas.nest.size then
            config.box_datas.nest.size = config.box_datas.nest.count
        end
		config.box_datas.nest.full = config.box_datas.nest.count == config.box_datas.nest.size
        previous_nest_time = current_nest_time
    end
    save_config()
end

-- Reset nest count on collect trinkets
sdk.hook(
    sdk.find_type_definition("app.Gm262"):get_method("successButtonEvent"),
    function(args)
        config.box_datas.nest.count = 0
        save_config()
    end,
    nil
)

local function get_nest_message()
    -- if config.box_datas.nest.count == config.box_datas.nest.size then
        -- return "Full!"
    -- end
    return "Nest: " .. config.box_datas.nest.count .. "/" .. config.box_datas.nest.size
end

-- === Poogie ===

local function get_pugee_state()
	local timer = get_timer(tidx.pugee)
	config.box_datas.pugee.full = timer < 0
	save_config()
end

-- === Moon ===

local function get_moon_idx()
	local moon_controller  = environment_manager:get_field("_MoonController")
	local active_moon_data = moon_controller:call("getActiveMoonData")
	local moon_idx         = active_moon_data:call("get_MoonIdx")
	return moon_idx
end

local function get_moon_folder()
    if config.moons_txt == true then
        return "numerals"
    else
        config.moons = true
		save_config()
        return "default"
    end
end

-- === Helper functions ===

local function apply_opacity(argb, opacity)
    local a     = (argb >> 24) & 0xFF
    local rgb   = argb & 0x00FFFFFF
    local new_a = math.floor(a * opacity)
    return (new_a << 24) | rgb
end

local function measureElements(font, elements, gap, scale_elements)
    local totalWidth = 0
    local text_font = d2d.Font.new(font.name, font.size, font.bold, font.italic)
    local timer_font = d2d.Font.new(font.name, font.size * timer_scale, font.bold, font.italic)
    for i, elem in ipairs(elements) do
        if elem.type == "text" then
            elem.measured_width = text_font:measure(elem.value)
        elseif elem.type == "icon" then
			elem.measured_width = scale_elements and (elem.width * table_scale) or elem.width
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
            elem.measured_width = measureElements(table_font, elem.value, table_gap, true)
        end
        totalWidth = totalWidth + elem.measured_width + gap
    end
    return totalWidth - gap
end

local function drawElements(font, elements, start_x, y, icon_d, icon_y, gap, margin, color, alpha, scale_elements)
    local xPos = start_x
    local text_font = d2d.Font.new(font.name, font.size, font.bold, font.italic)
    local timer_font = d2d.Font.new(font.name, font.size * timer_scale, font.bold, font.italic)
    local ref_char_w, ref_char_h = text_font:measure("A")
    for i, elem in ipairs(elements) do
        if elem.type == "text" then
            d2d.text(text_font, elem.value, xPos, y, apply_opacity(color.text, alpha))
            xPos = xPos + elem.measured_width + gap
        elseif elem.type == "icon" then
			local drawY = scale_elements and (icon_y + (elem.height - (elem.height + margin) * table_scale) / 2) or icon_y
            local drawW = scale_elements and (elem.width * table_scale) or elem.width
            local drawH = scale_elements and (elem.height * table_scale) or elem.height
            d2d.image(elem.value, xPos, drawY, drawW, drawH, alpha)
			if elem.flag and config.draw_flags then
				local flagX = xPos - drawW / 2 + margin * 1.5
				local flagY = drawY - drawH / 2 + margin * 1.2
				d2d.image(img.flag, flagX, flagY, drawW, drawH, alpha)
			end
            xPos = xPos + elem.measured_width + gap
        elseif elem.type == "timer" and config.draw_timers then
            local timer_x = xPos - icon_d - margin * 3
            local timer_char_h = ref_char_h * timer_scale
            local timer_y = y + ref_char_h - timer_char_h - margin / 4
            local timer_bg_y = timer_y + margin * 4/5
            local timer_bg_w = elem.width
            local timer_bg_h = timer_char_h - margin
            d2d.fill_rect(timer_x, timer_bg_y, timer_bg_w, timer_bg_h, apply_opacity(color.background, alpha))
            d2d.text(timer_font, elem.value, timer_x, timer_y, apply_opacity(color.timer_text, alpha))
        elseif elem.type == "table" then
            local table_font = {
                name   = font.name,
                size   = font.size * table_scale,
                bold   = font.bold,
                italic = font.italic
            }
            local table_y      = y + (ref_char_h - ref_char_h * table_scale) / 2
			local table_icon_d = icon_d * table_scale
            local table_icon_y = icon_y + (icon_d - table_icon_d) / 2
            local table_gap    = gap * table_scale
            xPos = drawElements(table_font, elem.value, xPos, table_y, table_icon_d, table_icon_y, table_gap, margin, color, alpha, true)
        end
    end
    return xPos
end

-----------------------------------------------------------
-- ON-FRAME UPDATE
-----------------------------------------------------------

re.on_frame(
    function()
        if not timers or timers:get_field("_size") == 0 then
            first_run = true
            previous_nest_time = 1200
            config.box_datas.nest.count = 0
			nest_timer_reset = false
			nest_state_reset = false
            save_config()
            return
        end
		
        get_ration_state()
        get_ship_state()
        get_shares_state()
		get_retrieval_state()
        get_nest_state()
		get_pugee_state()
		
        -- === Time and time delta ===
        local current_time = os.clock()
        dt = current_time - previous_time
        previous_time = current_time
		
        first_run = false
    end
)

-----------------------------------------------------------
-- REGISTER DRAW
-----------------------------------------------------------

d2d.register(
    function()
        color.background    = 0x882E2810    -- Semi-transparent dark tan
        color.text          = 0xFFFFFFFF    -- White
        color.timer_text    = 0xFFFCFFA6    -- Light Yellow
		color.yellow_text   = 0xFFF4DB8A    -- Yellow
        color.red_text      = 0xFFFF0000    -- Red
        color.progress_bar  = 0xFF00FF00    -- Green
        color.full_progress = 0xFFFF3300    -- Red-orange
        color.border        = 0xFFAD9D75    -- Tan
    
        img.border_left    = d2d.Image.new("facility_tracker/border_left.png")
        img.border_right   = d2d.Image.new("facility_tracker/border_right.png")
        img.border_section = d2d.Image.new("facility_tracker/border_section.png")
        img.ph_icon        = d2d.Image.new("facility_tracker/ph_icon.png")
        img.error		   = d2d.Image.new("facility_tracker/error.png")
        img.spacer 	       = d2d.Image.new("facility_tracker/spacer.png")
        img.spacer_l 	   = d2d.Image.new("facility_tracker/spacer_l.png")
        img.flag 		   = d2d.Image.new("facility_tracker/flag.png")
        img.wilds 	       = d2d.Image.new("facility_tracker/wilds.png")
        img.rations	       = d2d.Image.new("facility_tracker/rations.png")
        img.ship   		   = d2d.Image.new("facility_tracker/ship.png")
        img.pugee          = d2d.Image.new("facility_tracker/pugee.png")
        img.nest		   = d2d.Image.new("facility_tracker/nest.png")
        img.nata 		   = d2d.Image.new("facility_tracker/nata.png")
        img.workshop       = d2d.Image.new("facility_tracker/workshop.png")
        img.retrieval      = d2d.Image.new("facility_tracker/retrieval.png")
        img.trader		   = d2d.Image.new("facility_tracker/trader.png")
        img.kunafa         = d2d.Image.new("facility_tracker/kunafa.png")
        img.wudwuds 	   = d2d.Image.new("facility_tracker/wudwuds.png")
        img.azuz 	 	   = d2d.Image.new("facility_tracker/azuz.png")
        img.suja 	 	   = d2d.Image.new("facility_tracker/suja.png")
        img.sild 	 	   = d2d.Image.new("facility_tracker/sild.png")
    end,
    function()
        if not timers or timers:get_field("_size") == 0 then
            return
        end
    
        local screen_w, screen_h = d2d.surface_size()
        local screen_scale       = screen_h / 2160.0
        local base_margin        = 4
        local base_border_h      = 40
        local base_end_border_w  = 34
        
        -------------------------------------------------------------------
        -- Ship/Trades Ticker
        -------------------------------------------------------------------

        local ti_user_scale  = config.ti_user_scale
        local ti_eff_scale   = screen_scale * ti_user_scale
        local ti_margin      = base_margin * ti_eff_scale
        local ti_bg_height   = 28 * ti_eff_scale
        local ti_icon_d      = ti_bg_height * 1.1
        local ti_speed_scale = config.ti_speed_scale * ti_eff_scale
        local ticker_speed   = 90 * ti_speed_scale
		local ti_bg_color    = apply_opacity(color.background, config.ti_opacity)
		local ticker_gap     = 10 * ti_eff_scale
		local ti_ex_gap      = ticker_gap
        local ti_bg_y        = 0
		local ti_icon_y      = (ti_bg_height - ti_icon_d) / 2
        local ti_font_size   = math.floor(ti_bg_height - ti_margin * 2)
        local ticker_font    = {
            name   = "Segoe UI",
            size   = ti_font_size,
            bold   = false,
            italic = true
        }
        
        local ship_elements = {
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
			{ type = "text",  value = "This is a scrolling ticker message." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
            { type = "text",  value = "This will eventually display support ship items available once I find them." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
            { type = "text",  value = "This is placeholder text for ship items." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d }
        }

        local trades_elements = {
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
            { type = "text",  value = "The text just keeps on scrolling!" },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
            { type = "text",  value = "Ideally, this will also list available trades, but those have been rather elusive." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
            { type = "text",  value = "Just placeholder text for now." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d }
        }
        
        local ticker_elements = {
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
            { type = "text",  value = "Here's a ticker." },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
			{ type = "table", value = ship_elements   },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
            { type = "table", value = trades_elements },
            { type = "icon",  value = img.ph_icon, width = ti_icon_d, height = ti_icon_d },
            { type = "text",  value = "And we loop around again." }
        }
        
        ti_scroll_offset = ti_scroll_offset + ticker_speed * dt
        local totalTickerWidth = measureElements(ticker_font, ticker_elements, ticker_gap) + ti_ex_gap
        if ti_scroll_offset > (screen_w + totalTickerWidth) then
            ti_scroll_offset = screen_w
        end
        local ticker_start_x = screen_w - ti_scroll_offset
        local current_x = ticker_start_x
        local ti_ref_font = d2d.Font.new(ticker_font.name, ticker_font.size, ticker_font.bold, ticker_font.italic)
        local ref_char_w, ref_char_h = ti_ref_font:measure("A")
        local ticker_txt_y = ti_bg_y + ti_bg_height - ref_char_h - ti_margin
        
        local ti_border_h      = base_border_h * 0.56 * ti_eff_scale
        local ti_end_border_w  = base_end_border_w * ti_eff_scale
        local ti_border_y      = ti_bg_y + ti_bg_height - (ti_border_h / 2)
        local ti_sect_border_x = ti_end_border_w - (ti_margin / 2)
        local ti_sect_border_w = screen_w - ti_end_border_w - ti_sect_border_x + ti_margin
		
        -------------------------------------------------------------------
        -- Factilities Tracker
        -------------------------------------------------------------------

        local tr_user_scale = config.tr_user_scale
        local tr_eff_scale  = screen_scale * tr_user_scale
        local tr_margin     = base_margin * tr_eff_scale
        local tr_bg_height  = 50 * tr_eff_scale
        local tr_bg_y       = screen_h - tr_bg_height
        local tr_bg_color   = apply_opacity(color.background, config.tr_opacity)
        local tr_icon_d     = tr_bg_height * 1.1
		local tracker_gap   = 18 * tr_eff_scale
		local tr_icon_y     = tr_bg_y + (tr_bg_height - tr_icon_d + tr_margin) / 2
        local tr_font_size  = math.floor(tr_bg_height - tr_margin * 2)
        local tracker_font  = {
            name   = "Segoe UI",
            size   = tr_font_size,
            bold   = false,
            italic = false
        }
        local retrieval_elements = {
            { type = "icon",  value = img.sild, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("Rysher")      },
            { type = "text",  value = get_npc_message("Rysher")    },
            { type = "icon",  value = img.kunafa, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("Murtabak")    },
            { type = "text",  value = get_npc_message("Murtabak")  },
            { type = "icon",  value = img.suja, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("Apar")      },
            { type = "text",  value = get_npc_message("Apar")      },
            { type = "icon",  value = img.wudwuds, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("Plumpeach")   },
            { type = "text",  value = get_npc_message("Plumpeach") },
            { type = "icon",  value = img.azuz, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("Sabar")      },
            { type = "text",  value = get_npc_message("Sabar")     }
        }
        
        local tracker_elements = {
            { type = "icon",  value = img.ship, width = tr_icon_d, height = tr_icon_d, flag = leaving      },
			{ type = "text",  value = get_ship_message()         },
            { type = "icon",  value = img.ship, width = tr_icon_d, height = tr_icon_d, flag = leaving      },
            { type = "icon",  value = img.spacer_l, width = tr_icon_d, height = tr_icon_d  },
            { type = "icon",  value = img.rations, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("ration")   },
            { type = "timer", value = get_timer_msg(tidx.ration) },
			{ type = "text",  value = get_ration_message()       },
            { type = "icon",  value = img.rations, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("ration")   },
            { type = "icon",  value = img.spacer_l, width = tr_icon_d, height = tr_icon_d  },
            { type = "icon",  value = img.retrieval, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("retrieval") },
            { type = "table", value = retrieval_elements         },
            { type = "icon",  value = img.retrieval, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("retrieval") },
            { type = "icon",  value = img.spacer_l , width = tr_icon_d, height = tr_icon_d },
            { type = "icon",  value = img.workshop, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("shares")  },
            { type = "text",  value = get_shares_message()       },
            { type = "icon",  value = img.workshop, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("shares")  },
            { type = "icon",  value = img.spacer_l, width = tr_icon_d, height = tr_icon_d  },
            { type = "icon",  value = img.nest, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("nest")      },
            { type = "timer", value = get_timer_msg(tidx.nest)   },
            { type = "text",  value = get_nest_message()         },
            { type = "icon",  value = img.nest, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("nest")      },
            { type = "icon",  value = img.spacer_l, width = tr_icon_d, height = tr_icon_d  },
            { type = "icon",  value = img.pugee, width = tr_icon_d, height = tr_icon_d, flag = is_box_full("pugee")     },
            { type = "timer", value = get_timer_msg(tidx.pugee)  }
        }
        
        local totalTrackerWidth = measureElements(tracker_font, tracker_elements, tracker_gap)
        local tracker_start_x = (screen_w - totalTrackerWidth) / 2
		
        local tr_ref_font = d2d.Font.new(tracker_font.name, tracker_font.size, tracker_font.bold, tracker_font.italic)
        local _, ref_char_height = tr_ref_font:measure("A")
        local tracker_txt_y = screen_h - ref_char_height
        
        local tr_border_h      = base_border_h * tr_eff_scale
        local tr_end_border_w  = base_end_border_w * tr_eff_scale
        local tr_border_y      = tr_bg_y - (tr_border_h / 2)
        local tr_sect_border_x = tr_end_border_w - (tr_margin / 2)
        local tr_sect_border_w = screen_w - tr_end_border_w - tr_sect_border_x + tr_margin

        -------------------------------------------------------------------
        -- DRAWS
        -------------------------------------------------------------------

        -- Draw the ticker
        if config.draw_ticker then
            d2d.fill_rect(0, ti_bg_y, screen_w, ti_bg_height, ti_bg_color)
            d2d.image(img.border_left, 0, ti_border_y, ti_end_border_w, ti_border_h, config.ti_opacity)
            d2d.image(img.border_right, screen_w - ti_end_border_w, ti_border_y, ti_end_border_w, ti_border_h, config.ti_opacity)
            if ti_sect_border_w > 0 then
                d2d.image(img.border_section, ti_sect_border_x, ti_border_y, ti_sect_border_w, ti_border_h, config.ti_opacity)
            end
            while current_x < screen_w do
                drawElements(ticker_font, ticker_elements, current_x, ticker_txt_y, ti_icon_d, ti_icon_y, ticker_gap, ti_margin, color, config.ti_opacity)
                current_x = current_x + totalTickerWidth
            end
        end

        -- Draw the tracker
        d2d.fill_rect(0, tr_bg_y, screen_w, tr_bg_height, tr_bg_color)
        d2d.image(img.border_left, 0, tr_border_y, tr_end_border_w, tr_border_h, config.tr_opacity)
        d2d.image(img.border_right, screen_w - tr_end_border_w, tr_border_y, tr_end_border_w, tr_border_h, config.tr_opacity)
        if tr_sect_border_w > 0 then
            d2d.image(img.border_section, tr_sect_border_x, tr_border_y, tr_sect_border_w, tr_border_h, config.tr_opacity)
        end
        drawElements(tracker_font, tracker_elements, tracker_start_x, tracker_txt_y, tr_icon_d, tr_icon_y, tracker_gap, tr_margin, color, config.tr_opacity)
		
		-- Draw the moon
		if config.draw_moon then
			local moon_image = d2d.Image.new("moon_tracker/" .. get_moon_folder() .. "/phase_" .. get_moon_idx() .. ".png")
            d2d.image(moon_image, 4 * screen_scale, 1922 * screen_scale, 140 * screen_scale, 140 * screen_scale, 1.0)
		end
    end
)

re.on_draw_ui(function()
    if imgui.tree_node("Facility Tracker") then
        local changed_tr_scale, newVal = imgui.slider_float("Tracker Scale", config.tr_user_scale, 0.0, 2.0)
        if changed_tr_scale then config.tr_user_scale = newVal; save_config() end

        local changed_tr_opacity, newVal2 = imgui.slider_float("Tracker Opacity", config.tr_opacity, 0.0, 1.0)
        if changed_tr_opacity then config.tr_opacity = newVal2; save_config() end
        
        local checkboxes = {
            { "Display Timers", "draw_timers" },
			{ "Display Flags", "draw_flags" }
        }
        for _, cb in ipairs(checkboxes) do
            local label, key = cb[1], cb[2]
            local changedBox, newVal = imgui.checkbox(label, config[key])
            if changedBox then
                config[key] = newVal
                save_config()
            end
        end

        imgui.tree_pop()
    end
	
	if imgui.tree_node("Moon Phase Tracker") then
        local checkboxes = {
            { "Display Moon Phase", "draw_moon" }
        }
        for _, cb in ipairs(checkboxes) do
            local label, key = cb[1], cb[2]
            local changedBox, newVal = imgui.checkbox(label, config[key])
            if changedBox then
                config[key] = newVal
                save_config()
            end
        end
		
		local img_checkboxes = {
			{ "Native Style",       "moons"     },
            { "With Numerals",      "moons_txt" }
        }
        for _, cb in ipairs(img_checkboxes) do
            local label, key = cb[1], cb[2]
            local changedBox, newValue = imgui.checkbox(label, config[key])
            if changedBox and newValue then
                for _, inner_cb in ipairs(img_checkboxes) do
                    config[inner_cb[2]] = false
                end
                config[key] = true
                save_config()
            end
        end
		
        imgui.tree_pop()
    end
	
    -- if imgui.tree_node("Trades Ticker") then
        -- local changed_ti_speed_scale, newVal2 = imgui.slider_float("Ticker Speed", config.ti_speed_scale, 0.1, 3.0)
        -- if changed_ti_speed_scale then config.ti_speed_scale = newVal2; save_config() end

        -- local changed_ti_scale, newVal = imgui.slider_float("Ticker Scale", config.ti_user_scale, 0.0, 2.0)
        -- if changed_ti_scale then config.ti_user_scale = newVal; save_config() end

        -- local changed_ti_opacity, newVal3 = imgui.slider_float("Ticker Opacity", config.ti_opacity, 0.0, 1.0)
        -- if changed_ti_opacity then config.ti_opacity = newVal3; save_config() end

        -- local checkboxes = {
            -- { "Display Ticker", "draw_ticker" },
            -- { "Include Ship",   "draw_ship"   },
            -- { "Include Trades", "draw_trades" }
        -- }
        -- for _, cb in ipairs(checkboxes) do
            -- local label, key = cb[1], cb[2]
            -- local changedBox, newVal = imgui.checkbox(label, config[key])
            -- if changedBox then
                -- config[key] = newVal
                -- save_config()
            -- end
        -- end

        -- imgui.tree_pop()
    -- end
end)
