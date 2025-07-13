local facility_updates = require("hud_extensions/facility_updates")
local voucher_updates  = require("hud_extensions/voucher_updates")

local bridge = {}

function bridge.init_savedata()
	voucher_updates.get_vouchers()
	voucher_updates.get_login_bonus()
	-- voucher_updates.get_login_days()
	
	facility_updates.get_ration_state()
	facility_updates.get_ship_state()
	facility_updates.get_shares_state()
	facility_updates.get_nest_state()
	facility_updates.get_pugee_state()
	facility_updates.init_retrieval()
end

---------------------------------------------------
---------------------------------------------------

bridge.init_savedata()

sdk.hook(
	sdk.find_type_definition("app.savedata.cUserSaveParam"):get_method("init"),
	nil, function(retval) bridge.init_savedata(); return retval end
)

---------------------------------------------------
---------------------------------------------------

return bridge