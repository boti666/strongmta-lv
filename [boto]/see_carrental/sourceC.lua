local screenX, screenY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local panelState = false
local Roboto = dxCreateFont("Roboto.ttf", respc(18), false, "antialiased")

local rentableVehicles = {
    [1] = {410, exports.see_vehiclenames:getCustomVehicleName(410), 30000},
    [2] = {445, exports.see_vehiclenames:getCustomVehicleName(445), 85000},
    [3] = {462, exports.see_vehiclenames:getCustomVehicleName(462), 20000}
}

local availableMarkers = {
    {1660.5107421875, 1315.9400634766, 9.5}
}

for k, v in pairs(availableMarkers) do 
    createdMarkers = createMarker(v[1], v[2], v[3], "cylinder", 3, 61, 122, 188)
end

addEventHandler("onClientMarkerHit", getRootElement(),
    function (hitElement, matchingDimension)
        if hitElement == localPlayer and matchingDimension and source == createdMarkers then 
            if not getPedOccupiedVehicle(localPlayer) then
                if not getElementData(localPlayer, "rentedCar") then  
                    panelState = true
                    if isElement(Roboto) then 
                        destroyElement(Roboto)
                    end
                    Roboto = dxCreateFont("Roboto.ttf", respc(18), false, "antialiased")
                    showCursor(true)
                    setElementFrozen(localPlayer, true)
                else
                    exports.see_hud:showInfobox("e", "Neked már van egy bérelt járműved!")
                end
            else
                triggerServerEvent("destroyMyRentalVehicle", localPlayer)  
            end
        end
        
    end 
)

addEventHandler("onClientClick", getRootElement(),
    function (sourceKey, sourceKeyState)
        --panelState = getElementData(localPlayer, "loggedIn")
        if panelState and sourceKey == "left" and sourceKeyState == "up" and activeButton then 
            if string.find(activeButton, "rentCar_") then 
                panelState = false 
                showCursor(false)
                if isElement(Roboto) then 
                    destroyElement(Roboto)
                end
                setElementFrozen(localPlayer, false)
                triggerServerEvent("rentACar", localPlayer, rentableVehicles[tonumber(split(activeButton, "_")[2])][1], rentableVehicles[tonumber(split(activeButton, "_")[2])][3])
            end
            if activeButton == "exit" then 
                panelState = false
                if isElement(Roboto) then 
                    destroyElement(Roboto)
                end
                showCursor(false)
                setElementFrozen(localPlayer, false)
            end
        end
    end 
)

addEventHandler("onClientRender", getRootElement(),
    function ()
        if panelState then 
            buttons = {}
            dxDrawRectangle(screenX / 2 - respc(300), screenY / 2 - respc(200), respc(600), respc(400), tocolor(0, 0, 0, 150))
            dxDrawRectangle(screenX / 2 - respc(300), screenY / 2 - respc(200), respc(600), respc(35), tocolor(0, 0, 0, 250))
            dxDrawText("#ffffffStrong#3d7abcMTA #ffffff- Járműbérlés", screenX / 2 - respc(300) + respc(10), screenY / 2 - respc(200), screenX / 2 - respc(300) + respc(600), screenY / 2 - respc(200) + respc(35), tocolor(255, 255, 255, 255), 0.9, Roboto, "left", "center", false, false, false, true)
            --end
            if activeButton == "exit" then 
                dxDrawText("x", screenX / 2 - respc(300) + respc(600) - respc(30), screenY / 2 - respc(200), screenX / 2 - respc(300) + respc(600) - respc(10), screenY / 2 - respc(200) + respc(35), tocolor(215, 89, 89, 255), 1, Roboto, "right", "center", false, false, false, true)
            else
                dxDrawText("x", screenX / 2 - respc(300) + respc(600) - respc(30), screenY / 2 - respc(200), screenX / 2 - respc(300) + respc(600) - respc(10), screenY / 2 - respc(200) + respc(35), tocolor(255, 255, 255, 255), 1, Roboto, "right", "center", false, false, false, true)
            end

            buttons.exit = {screenX / 2 + respc(270), screenY / 2 - respc(195), respc(25), respc(25)}
            for i = 1, #rentableVehicles do 
                if i % 2 ~= 1 then 
                    dxDrawRectangle(screenX / 2 - respc(300), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(35), respc(600), respc(365 / #rentableVehicles), tocolor(0, 0, 0, 155))
                else
                    dxDrawRectangle(screenX / 2 - respc(300), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(35), respc(600), respc(365 / #rentableVehicles), tocolor(0, 0, 0, 200))
                end
                dxDrawText(rentableVehicles[i][2], screenX / 2 - respc(300) + respc(15), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(35), 0, screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(35) + respc(365 / #rentableVehicles), tocolor(255, 255, 255, 255), 0.75, Roboto, "left", "center", false, false, false, true)
                dxDrawText("Bérlés ára: " .. rentableVehicles[i][3] .. " $", 0, screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(35), screenX / 2 - respc(300) + respc(425), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(35) + respc(365 / #rentableVehicles), tocolor(255, 255, 255, 255), 0.75, Roboto, "right", "center", false, false, false, true)
                
                if activeButton == "rentCar_" .. i then
                    dxDrawRectangle(screenX / 2 - respc(300) + respc(435), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(50), respc(150), respc(365 / #rentableVehicles) - respc(30), tocolor(61, 122, 188, 255))
                else
                    dxDrawRectangle(screenX / 2 - respc(300) + respc(435), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(50), respc(150), respc(365 / #rentableVehicles) - respc(30), tocolor(61, 122, 188, 200))
                end
                
                dxDrawText("Kibérlés", screenX / 2 - respc(300) + respc(435), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(50), screenX / 2 - respc(300) + respc(435) + respc(150), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(50) + respc(365 / #rentableVehicles) - respc(30), tocolor(0, 0, 0, 255), 0.75, Roboto, "center", "center", false, false, false, true)
                buttons["rentCar_" .. i] = {screenX / 2 - respc(300) + respc(435), screenY / 2 - respc(200) + respc(365 / #rentableVehicles) * (i - 1) + respc(50), respc(150), respc(365 / #rentableVehicles) - respc(30)}
            end

            local cx, cy = getCursorPosition()

            if tonumber(cx) and tonumber(cy) then
                cx = cx * screenX
                cy = cy * screenY
        
                activeButton = false
        
                for k, v in pairs(buttons) do
                    if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
                        activeButton = k
                        break
                    end
                end
            else
                activeButton = false
            end
        end 
    end
)