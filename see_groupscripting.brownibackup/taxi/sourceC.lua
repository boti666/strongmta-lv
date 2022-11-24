--pcall(loadstring(base64Decode(exports.see_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.see_core:getInterfaceElements())));end)

local screenX, screenY = guiGetScreenSize()

local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(x)
    return x * responsiveMultipler
end

local taxiFactionID = 24

local currentSettingTab = 0
local maxSettingTab = 2

local taxiMeterSizeX, taxiMeterSizeY = respc(250), respc(120)

local taxiMeterPosX, taxiMeterPosY = screenX / 2 - taxiMeterSizeX / 2, screenY / 2 - taxiMeterSizeY / 2

local scrollOffsetY = 0

local windowOffsetX, windowOffsetY = 0, 0

local isPanelMove = false

local currentMiles = 0

local deltaTime = 10

local tripDistance = {}

local RalewayS = dxCreateFont("files/fonts/Roboto.ttf", respc(12), false)
local LcdFont = dxCreateFont("files/fonts/ocr.ttf", respc(12), false)

function renderTaxiMeter(deltaTime)
    local sourceVehicle = getPedOccupiedVehicle(localPlayer)

    if sourceVehicle and isElement(sourceVehicle) then
        buttonsC = {}

        if isCursorShowing() then
            cursorX, cursorY = getCursorPosition()
            cursorX, cursorY = cursorX * screenX, cursorY * screenY
        end

        if isPanelMove then
			taxiMeterPosX, taxiMeterPosY = cursorX + windowOffsetX, cursorY + windowOffsetY
		end

        dxDrawRectangle(taxiMeterPosX, taxiMeterPosY, taxiMeterSizeX, taxiMeterSizeY, tocolor(25, 25, 25))
        dxDrawRectangle(taxiMeterPosX + 3, taxiMeterPosY + 3, taxiMeterSizeX - 6, respc(30) - 3, tocolor(45, 45, 45, 180))
        dxDrawText("StrongMTA - Taxi", taxiMeterPosX + 3 + respc(5), taxiMeterPosY + 3 + (respc(30) - 3) / 2, nil, nil, tocolor(200, 200, 200, 200), 1, RalewayS, "left", "center")
            
        if checkTaxiLeader(localPlayer) then
            buttonsC["taxiSettings"] = {taxiMeterPosX + taxiMeterSizeX - respc(20) - 3, taxiMeterPosY + 3 + respc(5), respc(20) - 3, respc(20) - 3}
            dxDrawImage(taxiMeterPosX + taxiMeterSizeX - respc(20) - 3, taxiMeterPosY + 3 + respc(5), respc(20) - 3, respc(20) - 3, "files/images/settings.png", 0, 0, 0, tocolor(200, 200, 200, 200))
        end

        if settingsMenu then
            renderEditBoxes()

            if currentSettingTab == 0 then
                local taxiMeterPosY = scrollOffsetY + taxiMeterPosY
                local taxColor = {60, 60, 60, 40}

                if activeButtonC == "setVehicleTax" then
                    taxColor = {188, 64, 61, 140}
                end

                local minusColor = {60, 60, 60, 40}

                if activeButtonC == "minusCount" then
                    minusColor = {188, 64, 61, 140}
                end

                local plusColor = {60, 60, 60, 40}

                if activeButtonC == "plusCount" then
                    plusColor = {161, 210, 115}
                end

                if activeButtonC == "minusCount" then
                    if getKeyState("mouse1") then
                        if currentVehicleTax > 0 then
                            currentVehicleTax = currentVehicleTax - 1
                        end
                    end
                elseif activeButtonC == "plusCount" then
                    if getKeyState("mouse1") then
                        if currentVehicleTax < 100 then
                            currentVehicleTax = currentVehicleTax + 1
                        end
                    end
                end

                dxDrawRectangle(taxiMeterPosX + 5, taxiMeterPosY + respc(30) + respc(10), taxiMeterSizeX - 10, respc(30) + 6, tocolor(35, 35, 35, 200))
                dxDrawText(currentVehicleTax .. " %", taxiMeterPosX + 5 + 3 + (taxiMeterSizeX - 10) / 2, taxiMeterPosY + respc(30) + respc(10) + respc(30) / 2, nil, nil, tocolor(200, 200, 200, 200), 1, RalewayS, "center", "center")

                drawButton("minusCount", "-", taxiMeterPosX + 5 + 3, taxiMeterPosY + respc(30) + 3 + respc(10), respc(30), respc(30), minusColor, false, RalewayS, true)
                drawButton("plusCount", "+", taxiMeterPosX + 5 + 3 + respc(30) + 3, taxiMeterPosY + respc(30) + 3 + respc(10), respc(30), respc(30), plusColor, false, RalewayS, true)

                drawButton("setVehicleTax", "Beállítás", taxiMeterPosX + 5, taxiMeterPosY + taxiMeterSizeY - 5 - respc(30), taxiMeterSizeX - 10, respc(30), taxColor, false, RalewayS, true)

            elseif currentSettingTab == 1 then
                dxSetEditPosition("payTax", taxiMeterPosX + 5, taxiMeterPosY + respc(30) + respc(10) + 3)
                dxDrawRectangle(taxiMeterPosX + 5, taxiMeterPosY + respc(30) + respc(10) + 3, taxiMeterSizeX - 10 - respc(60) - 10, respc(30), tocolor(35, 35, 35, 200))
                taxColor = {60, 60, 60, 40}

                if activeButtonC == "setVehicleKmTax" then
                    taxColor = {188, 64, 61, 140}
                end

                drawButton("setVehicleKmTax", "Beállítás", taxiMeterPosX + 5, taxiMeterPosY + taxiMeterSizeY - 5 - respc(30), taxiMeterSizeX - 10, respc(30), taxColor, false, RalewayS, true)
            elseif currentSettingTab == 2 then
                local allTraveledMeter = getElementData(sourceVehicle, "veh.TaxiClockMeter") or 0

                zeroColor = {60, 60, 60, 40}

                if activeButtonC == "clockMoneyZero" then
                    zeroColor = {188, 64, 61, 140}
                end
                
                drawButton("clockMoneyZero", "Óra nullázása", taxiMeterPosX + 5, taxiMeterPosY + respc(30) + respc(10) + 3, taxiMeterSizeX - 10 - respc(60) - 10, respc(30), zeroColor, false, RalewayS, true)

                dxDrawText("Órával megtett távolság: " ..  string.format("%.1f", allTraveledMeter) .. " km", taxiMeterPosX + 5, taxiMeterPosY + taxiMeterSizeY - 5 - respc(30), nil, nil, tocolor(200, 200, 200, 200), 1, RalewayS)
            end

            local oldColor = {60, 60, 60, 40}

            if activeButtonC == "oldTab" then
                oldColor = {161, 210, 115}
            end

            local nextColor = {60, 60, 60, 40}

            if activeButtonC == "nextTab" then
                nextColor = {161, 210, 115}
            end

            drawButton("oldTab", "<", taxiMeterPosX + 5 + taxiMeterSizeX - 3 - 10 - respc(30) - respc(30) - 3, taxiMeterPosY + respc(30) + 3 + respc(10), respc(30), respc(30), oldColor, false, RalewayS, true)
            drawButton("nextTab", ">", taxiMeterPosX + 5 + taxiMeterSizeX - 3 - 10 - respc(30), taxiMeterPosY + respc(30) + 3 + respc(10), respc(30), respc(30), nextColor, false, RalewayS, true)
        else
            currentMiles = getElementData(sourceVehicle, "veh.traveledMeter") or 0

            if getElementData(sourceVehicle, "veh.TaxiClock") then
                handledDrawedText = "Leállítás"

                local vehicleSpeed = getVehicleSpeed(sourceVehicle)

                local vehicleDecimal = 1000
                local currentDistance = vehicleSpeed / 3600 / vehicleDecimal

                if not tripDistance[sourceVehicle] then
                    tripDistance[sourceVehicle] = 0
                end

                tripDistance[sourceVehicle] = tripDistance[sourceVehicle] + currentDistance
            else
                handledDrawedText = "Indítás"
            end

            local taxiMeterPrice = math.ceil(currentMiles)

            textWidth = dxGetTextWidth(taxiMeterPrice .. " $", 0.5, LcdFont)

            local currentVal = taxiMeterPrice

            local str = ""

            for i = 1, math.floor((respc(100) - textWidth) / dxGetTextWidth("0", 0.5, LcdFont)) + string.len(taxiMeterPrice) - utfLen(currentVal) do
                str = str .. "#c8c8c80"
            end

            if tonumber(currentVal) < 0 then
                currentVal = "#d75959" .. math.abs(currentVal)
            elseif tonumber(currentVal) > 0 then
                currentVal = "#3d7abc" .. math.abs(currentVal)
            else
                currentVal = 0
            end

            str = str .. currentVal .. " $"

            dxDrawText(str, taxiMeterPosX + taxiMeterSizeX / 2, taxiMeterPosY + taxiMeterSizeY / 2, nil, nil, tocolor(200, 200, 200, 200), 1, LcdFont, "center", "center", false, false, false, true)
            
            if checkTaxi(localPlayer) then
                local stopColor = {60, 60, 60, 40}

                if activeButtonC == "meterStop" then
                    stopColor = {188, 64, 61, 140}
                end
                
                drawButton("meterStop", handledDrawedText, taxiMeterPosX + 5, taxiMeterPosY + taxiMeterSizeY - 5 - respc(30), (taxiMeterSizeX - 10) / 2 - 2.5, respc(30), stopColor, false, RalewayS, true)
            
                local stopColor = {60, 60, 60, 40}

                if activeButtonC == "meterDouble" then
                    stopColor = {61, 122, 188, 140}
                end
                
                drawButton("meterDouble", "Duplázás", taxiMeterPosX + 5 + (taxiMeterSizeX - 10) / 2 + 2.5, taxiMeterPosY + taxiMeterSizeY - 5 - respc(30), (taxiMeterSizeX - 10) / 2 - 2.5, respc(30), stopColor, false, RalewayS, true)
            else
                local payColor = {60, 60, 60, 40}

                if activeButtonC == "payTaxi" then
                    payColor = {188, 64, 61, 140}
                end

                drawButton("payTaxi", "Kifizetés", taxiMeterPosX + 5, taxiMeterPosY + taxiMeterSizeY - 5 - respc(30), taxiMeterSizeX - 10, respc(30), payColor, false, RalewayS, true)
            end
        end

        local cx, cy = getCursorPosition()

        if tonumber(cx) and tonumber(cy) then
            cx = cx * screenX
            cy = cy * screenY

            activeButtonC = false

            if not buttonsC then
                return
            end
               
            for k,v in pairs(buttonsC) do
                if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
                    activeButtonC = k
                    break
                end
            end
        else
            activeButtonC = false
        end
    else

    end 
