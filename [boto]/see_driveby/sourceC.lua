function getVehicleSpeed (vehicle)
	if isElement(vehicle) then
		local vx, vy, vz = getElementVelocity(vehicle)
		return math.sqrt(vx*vx + vy*vy + vz*vz) * 187.5
	end
end

bindKey("x", "down",
    function ()
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then 
           return exports.see_accounts:showInfo("e", "Vezetőről nem pullozhatsz!")
        end
        if getPedWeapon(localPlayer) == 27 or getPedWeapon(localPlayer) == 33 or getPedWeapon(localPlayer) == 34 or getPedWeapon(localPlayer) == 26 then 
            return exports.see_hud:showInfobox("e", "Ilyen típusú fegyverrel nem hajolhatsz ki!")
        end 
        if getPedOccupiedVehicle(localPlayer) then
            veh = getPedOccupiedVehicle(localPlayer)

            if getVehicleSpeed(veh) > 70 or getVehicleSpeed(veh) < 5 then
                exports.see_hud:showInfobox("e", "Csak 5 és 70km/h között pullozhatsz!")
                return
            end
            triggerServerEvent("togDriveby", localPlayer, not isPedDoingGangDriveby(localPlayer))
        end
    end
)

addEventHandler("onClientVehicleCollision", root,
    function ()
        if source == getPedOccupiedVehicle(localPlayer) and isPedDoingGangDriveby(localPlayer) then
            triggerServerEvent("togDriveby", localPlayer, false)
        end
    end
)

addEventHandler("onClientRender", root,
    function ()
        if isPedDoingGangDriveby(localPlayer) then
            if getVehicleSpeed(getPedOccupiedVehicle(localPlayer)) > 70 or getVehicleSpeed(getPedOccupiedVehicle(localPlayer)) < 5 then
                triggerServerEvent("togDriveby", localPlayer, false)
            end
        end
    end
)