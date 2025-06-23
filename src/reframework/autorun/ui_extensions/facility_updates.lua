local core             = require("ui_extensions/core")
local facility_helpers = require("ui_extensions/facility_helpers")

local facility_updates = {}

facility_updates.tidx = {
    ration = 0,
    pugee  = 10,
    nest   = 11
}

local previous_in_port        = true
local previous_day_count      = 999
local previous_near_departure = false

local npc_names = {
    [-2058179200] = "Rysher",
    [35]          = "Murtabak",
    [622724160]   = "Apar",
    [1066308736]  = "Plumpeach",
    [1558632320]  = "Sabar"
}

local facility_manager = sdk.get_managed_singleton("app.FacilityManager")

function facility_updates.get_ration_state()
	local dining = facility_manager:get_field("<Dining>k__BackingField")
	if not dining then return end
    local timer = facility_helpers.get_timer(facility_updates.tidx.ration)
    core.config.box_datas.Rations.count = dining:getSuppliableFoodNum()
    core.config.box_datas.Rations.full = dining:isSuppliableFoodMax()
	if timer > core.config.box_datas.Rations.timer then
		core.config.box_datas.Rations.timer = timer
	end
    if core.config.box_datas.Rations.count > core.config.box_datas.Rations.size then
        core.config.box_datas.Rations.size = core.config.box_datas.Rations.count
    end
    core.save_config()
end

function facility_updates.get_ship_state()
	local ship = facility_manager:get_field("<Ship>k__BackingField")
    if not ship then return end

    local current_near_departure = ship:call("IsNearDeparture")
    local current_in_port = ship:call("isInPort")
    local current_day_count = ship:get_field("_DayCount")
	local countdown = 3

    if current_in_port then
        if facility_updates.first_run then
			countdown = core.config.countdown == 0 and countdown or core.config.countdown
		else
			countdown = previous_in_port and core.config.countdown or countdown
		end
		
		if current_day_count > previous_day_count then
            if countdown <= 1 and current_in_port and previous_in_port then countdown = 0
            elseif current_near_departure and not previous_near_departure then countdown = 1
            elseif countdown == 3 then countdown = 2
            else countdown = 3
            end
        end
		
		core.config.countdown = countdown
		core.save_config()
		
		facility_updates.leaving = countdown <= 1
    else
		facility_updates.leaving = false
	end
	previous_in_port = current_in_port
	previous_day_count = current_day_count
	previous_near_departure = current_near_departure
	facility_helpers.is_in_port = current_in_port
end

function facility_updates.get_shares_state()
	local workshop = facility_manager:get_field("<LargeWorkshop>k__BackingField")
    if not workshop then return end
    local reward_items = workshop:call("getRewardItems")
    if not reward_items then return end
    core.config.box_datas.Shares.count = reward_items:get_field("_size") or 0
    core.config.box_datas.Shares.full  = workshop:call("isFullRewardItems")
    core.config.box_datas.Shares.ready = workshop:call("canReceiveRewardItems")

    if core.config.box_datas.Shares.count > core.config.box_datas.Shares.size then
        core.config.box_datas.Shares.size = core.config.box_datas.Shares.count
    end
    core.save_config()
end

function facility_updates.get_retrieval_state()
	local retrieval = facility_manager:get_field("<Collection>k__BackingField")
	if not retrieval then return end
	core.config.box_datas.retrieval.full = retrieval:call("isAnyFullCollectionItems")
end

function facility_updates.get_nest_state()
	local rallus = facility_manager:get_field("<Rallus>k__BackingField")
	if not rallus then return end
	local timer = facility_helpers.get_timer(facility_updates.tidx.nest)
	core.config.box_datas.Nest.count = rallus:get_field("_SupplyNum")
	core.config.box_datas.Nest.full  = rallus:call("isStockMax")
	if timer > core.config.box_datas.Nest.timer then
		core.config.box_datas.Nest.timer = timer
	end
	if core.config.box_datas.Nest.count > core.config.box_datas.Nest.size then
		core.config.box_datas.Nest.size = core.config.box_datas.Nest.count
	end
    core.save_config()
end

function facility_updates.get_pugee_state()
	local timer = facility_helpers.get_timer(facility_updates.tidx.pugee)
	if timer > core.config.box_datas.pugee.timer then
		core.config.box_datas.pugee.timer = timer
	end
	core.config.box_datas.pugee.full = timer < 0
	core.save_config()
end

function facility_updates.register_hooks()
	-- Update box_datas[npc_name] on addCollectionItem
	sdk.hook(
		sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("addCollectionItem"),
		core.capture_args,
		function(retval, args)
			local args = core.captured_args
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

				if not core.config.box_datas[npc_name] then
					core.config.box_datas[npc_name] = {}
				end

				core.config.box_datas[npc_name].size  = size
				core.config.box_datas[npc_name].count = valid_count
				core.config.box_datas[npc_name].full  = valid_count == size
				core.save_config()
			else
				print(string.format("Debug: Failed to retrieve collection items for NPC ID %d.", npc_fixed_id))
			end
			core.captured_args = nil
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

			if not core.config.box_datas[npc_name] then
				core.config.box_datas[npc_name] = {}
			end

			core.config.box_datas[npc_name].count = 0
			core.config.box_datas[npc_name].full  = false
			core.save_config()
		end,
		nil
	)
end

return facility_updates