end

function toogleTaxiMeter(currentState)
    if currentState then

        addEventHandler("onClientRender", getRootElement(), renderTaxiMeter)

        addEventHandler("onClientKey", getRootElement(), editBoxesKey)
        addEventHandler("onClientCharacter", getRootElement(), editBoxesCharacter)
    else
    
        removeEventHandler("onClientRender", getRootElement(), renderTaxiMeter)

        removeEventHandler("onClientKey", getRootElement(), editBoxesKey)
        removeEventHandler("onClientCharacter", getRootElement(), editBoxesCharacter)
    end
end

addEventHandler("onClientElementDataChange", getRootElement(),
    function(theKey, oldValue, newValue)
        if theKey == "isVehicleInObject" then
            local playerVehicle = getPedOccupiedVehicle(localPlayer)

            if playerVehicle and playerVehicle == source then 
                if newValue then
                    toogleTaxiMeter(true)
                else 
                    toogleTaxiMeter(false)
                end
            end
        end
    end
)

addEventHandler("onClientVehicleEnter", getRootElement(),
    function(sourcePlayer)
        if sourcePlayer == localPlayer then
            if getElementData(source, "isVehicleInObject") then
                toogleTaxiMeter(true)
            end
        end
    end
)

addEventHandler("onClientVehicleExit", getRootElement(),
    function(sourcePlayer)
        if sourcePlayer == localPlayer then
            if getElementData(source, "isVehicleInObject") then
                toogleTaxiMeter(false)
            end
        end
    end
)

