local previous_time = 1200
local config_path = "tracker_status.json"
local config = {
    nest_count = 0
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

local facility_manager = sdk.get_managed_singleton("app.FacilityManager")
local dining_object = facility_manager and facility_manager:get_field("<Dining>k__BackingField")
local timers = facility_manager and facility_manager:get_field("<_FacilityTimers>k__BackingField")
local barter_object = facility_manager and facility_manager:call("get_Barter")
local large_workshop = facility_manager and facility_manager:get_field("<LargeWorkshop>k__BackingField")
local environment_manager = sdk.get_managed_singleton("app.EnvironmentManager")

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

local function format_time(timer_value)
    if timer_value == nil then return "" end
    local t = math.floor(timer_value)
    local minutes = math.floor(t / 60)
    local seconds = t % 60
    return string.format("%02d:%02d", minutes, seconds)
end

sdk.hook(
    sdk.find_type_definition("app.Gm262"):get_method("successButtonEvent"),
    function(args)
        config.nest_count = 0
        save_config()
    end,
    nil
)

re.on_draw_ui(function()
    if imgui.tree_node("Ration Status") then
        if dining_object then
            local is_suppliable = dining_object:isSuppliableFood()
            local ration_count = dining_object:getSuppliableFoodNum()
            local is_max = dining_object:isSuppliableFoodMax()
            local supply_timer_active = dining_object:supplyTimerContinuation()

            imgui.text("Rations Available: " .. tostring(ration_count))
            imgui.text("Suppliable: " .. tostring(is_suppliable))
            imgui.text("Cap Reached: " .. tostring(is_max))
            imgui.text("Timer Active: " .. tostring(supply_timer_active))
        else
            imgui.text("Dining object not found.")
        end
        imgui.tree_pop()
    end

    if imgui.tree_node("Barter Status") then
        if barter_object then
            local current_time = barter_object:get_field("_CurrentTime")
            imgui.text("_CurrentTime: " .. tostring(current_time))
        else
            imgui.text("Barter object not found.")
        end
        imgui.tree_pop()
    end

    if imgui.tree_node("Facility Timer Info") then
        if timers then
            local size = timers:get_field("_size")
            imgui.text("Timer count: " .. tostring(size))

            for i = 0, size - 1 do
                local timer = timers:get_Item(i)
                local get_time_func = timer:get_field("<GetTimeFunc>k__BackingField")

                if get_time_func ~= nil then
                    local success, value = pcall(function() return get_time_func:call("Invoke") end)
                    if success then
                        imgui.text(string.format("Timer %d Remaining Time: %.2f", i, value))
                    else
                        imgui.text(string.format("Timer %d -> Failed to invoke: %s", i, value))
                    end
                else
                    imgui.text(string.format("Timer %d -> No GetTimeFunc", i))
                end
            end
        else
            imgui.text("Timers not found.")
        end
        imgui.tree_pop()
    end

    if imgui.tree_node("Birb Counter") then
		local current_time = get_timer(11)
        if not timers or timers:get_field("_size") == 0 then
            config.nest_count = 0
            previous_time = 1200
            imgui.text("Timers not found!")
        elseif current_time then
            local formatted_time = format_time(current_time)
		    imgui.text("Item added in: " .. tostring(formatted_time))
            if previous_time < current_time then
                config.nest_count = config.nest_count + 1
            end
            imgui.text("Items in nest: " .. tostring(config.nest_count))
            if current_time == 1200 and previous_time == 1200 then
                imgui.text("Nest is full!")
            end
            previous_time = current_time
        else
            imgui.text("Timer not found!")
        end
        save_config()
        imgui.tree_pop()
    end

    if imgui.tree_node("Support Ship") then
        if facility_manager then
            local ship = facility_manager:get_field("<Ship>k__BackingField")
            if ship then
                -- Check if the ship is in port
                local success_in_port, is_in_port = pcall(function() return ship:call("isInPort") end)
                if success_in_port then
                    imgui.text("Is in port: " .. tostring(is_in_port))
                else
                    imgui.text("Failed to check ship status.")
                end

                -- Check if the ship is near departure
                local success_near_departure, is_near_departure = pcall(function() return ship:call("IsNearDeparture") end)
                if success_near_departure then
                    imgui.text("Is near departure: " .. tostring(is_near_departure))
                else
                    imgui.text("Failed to check departure status.")
                end

                -- Display _DayCount
                local day_count = ship:get_field("_DayCount")
                if day_count then
                    imgui.text("Day Count: " .. tostring(day_count))
                else
                    imgui.text("Day Count: Unknown")
                end

            else
                imgui.text("Ship object not found.")
            end
        else
            imgui.text("Facility Manager not found.")
        end
        imgui.tree_pop()
    end

    if imgui.tree_node("Festival Share") then
        if large_workshop then
            -- Get Reward Items Count and Default Capacity
            local reward_items = large_workshop:call("getRewardItems")
            if reward_items then
                local current_count = reward_items:get_field("_size") or 0
                imgui.text("Num of items: " .. tostring(current_count) .. "/100")
            else
                imgui.text("Failed to retrieve reward items.")
            end

            -- Check if Reward Items can be received
            local success_can_receive, can_receive_reward_items = pcall(function() return large_workshop:call("canReceiveRewardItems") end)
            if success_can_receive then
                imgui.text("Reward Items Present: " .. tostring(can_receive_reward_items))
            else
                imgui.text("Failed to check if reward items can be received.")
            end

            -- Check if Reward Items are full
            local success_is_full, is_full_reward_items = pcall(function() return large_workshop:call("isFullRewardItems") end)
            if success_is_full then
                imgui.text("Reward Items Full: " .. tostring(is_full_reward_items))
            else
                imgui.text("Failed to check if reward items are full.")
            end
        else
            imgui.text("Large Workshop object not found.")
        end
        imgui.tree_pop()
    end

    local moon_controller = environment_manager and environment_manager:get_field("_MoonController")
    if imgui.tree_node("Moon Phase") then
        if moon_controller then
            local active_moon_data = moon_controller:call("getActiveMoonData")
            if active_moon_data then
                local moon_idx = active_moon_data:call("get_MoonIdx")
                if moon_idx then
                    imgui.text("Moon Phase: " .. tostring(moon_idx))
                else
                    imgui.text("Failed to retrieve Moon Phase.")
                end
            else
                imgui.text("Active Moon Data not found.")
            end
        else
            imgui.text("Moon Controller not found.")
        end
        imgui.tree_pop()
    end
end)
