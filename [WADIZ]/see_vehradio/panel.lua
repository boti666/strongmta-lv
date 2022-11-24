local awesome = dxCreateFont("files/FontAwesome.ttf", 22)

local x, y, w, h = sx/2 - 225, sy/2 - 125, 450, 175

function reMap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

function respc(value)
	return math.ceil(value * reMap(sx,1024,1920,0.75,1))
end

local selectedType = "FM"
onVolumeChange = false

local ytPattern = "youtube\.com.+v=(...........)"


render = function()
    if not isPedInVehicle(localPlayer) then return hidePanel() end

    local radio   = radios[panelOpened]
    local stream  = inStreamRadios[panelOpened]
    local playing = stream and selectedType == radios[panelOpened].type
    local volume  = onVolumeChange or getRadioVolume(panelOpened)

    local extraH  = selectedType == "FM" and 0 or 0 

    rectangle(x, y, w, h+extraH,  tocolor(25, 25, 25)) -- background
    rectangle(x+3, y+3, w-6, 30-6, tocolor(35, 35, 35)) -- header

    rectangle(x, y+h+extraH+4, w, 40, tocolor(25, 25, 25)) -- volume background
    rectangle(x+3, y+h+extraH+4+3, (w-6)*volume, 34, tocolor(61, 122, 188, 150)) -- volume level

    if radio and isCursorShowing() and onVolumeChange then
        local cx = getCursorPosition()
        local percentage = (sx_*cx - (x)*xm) / ((w)*xm)
        onVolumeChange = math.max(0, math.min(1, percentage))
    end


    local active = isInZone(x+w/2-120, y+90, 110, 20)
    text("Rádió", x+w/2-120, y+90, x+w/2-10, y+110, (active or selectedType == "FM") and 0xffaaaaaa or 0xff888888, 0.6, awesome, "center", "center") -- type FM

    local active = isInZone(x+w/2+10, y+90, 110, 20)
    text("YouTube",  x+w/2+10, y+90, x+w/2+120, y+110, (active or selectedType == "YT") and 0xffaaaaaa or 0xff888888, 0.6, awesome, "center", "center") -- type YT
    text("#3d7abcStrong#ffffffMTA", x+10, y, x+w-20, y+30, 0xeeffffff, 0.5, awesome, "center", "center", true, false, false, true) -- radio station name

    if selectedType == "FM" then
        local title = playing and SETTINGS.STATIONS[radio.path][1] or "RÁDIÓ"
        text(title, x+10, y+40, x+w-20, y+40+30, 0xeeffffff, 0.5, awesome, "center", "center", true) -- radio station name

        local active = isInZone(x+w/2-25, y+120, 50, 40)
        text(playing and "" or "", x+w/2-25, y+120, x+w/2+25, y+160, active and 0xffaaaaaa or 0xff888888, 0.9, awesome, "center", "center") -- FM start / pause

        if playing then
            local active = isInZone(x+w/2-75, y+120, 50, 40)
            text("", x+w/2-75, y+120, x+w/2-25, y+160, active and 0xffaaaaaa or 0xff888888, 0.9, awesome, "center", "center") -- left
    
            local active = isInZone(x+w/2+25, y+120, 50, 40)
            text("", x+w/2+25, y+120, x+w/2+75, y+160, active and 0xffaaaaaa or 0xff888888, 0.9, awesome, "center", "center") -- right
        end

    elseif selectedType == "YT" then
        text("YOUTUBE", x+10, y+30, x+w-20, y+30+30, 0xeeffffff, 0.5, awesome, "center", "center", true) -- radio station name

        rectangle(x+20, y+120, w-40, 40, 0xb4353535) -- input background
        text("", x+30, y+120, x+30, y+160, 0xb4888888, 0.8, awesome, "left", "center") -- YT icon

        local active = isInZone(x+w-60, y+120, 50, 40)
        text(playing and "" or "", x+w-30, y+120, x+w-30, y+160, active and 0xffaaaaaa or 0xff888888, 0.8, awesome, "right", "center") -- YT start / pause

        local link  = guiGetText(input)
        local width = dxGetTextWidth(link, 0.7, awesome)
        local align = width >= w-120 and "right" or "left"
        local correct = link:match(ytPattern);
        text(link == "" and "Link . . ." or link, x+60, y+120, x+w-60, y+160, correct and 0xb47fb863 or 0xb4888888, 0.65, awesome, align, "center", true) -- YT link input
    end