local trafficMeterShowState = true

function clickOnTaxiMeter(sourceKey, keyState, absX, absY)
    if sourceKey == "left"then
        if trafficMeterShowState then
            if absX >= taxiMeterPosX + 3 and absX <= taxiMeterPosX + 3 + taxiMeterSizeX - 6 - respc(25) - 3 and absY >= taxiMeterPosY + 3 and absY <= taxiMeterPosY + 3 + respc(30) - 3 then
				if keyState == "down" then
                    windowOffsetX, windowOffsetY = (taxiMeterPosX) - absX, (taxiMeterPosY) - absY

                    isPanelMove = true
                elseif keyState == "up" then
                    isPanelMove = false
                end
            end
        end

        local sourceVehicle = getPedOccupiedVehicle(localPlayer)

        if activeButtonC and keyState == "down"  then
            if activeButtonC == "meterStop" then
                if checkTaxi(localPlayer) then
                    if getElementData(sourceVehicle, "veh.TaxiClock") then
                        triggerServerEvent("stopTaxiClock", localPlayer, localPlayer, sourceVehicle, tripDistance[sourceVehicle])
                        
                        tripDistance[sourceVehicle] = 0
                    else
                        if getElementData(sourceVehicle, "veh.PayTax") then
                            taxiMessage("Nincs kifizetve a fuvar díja!")
                        else
                            triggerServerEvent("resetTaxiClock", localPlayer, localPlayer, sourceVehicle)
                            triggerServerEvent("startTaxiClock", localPlayer, localPlayer, sourceVehicle)
                        end
                    end
                end
            elseif activeButtonC == "meterDouble" then
                if checkTaxi(localPlayer) then
                    if getElementData(sourceVehicle, "veh.TaxiClock") then
                        taxiMessage("Előbb állísd le az órát!")
                    else
                        if getElementData(sourceVehicle, "veh.TaxiClockDouble") then
                            taxiMessage("Már dupláztad ezt a fuvart!")
                        else
                            setElementData(sourceVehicle, "veh.TaxiClockDouble", true)

                            local vehDistance = getElementData(sourceVehicle, "veh.traveledMeter") or 0

                            if vehDistance > 0 then
                                setElementData(sourceVehicle, "veh.traveledMeter", math.ceil(vehDistance * 2))
                            end
                        end
                    end
                end
            elseif activeButtonC == "taxiSettings" then
                settingsMenu = not settingsMenu

                if settingsMenu then
                    currentVehicleTax = getElementData(getPedOccupiedVehicle(localPlayer), "veh.TaxiPayTax") or 0
                    oldVehicleTax = currentVehicleTax
                else
                    currentVehicleTax = false
                    oldVehicleTax = false
                end
            elseif activeButtonC == "payTaxi" then
                local vehicleDriver = getVehicleController(sourceVehicle)

                if vehicleDriver then
                    if checkTaxi(vehicleDriver) then
                        local meterTax = getElementData(sourceVehicle, "veh.traveledMeter") or 0

                        if tonumber(meterTax) and meterTax > 0 then
                            triggerServerEvent("payTaxiPrice", localPlayer, localPlayer, sourceVehicle, vehicleDriver, currentMiles)
                        else
                            taxiMessage("Nincs mit kifizetni!")
                        end
                    else
                        taxiMessage("A jármű vezetője nem taxis!")
                    end
                else
                    taxiMessage("Nincs sofőr a járműben!")
                end
            elseif activeButtonC == "setVehicleTax" then
                if currentVehicleTax then
                    if oldVehicleTax ~= currentVehicleTax then
                        if oldVehicleTax > currentVehicleTax then
                            settingMessage = "csökkentetted"
                        else
                            settingMessage = "megemelted"
                        end
                        taxiMessage("A sofőr részesedését " .. settingMessage .. " ebben a járműben.")
                        triggerServerEvent("setTaxiVehicleTax", localPlayer, localPlayer, sourceVehicle, currentVehicleTax)

                        settingsMenu = false
                        
                        currentVehicleTax = false
                        oldVehicleTax = false
                    else
                        taxiMessage("A szorzó ugyan annyi mint volt!")
                    end
                end
            elseif activeButtonC == "oldTab" then
                if currentSettingTab > 0 then
                    
                    dxDestroyEdit("payTax")

                    currentSettingTab = currentSettingTab - 1

                    if currentSettingTab == 1 then
                        dxCreateEdit("payTax", "", "$ / km", taxiMeterPosX + 5, taxiMeterPosY + respc(30) + respc(10) + 3, taxiMeterSizeX - 10 - respc(60) - 10, respc(30), 11, 2)
                    end
                end
            elseif activeButtonC == "nextTab" then
                if currentSettingTab == maxSettingTab then
                    return
                end

                currentSettingTab = currentSettingTab + 1

                dxDestroyEdit("payTax")


                if currentSettingTab == 1 then
                    dxCreateEdit("payTax", "", "$ / km", taxiMeterPosX + 5, taxiMeterPosY + respc(30) + respc(10) + 3, taxiMeterSizeX - 10 - respc(60) - 10, respc(30), 11, 2)
                end
            elseif activeButtonC == "setVehicleKmTax" then
                if dxGetEditText("payTax") and tonumber(dxGetEditText("payTax")) > 0 and tonumber(dxGetEditText("payTax")) < 1000 then
                    taxiMessage("Sikeresen beállítottad a " .. dxGetEditText("payTax") .. "$ / km vételdíjat!")
                    triggerServerEvent("setTaxiMultiplier", localPlayer, localPlayer, sourceVehicle, tonumber(dxGetEditText("payTax")))
                    settingsMenu = false
                else
                    taxiMessage("A vételdíj 0 és 1000 dollár közt lehet!")
                end
            elseif activeButtonC == "clockMoneyZero" then
                triggerServerEvent("resetTaxiClock", localPlayer, localPlayer, sourceVehicle)
            end
        end
    end
