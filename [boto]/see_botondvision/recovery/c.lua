local screenX,screenY = guiGetScreenSize()
local screenSource = dxCreateScreenSource(screenX,screenY)

function screenSourceUpdate()
    dxUpdateScreenSource(screenSource)
    if screenSource then
        setTimer(screenSourceUpdate, math.random(100, 200), 1)
    end
end

addEventHandler("onClientHUDRender", root, function()
    if screenSource then
        if isDrugged then

            local numberRandom = math.random(1,10)
            local numberRandom2 = math.random(5,15)

            if numberRandom == 5 then
                dxUpdateScreenSource(screenSource)
            end

            dxDrawImage(-numberRandom2, -numberRandom2, screenX + numberRandom2 * 2, screenY + numberRandom2 * 2, screenSource, 0, 0, 0)
        end

        if isDrugged then

            local numberRandom3 = math.random(25,30)
            local randomColor1 = math.random(150,255)
            local randomColor2 = math.random(150,200)

            dxDrawImage(-numberRandom3, -numberRandom3, screenX + numberRandom3 * 2, screenY + numberRandom3 * 2, screenSource, 0, 0, 0, tocolor(255, randomColor1, 255, randomColor2))
        end

        if isDrugged then

            local numberRandom4 = math.random(40,80)

            dxUpdateScreenSource(screenSource)
            dxDrawImage(0, 0, screenX, screenY, screenSource, 0, 0, 0, tocolor(255, 255, 255, numberRandom4))
        end
    end
end)

addEvent("vortyvision1_enable", true)
addEventHandler("vortyvision1_enable", localPlayer, function(drugTime)
    isDrugged = true
    screenSourceUpdate()

    setTimer(function()
        isDrugged = false
    end, drugTime, 1)
end)

addEvent("vortyvision1_disable", true)
addEventHandler("vortyvision1_disable", localPlayer, function()
    isDrugged = false
end)

