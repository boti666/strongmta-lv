local screenX, screenY = guiGetScreenSize()
local datas = {}
local lastDelete = 0
local selectedChat = false
local panelState = false
local crossStatus = false
local openedMessages = {}

local panelIsMoving = false
local moveDifferenceX = 0
local moveDifferenceY = 0

addEvent("onClientGotDatas", true)
addEventHandler("onClientGotDatas", getRootElement(),
    function(newData)
        datas = newData
    end
)

local chatInput = guiCreateEdit(-10000, -10000, 100, 100, "", true)

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

local responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local panelW, panelH = respc(880), respc(530) 
local panelStart = {screenX/2 - panelW/2, screenY/2 - panelH/2}

local Raleway12 = dxCreateFont("files/Roboto.ttf", respc(10), false, "antialiased")
local Raleway14 = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")

function drawButton(key, text, x, y, w, h)
    if activeButton == key then
        alpha = 255
    else
        alpha = 220
    end
    dxDrawRectangle(x, y, w, h, tocolor(61, 122, 188, alpha or 220))
    dxDrawText(text, x, y, x + w, y + h, tocolor(255, 255, 255), 1, Raleway12, "center", "center")
    buttonsC[key] = {x, y, w, h}
end

function drawButton2(key, text, x, y, w, h)
    if activeButton == key then
        alpha = 0
    else
        alpha = 0
    end
    dxDrawRectangle(x, y, w, h, tocolor(61, 122, 188, alpha or 0))
    dxDrawText(text, x, y, x + w, y + h, tocolor(255, 255, 255), 1, Raleway12, "center", "center")
    buttonsC[key] = {x, y, w, h}
end

local monthPrefix = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}

addEvent("onClientPM", true)
addEventHandler("onClientPM", getRootElement(),
    function(player, msg, whoIs)
        whoIs = whoIs == true
        if not whoIs then
            playSound("files/noti.mp3")
        end



        local openNew = true
        for k, v in pairs(openedMessages) do
            if v[1] == player then
                openNew = false
                index = k
                break
            end
        end
        local year = (getRealTime().year+1900)
        local month = monthPrefix[getRealTime().month+1]
        local day = getRealTime().monthday
        if day < 10 then
            day = "0" .. day
        end
        local hour = getRealTime().hour
        if hour < 10 then
            hour = "0" .. hour
        end
        local minute = getRealTime().minute
        if minute < 10 then
            minute = "0" .. minute
        end
        local second = getRealTime().second
        if second < 10 then
            second = "0" .. second
        end
        if whoIs then
            datePlayer = localPlayer
        else
            datePlayer = player
        end
        local dateText = tostring((getPlayerName(datePlayer) or "Ismeretlen N/A"):gsub("_", " ").." - "..year..". "..string.lower(month)..". "..day.." "..hour..":"..minute..":"..second)
        
        createTrayNotification("[Strong PM]: " .. getPlayerName(player) .. ": " .. msg)

        --PM

        if openNew then
            table.insert(openedMessages, {player, {{msg, whoIs, dateText}}})
        else
            table.insert(openedMessages[index][2], {msg, whoIs, dateText})
        end
    end
)

function isInSlot(x, y, width, height)
	if (not isCursorShowing()) then
		return false
	end
	local sx, sy = guiGetScreenSize()
	local cx, cy = getCursorPosition()
	local cx, cy = (cx*sx), (cy*sy)	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

local scroll = 0
local maxShowed = 8
local deleteTexture = dxCreateTexture("files/delete.png")

function dxDrawSeeBar(x, y, sx, sy, margin, colorOfProgress, value, key, bgcolor, bordercolor)
	sx, sy = math.ceil(sx), math.ceil(sy)

	if value > 100 then
		value = 100
	end

	bordercolor = bordercolor or tocolor(20, 20, 20, 200)

	dxDrawRectangle(x, y, sx, margin, bordercolor) -- felső
	dxDrawRectangle(x, y + sy - margin, sx, margin, bordercolor) -- alsó
	dxDrawRectangle(x, y + margin, margin, sy - margin * 2, bordercolor) -- bal
	dxDrawRectangle(x + sx - margin, y + margin, margin, sy - margin * 2, bordercolor) -- jobb

	dxDrawRectangle(x + margin, y + margin, sx - margin * 2, sy - margin * 2, bgcolor or tocolor(0, 0, 0, 155)) -- háttér
	dxDrawRectangle(x + margin, y + margin, (sx - margin * 2) * (value / 100), sy - margin * 2, colorOfProgress) -- állapot
