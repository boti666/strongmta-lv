addEventHandler("onClientKey", getRootElement(),
    function(button, down)
        if button == "mouse1" and down then
            if getPedOccupiedVehicle(localPlayer) then
                return
            end

            if getPedWeapon(localPlayer) == 43 and getKeyState("mouse2") then
                local x, y, z = getElementPosition(localPlayer)
                local range = 3

                local x1, x2, x3, x4, x5, x6 = getCameraMatrix()

                for k, v in ipairs(getElementsWithinRange(x, y, z, range)) do
                    if getElementData(v, "isHalloweenPed") and getScreenFromWorldPosition(getElementPosition(v)) and getScreenFromWorldPosition(getElementPosition(v)) and isLineOfSightClear(x1, x2, x3, x4, x5, x6) then
                        triggerServerEvent("halloweenCamera", localPlayer, getElementData(v, "halloween.id"))
                    end
                end
            end
        end
    end
)