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
end

local function clear_shares()
	core.savedata.Shares.count = 0
	core.savedata.Shares.full  = false
	core.savedata.Shares.ready = false
end

function facility_updates.get_shares_state()
	local active_savedata = core.get_savedata()
	if not active_savedata then return end
	local workshop = active_savedata:get_field("_LargeWorkshop")
	
	core.savedata.Shares.count = workshop:call("getRewardItems"):get_field("_size") or 0
	core.savedata.Shares.full  = workshop:call("isFullRewards")
	core.savedata.Shares.ready = workshop:call("canReceiveRewards")
end

function facility_updates.get_nest_state()
	local rallus = facility_manager and facility_manager:get_field("<Rallus>k__BackingField")
	if not rallus then return end
	
	core.savedata.Nest.count = rallus:get_field("_SupplyNum")
	core.savedata.Nest.full  = rallus:call("isStockMax")
end

function facility_updates.get_pugee_state()
	local active_savedata = core.get_savedata()
	if not active_savedata then return end
	local pugee = active_savedata:get_field("_Pugee")
	
	core.savedata.pugee.full = pugee:get_field("CoolTimer") < 0
end

local function retrieval_full()
	local retrieval = facility_manager:get_field("<Collection>k__BackingField")
	if not retrieval then return end
	core.savedata.retrieval.full = retrieval:call("isAnyFullCollectionItems")
end

local function clear_retrieval(npc)
	if not npc then
		print("Debug: No NPC provided to clear_retrieval.")
		return
	end
	local npc_fixed_id = npc:get_field("NPCFixedId")
	local npc_name = core.npc_names[npc_fixed_id]
	if not npc_name then
		print(string.format("Debug: NPCFixedId %d not found in npc_names table.", npc_fixed_id))
		return
	end
	
	core.savedata.retrieval[npc_name].count = 0
	core.savedata.retrieval[npc_name].full  = false
end

local function update_retrieval(npc)
	if not npc then
		print("Debug: No NPC provided to update_retrieval.")
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

---------------------------------------------------
---------------------------------------------------

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
	sdk.find_type_definition("app.savedata.cShipParam"):get_method("setStatus"),
	nil, function(retval) facility_updates.get_ship_state(); return retval end
)
sdk.hook(
	sdk.find_type_definition("app.savedata.cLargeWorkshopParam"):get_method("addRewardItem"),
	nil, function(retval) facility_updates.get_shares_state(); return retval end
)
sdk.hook(
	sdk.find_type_definition("app.savedata.cLargeWorkshopParam"):get_method("clearRewardItem"),
	function(args) clear_shares() end, nil
)
sdk.hook(
	sdk.find_type_definition("app.FacilityRallus"):get_method("supplyTimerGoal"),
	nil, function(retval) facility_updates.get_nest_state(); return retval end
)
sdk.hook(
	sdk.find_type_definition("app.FacilityRallus"):get_method("getSupplyItem"),
	nil, function(retval) facility_updates.get_nest_state(); return retval end
)
sdk.hook(
	sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("clearCollectionItem"),
	function(args) clear_retrieval(sdk.to_managed_object(args[2])) end,
	function(retval) retrieval_full(); return retval end
)
sdk.hook(
	sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("clearAllCollectionItem"),
	function(args) clear_retrieval(sdk.to_managed_object(args[2])) end,
	function(retval) retrieval_full(); return retval end
)
sdk.hook(
	sdk.find_type_definition("app.savedata.cCollectionNPCParam"):get_method("addCollectionItem"),
	function(args) thread.get_hook_storage()["npc"] = sdk.to_managed_object(args[2]) end, 
	function(retval) update_retrieval(thread.get_hook_storage()["npc"]); retrieval_full(); return retval end
)

---------------------------------------------------
---------------------------------------------------

return facility_updates