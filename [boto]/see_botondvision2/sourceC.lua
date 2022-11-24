screenX,screenY = guiGetScreenSize()
screenSource = dxCreateScreenSource(screenX,screenY)

local colorTable = {math.random(30, 255),math.random(100, 255),math.random(0, 255)}
local colorTable2 = {math.random(30, 255),math.random(100, 255),math.random(0, 255)}

addEventHandler("onClientHUDRender", root, function()
    if isDrugged then
        drugTick = getTickCount()
        currentTick = getTickCount()

        local progress = (currentTick - drugTick) / 250

        RGBcolor1, RGBcolor2, RGBcolor3 = interpolateBetween(colorTable[1], colorTable[2], colorTable[3], colorTable[1], colorTable[2], colorTable[3], progress, "Linear")
        RGB2color1, RGB2color2, RGB2color3 = interpolateBetween(colorTable2[1], colorTable2[2], colorTable2[3], colorTable2[1], colorTable2[2], colorTable2[3], progress, "Linear")

        if progress > 1 then
            currentTick = getTickCount()
            colorTable = {math.random(30, 255),math.random(100, 255),math.random(0, 255)}
            colorTable2 = {math.random(30, 255),math.random(100, 255),math.random(0, 255)}
        end

        if screenSource then
            dxUpdateScreenSource(screenSource)
            dxDrawImage(0, 0, screenX, screenY, screenSource, 0, 0, 0, tocolor(RGB2color1, RGB2color2, RGB2color3, 255))
            dxDrawImage(-200, 0, screenX + 100, screenY, screenSource, 0, 0, 0, tocolor(RGBcolor1, RGBcolor2, RGBcolor3, 100))
            dxDrawImage(-100, 0, screenX + 100, screenY, screenSource, 0, 0, 0, tocolor(RGB2color1, RGB2color2, RGB2color3, 100))
            dxDrawImage(100, 0, screenX + 100, screenY, screenSource, 0, 0, 0, tocolor(RGB2color1, RGB2color2, RGB2color3, 100))
            dxDrawImage(200, 0, screenX + 100, screenY, screenSource, 0, 0, 0, tocolor(RGB2color1, RGB2color2, RGB2color3, 100))
        end
    end
end)

addEvent("vortyvision2_enable", true)
addEventHandler("vortyvision2_enable", localPlayer, function(drugTime)
    isDrugged = true
    setTimer(function()
        isDrugged = false
    end, drugTime, 1)
end)

addEvent("vortyvision2_disable", true)
addEventHandler("vortyvision2_disable", localPlayer, function()
    isDrugged = false
end)
