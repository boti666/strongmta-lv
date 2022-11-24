local rentedCars = {}
local destroyTimer = {}

local lastPlate = 0

addEvent("rentACar", true)
addEventHandler("rentACar", getRootElement(),
    function (vehicleId, vehiclePrice)
        if isElement(source) and client and client == source then 
            if vehicleId and vehiclePrice then
                if exports.see_core:getMoney(source) - vehiclePrice > 0 then
                    exports.see_core:takeMoneyEx(source, vehiclePrice, "rentVehicle")

                    local playerPositionX, playerPositionY, playerPositionZ = getElementPosition(source)
                    
                    lastPlate = lastPlate + 1
                    local plateText = "RENT-" .. lastPlate

                    local createdVeh = createVehicle(vehicleId, playerPositionX, playerPositionY, playerPositionZ)
                    setElementData(source, "rentedCar", true)
                    setElementData(createdVeh, "rentedCarID", lastPlate)
                    setElementData(createdVeh, "rentedPlayerName", getElementData(source, "visibleName"))

                    setVehiclePlateText(createdVeh, plateText)
                    warpPedIntoVehicle(source, createdVeh)
                else
                    exports.see_hud:showInfobox(source, "e", "Nincs elég pénzed!")
                end
            end
        end
    end 
)

addEvent("destroyMyRentalVehicle", true)
addEventHandler("destroyMyRentalVehicle", getRootElement(),
    function ()
        if isElement(source) and client and client == source then
            local pedVehicle = getPedOccupiedVehicle(source) 
            if pedVehicle then 
                if getElementData(pedVehicle, "rentedCarID") then 
                    if getElementData(pedVehicle, "rentedPlayerName") == getElementData(source, "visibleName") then 
                        if isElement(pedVehicle) then 
                            setElementData(source, "rentedCar", false)
                            destroyElement(pedVehicle)
                        end
					else
						exports.see_hud:showInfobox(source, "e", "Ez nem a te bérelt járműved!")
                    end
                end
            end
        end
    end 
)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("player")) do
			removeElementData(v, "rentedCar")
		end
	end)

addEventHandler("onPlayerVehicleEnter", getRootElement(),
	function (vehicle)
		local vehicleId = getElementData(vehicle, "rentedCarID")
		
		if vehicleId then
			local spawnerName = getElementData(vehicle, "rentedPlayerName")
			local myName = getElementData(source, "visibleName")

			if spawnerName == myName then
				if isTimer(destroyTimer[vehicle]) then
					killTimer(destroyTimer[vehicle])
				end

				destroyTimer[vehicle] = nil

				exports.see_hud:showInfobox(source, "i", "Beszálltál a bérelt járművedbe.")
			end
		end
	end)

addEventHandler("onPlayerVehicleExit", getRootElement(),
	function (vehicle, seat, jacker, forcedByScript)
		if not forcedByScript then
			local vehicleId = getElementData(vehicle, "rentedCarID")
			
			if vehicleId then
				local spawnerName = getElementData(vehicle, "rentedPlayerName")
				local myName = getElementData(source, "visibleName")

				if spawnerName == myName then
					if isTimer(destroyTimer[vehicle]) then
						killTimer(destroyTimer[vehicle])
					end

					destroyTimer[vehicle] = setTimer(
						function (thePlayer, veh)
							if isElement(thePlayer) then
								removeElementData(thePlayer, "rentedCar")
							end

							rentedCars[thePlayer] = nil

							if isElement(veh) then
								destroyElement(veh)
                                exports.see_hud:showInfobox(source, "i", "Bérelt járműved törölve.")
							end

							destroyTimer[veh] = nil
						end,
					1000 * 60 * 15, 1, source, vehicle)

					exports.see_hud:showInfobox(source, "i", "Kiszálltál a bérelt járművedből. Ha nem szállsz vissza, a jármű 15 percen belül törlődik!")
				end
			end
		end
	end)

addEvent("deleteRentedCar", true)
addEventHandler("deleteRentedCar", getRootElement(),
	function ()
		if source then
			for k, v in pairs(rentedCars) do
				if v == source then
					if isElement(k) then
						removeElementData(k, "rentedCar")
					end

					if isTimer(destroyTimer[v]) then
						killTimer(destroyTimer[v])
					end

					destroyTimer[v] = nil

					if isElement(v) then
                        setElementData(source, "rentedCar", false)
						destroyElement(v)
					end

					rentedCars[k] = nil

					break
				end
			end
		end
	end
)


