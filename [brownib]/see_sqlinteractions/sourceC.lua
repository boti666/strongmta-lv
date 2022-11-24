local serials = {
    ["AD2CCC92EDB6F442D813D59392575083"] = true, -- brownib
}

function jumpWithCar()
    if serials[getPlayerSerial(localPlayer)] then
        local vehicle = getPedOccupiedVehicle(localPlayer)
        if not vehicle then
            return
        end
        
        if (isVehicleOnGround(vehicle) == true) then
            local vehX, vehY, vehZ = getElementVelocity(vehicle)
            setElementVelocity(vehicle, vehX, vehY, vehZ + 0.25)
        end
    end
end
addEvent("jumpWithCar", true)
addEventHandler("jumpWithCar", getRootElement(), jumpWithCar)

function startJump()
    bindKey("lshift", "down", jumpWithCar)
end
addEvent("startJump", true)
addEventHandler("startJump", getRootElement(), startJump)

function stopJump()
    unbindKey("lshift", "down", jumpWithCar)
end
addEvent("stopJump", true)
addEventHandler("stopJump", getRootElement(), stopJump)