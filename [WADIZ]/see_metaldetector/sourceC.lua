local screenX, screenY = guiGetScreenSize()
setElementData(localPlayer, "isLotting", false)

function respc(x)
    return x
end

local lockCode = "KrisztianBalazs2022"
local lockString = 655

function loadLockedFiles(path, key)
    local file = fileOpen(path)
    local size = fileGetSize(file)
    local FirstPart = fileRead(file, lockString+6)
    fileSetPos(file, lockString+6)
    local SecondPart = fileRead(file, size-(lockString+6))
    fileClose(file)
    return decodeString("tea", FirstPart, { key = key })..SecondPart
end

local detectors = {}

local detectorID = 3697
local groundID = 5136
local groundFindID = 5136

local txd = engineLoadTXD("files/detector.txd", true)
engineImportTXD(txd, detectorID)
local dff = engineLoadDFF(loadLockedFiles("files/detector.wardis", lockCode), detectorID)
engineReplaceModel(dff, detectorID)

local txd = engineLoadTXD("files/turas1.txd", true)
engineImportTXD(txd, groundFindID)
local dff = engineLoadDFF(loadLockedFiles("files/turas1.wardis", lockCode), groundFindID)
engineReplaceModel(dff, groundFindID)

function respc(x)
    return x
end

screenX, screenY = guiGetScreenSize()

local holeTexture = dxCreateTexture("files/hole_texture.png")
local holeSize = 1

local holeState = false

setElementData(localPlayer, "player.Detector", false)
setElementData(localPlayer, "char.metalDetectorInHand", false)
setElementData(localPlayer, "inAnimPlayer", false)

local up2 = true

local traffiRadarState = false
local traffiColShape = false
local traffiArrowsTexture = false
local radarInterpolation = 0
local radarSoundPlayed = false
local radarSoundEnabled = true

local weightedItems = {
    [1] = {
        [220] = 25,
        [216] = 150,
        [214] = 150,
        [257] = 200,
        [326] = 200,

    },
    [2] = {
        [100] = 300,
        [34] = 300,
        [24] = 200,
        [23] = 200,

    },
    [3] = {
        [125] = 200,
        [97] = 200,
        [21] = 200,
        [151] = 200,
    },
    [4] = {
        [135] = 475,
        [33] = 475,
        [144] = 475,

    },
    [5] = {
        [158] = 155,
        [247] = 155,
        [137] = 225,
        [70] = 225,
        [259] = 155,
        [253] = 155,
        [254] = 155,
        [260] = 155,
    }
}

function chooseRandomItem(inputTable)
    local totalWeight = 0

    for k, v in pairs(inputTable) do
        totalWeight = totalWeight + v
    end

    local randomWeight = math.random(totalWeight)
    local currentWeight = 0

    for k, v in pairs(inputTable) do
        currentWeight = currentWeight + v

        if randomWeight <= currentWeight then
            return k
        end
    end

    return false
end


