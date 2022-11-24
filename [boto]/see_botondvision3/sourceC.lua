screenX,screenY = guiGetScreenSize()
screenSource = dxCreateScreenSource(screenX,screenY)
maxPosChange = 30

startDrugCounter = 0
drugCounter = 0
drugTrick = 0
alphaTick = 0;

isDrugged = false

playerSkinThing = {}
haluPedTable = {}
disallowedSkins = {
    "280",
}

screenMoverXOLD = 0
screenMoverYOLD = 0
screenMoverX = 0
screenMoverY = 0

local abrilkod = true

addEvent("nigokod", true)
addEventHandler("nigokod", getRootElement(),
    function ()
        if abrilkod then 
            print("elsö scriptem : )")
        end
    end 
)

local colorTable1 = {math.random(30, 200),math.random(0, 125),math.random(130, 255)}
local colorTable2 = {math.random(30, 200),math.random(0, 125),math.random(130, 255)}
local colorTable3 = {math.random(30, 200),math.random(0, 125),math.random(130, 255)}
        local drugTick = 0
        currentTick = getTickCount()
        local progress = (currentTick - drugTick) / 2000
        local RGBcolor1, RGBcolor2, RGBcolor3 = interpolateBetween(colorTable1[1], colorTable1[2], colorTable1[3], colorTable1[1], colorTable1[2], colorTable1[3], progress, "Linear")
        local RGB2color1, RGB2color2, RGB2color3 = interpolateBetween(colorTable2[1], colorTable2[2], colorTable2[3], colorTable2[1], colorTable2[2], colorTable2[3], progress, "Linear")

addEventHandler("onClientHUDRender", root, function()
    if isDrugged then
        if drugCounter ~= startDrugCounter then
            strenghtLevel = interpolateBetween(startDrugCounter, 0, 0, drugCounter, 0, 0, (getTickCount() - alphaTick) / 60000, "Linear")
        end

        alphaStrength = strenghtLevel / 15

        moverX = interpolateBetween(screenMoverXOLD, 0, 0, screenMoverX, 0, 0, progress, "Linear")
        moverY = interpolateBetween(screenMoverYOLD, 0, 0, screenMoverY, 0, 0, progress, "Linear")

        if progress > 1 then

            screenMoverXOLD = screenMoverX

            if screenMoverX > maxPosChange then
                screenMoverX = math.random(0, maxPosChange)
            else
                screenMoverX = math.random(maxPosChange, maxPosChange * 2)
            end

            screenMoverYOLD = screenMoverY

            if screenMoverY > maxPosChange then
                screenMoverY = math.random(0, maxPosChange)
            else
                screenMoverY = math.random(maxPosChange, maxPosChange * 2)
            end

            colorTable1 = {math.random(30, 200),math.random(0, 125),math.random(130, 255)}
            colorTable2 = {math.random(30, 200),math.random(0, 125),math.random(130, 255)}
            colorTable3 = {math.random(30, 200),math.random(0, 125),math.random(130, 255)}
        end

        if screenSource then
            dxUpdateScreenSource(screenSource)
            dxDrawImage(0, 0, screenX, screenY, screenSource, 0, 0, 0, tocolor(RGB2color1, RGB2color2, RGB2color3, 255 * alphaStrength))
            dxDrawImage(-moverX, -moverX, screenX + maxPosChange * 2, screenY + maxPosChange * 2, screenSource, 0, 0, 0, tocolor(RGBcolor1, RGBcolor2, RGBcolor3, 100 * alphaStrength))
            dxDrawImage(-moverY, -moverY, screenX + maxPosChange * 2, screenY + maxPosChange * 2, screenSource, 0, 0, 0, tocolor(RGB2color1, RGB2color2, RGB2color3, 100 * alphaStrength))
        end
    end
end)

function skinThing()
    if isDrugged then
        for k, v in ipairs(getElementsByType("player"), getRootElement(), true) do
            randomSkin = math.random(1, 312)

            if not tonumber(playerSkinThing[v]) then
                playerSkinThing[v] = getElementModel(v)
            end
            if not disallowedSkins[randomSkin] then
                setElementModel(v, randomSkin)
            end
        end
        setTimer(skinThing, math.random(10, 15) * 1000, 1)
    end
end

function haluPedMaking()
    if isDrugged then
        for k, v in pairs(haluPedTable) do
            if isElement(v) then
                destroyElement(v)
            end
        end

        for i = 1, 10 do

            local skin = math.random(1,312)

            if disallowedSkins[skin] then
                skin = 87
            end


            local x,y,z = getElementPosition(localPlayer)
            haluPed = createPed(skin, x + math.random(-10000, 10000) / 1000, y + math.random(-10000, 10000) / 1000, z,0,0,math.random(0,360))

            if isElement(haluPed) then
                setElementCollisionsEnabled(haluPed, false)
                table.insert(haluPedTable, haluPed)
            end
        end
        setTimer(haluPedMaking, math.random(5, 10) * 1000, 1)
    end
end

addEvent("vortyvision3_enable", true)
addEventHandler("vortyvision3_enable", localPlayer, function(drugTimer, drugLevel)
    drugLevel = math.max(5, drugLevel)
    startDrugCounter = drugCounter
    drugCounter = drugCounter + drugLevel

    drugTick = getTickCount()

    if 15 <= drugCounter then
        drugCounter = 15
    end

    setElementData(localPlayer, "drugEffect", "3;" .. drugCounter)

    if 7 <= drugCounter and not isDrugged then
        skinThing()
        haluPedMaking()
    end

    isDrugged = true
end)

setTimer(function()
    if 0 < drugCounter and drugCounter and alphaTick + 60000 <= getTickCount() then
        startDrugCounter = drugCounter
        drugCounter = drugCounter - 1

        alphaTick = getTickCount()

        setElementData(localPlayer, "drugEffect", "3;" .. drugCounter)
        if drugCounter <= 0 then
            isDrugged = false

            setElementData(localPlayer, "drugEffect", "")

            for k, v in ipairs(getElementsByType("player")) do
                if playerSkinThing[v] then
                  setElementModel(v, playerSkinThing[v])
                  playerSkinThing[v] = false
                end
            end

            for k, v in ipairs(haluPedTable) do
                if isElement(v) then
                  destroyElement(v)
                end
            end
        end
    end
end, 60000, 0)

addEvent("vortyvision3_disable", true)
addEventHandler("vortyvision3_disable", localPlayer, function()
    isDrugged = false
end)
