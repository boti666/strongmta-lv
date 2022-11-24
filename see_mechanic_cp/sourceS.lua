addEvent("points->FixVehicle", true)
addEventHandler("points->FixVehicle", root, function(vehicle)
	fixVehicle(vehicle)
end)

addEvent("fixVehicle", true)
addEventHandler("fixVehicle", getRootElement(),
	function (fixMoney)
		if isElement(source) and client and client == source then 
			exports.see_core:takeMoney(source, fixMoney, "fixTake")
		end
	end 
)
