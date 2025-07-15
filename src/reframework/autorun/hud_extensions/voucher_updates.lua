local core = require("hud_extensions/core")

local voucher_updates = {}

local network_manager = core.singletons.network_manager

function voucher_updates.get_vouchers()
	local active_savedata = core.get_savedata()
	if not active_savedata then return end
	local basic_data = active_savedata:get_field("_BasicData")
	core.savedata.vouchers.count = basic_data:call("getTicketNum")
	
	-- print("count " .. tostring(core.savedata.vouchers.count))
end

function voucher_updates.get_login_bonus()
	local delivery = network_manager:get_field("_DeliveryService")
	if not delivery then return end
	core.savedata.vouchers.ready = delivery:call("isNeedPickupLoginBonus")
	core.savedata.vouchers.days = delivery:call("getElapsedDays")
	
	-- print("ready " .. tostring(core.savedata.vouchers.ready))
	-- print("days " .. tostring(core.savedata.vouchers.days))
end

---------------------------------------------------
---------------------------------------------------

sdk.hook(
	sdk.find_type_definition("app.savedata.cBasicParam"):get_method("addTicket"),
	nil, function(retval) voucher_updates.get_vouchers(); return retval end
)
sdk.hook(
	sdk.find_type_definition("app.Net_DeliveryService"):get_method("saveLoginBonusDataEnd"),
	nil, function(retval) voucher_updates.get_login_bonus(); return retval end
)
sdk.hook(
	sdk.find_type_definition("app.Net_DeliveryService"):get_method("isNeedPickupLoginBonus"),
	nil, function(retval)
		core.savedata.vouchers.ready = (sdk.to_int64(retval) & 1) == 1
		return retval
	end
)
sdk.hook(
	sdk.find_type_definition("app.Net_DeliveryService"):get_method("getElapsedDays"),
	nil, function(retval)
		core.savedata.vouchers.days = sdk.to_int64(retval)
		return retval
	end
)
sdk.hook(
	sdk.find_type_definition("app.savedata.cBasicParam"):get_method("getTicketNum"),
	nil, function(retval)
		core.savedata.vouchers.count = sdk.to_int64(retval)
		return retval
	end
)

---------------------------------------------------
---------------------------------------------------

return voucher_updates