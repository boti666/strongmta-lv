addEvent("onTireFlatten", true)
addEventHandler("onTireFlatten", getRootElement(),
	function (tireId)
		local wheelStates = {getVehicleWheelStates(source)}

		for i = 1, 4 do
			if tireId + 1 == i then
				wheelStates[i] = 1
			end
		end

		setVehicleWheelStates(source, unpack(wheelStates))
	end
)

addEventHandler("onElementModelChange", getRootElement(),
	function ()
		if getElementType(source) == "player" then
			setPedAnimation(source)
		end
	end
)
