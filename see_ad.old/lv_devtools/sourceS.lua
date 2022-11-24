addCommandHandler("ssc",
	function(source)
		setElementData(source, "char.slotCoins",1000000)
	end
)

addCommandHandler("givenitro",
	function(source)
		local veh = getPedOccupiedVehicle(source) 
		setElementData(veh, "vehicle.nitroLevel", 1000000000000)
	end 
)

addCommandHandler("badgedata",
	function (sourcePlayer, commandName, value, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not (value) then
				exports.lv_administration:showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				setElementData(sourcePlayer, "badgeData", value)
			end
		end
	end)