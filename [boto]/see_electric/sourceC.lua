local chargerObjects = {}
local pumpObjects = {}

local screenX, screenY = guiGetScreenSize()

function respc(X)
    return X
end

function createSpline(points, steps)
    if #points < 3 then
        return points
    end

    local spline = {}

    do
        steps = steps or 3
        steps = 1 / steps

        local count = #points - 1
        local p0, p1, p2, p3, x, y, z

        for i = 1, count do
            if i == 1 then
                p0, p1, p2, p3 = points[i], points[i], points[i + 1], points[i + 2]
            elseif i == count then
                p0, p1, p2, p3 = points[#points - 2], points[#points - 1], points[#points], points[#points]
            else
                p0, p1, p2, p3 = points[i - 1], points[i], points[i + 1], points[i + 2]
            end

            for t = 0, 1, steps do
                x = (1 * ((2 * p1[1]) + (p2[1] - p0[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t * t + (3 * p1[1] - p0[1] - 3 * p2[1] + p3[1]) * t * t * t)) * 0.5
                y = (1 * ((2 * p1[2]) + (p2[2] - p0[2]) * t + (2 * p0[2] - 5 * p1[2] + 4 * p2[2] - p3[2]) * t * t + (3 * p1[2] - p0[2] - 3 * p2[2] + p3[2]) * t * t * t)) * 0.5
                z = (1 * ((2 * p1[3]) + (p2[3] - p0[3]) * t + (2 * p0[3] - 5 * p1[3] + 4 * p2[3] - p3[3]) * t * t + (3 * p1[3] - p0[3] - 3 * p2[3] + p3[3]) * t * t * t)) * 0.5

                local splineId = #spline

                if not (splineId > 0 and spline[splineId][1] == x and spline[splineId][2] == y and spline[splineId][3] == z) then
                    spline[splineId + 1] = {x, y, z}
                end
            end
        end
    end

    return spline
end

addEvent("receiveObjects", true)
addEventHandler("receiveObjects", getRootElement(),
    function(chargerObjectsServer, pumpObjectsServer)
        chargerObjects = chargerObjectsServer
        pumpObjects = pumpObjectsServer
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setElementData(localPlayer, "pump.Used", false)
        engineImportTXD(engineLoadTXD("files/models/hand.txd"), 7238)
        engineReplaceCOL(engineLoadCOL("files/models/hand.col"), 7238)
        engineReplaceModel(engineLoadDFF("files/models/hand.dff"), 7238)

        engineImportTXD(engineLoadTXD("files/models/charger.txd"), 6929)
        engineReplaceCOL(engineLoadCOL("files/models/charger.col"), 6929)
        engineReplaceModel(engineLoadDFF("files/models/charger.dff"), 6929)

        triggerServerEvent("requestObjects", localPlayer)
    end
)

function draw3DButton(buttonKey, imagePath, x, y, z, activeColor, multiplier)
    local buttonColor
    if activeButton == buttonKey then
        buttonColor = {activeColor[1], activeColor[2], activeColor[3]}
    else
        buttonColor = {255, 255, 255}
    end

    local screenX, screenY = getScreenFromWorldPosition(x, y, z)
    local buttonSize = respc(35) * multiplier

    if screenX and screenY then
        --dxDrawRectangle(screenX - buttonSize/2, screenY - buttonSize/2, buttonSize, buttonSize, tocolor(10, 10, 10, 255 * multiplier))
        if imagePath then
            dxDrawImage(screenX - buttonSize/2 + respc(2), screenY - buttonSize/2 + respc(2), buttonSize - respc(4), buttonSize - respc(4), imagePath, 0, 0, 0, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 255 * multiplier))
        end
        buttons[buttonKey] = {screenX - buttonSize/2, screenY - buttonSize/2, buttonSize, buttonSize}
    end
end

local maxDistanceButton = 5

local ZONE_MIN_X, ZONE_MIN_Y = 359.55825805664 - 100, 2494.1267089844
local ZONE_MAX_X, ZONE_MAX_Y = 417.82620239258, 2588.1391601562, 16.865913391113
local ZONE_Z = 16.484375 - 0.95

local Col = createColCuboid(ZONE_MIN_X, ZONE_MIN_Y, ZONE_Z, ZONE_MAX_X - ZONE_MIN_X, ZONE_MAX_Y - ZONE_MIN_Y, 5)

function RenderElectric()
    buttons = {}

    local pumpUsed = getElementData(localPlayer, "pump.Used")
    local playerX, playerY, playerZ = getElementPosition(localPlayer)

     if pumpUsed then
        local stationX, stationY, stationZ = getElementPosition(getElementData(localPlayer, "pump.Station"))
        local distanceFromStation = getDistanceBetweenPoints3D(playerX, playerY, playerZ, stationX, stationY, stationZ)
        for _, nearbyVehicle in pairs(getElementsByType("vehicle"), getRootElement(), true) do
            if isElementStreamedIn(nearbyVehicle) then
                local nearbyVehicleModel = getElementModel(nearbyVehicle)
                
                if enabledModels[(nearbyVehicleModel)] then
                    local nearbyVehicleIconX, nearbyVehicleIconY, nearbyVehicleIconZ = getPositionFromElementOffset(nearbyVehicle, modelOffsets[nearbyVehicleModel][1], modelOffsets[nearbyVehicleModel][2], modelOffsets[nearbyVehicleModel][3])
                    local nearbyVehicleDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, nearbyVehicleIconX, nearbyVehicleIconY, nearbyVehicleIconZ)
                    
                    if (nearbyVehicleDistance <= maxDistanceButton) then
                        local multiplier = interpolateBetween(1, 0, 0, 0.8, 0, 0, nearbyVehicleDistance/maxDistanceButton, "Linear")
                        draw3DButton("plugInVehicle:" .. getElementData(nearbyVehicle, "vehicle.dbID"), "files/images/electricpump.png", nearbyVehicleIconX, nearbyVehicleIconY, nearbyVehicleIconZ, {188, 135, 61}, multiplier)
                    end
                end
            end
        end
            
        if getPedOccupiedVehicle(localPlayer) then
            setElementFrozen(getPedOccupiedVehicle(localPlayer), true)
        end
    
        if distanceFromStation >= maxDistanceButton or getPedOccupiedVehicle(localPlayer) then
            triggerServerEvent("dropPump", localPlayer, pumpUsed)
            setElementData(localPlayer, "pump.Used", false)
        end
    end
        
    for _, nearbyVehicle in pairs(getElementsByType("vehicle"), getRootElement(), true) do
        if isElementStreamedIn(nearbyVehicle) and getElementData(nearbyVehicle, "pump.vehicleUsed") then
            local nearbyVehicleModel = getElementModel(nearbyVehicle)
                
            if enabledModels[nearbyVehicleModel] then
                local nearbyVehicleIconX, nearbyVehicleIconY, nearbyVehicleIconZ = getPositionFromElementOffset(nearbyVehicle, modelOffsets[nearbyVehicleModel][1], modelOffsets[nearbyVehicleModel][2], modelOffsets[nearbyVehicleModel][3])
                local nearbyVehicleDistance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, nearbyVehicleIconX, nearbyVehicleIconY, nearbyVehicleIconZ)
                    
                if (nearbyVehicleDistance <= maxDistanceButton) then
                    local multiplier = interpolateBetween(1, 0, 0, 0.5, 0, 0, nearbyVehicleDistance/maxDistanceButton, "Linear")
                   
                    draw3DButton("plugInVehicle:" .. getElementData(nearbyVehicle, "vehicle.dbID"), "files/images/electricpump.png", nearbyVehicleIconX, nearbyVehicleIconY, nearbyVehicleIconZ, {188, 135, 61}, multiplier)
                end
            end
        end
    end
        
    for chargerParent, pumpObject in pairs(pumpObjects) do
        if isElementStreamedIn(pumpObject) and isElementStreamedIn(chargerParent) then
            local pumpX, pumpY, pumpZ = getElementPosition(pumpObject)
            local linePos = {getPositionFromElementOffset(chargerParent, -0.20, 0, 2)}
            local offsetX = (pumpX - linePos[1]) / 2
            local offsetY = (pumpY - linePos[2]) / 2
                
            local splinePositions = {
                {linePos[1], linePos[2], linePos[3]},
                {linePos[1] + offsetX / 2, linePos[2] + offsetY / 2, linePos[3] - 0.5},
                {pumpX - offsetX / 2, pumpY - offsetY / 2, pumpZ - 0.3},
                {pumpX, pumpY, pumpZ}
            }

            if getElementData(pumpObject, "pump.User") then
                pumpX, pumpY, pumpZ = getPedBonePosition(getElementData(pumpObject, "pump.User"), 25)
                offsetX = (pumpX - linePos[1]) / 2
                offsetY = (pumpY - linePos[2]) / 2
                splinePositions = {
                    {linePos[1], linePos[2], linePos[3]},
                    {linePos[1] + offsetX / 2, linePos[2] + offsetY / 2, linePos[3] - 0.8},
                    {pumpX - offsetX / 2, pumpY - offsetY / 2, pumpZ - 0.3},
                    {pumpX, pumpY, pumpZ}
                }
            end
                
            pistolSpline = createSpline(splinePositions)

            for j = 1, #pistolSpline do
                local k = j + 1
                
                if pistolSpline[k] then
                    dxDrawLine3D(pistolSpline[j][1], pistolSpline[j][2], pistolSpline[j][3], pistolSpline[k][1], pistolSpline[k][2], pistolSpline[k][3], tocolor(5, 5, 5), 3)
                end
            end

            local chargerX, chargerY, chargerZ = getElementPosition(chargerParent)
            local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, chargerX, chargerY, chargerZ + 1)
                
            if (distance <= maxDistanceButton) and ((not pumpUsed) or getElementData(pumpObject, "pump.Id") == pumpUsed) then
                local multiplier = interpolateBetween(1, 0, 0, 0.5, 0, 0, distance/maxDistanceButton, "Linear")
                
                draw3DButton("selectPump:" .. getElementData(chargerParent, "charger.Id"), "files/images/electricpump.png", chargerX, chargerY, chargerZ + 1, {188, 135, 61}, multiplier)
            end
        end
    end

    local cx, cy = getCursorPosition()
    activeButton = false
    
    if tonumber(cx) and tonumber(cy) then
        cx = cx * screenX
        cy = cy * screenY

        for k,v in pairs(buttons) do
            if v[1] and v[2] and cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
                activeButton = k
                break
            end
        end
    end
