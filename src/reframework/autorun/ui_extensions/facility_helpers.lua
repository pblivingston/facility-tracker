local core = require("ui_extensions/core")

local facility_helpers = { is_in_port = false }

local previous_timer_value = {}

local facility_manager = sdk.get_managed_singleton("app.FacilityManager")

function facility_helpers.get_timer(timer_index)
	local timers = facility_manager:get_field("<_FacilityTimers>k__BackingField")
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

local function format_time(timer_value)
    if timer_value == nil then return "" end
    local t = math.floor(timer_value)
    local minutes = math.floor(t / 60)
    local seconds = t % 60
    return string.format("%02d:%02d", minutes, seconds)
end

function facility_helpers.get_timer_msg(timer_index)
    local timer_value = facility_helpers.get_timer(timer_index)
    if timer_value and timer_value == previous_timer_value[timer_index] then
        return "00:00"
    end
    if timer_value then
        previous_timer_value[timer_index] = timer_value
        return format_time(timer_value)
    end
    return "ERR"
end

function facility_helpers.get_box_msg(box)
	local count = core.config.box_datas[box].count
	local size  = core.config.box_datas[box].size
	return string.format("%s: %d/%d", box, count, size)
end

function facility_helpers.is_box_full(box)
	return core.config.box_datas[box].full
end

function facility_helpers.get_ship_message()
    if facility_helpers.is_in_port then
        if core.config.countdown == 0 then return "Casting off!" end
		if core.config.countdown == 1 then return "Leaving soon!" end
		return "In port: " .. core.config.countdown .. " days"
    end
    return "Away from port"
end

return facility_helpers