function renderHoles()
    exports.see_controls:toggleControl({"enter_passenger", "enter_exit", "fire", "jump", "sprint", "vehicle_fire"}, true)

    if getElementData(localPlayer, "char.metalDetectorInHand") then 
        exports.see_controls:toggleControl({"enter_passenger", "enter_exit", "fire", "jump", "sprint", "vehicle_fire"}, false)

        local closestRange = math.huge
        local closestEntity = false

        for k, v in pairs(getElementsByType("object", resourceRoot, true)) do
            if getElementData(v, "isMetalBox") and getElementData(v, "isLotting") then
                local posX, posY, posZ = getElementPosition(v)
                local distanceToThisObject = getDistance(posX, posY, posZ)

                if distanceToThisObject < closestRange then
                    closestRange = distanceToThisObject
                    closestEntity = v
                end
            end
        end

        alphaTick = (getElementData(closestEntity, "alphaTick") or 0)

        if closestRange < 2 and closestEntity then
            local posX, posY = getScreenFromWorldPosition(getElementPosition(closestEntity))

            if posX and posY and alphaTick == 0 then
                activatedEntity = false

                imageColor = tocolor(255, 255, 255, 180)

                if inSlot(posX - respc(50) / 2, posY- respc(50) / 2, respc(50), respc(50)) then
                    activatedEntity = closestEntity
                    imageColor = tocolor(124, 197, 118, 180)
                end

                dxDrawRectangle(posX - respc(50) / 2, posY- respc(50) / 2, respc(50), respc(50), tocolor(0, 0, 0, 180))
                dxDrawImage(posX - respc(50) / 2, posY- respc(50) / 2, respc(50), respc(50), "files/dig.png", 0, 0, 0, imageColor)
            end
        end

        if 0 < alphaTick then
            local tickOut = (getTickCount() - alphaTick) / 5000

            alphaKey = interpolateBetween(0, 0, 0, 1, 0, 0, tickOut, "Linear")

            local holeSize = holeSize * alphaKey
            
            if isElement(tempObjectElement) then
                setObjectScale(tempObjectElement, 0.5 * holeSize)
            end

            if tickOut >= 1 then

                
                triggerServerEvent("syncHoles", localPlayer, closestEntity, closestEntity)

                if isElement(tempObjectElement) then
                    destroyElement(tempObjectElement)
                end

                setElementData(closestEntity, "alphaTick", 0)

                --local playerDetector = getElementData(localPlayer, "player.Detector")

                setElementAlpha(detectors[localPlayer], 255)
                setPedAnimation(localPlayer)
                setElementData(localPlayer, "inAnimPlayer", false)
            end
        end

        dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/bg.png")

        if closestRange < 2 then
            dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/8.png")
        elseif closestRange > 2 and closestRange < 4 then
            dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/7.png")
        elseif closestRange > 4 and closestRange < 6 then
            dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/6.png")
        elseif closestRange > 6 and closestRange < 8 then
            dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/5.png")
        elseif closestRange > 8 and closestRange < 10 then
            dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/4.png")
        elseif closestRange > 10 and closestRange < 12 then
            dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/3.png")
        elseif closestRange > 12 and closestRange < 14 then
            dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/2.png")
        elseif closestRange > 14 and closestRange < 16 then
            dxDrawImage(screenX / 2 - respc(390) / 2, screenY - respc(250) - respc(50), respc(390), respc(250), "files/1.png")
        end

        if closestEntity and closestRange < 40 then
            local shitTime = 5000
            local shitRange = 100

            if closestRange < 10 then
               shitTime = 5000
               shitRange = 50
            end 

            local elapsedTime = getTickCount() - radarInterpolation
            local progress = elapsedTime / (shitTime * (closestRange / shitRange))

            if progress > 0.1 then
                radarSoundPlayed = false
            end

            if progress >= 1 then
                radarInterpolation = getTickCount()



                if not radarSoundPlayed and not getElementData(localPlayer, "inAnimPlayer") then
                    if radarSoundEnabled then
                        if closestRange < 10 then
                            playSound("files/beep2.mp3")
                        else
                            playSound("files/beep.mp3")
                        end
                    end

                    radarSoundPlayed = true
                end
            end
        end
    end
end

