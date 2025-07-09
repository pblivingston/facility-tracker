local core             = require("hud_extensions/core")
local facility_helpers = require("hud_extensions/facility_helpers")

local facility_updates = {}

local previous_in_port        = true
local previous_day_count      = 999
local previous_near_departure = false

local facility_manager = core.singletons.facility_manager

function facility_updates.get_ration_state()
	local active_savedata = core.get_savedata()
	if not active_savedata then return end
	local dining = active_savedata:get_field("_Dining")
	
	core.savedata.Rations.count = dining:get_field("SupplyNum")
	core.savedata.Rations.full  = core.savedata.Rations.count == core.savedata.Rations.size
	
	-- local dining = facility_manager:get_field("<Dining>k__BackingField")
	-- if not dining then return end
    -- core.savedata.Rations.count = dining:getSuppliableFoodNum()
    -- core.savedata.Rations.full = dining:isSuppliableFoodMax()
end

function facility_updates.get_ship_state()
	local active_savedata = core.get_savedata()
	if not active_savedata then return end
	local ship = active_savedata:get_field("_Ship")
	local status = ship:get_field("Status")
	local count = ship:get_field("DayCount")
	
	core.savedata.ship.is_in_port = status == 1
	core.savedata.ship.countdown  = status == 1 and count or nil
	core.savedata.ship.leaving    = status == 1 and count <= 1
	
	-- local ship = facility_manager:get_field("<Ship>k__BackingField")
    -- if not ship then return end

    -- local current_near_departure = ship:call("IsNearDeparture")
    -- local current_in_port = ship:call("isInPort")
    -- local current_day_count = ship:get_field("_DayCount")
	-- local countdown = 3

    -- if current_in_port then
        -- if core.first_run then
			-- countdown = core.config.countdown == 0 and countdown or core.config.countdown
		-- else
			-- countdown = previous_in_port and core.config.countdown or countdown
		-- end
		
		-- if current_day_count > previous_day_count then
            -- if countdown <= 1 and current_in_port and previous_in_port then countdown = 0
            -- elseif current_near_departure and not previous_near_departure then countdown = 1
            -- elseif countdown == 3 then countdown = 2
            -- else countdown = 3
            -- end
        -- end
		
		-- core.config.countdown = countdown
		-- core.save_config()
		
		-- facility_updates.leaving = countdown <= 1
    -- else
		-- facility_updates.leaving = false
		-- core.config.countdown = nil
	-- end
	-- previous_in_port = current_in_port
	-- previous_day_count = current_day_count
	-- previous_near_departure = current_near_departure
	-- facility_helpers.is_in_port = current_in_port
end

function facility_updates.get_shares_state()
	local active_savedata = core.get_savedata()
	if not active_savedata then return end
	local workshop = active_savedata:get_field("_LargeWorkshop")
	
	core.savedata.Shares.count = workshop:call("getRewardItems"):get_field("_size") or 0
	core.savedata.Shares.full  = workshop:call("isFullRewards")
	core.savedata.Shares.ready = workshop:call("canReceiveRewards")
	
	-- local workshop = facility_manager:get_field("<LargeWorkshop>k__BackingField")
    -- if not workshop then return end
    -- local reward_items = workshop:call("getRewardItems")
    -- if not reward_items then return end
    -- core.savedata.Shares.count = reward_items:get_field("_size") or 0
    -- core.savedata.Shares.full  = workshop:call("isFullRewardItems")
    -- core.savedata.Shares.ready = workshop:call("canReceiveRewardItems")
end

function facility_updates.get_nest_state()
	local rallus = facility_manager:get_field("<Rallus>k__BackingField")
	if not rallus then return end
	
	core.savedata.Nest.count = rallus:get_field("_SupplyNum")
	core.savedata.Nest.full  = rallus:call("isStockMax")
end

function facility_updates.get_pugee_state()
	local active_savedata = core.get_savedata()
	if not active_savedata then return end
	local pugee = active_savedata:get_field("_Pugee")
	
	core.savedata.pugee.full = pugee:get_field("CoolTimer") < 0
	
	-- local timer = facility_helpers.get_timer(core.tidx.pugee)
	-- if not timer then return end
	-- core.savedata.pugee.full = timer < 0
end

local function retrieval_full()
	local retrieval = facility_manager:get_field("<Collection>k__BackingField")
	if not retrieval then return end
	core.savedata.retrieval.full = retrieval:call("isAnyFullCollectionItems")
