addEvent("gluePlayer", true)
addEventHandler("gluePlayer", getRootElement(),
	function (slot, vehicle, x, y, z, rx, ry, rz)
		if isElement(source) and client and client == source then
			if isElement(vehicle) then
				exports.see_controls:toggleControl(source, {"aim_weapon", "action"}, false)
				attachElements(source, vehicle, x, y, z, rx, ry, rz)
				setPedWeaponSlot(source, slot)
				setElementData(source, "playerGlueRotation", rz)
				setElementData(source, "playerGlueState", vehicle)
			end
		end
	end)

addEvent("unGluePlayer", true)
addEventHandler("unGluePlayer", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			detachElements(source)
			removeElementData(source, "playerGlueState")
			removeElementData(source, "playerGlueRotation")
			exports.see_controls:toggleControl(source, {"aim_weapon", "action"}, true)
		end
	end)