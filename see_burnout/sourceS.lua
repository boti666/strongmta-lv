addEvent("damageWheels", true)
addEventHandler("damageWheels", getRootElement(),
	function (wheelIndex)
		if isElement(source) and client and source == getPedOccupiedVehicle(client) then
			if wheelIndex then
				local wheelStates = {getVehicleWheelStates(source)}

				for i = 1, 4 do
					if wheelIndex == i then
						wheelStates[i] = 1
					end
				end

				setVehicleWheelStates(source, unpack(wheelStates))
			end
		end
	end
)
