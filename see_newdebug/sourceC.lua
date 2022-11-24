local screenX, screenY = guiGetScreenSize()

local panelState = false
local panelHeight = 400
local panelPosX = screenX / 4
local panelPosY = screenY - panelHeight - 86

local debugLines = {}

local RobotoFont = false
local RobotoHeight = false

addCommandHandler("cd",
	function ()
		debugLines = {}
	end)

addCommandHandler("debugon",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 7 or getElementData(localPlayer, "acc.rpGuard") >= 3 then
			if not panelState then
				RobotoFont = dxCreateFont("Roboto.ttf", 14, false, "antialiased")
				RobotoHeight = dxGetFontHeight(0.75, RobotoFont)

				panelHeight = RobotoHeight * 20
				panelPosY = screenY - panelHeight - 86
				panelState = true

				addEventHandler("onClientRender", getRootElement(), renderTheNewDebug, true, "low")
				addEventHandler("onClientDebugMessage", getRootElement(), onDebugMessage)

				outputChatBox("Debugscript on")
			end
		end
	end)

addCommandHandler("debugoff",
	function ()
		if panelState then
			removeEventHandler("onClientRender", getRootElement(), renderTheNewDebug)
			removeEventHandler("onClientDebugMessage", getRootElement(), onDebugMessage)

			if isElement(RobotoFont) then
				destroyElement(RobotoFont)
			end

			RobotoFont = nil
			panelState = false

			outputChatBox("Debugscript off")
		end
	end)

function dxDrawBorderText(text, x, y, w, h, color, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	text = text:gsub("#......", "")
	dxDrawText(text, x - 1, y - 1, w - 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(text, x - 1, y + 1, w - 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(text, x + 1, y - 1, w + 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(text, x + 1, y + 1, w + 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end

function renderTheNewDebug()
	if panelState then
		for i = 1, 20 do
			if debugLines[i] then
				local y = panelPosY + panelHeight - RobotoHeight * (i - 1)

				dxDrawBorderText(debugLines[i][1] .. "x", panelPosX, y, 0, 0, tocolor(255, 255, 255), tocolor(0, 0, 0, 200), 0.75, RobotoFont, "left", "top")
				
				dxDrawBorderText(debugLines[i][2], panelPosX + dxGetTextWidth(debugLines[i][1] .. "x", 0.75, RobotoFont) + 5, y, 0, 0, debugLines[i][3], tocolor(0, 0, 0, 200), 0.75, RobotoFont, "left", "top")
			end
		end
	end
end

function onDebugMessage(message, level, file, line, r, g, b)
	if panelState then
		local color = false

		if level == 1 then
			level = "[ERROR] "
			color = tocolor(215, 89, 89)
		elseif level == 2 then
			level = "[WARNING] "
			color = tocolor(255, 150, 0)
		elseif level == 3 then
			level = "[INFO] "
			color = tocolor(61, 122, 188)
		else
			level = "[INFO] "
			color = tocolor(r, g, b)
		end
		
		if file and line then
			addDebugLine(level .. file .. ":" .. line .. ", " .. message, color)
		else
			addDebugLine(level .. message, color)
		end
	end
end

function addDebugLine(message, color)
	if panelState then
		for i = 1, #debugLines do
			if debugLines[i][2] == message then
				debugLines[i] = {debugLines[i][1] + 1, debugLines[i][2], debugLines[i][3]}
				return
			end
		end
		
		local lines = {}

		for i = 1, 20 do
			if debugLines[i] then
				lines[i + 1] = debugLines[i]
			end
		end
		
		debugLines = lines
		debugLines[1] = {1, message, color}
		
		if #debugLines >= 20 then
			debugLines[#debugLines] = nil
		end
	end
end
addEvent("addDebugLine", true)
addEventHandler("addDebugLine", resourceRoot, addDebugLine)