end

clickSound = function() playSound("files/click.wav") end

onClick = function(button, state)
    if button == "left" and state == "down" then
        local extraH  = selectedType == "FM" and 0 or 0 
        local volume  = onVolumeChange or getRadioVolume(panelOpened)
        if isInZone(x+3, y+h+extraH+4+3, w-6, 34) then -- volume level
            onVolumeChange = getRadioVolume(panelOpened)
            --return clickSound()
        end

    elseif button == "left" and state == "up" then
        local radio   = radios[panelOpened]
        local stream  = inStreamRadios[panelOpened]
        local playing = stream and selectedType == radios[panelOpened].type


        if onVolumeChange then
            if radio then
                setElementData(panelOpened, "radio:volume", onVolumeChange)
            end
            onVolumeChange = false
            return
        end

        if isInZone(x+w/2-120, y+90, 110, 20) then -- switch to FM
            selectedType = "FM"
            --return clickSound()
        elseif isInZone(x+w/2+10, y+90, 110, 20) then -- switch to YT
            if getElementData(getPedOccupiedVehicle(localPlayer), "tuning.radio") then
                selectedType = "YT"
            else
                outputChatBox("Nincs beszerelve!")
            end
        end


        if selectedType == "FM" then
            if isInZone(x+w/2-25, y+120, 50, 40) then -- FM start / pause
                if playing then
                    triggerServerEvent("onDisableRadio", panelOpened)
                else
                    triggerServerEvent("onEnableRadio", panelOpened, selectedType, 1)
                end
               -- return clickSound()

            elseif isInZone(x+w/2-75, y+120, 50, 40) then -- left
                local next = radio.path - 1
                if next < 1 then next = #SETTINGS.STATIONS end
               -- clickSound()
                return triggerServerEvent("onEnableRadio", panelOpened, selectedType, next)
                
            elseif isInZone(x+w/2+25, y+120, 50, 40) then -- right
                local next = radio.path + 1
                if next > #SETTINGS.STATIONS then next = 1 end
              --  clickSound()
                return triggerServerEvent("onEnableRadio", panelOpened, selectedType, next)
            end
        
        elseif selectedType == "YT" then
            if isInZone(x+w-60, y+120, 50, 40) then -- YT start / pause
                if playing then
                    triggerServerEvent("onDisableRadio", panelOpened)
                else
                    local link = guiGetText(input)
                    local id   = link:match(ytPattern)
                    if link and id then
                        triggerServerEvent("onEnableRadio", panelOpened, selectedType, id)
                    end
                end
                --return clickSound()

            elseif isInZone(x+60, y+120, w-120, 40) then -- input
                guiSetText(input, "")
                guiFocus(input)
                --return clickSound()
            end
        end
    end
end


showPanel = function()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        addEventHandler("onClientRender",            root,        render)
        addEventHandler("onClientClick",             root,        onClick)
        addEventHandler("onClientPlayerVehicleExit", localPlayer, hidePanel)
        
        panelOpened = vehicle
        input       = guiCreateEdit(0, 0, 0, 0, "", false)
    end
end

hidePanel = function()
    removeEventHandler("onClientRender",            root,        render)
    removeEventHandler("onClientClick",             root,        onClick)
    removeEventHandler("onClientPlayerVehicleExit", localPlayer, hidePanel)
    destroyElement(input)
    panelOpened = false
end