end
addEventHandler("onClientClick", getRootElement(), clickOnTaxiMeter)

addCommandHandler("paytaxi",
    function(sourceCommand)
        local currentVehicle = getPedOccupiedVehicle(localPlayer)

        if currentVehicle and isElement(currentVehicle) then
            if checkTaxi(localPlayer) then
                if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    local meterTax = getElementData(currentVehicle, "veh.traveledMeter") or 0

                    if tonumber(meterTax) and meterTax > 0 then
                        triggerServerEvent("payTaxiPrice", localPlayer, localPlayer, currentVehicle, localPlayer, currentMiles)
                    end
                end
            end
        end
    end
)

function checkTaxi(sourcePlayer)
    if getPedOccupiedVehicleSeat(sourcePlayer) == 0 then
       return exports.see_groups:isPlayerInGroup(sourcePlayer, taxiFactionID)
    end
end

function checkTaxiLeader(sourcePlayer)
    return exports.see_groups:isPlayerLeaderInGroup(sourcePlayer, taxiFactionID) 
end

function taxiMessage(sourceMessage)
    outputChatBox("#DCA300[StrongMTA - Taxi]:#FFFFFF " .. sourceMessage, 255, 255, 255, true)
end

colorSwitches = {}
        lastColorSwitches = {}
        startColorSwitch = {}
        lastColorConcat = {}
        
        function processColorSwitchEffect(key, color, duration, type)
            if not colorSwitches[key] then
                if not color[4] then
                    color[4] = 255
                end
        
                colorSwitches[key] = color
                lastColorSwitches[key] = color
        
                lastColorConcat[key] = table.concat(color)
            end
        
            duration = duration or 3000
            type = type or "Linear"
        
            if lastColorConcat[key] ~= table.concat(color) then
                lastColorConcat[key] = table.concat(color)
                lastColorSwitches[key] = color
                startColorSwitch[key] = getTickCount()
            end
        
            if startColorSwitch[key] then
                local progress = (getTickCount() - startColorSwitch[key]) / duration
        
                local r, g, b = interpolateBetween(
                        colorSwitches[key][1], colorSwitches[key][2], colorSwitches[key][3],
                        color[1], color[2], color[3],
                        progress, type
                )
        
                local a = interpolateBetween(colorSwitches[key][4], 0, 0, color[4], 0, 0, progress, type)
        
                colorSwitches[key][1] = r
                colorSwitches[key][2] = g
                colorSwitches[key][3] = b
                colorSwitches[key][4] = a
        
                if progress >= 1 then
                    startColorSwitch[key] = false
                end
            end
        
            return colorSwitches[key][1], colorSwitches[key][2], colorSwitches[key][3], colorSwitches[key][4]
        end

        local alpha = 1
        
        function rgba(r, g, b, a)
            return tocolor(r, g, b, (a or 255) * alpha)
        end
        
        function drawButton(key, label, x, y, w, h, activeColor, postGui, theFont, rgbaoff, labelScale)
            local buttonColor
            if activeButtonC == key then
                buttonColor = {processColorSwitchEffect(key, {activeColor[1], activeColor[2], activeColor[3], 175})}
            else
                buttonColor = {processColorSwitchEffect(key, {60, 60, 60, 125})}
            end
        
            local alphaDifference = 175 - buttonColor[4]
        
            labelFont = theFont
            postGui = postGui or false
            labelScale = labelScale or 0.85
            rgbaoff = true
            
            if rgbaoff then
                dxDrawRectangle(x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference), postGui)
                dxDrawInnerBorder(2, x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 125 + alphaDifference), postGui)
                dxDrawText(label, x, y, x + w, y + h, tocolor(200, 200, 200, 200), labelScale, labelFont, "center", "center", false, false, postGui, true)
            else
                dxDrawRectangle(x, y, w, h, rgba(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference), postGui)
                dxDrawInnerBorder(2, x, y, w, h, rgba(buttonColor[1], buttonColor[2], buttonColor[3], 125 + alphaDifference), postGui)
                dxDrawText(label, x, y, x + w, y + h, rgba(200, 200, 200, 200), labelScale, labelFont, "center", "center", false, false, postGui, true)
            end
        
            buttonsC[key] = {x, y, w, h}
        end
        
        function dxDrawInnerBorder(thickness, x, y, w, h, color, postGUI)
            thickness = thickness or 1
            dxDrawRectangle(x, y, w, thickness, color, postGUI)
            dxDrawRectangle(x, y + h - thickness, w, thickness, color, postGUI)
            dxDrawRectangle(x, y, thickness, h, color, postGUI)
            dxDrawRectangle(x + w - thickness, y, thickness, h, color, postGUI)
        end

        -----------edit box----------------------

        local sx, sy = guiGetScreenSize()
        local screenX, screenY = guiGetScreenSize()
        local edits = {}

        local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

        function resp(value)
            return value * responsiveMultipler
        end

        function respc(value)
            return math.ceil(value * responsiveMultipler)
        end

        local RobotoL = dxCreateFont("files/fonts/Roboto.ttf", respc(15))



        function dxCreateEdit(name, text, defaultText, x, y, w, h, font, type)
            local id = #edits + 1
            edits[id] = {name, text, defaultText, x, y, w, h, font, type, false, 0, 0, 100, getTickCount()}
            return id
        end

        local numbers = {
            ["0"] = true,
            ["1"] = true,
            ["2"] = true,
            ["3"] = true,
            ["4"] = true,
            ["5"] = true,
            ["6"] = true,
            ["7"] = true,
            ["8"] = true,
            ["9"] = true,
        }
        
        function editBoxesKey(button, state)
            if button == "mouse1" and state and isCursorShowing() then
                for k, v in pairs(edits) do
                    local name, text, defaultText, x, y, w, h, font, type, active, tick = unpack(v)
                    if not active then
                        if isMouseInPosition(x, y, w, h) then
                            edits[k][10] = true
                            edits[k][11] = getTickCount()
                        end
                    else
                        edits[k][10] = false
                        edits[k][11] = getTickCount()
                    end
                end
            end
        
            if button == "tab" and state and isCursorShowing() then
                if dxGetActiveEdit() then
                    local nextGUI = dxGetActiveEdit()+1
                    if edits[nextGUI] then
                        local current = dxGetActiveEdit()
                        edits[current][10] = false
                        edits[current][11] = getTickCount()
        
                        edits[nextGUI][10] = true
                        edits[nextGUI][11] = getTickCount()
                    else
                        local current = dxGetActiveEdit()
                        edits[current][10] = false
                        edits[current][11] = getTickCount()
        
                        edits[1][10] = true
                        edits[1][11] = getTickCount()
                    end
                end
                cancelEvent()
            end
        
            for k, v in pairs(edits) do
                local name, text, defaultText, x, y, w, h, font, type, active, tick, w2 = unpack(v)
                if active then
                    if not getKeyState("v") and not getKeyState("lctrl") then
                        cancelEvent()
                    end
                end
            end
        end
        
        function editBoxesCharacter(key)
            if isCursorShowing() then
                for k, v in pairs(edits) do
                    local name, text, defaultText, x, y, w, h, font, type, active, tick, w2 = unpack(v)
                    if active then
                        if type == 2 then
                            if numbers[key] then  
                                edits[k][2] = edits[k][2] .. key
                            end
                        else
                            edits[k][2] = edits[k][2] .. key
                        end
                    end
                end
            end
        end
        
        function isMouseInPosition(x, y, w, h)
            if not isCursorShowing() then 
                return 
            end
            local pos = {getCursorPosition()}
            pos[1], pos[2] = (pos[1] * sx), (pos[2] * sy)
            if pos[1] >= x and pos[1] <= (x + w) and pos[2] >= y and pos[2] <= (y + h) then
                return true
            else
                return false
            end
        end
        
        function dxGetActiveEditName()
            local a = false
            for k, v in pairs(edits) do
                local name, text, defaultText, x, y, w, h, font, type, active, tick, w2 = unpack(v)
                if active then
                    a = name
                    break
                end
            end
            return a
        end
        
        function dxGetActiveEdit()
            local a = false
            for k, v in pairs(edits) do
                local name, text, defaultText, x, y, w, h, font, type, active, tick, w2 = unpack(v)
                if active then
                    a = k
                    break
                end
            end
            return a
        end
        
        function dxDestroyEdit(id)
            if tonumber(id) then
                if not edits[id] then return false end
                table.remove(edits, id)
                return true
            else
                local edit = dxGetEdit(id)
                if not edits[edit] then 
                    return false 
                end
                table.remove(edits, edit)
                return true
            end
        end
        
        function dxEditSetText(id, text)
            if tonumber(id) then
                if not edits[id] then 
                    error("Not valid editbox") 
                    return false 
                end
        
                edits[id][2] = text
                return true
            else
                local edit = dxGetEdit(id)
                if not edits[edit] then 
                    error("Not valid editbox") 
                    return false 
                end
                edits[edit][2] = text
                return true
            end
        end
        
        function dxGetEdit(name)
            local found = false
            for k, v in pairs(edits) do
                if v[1] == name then
                    found = k
                    break
                end
            end
            return found
        end
        
        function dxGetEditText(id)
            if tonumber(id) then
                if not edits[id] then error("Not valid editbox") return false end
                return edits[id][2]
            else
                local edit = dxGetEdit(id)
                if not edits[edit] then error("Not valid editbox") return false end
                return edits[edit][2]
            end
        end
        
        function dxSetEditPosition(id, x, y)
            if tonumber(id) then
                if not edits[id] then error("Not valid editbox") return false end
                edits[id][4] = x
                edits[id][5] = y
                return true
            else
                local edit = dxGetEdit(id)
                if not edits[edit] then error("Not valid editbox") return false end
                edits[edit][4] = x
                edits[edit][5] = y
                return true
            end
        end
        
        function isMouseInPosition(x, y, w, h)
            if not isCursorShowing() then return end
            local pos = {getCursorPosition()}
            pos[1], pos[2] = (pos[1] * screenX), (pos[2] * screenY)
            if pos[1] >= x and pos[1] <= (x + w) and pos[2] >= y and pos[2] <= (y + h) then
                return true
            else
                return false
            end
        end

        function renderEditBoxes()
            for k, v in pairs(edits) do
                local name, text, defaultText, x, y, w, h, font, type, active, tick, w2, backState, tickBack = unpack(v)
                local textWidth = dxGetTextWidth(text, 0.7, RobotoL, false) or 0
                dxDrawRectangle(x, y, w, h, tocolor(55, 55, 55, 120), true)
                dxDrawInnerBorder(2, x, y, w, h, tocolor(55, 55, 55, 200), true)
                if active then
                    edits[k][12] = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount()-tick)/200, "Linear")
                    dxDrawRectangle(x, y + h - 2, w * w2, 2, tocolor(61, 122, 188), true)
        
                    local carretAlpha = interpolateBetween(50, 0, 0, 255, 0, 0, (getTickCount()-tick)/1000, "SineCurve")
                    local carretSize = dxGetFontHeight(0.7, RobotoL)*2.4
                    local carretPosX = textWidth > (w-10) and x + w - 10 or x + textWidth + 5
                    dxDrawRectangle(carretPosX + 2, y + 2.5, 2, h - 5, tocolor(200, 200, 200, carretAlpha), true)
        
                    if getKeyState("backspace") then
                        backState = backState - 1
                    else
                        backState = 100
                    end
                    if getKeyState("backspace") and (getTickCount() - tickBack) > backState then
                        edits[k][2] = string.sub(text, 1, #text - 1)
                        edits[k][14] = getTickCount()
                    end
                else
                    if w2 > 0 then
                        edits[k][12] = interpolateBetween(edits[k][12], 0, 0, 0, 0, 0, (getTickCount()-tick)/200, "Linear")
                        dxDrawRectangle(x, y + h - 2, w * w2, 2, tocolor(61, 122, 188), true)
                    end
                end
        
                if string.len(text) == 0 or textWidth == 0 then
                    dxDrawText(defaultText, x+5, y, w, y+h, tocolor(255, 255, 255, 120), 0.7, RobotoL, "left", "center", false, false, true)
                else
                    if w > textWidth then
                        dxDrawText(text, x+5, y, w, y+h, tocolor(200, 200, 200), 0.7, RobotoL, "left", "center", false, false, true)
                    else
                        dxDrawText(text, x+5, y, x+w-5, y+h, tocolor(200, 200, 200), 0.7, RobotoL, "right", "center", true, false, true)
                    end
                end
            end
        end


        function drawStrongPanelBottomExit(x, y, h, w, font, buttonFontScale)

            dxDrawRectangle(x, y, h, w, tocolor(25, 25, 25))
            dxDrawRectangle(x + 3, y + 3, h - 6, respc(40) - 6, tocolor(55, 55, 55, 200))
            dxDrawText("StrongMTA", x + respc(5), y + respc(40) / 2, nil, nil, tocolor(200, 200, 200, 200), 1, font, "left", "center")

            drawButton("exitFromPanel", "Kilépés", x + 3, y + w - respc(40), h - 6, respc(40) - 3, {188, 64, 61}, false, font, true, buttonFontScale)
        end