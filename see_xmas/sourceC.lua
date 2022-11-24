local renderTarget = dxCreateRenderTarget(512, 288)
local shaderElement = dxCreateShader("texturechanger.fx")
local Roboto = dxCreateFont("Roboto.ttf", 30, false, "antialiased")

addEventHandler("onClientResourceStart", resourceRoot, 
    function ()
        createdObject = createObject(3053, 2363.2, 2143.3999, 9.3, 0, 180, 0)
        createObject(2789, 2349.7048339844, 2138.37109375, 10.680848121643)
        
        reCreateObject = createObject(11292, 2363.2, 2143.3999, 8.8, 0, 0, 90)
        setObjectScale(createdObject, 4)
        setElementAlpha(reCreateObject, 0)
        setElementCollisionsEnabled(reCreateObject, false)
        
        createdVehicle = createVehicle(445, 2363.2, 2143.3999, 11)
        attachElements(createdVehicle, createdObject, 0, 0, -1.7, 0, 180, 0)
        setVehicleColor(createdVehicle, 4, 38, 18, 255, 255, 255)
        setVehicleOverrideLights(createdVehicle, 2)
        setElementCollisionsEnabled(createdVehicle, false)

        createdSound = playSound3D("https://www.internet-radio.com/servers/tools/playlistgenerator/?u=http://46.105.118.14:24000/listen.pls&t=.m3u", 2366.43628, 2143.21069, 10.7308)
        setSoundMaxDistance(createdSound, 200)

        if isElement(renderTarget) then
            if isElement(shaderElement) then
                dxSetShaderValue(shaderElement, "gTexture", renderTarget)
                engineApplyShaderToWorldTexture(shaderElement, "cj_airp_s_1")
            end
        end
        renderTheBoard()
    end 
)

function dxDrawBorderText(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_12_, _ARG_13_)
  dxDrawText(string.gsub(_ARG_0_, "#......", ""), _ARG_1_ - 1, _ARG_2_ - 1, _ARG_3_ - 1, _ARG_4_ - 1, tocolor(0, 0, 0), _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_12_, _ARG_13_, true)
  dxDrawText(string.gsub(_ARG_0_, "#......", ""), _ARG_1_ - 1, _ARG_2_ + 1, _ARG_3_ - 1, _ARG_4_ + 1, tocolor(0, 0, 0), _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_12_, _ARG_13_, true)
  dxDrawText(string.gsub(_ARG_0_, "#......", ""), _ARG_1_ + 1, _ARG_2_ - 1, _ARG_3_ + 1, _ARG_4_ - 1, tocolor(0, 0, 0), _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_12_, _ARG_13_, true)
  dxDrawText(string.gsub(_ARG_0_, "#......", ""), _ARG_1_ + 1, _ARG_2_ + 1, _ARG_3_ + 1, _ARG_4_ + 1, tocolor(0, 0, 0), _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_12_, _ARG_13_, true)
  dxDrawText(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_12_, _ARG_13_, true)
end

function renderTheBoard()
    if renderTarget then 
        dxSetRenderTarget(renderTarget)
        dxDrawRectangle(0, 0, 512, 288, tocolor(0, 0, 0))
        dxDrawImage(0, 0, 512, 288, "bcg.jpg", 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawBorderText("Hamarosan nyereményjáték!", 0, 0, 512, 288, tocolor(255, 255, 255), 0.9, Roboto, "center", "center")
        dxDrawImage(0, 0, 512, 288, "screen.png", 0, 0, 0, tocolor(255, 255, 255, 100))
        dxSetRenderTarget()
    end
end

addCommandHandler("tombolasorsol", 
    function (arg0, number)
        if getElementData(localPlayer, "acc.adminLevel") >= 9 then 
            setElementData(resourceRoot, "winnerNum", tonumber(number) or 0)
        end
    end 
)

local snowTexture = dxCreateTexture("xcross.png")

local startX, startY, startZ = 2350.001953125, 2142.400390625, 9.75
local _UPVALUE0_ = 9.85
local sizeToRemove = 25

addEventHandler("onClientRender", getRootElement(),
    function ()
        local currentTick = getTickCount()

        dxDrawMaterialLine3D(startX - sizeToRemove, startY, startZ, startX + sizeToRemove, startY, _UPVALUE0_, snowTexture, sizeToRemove * 2, tocolor(255, 255, 255), startX, startY, startZ)

        setElementRotation(createdObject, 0, 180, currentTick / 100)
    end 
)

function shuffleTable(selectedTable)
    for i = #selectedTable, 2, -1 do 
        selectedTable[i], selectedTable[math.random(i)] = selectedTable[math.random(i)], selectedTable[i]
    end
    return selectedTable
end

--[[function markerAlpha(alpha)
    for i = 1, #createdMarkers do 
        setMarkerColor(createdMarkers[i], 255, 255, 255, i % 2 == alpha and 255 or 0)
    end
    alpha = alpha + 1

    if alpha >= 2 then 
        alpha = 0 
    end
    setTimer(markerAlpha, 400, 1, alpha)
end
markerAlpha(1)]]

addEvent("polgiXmasSpeech", true)
addEventHandler("polgiXmasSpeech", getRootElement(), 
    function()
        attachElements(playSound3D("text.mp3", getElementPosition(source)), source)
        setSoundMaxDistance(playSound3D("text.mp3", getElementPosition(source)), 100)
    end
)