end

addEventHandler("onClientColShapeHit", Col,
    function(Entity, Dim)
        if Dim then
            if Entity == localPlayer then
                addEventHandler("onClientRender", getRootElement(), RenderElectric)
            end
        end
    end
)

addEventHandler("onClientColShapeLeave", Col,
    function(Entity, Dim)
        if Dim then
            if Entity == localPlayer then
                removeEventHandler("onClientRender", getRootElement(), RenderElectric)
            end
        end
    end
)


addEventHandler("onClientVehicleStartEnter", getRootElement(),
    function(sourcePlayer)
        if sourcePlayer == localPlayer then
            if getElementData(localPlayer, "pump.Used") then
                cancelEvent()
            end
        end
    end
)

addEventHandler("onClientClick", getRootElement(),
    function(button, state)
        if state == "up" then
            if button == "left" then
                if activeButton then
                    local buttonDetails = split(activeButton, ":")

                    if getPedOccupiedVehicle(localPlayer) then
                        exports.see_accounts:showInfo("e", "Autóban ülve nem használhatod!")
                    else
                        if buttonDetails[1] == "selectPump" then
                            if getElementData(localPlayer, "pump.Used") and getElementData(localPlayer, "pump.Used") == tonumber(buttonDetails[2]) then
                                triggerServerEvent("dropPump", localPlayer, buttonDetails[2])
                            elseif not getElementData(localPlayer, "pump.Used") then
                                triggerServerEvent("selectPump", localPlayer, buttonDetails[2])
                            end
                        elseif buttonDetails[1] == "plugInVehicle" then
                            local selectedVehicle = false

                            for k, v in pairs(getElementsByType("vehicle")) do
                                if getElementData(v, "vehicle.dbID") == tonumber(buttonDetails[2]) then
                                    selectedVehicle = v
                                    break
                                end
                            end
                            if isElement(selectedVehicle) and getElementData(selectedVehicle, "pump.vehicleUsed") and getElementData(selectedVehicle, "vehicle.dbID") == tonumber(buttonDetails[2]) then
                                if getElementData(localPlayer, "pump.Used") then
                                    exports.see_accounts:showInfo("e", "Először tedd le a töltőpisztolyt!")
                                    return
                                end

                                triggerServerEvent("dropVehiclePump", localPlayer, buttonDetails[2])
                            elseif not getElementData(localPlayer, "pump.vehicleUsed") then
                                if getElementData(selectedVehicle, "pump.vehicleUsed") then
                                    exports.see_accounts:showInfo("e", "Ez az autó már töltés alatt áll!")
                                    return
                                end
                                triggerServerEvent("selectVehiclePump", localPlayer, buttonDetails[2])
                            end
                        end
                    end
                end
            end
        end
    end
)

local SoundTable = {
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [40] = true
}

addEventHandler("onClientWorldSound", getRootElement(), 
    function(Group)
        if getElementType(source) == "vehicle" and enabledModels[getElementModel(source)] then
            if SoundTable[Group] then
                cancelEvent()
            end
        end
    end
)