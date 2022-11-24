local registrationPed = createPed(62, 356.296875, 178.0537109375, 1008.3762207031, 270)
setElementDimension(registrationPed, 13)
setElementInterior(registrationPed, 3)
setElementData(registrationPed, "invulnerable", true)
setElementData(registrationPed, "visibleName", "Kenneth Velasquez", true)
setElementData(registrationPed, "ped.type", "v3Registration", true)
setElementFrozen(registrationPed, true)

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
						if pedType == "v3Registration" then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local targetX, targetY, targetZ = getElementPosition(hitElement)

							if getDistanceBetweenPoints3D(targetX, targetY, targetZ, playerX, playerY, playerZ) < 2.5 then
								if not panelState then
									panelState = true
									showCursor(true)
									RobotoFont = dxCreateFont("files/Roboto.ttf", respc(18), false, "antialiased")
									addEventHandler("onClientRender", getRootElement(), registrationRender)
									addEventHandler("onClientClick", getRootElement(), registrationClick)
								end
							end
						end
					end
				end
			end
		end
	end)

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

local fishingZones = {
	"Las Venturas és környéke",
	"Bone County és környéke",
	"Tierra Robada és környéke"
}

function registrationClick(button, state)
	if button == "left" then
		if state == "up" then
			if activeButton then
				if string.find(activeButton, "makeDocument_") then
					local selected = split(activeButton, "_")

					-- Személyigazolvány
					if tonumber(selected[2]) == 1 then
						triggerServerEvent("giveDocument", localPlayer, 207)
					-- Üres adásvételi
					elseif tonumber(selected[2]) == 6 then
						triggerServerEvent("giveDocument", localPlayer, 311)
					-- Horgászengedély
					elseif tonumber(selected[2]) == 3 then
						triggerServerEvent("giveDocument", localPlayer, 310, false, selected[3])
					-- Útlevél
					else
						triggerServerEvent("giveDocument", localPlayer, 264)
					end
				end

				removeEventHandler("onClientRender", getRootElement(), registrationRender)
				removeEventHandler("onClientClick", getRootElement(), registrationClick)
				panelState = false
				showCursor(false)
				destroyElement(RobotoFont)
			end
		end
	end
end