end

--triggerEvent("onClientPM", localPlayer, localPlayer,  "message", true)

addCommandHandler("trigger",
    function ()
        triggerEvent("onClientPM", localPlayer, localPlayer,  "chat", true)
    end 
)

function showTooltip(x, y, text, subText, showItem)
    text = tostring(text)
    subText = subText and tostring(subText)

    if text == subText then
        subText = nil
    end

    local sx = dxGetTextWidth(text, 1, "clear", true) + 20
    
    if subText then
        sx = math.max(sx, dxGetTextWidth(subText, 1, "clear", true) + 20)
        text = "#3d7abc" .. text .. "\n#ffffff" .. subText
    end

    local sy = 30

    if subText then
        local _, lines = string.gsub(subText, "\n", "")
        
        sy = sy + 12 * (lines + 1)
    end

    local drawnOnTop = true

    if showItem then
        x = math.floor(x - sx / 2)
        drawnOnTop = false
    else
        x = math.max(0, math.min(screenX - sx, x))
        y = math.max(0, math.min(screenY - sy, y))
    end

    dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 190), drawnOnTop)
    dxDrawText(text, x, y, x + sx, y + sy, tocolor(255, 255, 255), 0.9, Raleway12, "center", "center", false, false, drawnOnTop, true)
end