end

local function clear_retrieval(args)
	local npc = sdk.to_managed_object(args[2])
	local npc_fixed_id = npc:get_field("NPCFixedId")
	local npc_name = core.npc_names[npc_fixed_id]
	if not npc_name then
		print(string.format("Debug: NPCFixedId %d not found in npc_names table.", npc_fixed_id))
		return
	end
	
	core.savedata.retrieval[npc_name].count = 0
	core.savedata.retrieval[npc_name].full  = false
	
	retrieval_full()
end

local function update_retrieval(npc)
	npc = npc or (core.captured_args and sdk.to_managed_object(core.captured_args[2]))
	if not npc then
		print("Debug: No NPC or captured_args provided to update_retrieval.")
		return
	end
	
	local npc_fixed_id = npc:get_field("NPCFixedId")
	local npc_name = core.npc_names[npc_fixed_id]
	if not npc_name then
		print(string.format("Debug: NPCFixedId %d not found in npc_names table.", npc_fixed_id))
		return
	end

	local valid_count = 0
	local full = npc:call("isFullCollectionItems")
	local collection_items = npc:call("getCollectionItems")
	local size = collection_items:get_size()
	if full then valid_count = size; goto skip_count end

	for i = 0, size - 1 do
		local item = collection_items:get_element(i)
		if item then
			local num = item:get_field("Num")
			if num and num > 0 then
				valid_count = valid_count + 1
			end
		end
	end
	
	::skip_count::

	core.savedata.retrieval[npc_name].size  = size
	core.savedata.retrieval[npc_name].full  = full
	core.savedata.retrieval[npc_name].count = valid_count
	
	if not npc then core.captured_args = nil end
end

function facility_updates.init_retrieval()
	local active_savedata = core.get_savedata()
	if not active_savedata then return end
	local collection_npcs = active_savedata:get_field("_Collection"):get_field("_CollectionNPC")
	
	local npcs_size = collection_npcs:get_size()
	local any_full = false
	
	for i = 0, npcs_size - 1 do
		local npc = collection_npcs:get_element(i)
		local npc_fixed_id = npc:get_field("NPCFixedId")
		if npc_fixed_id == -1 then goto continue end
		local npc_name = core.npc_names[npc_fixed_id]
		if not npc_name then
			print(string.format("Debug: NPCFixedId %d not found in npc_names table.", npc_fixed_id))
			goto continue
		end
		
		update_retrieval(npc)
		
		if core.savedata.retrieval[npc_name].full then any_full = true end
		
		::continue::
	end
	
	core.savedata.retrieval.full = any_full
end

function facility_updates.register_hooks()
	sdk.hook(
		sdk.find_type_definition("app.savedata.cDiningParam"):get_method("addSuplyNum"),
		nil, function(retval) facility_updates.get_ration_state(); return retval end
	)
	sdk.hook(
		sdk.find_type_definition("app.savedata.cDiningParam"):get_method("setSupplyNum"),
		nil, function(retval) facility_updates.get_ration_state(); return retval end
	)
	sdk.hook(
		sdk.find_type_definition("app.savedata.cShipParam"):get_method("setDayCount"),
		nil, function(retval) facility_updates.get_ship_state(); return retval end
	)
	sdk.hook(
		sdk.find_type_definition("app.savedata.cLargeWorkshopParam"):get_method("addRewardItem"),
		nil, function(retval) facility_updates.get_shares_state() return retval end
	)
	sdk.hook(
		sdk.find_type_definition("app.savedata.cLargeWorkshopParam"):get_method("clearRewardItem"),
		nil, function(retval) facility_updates.get_shares_state() return retval end
	)
	sdk.hook(
		sdk.find_type_definition("app.FacilityRallus"):get_method("supplyTimerGoal"),
		nil, function(retval) facility_updates.get_nest_state() return retval end
	)
	sdk.hook(
		sdk.find_type_definition("app.FacilityRallus"):get_method("getSupplyItem"),
		nil, function(retval) facility_updates.get_nest_state() return retval end
	)
	sdk.hook(
		sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("addCollectionItem"),
		core.capture_args(args), function(retval) update_retrieval(); retrieval_full(); return retval end
	)
	sdk.hook(
		sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("clearCollectionItem"),
		clear_retrieval(args), nil
	)
	sdk.hook(
		sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("clearAllCollectionItem"),
		clear_retrieval(args), nil
	)
end

return facility_updates