function registrationRender()
	local sx, sy = respc(600), respc(450)
	local x, y = screenX / 2 - sx / 2, screenY / 2 - sy / 2

	dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))
	dxDrawRectangle(x, y, sx, respc(35), tocolor(0, 0, 0, 200))
	dxDrawText("#ffffffStrong#3d7abcMTA #ffffff- Okmányiroda", x + respc(10), y, 0, y + respc(35), tocolor(255, 255, 255), 0.9, RobotoFont, "left", "center", false, false, false, true)

	local buttons = {}

	if activeButton == "exit" then
		dxDrawText("x", x + sx - respc(30), y, x + sx - respc(10), y + respc(35), tocolor(215, 89, 89, 255), 1, RobotoFont, "right", "center", false, false, false, true)
	else
		dxDrawText("x", x + sx - respc(30), y, x + sx - respc(10), y + respc(35), tocolor(255, 255, 255), 1, RobotoFont, "right", "center", false, false, false, true)
	end

	buttons.exit = {x + sx - respc(30), y, respc(20), respc(35)}

	local oneSize = (sy - respc(35)) / 6

	for i=1, 6 do
		local y = y + oneSize * (i - 1) + respc(35)

		if i % 2 ~= 1 then
			dxDrawRectangle(x, y, sx, oneSize, tocolor(0, 0, 0, 55))
		else
			dxDrawRectangle(x, y, sx, oneSize, tocolor(0, 0, 0, 100))
		end

		if i > 5 then
			dxDrawText("Üres adásvételi (100 $)", x + respc(15), y, 0, y + oneSize, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center")
		elseif i == 1 then
			dxDrawText("Személyi igazolvány (ingyenes)", x + respc(15), y, 0, y + oneSize, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center")
		elseif i >= 3 then
			dxDrawText("Horgászengedély: " .. fishingZones[i - 2] .. " (200 $)", x + respc(15), y, 0, y + oneSize, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center")
		else
			dxDrawText("Útlevél (350 $)", x + respc(15), y, 0, y + oneSize, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center")
		end

		local buttonAlpha = 175

		if i > 5 then
			if activeButton == "makeDocument_" .. i then
				buttonAlpha = 255
			end
		elseif i >= 3 then
			if activeButton == "makeDocument_3_" .. fishingZones[i - 2] then
				buttonAlpha = 255
			end
		else
			if activeButton == "makeDocument_" .. i then
				buttonAlpha = 255
			end
		end

		local buttonHeight = oneSize - respc(30)
		local y2 = y + (oneSize - buttonHeight) / 2

		dxDrawRectangle(x + sx - respc(15) - respc(100), y2, respc(100), buttonHeight, tocolor(61, 122, 188, buttonAlpha))
		
		if i > 5 then
			dxDrawText("Vásárlás", x + sx - respc(15) - respc(100), y, x + sx - respc(15), y + oneSize, tocolor(0, 0, 0, 255), 0.75, RobotoFont, "center", "center")
		else
			dxDrawText("Kiváltás", x + sx - respc(15) - respc(100), y, x + sx - respc(15), y + oneSize, tocolor(0, 0, 0, 255), 0.75, RobotoFont, "center", "center")
		end

		if i > 5 then
			buttons["makeDocument_" .. i] = {x + sx - respc(15) - respc(100), y2, respc(100), buttonHeight}
		elseif i >= 3 then
			buttons["makeDocument_3_" .. fishingZones[i - 2]] = {x + sx - respc(15) - respc(100), y2, respc(100), buttonHeight}
		else
			buttons["makeDocument_" .. i] = {x + sx - respc(15) - respc(100), y2, respc(100), buttonHeight}
		end
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

local descriptionPanel = false
local panelW, panelH = respc(400), respc(200)
local panelX, panelY = screenX / 2 - panelW/2, screenY / 2 - panelH /2
local descriptionPanelFont = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")

dInput = "agyad"
addEventHandler("onClientCharacter", getRootElement(), function(character)
  	if dState and string.len(dInput) < 150 then
    	dInput = dInput .. character
  	end
end)
addEventHandler("onClientKey", getRootElement(), function(key, state)
  	if dState then
    	cancelEvent()

    	if key == "backspace" and state then
      		dInput = utf8.sub(dInput, 0, utf8.len(dInput) - 1)
    	end
  	end
end)

local dState = true


--[[function renderTheDescriptionPanel()
	buttonsC = {}
	if dState then
		dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(0, 0, 0, 150))
		dxDrawRectangle(panelX, panelY, panelW, respc(30), tocolor(0, 0, 0, 200))
		--dxDrawText("#ffffffStrong#7cc576MTA v3 #ffffff- Karaktered leírása", panelX - respc(200) + respc(7), panelY - respc(100), panelX - respc(200) + respc(400), panelY - respc(100) + respc(35), tocolor(200, 200, 200), 1, RobotoFont, "left", "center", false, false, false, true)
		dxDrawText("#ffffffStrong#3d7abcMTA #ffffff- Karaktered leírása", panelX + respc(5), panelY - respc(5), screenX / 2 - respc(200) + respc(400), screenY / 2 - respc(100) + respc(35), tocolor(255, 255, 255, 255), 0.9, descriptionPanelFont, "left", "center", false, false, false, true)
		drawButton("done", "Szerkesztés", panelX + respc(5), panelY + respc(165), respc(390), respc(30), {61, 122, 188}, false, descriptionPanelFont, true)
		
		 dxDrawText(dInput .. " |", panelX + respc(10), panelY + respc(40), panelX  - respc(10), panelY + respc(100), tocolor(255, 255, 255, 255), 0.75, descriptionPanelFont, "left", "top", false, true)

		if activeButtonC == "done" then 
			--outputChatBox("asd")
		end

		local relX, relY = getCursorPosition()

		activeButtonC = false

		if relX and relY then
			relX = relX * screenX
			relY = relY * screenY

			for k, v in pairs(buttonsC) do
				if relX >= v[1] and relY >= v[2] and relX <= v[1] + v[3] and relY <= v[2] + v[4] then
					activeButtonC = k
					break
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, renderTheDescriptionPanel)]]

function descriptionPanelClick(sourceKey, sourceKeyState)
	if sourceKey == "left" and sourceKeyState == "down" then 
		if activeButtonC then 
			if activeButtonC == "done" then 
				outputChatBox("anasdasd")
			end
		end
	end
end
addEventHandler("onClientClick", root, descriptionPanelClick)

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