function renderPanel()
    buttonsC = {}
    dxDrawRectangle(panelStart[1], panelStart[2], panelW, panelH, tocolor(0, 0, 0, 180))
    dxDrawRectangle(panelStart[1], panelStart[2], panelW, respc(30), tocolor(0, 0, 0, 220))
    dxDrawText("#3d7abcStrong#ffffffMTA - Admin", panelStart[1] + respc(10), panelStart[2], panelStart[1] + panelW, panelStart[2] + respc(30), tocolor(0, 0, 0, 220), 1, Raleway14, "left", "center", false, false, false, true)

    --dxDrawRectangle(panelStart[1] + panelW - respc(97) - respc(36), panelStart[2] + panelH / 2 - respc(31), respc(70), respc(18), tocolor(200, 200, 200, 255))

    local cx, cy = getCursorPosition()
    if isCursorShowing() then 
        cx = cx * screenX
        cy = cy * screenY
    else
        --return cx, cy
    end

    if isInSlot(panelStart[1] + panelW - respc(97) - respc(36), panelStart[2] + panelH / 2 - respc(31), respc(70), respc(18)) and openedMessages[selectedChat] then 
        showTooltip(cx, cy, "Vagyon:", ecoDatas)
    end

    if isInSlot(panelStart[1] + panelW - respc(97), panelStart[2] + panelH / 2 + respc(2), respc(35), respc(18)) and adminJailTooltipData and openedMessages[selectedChat] then 
        showTooltip(cx, cy, "Részletek:", adminJailTooltipData)
    end

    --dxDrawRectangle(panelStart[1] + panelW - respc(22), panelStart[2] + respc(8), respc(12), respc(16), tocolor(200, 200, 200, 200))

    if isInSlot(panelStart[1] + panelW - respc(22), panelStart[2] + respc(8), respc(12), respc(16)) then
        crossStatus = true
        crossColor = tocolor(215, 99, 99)
    else
        crossStatus = false
        crossColor = tocolor(255, 255, 255)
    end
    dxDrawText("X", panelStart[1] - respc(10), panelStart[2], panelStart[1] + panelW - respc(10), panelStart[2] + respc(33), crossColor, 0.8, Raleway14, "right", "center")
    if isInSlot(panelStart[1] + panelW - respc(55), panelStart[2] + respc(5), respc(20), respc(20)) then
        notiColor = tocolor(61, 122, 188)
        notiActive = true
    else
        notiColor = tocolor(255, 255, 255)
        notiActive = false
    end

    if getElementData(localPlayer, "notiOn") then
        notiColor = tocolor(61, 122, 188)
    end

    if isInSlot(panelStart[1] + panelW - respc(85), panelStart[2] + respc(5), respc(20), respc(20)) then
        refreshColor = tocolor(61, 122, 188)
        --notiActive = true
    else
        refreshColor = tocolor(255, 255, 255)
        --notiActive = false
    end

    drawButton2("sendMessage", "", panelStart[1] + respc(500) + respc(76), panelStart[2] + respc(500), respc(30), respc(15))

    dxDrawImage(panelStart[1] + panelW - respc(55), panelStart[2] + respc(5), respc(20), respc(20), "files/noti.png", 0, 0, 0, notiColor)
    dxDrawImage(panelStart[1] + panelW - respc(85), panelStart[2] + respc(5), respc(20), respc(20), "files/refresh.png", 0, 0, 0, refreshColor)
    dxDrawImage(panelStart[1] + panelW - respc(300), panelStart[2] + panelH - respc(30) - respc(5), respc(30), respc(30), "files/send.png", 0, 0, 0, tocolor(61, 122, 188))
    --drawButton("UCPswitch", "UCP nézet váltása", panelStart[1] + panelW - respc(170), panelStart[2] + respc(5), respc(115), respc(20))

    for i = 1, 9 do
        local startY = panelStart[2] + respc(30) + (i-1) * respc(499)/9
        if i % 2 == 0 then
            dxDrawRectangle(panelStart[1], startY, respc(200), respc(499)/9, tocolor(0, 0, 0, 100))
        else
            dxDrawRectangle(panelStart[1], startY, respc(200), respc(499)/9, tocolor(0, 0, 0, 140))
        end
        if openedMessages[i] then
            if isInSlot(panelStart[1], startY, respc(200), respc(499)/9) then
                dxDrawRectangle(panelStart[1], startY, respc(200), respc(499)/9, tocolor(61, 122, 188, 80))
                if selectedChat ~= i then
                    if getKeyState("mouse1") then
                        selectedChat = i
                        triggerServerEvent("requestPlayerDatas", localPlayer, openedMessages[i][1])
                    end
                end
            end
        end
        if selectedChat == i then
            dxDrawRectangle(panelStart[1], startY, respc(200), respc(499)/9, tocolor(61, 122, 188, 200))
        end
        if openedMessages[i] then
            local v = openedMessages[i]
            if isElement(v[1]) then
                if dxGetTextWidth(v[2][#v[2]][1], 1, Raleway12) > respc(120) then
                    for i = 1, string.len(v[2][#v[2]][1]) do
                        local text = utf8.sub(v[2][#v[2]][1], 1, i)
                        if respc(150) < dxGetTextWidth(text, 1, Raleway12) then
                            --print("nagyobb "..text)
                            lastText = text.."..."
                            break
                        end
                    end
                end
                dxDrawText(getPlayerName(v[1]):gsub("_", " "), panelStart[1] + respc(10), startY + respc(5), panelStart[1] + respc(210), startY + respc(490)/9 + respc(5), tocolor(255, 255, 255), 1, Raleway12, "left", "top")
                if not v[2][#v[2]][2] then
                    dxDrawText((lastText or v[2][#v[2]][1]), panelStart[1] + respc(10), startY + respc(5), panelStart[1] + respc(210), startY + respc(490)/9 - respc(5), tocolor(255, 255, 255), 1, Raleway12, "left", "bottom")
                else
                    dxDrawText("> "..(lastText or v[2][#v[2]][1]), panelStart[1] + respc(10), startY + respc(5), panelStart[1] + respc(210), startY + respc(490)/9 - respc(5), tocolor(255, 255, 255), 1, Raleway12, "left", "bottom")
                end
            else
                dxDrawText("N/A", panelStart[1] + respc(10), startY + respc(5), panelStart[1] + respc(210), startY + respc(490)/9 + respc(5), tocolor(255, 255, 255), 1, Raleway12, "left", "top")
            end
            if isInSlot(panelStart[1] + respc(15) + respc(155), startY + respc(15), respc(25), respc(25)) then
                trashColor = tocolor(215, 99, 99, 220)
                if getKeyState("mouse1") and getTickCount() > (lastDelete + 2500) then
                    --print("delete")
                    lastDelete = getTickCount()
                    table.remove(openedMessages, i)
                    selectedChat = false
                end
            else
                trashColor = tocolor(255, 255, 255, 220)
            end
            dxDrawImage(panelStart[1] + respc(15) + respc(155), startY + respc(15), respc(25), respc(25), deleteTexture, 0, 0, 0, trashColor)
        end
    end
    --880, 520
    dxDrawRectangle(panelStart[1] + respc(200), panelStart[2] + respc(30), respc(424), respc(455), tocolor(0, 0, 0, 120))
    dxDrawRectangle(panelStart[1] + respc(625), panelStart[2] + respc(30), respc(254), respc(498), tocolor(0, 0, 0, 100))
    local commandButtons = {
        {"fixveh"},
        {"asegit"},
        {"agyogyit"},
        {"akspawn"},
        {"vhspawn"},
        {"spec"},
        {"unflip"},
        {"gethere"},
        {"goto"},
    }
    if dxGetTextWidth(guiGetText(chatInput), 1, Raleway12) > respc(350) then
        guiEditSetMaxLength(chatInput, string.len(guiGetText(chatInput)))
    end

    if selectedChat then
        local v = openedMessages[selectedChat]
        ecoDatas = "Készpénz: #7cc576" .. getElementData(v[1], "char.Money") .. " #ffffff$" .. "\nBanki egyenleg: #7cc576" .. getElementData(v[1], "char.bankMoney") .. " #ffffff$" .. "\nPrémium egyenleg: #32b3ef" .. getElementData(v[1], "acc.premiumPoints") .. " #ffffffPP" .. "\nCasino Coin: #32b3ef" .. getElementData(v[1], "char.slotCoins") .. " #ffffffSSC"
        if (getElementData(v[1], "acc.adminJail") or 0) > 0 then
            adminJailData = "Igen"
            adminJailTooltipData = "Bebörtönözte: #3d7abc" .. tostring(getElementData(v[1], "acc.adminJailBy") or "N/A") .. "\n #ffffffIndok: #3d7abc" .. tostring(getElementData(v[1], "acc.adminJailReason")) .. " \n#ffffffIdőtartam: #3d7abc" .. tonumber(getElementData(v[1], "acc.adminJailTime")) .. " #ffffffperc" 
            --dxDrawRectangle(panelStart[1] + panelW, panelStart[2] + respc(30), respc(254), respc(498), tocolor(200, 200, 200, 200))
        else
            adminJailData = "Nem"
            adminJailTooltipData = false
        end
        local commandDatas = {--function dxDrawSeeBar(x, y, sx, sy, margin, colorOfProgress, value, key, bgcolor, bordercolor)
            --{"Életerő#3d7abc ["..(math.ceil(getElementHealth(v[1])) or "N/A").."]", (getElementHealth(v[1])) or tonumber(0), true, tocolor(203, 98, 96)},
            --{"Páncél#3d7abc ["..(math.ceil(getPedArmor(v[1])) or "N/A").."]", (getPedArmor(v[1])) or tonumber(0), true, tocolor(77, 134, 197)},
            {"Vagyon:", "Részletek"},
            {"Adminjailben:", adminJailData},
        }
        dxDrawText((getPlayerName(v[1]) or "Ismeretlen"):gsub("_", " ").." #3d7abc("..(getElementData(v[1], "playerID") or "N/A")..")\n#ffffffJailek: #3d7abc"..(datas.jailNum or "N/A").."#ffffff db | Banok: #3d7abc"..(datas.banNum or "N/A").." #ffffffdb",
        panelStart[1] + respc(625),
        panelStart[2] + panelH - respc(185), 
        panelStart[1] + respc(625) + respc(255), 
        panelStart[2] + respc(45) + respc(20), 
        tocolor(255,255,255), 1, Raleway12, "center", "center", false, false, false, true)
        for k, v in pairs(commandButtons) do
            if k % 2 == 1 then
                drawButton("commandBTN:"..v[1], v[1], panelStart[1] + respc(635), panelStart[2] + panelW/2 + respc(83) - (respc(25) * math.floor(k)), respc(234), respc(20))
            else
                drawButton("commandBTN:"..v[1], v[1], panelStart[1] + respc(635), panelStart[2] + panelW/2 + respc(83) - (respc(25) * math.floor(k)), respc(234), respc(20))
            end
        end
        for k, v in pairs(commandDatas) do
            startY = panelStart[2] + respc(227) + (k-1) * respc(34)
            dxDrawRectangle(panelStart[1] + respc(635), startY, respc(234), respc(30), tocolor(0, 0, 0, 100))
            if not v[2] then 
                return false
            end
            dxDrawText(v[1] .. " " .. v[2],
            panelStart[1] + respc(630), 
            startY + respc(5), 
            panelStart[1] + respc(630) + respc(240), 
            startY + respc(25), tocolor(255, 255, 255), 1, Raleway12, "center", "center", false, false, false, true)

            if v[3] then
                dxDrawSeeBar(panelStart[1] + respc(650), startY + respc(40), respc(200), respc(15), respc(2), v[4], v[2], false, tocolor(0, 0, 0, 155), tocolor(0,0,0))
            else
                --dxDrawText(v[2],
                --panelStart[1] + respc(630), 
                --startY + respc(25), 
                --panelStart[1] + respc(630) + respc(240), 
                --startY + respc(25) + respc(45), tocolor(255, 255, 255), 
                --1, Raleway14, "center", "center", false, false, false, true)
            end

            --dxDrawRectangle(panelStart[1] + respc(630), startY, respc(3), respc(75), tocolor(10, 10, 10))
            --dxDrawRectangle(panelStart[1] + respc(630) + respc(237), startY, respc(3), respc(75), tocolor(10, 10, 10))
            --dxDrawRectangle(panelStart[1] + respc(630), startY+respc(72), respc(240), respc(3), tocolor(10, 10, 10))
        end
    end
    dxDrawRectangle(panelStart[1] + respc(210), panelStart[2] + respc(495), respc(405), respc(25), tocolor(0, 0, 0, 100))
    --drawButton("sendMessage", "", panelStart[1] + respc(200+370), panelStart[2] + respc(492), respc(50), respc(10))
    
    if selectedChat then
        local index = 0
        for i, v in pairs(openedMessages[selectedChat][2]) do
            if (i > scroll and index < maxShowed)  then
                index = index + 1
                i = index
                local startY = panelStart[2] + respc(30) + ((i-1) * respc(55)) + respc(35)
                if dxGetTextWidth(v[1], 1, Raleway12) > respc(400) then
                    --[[for i = 1, string.len(v[1]) then
                        if dxGetTextWidth(utfSub(v[1], 1, i), 1, Raleway12)
                    end]]
                end
                if not v[2] then
                    dxDrawRectangle(panelStart[1] + respc(610) - dxGetTextWidth(v[1], 1, Raleway12), startY, dxGetTextWidth(v[1], 1, Raleway12), respc(25), tocolor(61, 122, 188))
                    dxDrawText(v[1], panelStart[1] + respc(610) - dxGetTextWidth(v[1], 1, Raleway12), startY, panelStart[1] + respc(610) - dxGetTextWidth(v[1], 1, Raleway12) + dxGetTextWidth(v[1], 1, Raleway12), startY  + respc(30), tocolor(255, 255, 255), 0.95, Raleway12, "center", "center")
                    dxDrawText((v[3] or "N/A"), panelStart[1] + respc(610) - dxGetTextWidth(v[1], 1, Raleway12), startY - respc(30), panelStart[1] + respc(610) - dxGetTextWidth(v[1], 1, Raleway12) + dxGetTextWidth(v[1], 1, Raleway12), startY  + respc(30) - respc(30), tocolor(255, 255, 255, 200), 0.85, Raleway12, "right", "center")
                else
                    dxDrawRectangle(panelStart[1] + respc(210), startY, dxGetTextWidth(v[1], 1, Raleway12), respc(25), tocolor(66, 135, 245))
                    dxDrawText(v[1], panelStart[1] + respc(210), startY, panelStart[1] + respc(210) + dxGetTextWidth(v[1], 1, Raleway12), startY  + respc(30), tocolor(255, 255, 255), 0.95, Raleway12, "center", "center")
                    dxDrawText((v[3] or "N/A"), panelStart[1] + respc(210), startY - respc(30), panelStart[1] + respc(210) + dxGetTextWidth(v[1], 1, Raleway12), startY  + respc(30) - respc(30), tocolor(255, 255, 255, 200), 0.85, Raleway12, "left", "center")
                end
            end
        end
        if getKeyState("mouse1") then
            if isInSlot(panelStart[1] + respc(200), panelStart[2] + respc(492), respc(365), respc(25)) then
                guiBringToFront(chatInput)
            else
                guiMoveToBack(chatInput)
            end
        end

        if guiGetInputEnabled() then
            if getTickCount()%2000 < 1000 then
                indicator = "|"
            else
                indicator = ""
            end
        else
            indicator = ""
        end
    
        dxDrawText(guiGetText(chatInput) .. indicator, panelStart[1] + respc(215), panelStart[2] + respc(496), panelStart[1] + respc(205) + respc(420), panelStart[2] + respc(492) + respc(25), tocolor(255, 255, 255), 1, Raleway12, "left", "center", true)
        if getKeyState("enter") then
            if string.len(guiGetText(chatInput)) > 0 then
                local myName = getElementData(localPlayer, "visibleName"):gsub("_", " ")
				local myPlayerID = getElementData(localPlayer, "playerID") or "N/A"
                triggerServerEvent("onAnwserSent", localPlayer, myName, myPlayerID, guiGetText(chatInput), openedMessages[selectedChat][1])
                triggerEvent("onClientPM", localPlayer, openedMessages[selectedChat][1], guiGetText(chatInput), true)
                guiSetText(chatInput, "")
                guiMoveToBack(chatInput)
                --scroll = scroll + 1
            end
        end
    end

    -- ** Button handler
    activeButton = false

    if isCursorShowing() then
        local relX, relY = getCursorPosition()
        local absX, absY = relX * screenX, relY * screenY

        if panelIsMoving then
            panelStart[1] = absX - moveDifferenceX
            panelStart[2] = absY - moveDifferenceY
        else
            for k, v in pairs(buttonsC) do
                if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
                    activeButton = k
                    break
                end
            end
        end
    else
        panelIsMoving = false
    end
end
addEvent("scrollDown", true)
addEventHandler("scrollDown", getRootElement(),
    function ()
        --if scroll < #openedMessages[selectedChat][2] - maxShowed then
        --    scroll = scroll + 1 
        --end
    end 
)

function clickPanel(button, state, absX, absY)
    if state == "down" then
        if button == "left" then
            if crossStatus then
                executeCommandHandler("apanel")
            elseif notiActive then
                setElementData(localPlayer, "notiOn", not getElementData(localPlayer, "notiOn"))
                if getElementData(localPlayer, "notiOn") then
                    --outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen #7cc576bekapcsoltad #ffffffaz értesítéseket!", 255, 255, 255, true)
                else
                    --outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen #d76363kikapcsoltad #ffffffaz értesítéseket!", 255, 255, 255, true)
                end
            elseif trashActive then
                openedMessages[trashActive] = nil
            elseif activeButton then
                local selected = split(activeButton, ":")
                if selected[1] == "commandBTN" then
                    triggerServerEvent("executeCommandForClient", localPlayer, selected[2], getElementData(openedMessages[selectedChat][1], "playerID"))
                end
                if activeButton == "sendMessage" then
                    if string.len(guiGetText(chatInput)) > 0 then
                        local myName = getElementData(localPlayer, "visibleName"):gsub("_", " ")
                        local myPlayerID = getElementData(localPlayer, "playerID") or "N/A"
                        triggerServerEvent("onAnwserSent", localPlayer, myName, myPlayerID, guiGetText(chatInput), openedMessages[selectedChat][1])
                        triggerEvent("onClientPM", localPlayer, openedMessages[selectedChat][1], guiGetText(chatInput), true)
                        guiSetText(chatInput, "")
                        --scroll = scroll - 2
                        --scroll = scroll + 1
                        --if scroll < #openedMessages[selectedChat][2] - maxShowed then
                        --    scroll = scroll + 1 
                        --end
                    end
                end
            end
            if isInSlot(panelStart[1], panelStart[2], panelW, respc(30)) then
                panelIsMoving = true
                moveDifferenceX = absX - panelStart[1]    
                moveDifferenceY = absY - panelStart[2]
                print(moveDifferenceX)
            end
        end
    else
        if state == "up" then
        panelIsMoving = false
        moveDifferenceX = 0
        moveDifferenceY = 0
        end
    end
end

addEventHandler("onClientPlayerQuit", root,
    function()
        for k, v in pairs(openedMessages) do
            if v[1] == source then
                openedMessages[k][3] = true
                table.insert(openedMessages[k][2], {getPlayerName(source).." lelépett a szerverről!"})
                break
            end
        end
    end
)

function togAdminPanel()
    panelState = not panelState
    if panelState then
    --if getElementData(localPlayer, "boto") then 
        addEventHandler("onClientRender", root, renderPanel)
        addEventHandler("onClientClick", root, clickPanel)
    --end
    else
        removeEventHandler("onClientRender", root, renderPanel)
        removeEventHandler("onClientClick", root, clickPanel)
    end
end
--addCommandHandler("adminpanel", togAdminPanel)
addCommandHandler("apanel", togAdminPanel)

bindKey("mouse_wheel_down", "down", 
	function() 
        if panelState then
            if scroll < #openedMessages[selectedChat][2] - maxShowed then
                scroll = scroll + 1	
            end
		end
	end
)

bindKey("mouse_wheel_up", "down", 
	function() 
        if panelState then
            if scroll > 0 then
                scroll = scroll - 1		
            end
		end
	end
)

function formatNumber(amount, stepper)
	amount = tonumber(amount)

	if not amount then
		return ""
	end

	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end