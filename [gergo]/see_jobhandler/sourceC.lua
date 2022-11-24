local jobPed = createPed(62, 359.7138671875, 173.599609375, 1008.3893432617, 270)
setElementDimension(jobPed, 13)
setElementInterior(jobPed, 3)
setElementData(jobPed, "invulnerable", true)
setElementData(jobPed, "visibleName", "Marco Shirt", true)
setElementData(jobPed, "ped.type", "v3Job", true)
setElementFrozen(jobPed, true)

local panelState = false
local RobotoFont = false
local activeButton = false

addEventHandler("onClientClick", getRootElement(),
	function (button, state, _, _, _, _, _, hitElement)
		if button == "right" then
			if state == "up" then
				if hitElement then
					local pedType = getElementData(hitElement, "ped.type")
					if pedType and type(pedType) == "string" then
						if pedType == "v3Job" then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local targetX, targetY, targetZ = getElementPosition(hitElement)

							if getDistanceBetweenPoints3D(targetX, targetY, targetZ, playerX, playerY, playerZ) < 2.5 then
								if getElementData(localPlayer, "char.Job") > 0 then
									exports.see_hud:showInfobox("e", "Már van munkád. Használd a /felmond parancsot!")
								else
									if not panelState then
										panelState = true
										showCursor(true)
										RobotoFont = dxCreateFont("files/Roboto.ttf", respc(18), false, "antialiased")
										addEventHandler("onClientRender", getRootElement(), renderThePanel)
										addEventHandler("onClientClick", getRootElement(), handlePanelClick)
									end
								end
							end
						end
					end
				end
			end
		end
	end)

function terminateJob()
	if getElementData(localPlayer, "char.Job") > 0 then
		local playerX, playerY, playerZ = getElementPosition(localPlayer)
		local targetX, targetY, targetZ = getElementPosition(jobPed)

		if getDistanceBetweenPoints3D(targetX, targetY, targetZ, playerX, playerY, playerZ) < 2.5 then
			setElementData(localPlayer, "char.Job", 0)
			exports.see_hud:showInfobox("s", "Sikeresen felmondtál! Már vállalhatsz más munkát is!")
		else
			exports.see_hud:showInfobox("e", "Itt nem tudsz felmondani!")
		end
	else
		exports.see_hud:showInfobox("e", "Már munkanélküli vagy!")
	end
end
addCommandHandler("felmond", terminateJob)
addCommandHandler("felmondas", terminateJob)
addCommandHandler("quitjob", terminateJob)

local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = 1

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedres)
		if getResourceName(startedres) == "see_hud" then
			responsiveMultipler = exports.see_hud:getResponsiveMultipler()
		else
			if source == getResourceRootElement() then
				local see_hud = getResourceFromName("see_hud")

				if see_hud then
					if getResourceState(see_hud) == "running" then
						responsiveMultipler = exports.see_hud:getResponsiveMultipler()
					end
				end
			end
		end
	end)

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "char.Job" then
			local id = getElementData(localPlayer, dataName)

			if availableJobs[id] then
				for i = 1, #availableJobs[id].instructions do
					outputChatBox("#3d7abc[StrongMTA - " .. availableJobs[id].name .. "]: #ffffff" .. availableJobs[id].instructions[i], 255, 255, 255, true)
				end
			end
		end
	end)

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end

function handlePanelClick(button, state)
	if button == "left" then
		if state == "up" then
			if activeButton then
				if string.find(activeButton, "applyJob_") then
					local id = tonumber(gettok(activeButton, 2, "_"))

					if availableJobs[id] then
						local items = exports.see_items:getLocalPlayerItems()
						local identityCard = false
						local driverLicense = false
						local myName = getElementData(localPlayer, "visibleName"):gsub("_", " ")

						for k, v in pairs(items) do
							if v.itemId == 207 or v.itemId == 208 then
								local characterName = split(v.data1, ";")[2] or "N/A"

								if characterName:gsub("_", " ") == myName then
									local expireTime = split(v.data3, ".")

									if getTimestamp() < getTimestamp(expireTime[1], expireTime[2], expireTime[3], 0, 0, 0) then
										if v.itemId == 207 then
											identityCard = true
										else
											driverLicense = true
										end
									end
								end
							end
						end

						if not identityCard then
							exports.see_hud:showInfobox("e", "A munka felvételéhez érvényes személyi kell!")
							return
						end

						if availableJobs[id].driverLicense then
							if not driverLicense then
								exports.see_hud:showInfobox("e", "A munka felvételéhez érvényes jogosítvány kell!")
								return
							end
						end

						setElementData(localPlayer, "char.Job", id)
						exports.see_hud:showInfobox("s", "Sikeresen felvetted a következő munkát: " .. availableJobs[id].name .. "!")
					end
				end

				removeEventHandler("onClientRender", getRootElement(), renderThePanel)
				removeEventHandler("onClientClick", getRootElement(), handlePanelClick)

				panelState = false

				showCursor(false)
				destroyElement(RobotoFont)
				RobotoFont = nil
			end
		end
	end
end

function renderThePanel()
	local sx, sy = respc(500), respc(80) + respc(40) * #availableJobs--600
	local x, y = screenX / 2 - sx / 2, screenY / 2 - sy / 2

	dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))
	dxDrawRectangle(x, y, sx, respc(35), tocolor(0, 0, 0, 200))
	dxDrawText("#ffffffStrong#3d7abcMTA #ffffff- Munka", x + respc(10), y, 0, y + respc(35), tocolor(255, 255, 255), 0.9, RobotoFont, "left", "center", false, false, false, true)

	local buttons = {}

	if activeButton == "exit" then
		dxDrawText("x", x + sx - respc(30), y, x + sx - respc(10), y + respc(35), tocolor(215, 89, 89, 255), 1, RobotoFont, "right", "center", false, false, false, true)
	else
		dxDrawText("x", x + sx - respc(30), y, x + sx - respc(10), y + respc(35), tocolor(255, 255, 255), 1, RobotoFont, "right", "center", false, false, false, true)
	end

	buttons.exit = {x + sx - respc(30), y, respc(20), respc(35)}

	local oneSize = (sy - respc(35)) / #availableJobs

	for i=1, #availableJobs do
		local y = y + oneSize * (i - 1) + respc(35)

		if i % 2 ~= 1 then
			dxDrawRectangle(x, y, sx, oneSize, tocolor(0, 0, 0, 55))
		else
			dxDrawRectangle(x, y, sx, oneSize, tocolor(0, 0, 0, 100))
		end

		dxDrawText(availableJobs[i].name, x + respc(15), y, 0, y + oneSize, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center")

		local buttonHeight = oneSize * 0.75
		local y2 = y + (oneSize - buttonHeight) / 2

		local buttonAlpha = 175

		if activeButton == "applyJob_" .. i then
			buttonAlpha = 255
		end

		dxDrawRectangle(x + sx - respc(15) - respc(150), y2, respc(150), buttonHeight, tocolor(61, 122, 188, buttonAlpha))
		
		dxDrawText("Munka felvétele", x + sx - respc(15) - respc(150), y, x + sx - respc(15), y + oneSize, tocolor(0, 0, 0, 255), 0.65, RobotoFont, "center", "center")

		buttons["applyJob_" .. i] = {x + sx - respc(15) - respc(150), y2, respc(150), buttonHeight}
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