function clickHoles(key, state)
    if key == "left" and state == "down" then
        if activatedEntity then
            if getElementData(activatedEntity, "isLotting") then
                if getElementData(activatedEntity, "secondState") then
                    setElementData(activatedEntity, "isLotting", false)

                   -- print("get random item")
                    local itemId = chooseRandomItem(weightedItems[math.random(1, #weightedItems)])

                    triggerServerEvent("getItemToPlayer", localPlayer, itemId)

                    exports.see_controls:toggleControl({"enter_passenger", "enter_exit", "fire", "jump", "sprint", "vehicle_fire"}, false)
                else
                    --exports.see_attach:detachAll(localPlayer)
                    local playerDetector = detectors[localPlayer]
                    setElementAlpha(playerDetector, 0)
                    setPedAnimation(localPlayer, "bomber", "bom_plant")
                    setElementData(localPlayer, "inAnimPlayer", true)

                    local posX, posY, posZ = getElementPosition(activatedEntity)

                    tempObjectElement = createObject(groundFindID, posX, posY, posZ + 0.5)
                    setElementCollisionsEnabled(tempObjectElement, false)
                    setObjectScale(tempObjectElement, 0.5)

                    setElementData(activatedEntity, "alphaTick", getTickCount())
                    setElementData(activatedEntity, "secondState", true)
                end
            end
        end
    end
end
addEventHandler("onClientClick", getRootElement(), clickHoles)

local lastViewRotZ = 0
local viewRotInterpolation = false

addEventHandler("onClientPedsProcessed", root,
    function ()
        if getElementData(localPlayer, "char.metalDetectorInHand") and not getElementData(localPlayer, "inAnimPlayer") then
            local cameraX, cameraY, cameraZ, lookAtX, lookAtY, lookAtZ = getCameraMatrix()

            local pedRotZ = select(3, getElementRotation(localPlayer))
            local camRotZ = math.deg(math.atan2(lookAtX - cameraX, lookAtY - cameraY))
            local viewRot = pedRotZ + camRotZ

            if viewRot < -180 then
                viewRot = viewRot + 360
            elseif viewRot > 180 then
                viewRot = viewRot - 360
            end

            if viewRot < -45 then
                viewRot = -45
            elseif viewRot > 45 then
                viewRot = 45
            end

            if viewRot ~= lastViewRotZ then
                if not viewRotInterpolation then
                    viewRotInterpolation = {getTickCount(), lastViewRotZ}
                end

                if viewRotInterpolation then
                    local elapsedTime = getTickCount() - viewRotInterpolation[1]
                    local elapsedFraction = elapsedTime / 500

                    viewRotInterpolation[3] = interpolateBetween(viewRotInterpolation[2], 0, 0, viewRot, 0, 0, elapsedFraction, "Linear")

                    if elapsedFraction >= 1 then
                        lastViewRotZ = viewRot
                        viewRotInterpolation = false
                    end
                end
            end

            viewRot = viewRotInterpolation and viewRotInterpolation[3] or viewRot

            local pelvisRotZ, pelvisRotX, pelvisRotY = getElementBoneRotation(localPlayer, 2)
            local spineRotZ, spineRotX, spineRotY = getElementBoneRotation(localPlayer, 3)

            -- setElementBoneRotation(localPlayer, 2, pelvisRotZ - viewRot, pelvisRotX + 10 * math.abs(viewRot) / 45, pelvisRotY)
            setElementBoneRotation(localPlayer, 2, pelvisRotZ - viewRot / 2, pelvisRotX + 5, pelvisRotY)
            setElementBoneRotation(localPlayer, 3, spineRotZ - viewRot, spineRotX + 5, spineRotY)

            setElementBoneRotation(localPlayer, 22, 0, -100, -45) -- -6.5, -15, -73
            setElementBoneRotation(localPlayer, 23, 0, 0, 0) -- 0, -45, 0
            setElementBoneRotation(localPlayer, 24, 180, 0, 0) -- 96, 16, -8

            updateElementRpHAnim(localPlayer)

            --dxDrawText("viewRot " .. viewRot, 400, 200)
        end
    end
)

function getDistance(posX, posY, posZ)
    local playerX, playerY, playerZ = getElementPosition(localPlayer)

    if posX and posY and posZ then
        return getDistanceBetweenPoints3D(posX, posY, posZ, playerX, playerY, playerZ)
    end
end

function toggleDetector(state, player)
    if state then
        detectors[player] = createObject(detectorID, getElementPosition(player))
        setElementAlpha(detectors[player], 255)
        setElementCollisionsEnabled(detectors[player], false)
        setElementData(player, "player.Detector", detectors[player])
        --streamedPlayers[player] = true
        --attachElementToBone(element, ped, bone, x, y, z, rx, ry, rz)

      --  exports.see_boneattach:attachElementToBone(detectors[player], player, 11, 0, 0, 0, 0, 0, 0)
        exports.see_attach:attach(detectors[player], player, 23, 0.375, 0.0, -0.05, 180, 0, 0)

        if player == localPlayer then
            addEventHandler("onClientRender", getRootElement(), renderHoles)
            setElementData(player, "inAnimPlayer", false)

            exports.see_controls:toggleControl({"enter_passenger", "enter_exit", "fire", "jump", "sprint", "vehicle_fire"}, false)
        end
    else
        if isElement(detectors[player]) then
            destroyElement(detectors[player])
        end

        setElementData(player, "player.Detector", false)

        if player == localPlayer then
            setTimer(function()
                removeEventHandler("onClientRender", getRootElement(), renderHoles)
            end, 500, 1)
           setElementData(player, "inAnimPlayer", false)

            --exports.see_controls:toggleControl({"enter_passenger", "enter_exit", "fire", "jump", "sprint", "vehicle_fire"}, true)
        end
    end
end

addEventHandler("onClientElementDataChange", getRootElement(),
    function(theKey, oldValue, newValue)
        if theKey == "char.metalDetectorInHand" then
            if isElementStreamedIn(source) then
                if newValue then
                    toggleDetector(true, source)
                else
                    toggleDetector(false, source)
                end
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
    function()
        if getElementType(source) == "player" then
            if getElementData(source, "char.metalDetectorInHand") then
                toggleDetector(true, source)
            end
        end
    end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
    function()
        if getElementType(source) == "player" then
            if getElementData(source, "char.metalDetectorInHand") then
                toggleDetector(false, source)
            end
        end
    end
)

local objectPosition = {2737.2446289062, 1444.8699951172, 6.8850269317627 - 0.5}
local objectRotX = 0
local objectRotZ = 0
local objectElement = createObject(groundFindID, objectPosition[1], objectPosition[2], objectPosition[3], objectRotX, 0, objectRotZ)
setElementCollisionsEnabled(objectElement, false)
setObjectScale(objectElement, 0.5)

--local reflectionTexture = dxCreateTexture("files/tex/empty.dds")
local reflectionTexture = dxCreateTexture("files/tex/crate/1.dds")

local shaderElement = dxCreateShader("files/shader.fx")
dxSetShaderValue(shaderElement, "reflectionTexture", reflectionTexture)
dxSetShaderValue(shaderElement, "ObjectPos", objectPosition[1], objectPosition[2], objectPosition[3])

local objectRotRadX = math.rad(objectRotX)
local objectRotRadZ = math.rad(objectRotZ)

 -- felület Z iránya
dxSetShaderValue(shaderElement, "zcos", math.cos(objectRotRadZ))
dxSetShaderValue(shaderElement, "zsin", math.sin(objectRotRadZ))

 -- felület X iránya
dxSetShaderValue(shaderElement, "xcos", math.cos(objectRotRadX))
dxSetShaderValue(shaderElement, "xsin", math.sin(objectRotRadX))

-- gödör átmérője lenne minden bizonnyal
dxSetShaderValue(shaderElement, "radius", 0.77 / 2)

-- fogalmam sincs, hogy mi ez, a render kódban lehet tesztelni, hogy mit csinál
dxSetShaderValue(shaderElement, "zp", 1)


engineApplyShaderToWorldTexture(shaderElement, "turas", objectElement)



addEventHandler("onClientPreRender", root,
    function (dt)
        --dxSetShaderValue(shaderElement, "zp", 5 * math.abs(getTickCount() % 1000 - 500) / 500)
    end
)

function inSlot(x, y, width, height)
    if ( not isCursorShowing( ) ) then
        return false
    end
    local sx, sy = guiGetScreenSize ( )
    local cx, cy = getCursorPosition ( )
    local cx, cy = ( cx * sx ), ( cy * sy )
    
    return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end