local screenX, screenY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
	return (value - low1) * (high2 - low2) / (high1 - low1) + low2
end

local responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)
local responsiveMultipler2 = reMap(screenX, 1024, 1920, 0.45, 1)

function respc(value)
	return math.ceil(value * responsiveMultipler)
end

local panelState = false

local dataRefreshTimer = false
local sampleRate = 2500

local performanceElement = false
local performanceElementType = "client"
local performanceCategory = "Lua timing"
local performanceCategoryId = 1
local performanceCategories = {
	"Lua timing",
	"Lua memory",
	"Lib memory",
	"Packet usage",
	"Server info",
	"Function stats",
	"RPC Packet usage",
	"Packet usage",
	"Event Packet usage",
	"Player packet usage"
}

local statsColumn = {}
local statsRow = {}

local panelWidth = screenX / 2
local maxColumnWidth = screenX - math.floor(256 * responsiveMultipler2)
local rowHeight = math.floor(50 * responsiveMultipler2)

local rowsLength = {}
local columnCount = 0
local rowsWidth = {}
local rowsSortBy = 2
local rowsSortAlign = true

local renderTarget = false
local activeButton = false

local titleHeight = respc(32)
local buttonSize = respc(24)
local buttonSize2 = respc(28)

local visibleItem = 12
local maxPanelHeight = rowHeight * visibleItem
local scrollOffset = 0
local scrollbarPosition = 0
local scrollbarStartTick = false

local performanceLogging = false
local performanceLogs = {}

local RobotoFont = false

addCommandHandler("performancelog",
	function (commandName, targetPlayer)
		if getElementData(localPlayer, "acc.adminLevel") >= 7 and not targetPlayer then
			performanceLogging = not performanceLogging

			if performanceLogging then
				savePerformance(1)
			else
				local timestamp = getRealTime().timestamp
				local logFile = fileCreate(timestamp .. "_log/log.csv")

				for k, v in pairs(performanceLogs) do
					fileWrite(logFile, k .. ";")

					for i = 1, #v do
						fileWrite(logFile, tostring(v[i]) .. ";")
					end

					fileWrite(logFile, "\n")
				end

				performanceLogs = {}

				fileClose(logFile)
			end
		end
	end)

function savePerformance(times)
	if performanceLogging then
		local columns, rows = getPerformanceStats("Lua timing")

		for i = 1, #rows do
			if not performanceLogs[rows[i][1]] then
				performanceLogs[rows[i][1]] = {}
			end

			performanceLogs[rows[i][1]][times] = rows[i][2]
		end

		setTimer(savePerformance, 750, 1, times + 1)
	end
end

addCommandHandler("performance",
	function (commandName, targetPlayer)
		if getElementData(localPlayer, "acc.adminLevel") >= 7 and not targetPlayer then
			performanceElementType = "client"
			performanceElement = false
			panelState = not panelState

			if isTimer(dataRefreshTimer) then
				killTimer(dataRefreshTimer)
			end

			if isElement(renderTarget) then
				destroyElement(renderTarget)
			end

			if panelState then
				RobotoFont = dxCreateFont("Roboto.ttf", respc(12), false, "antialiased")

				addEventHandler("onClientRender", getRootElement(), renderPerformance, true, "low-9999999999")
				addEventHandler("onClientClick", getRootElement(), clickPerformance)
				addEventHandler("onClientKey", getRootElement(), keyPerformance)

				dataRefresh()
				dataRefreshTimer = setTimer(dataRefresh, sampleRate, 0)
				showChat(false)
			else
				removeEventHandler("onClientRender", getRootElement(), renderPerformance, true, "low-9999999999")
				removeEventHandler("onClientClick", getRootElement(), clickPerformance)
				removeEventHandler("onClientKey", getRootElement(), keyPerformance)
				showChat(true)

				if isElement(RobotoFont) then
					destroyElement(RobotoFont)
				end
				RobotoFont = nil
			end
		end
	end)

addEvent("clientPerformance", true)
addEventHandler("clientPerformance", getRootElement(),
	function ()
		performanceElement = source
		performanceElementType = "anotherClient"
		panelState = not panelState

		if isTimer(dataRefreshTimer) then
			killTimer(dataRefreshTimer)
		end

		if isElement(renderTarget) then
			destroyElement(renderTarget)
		end

		if panelState then
			RobotoFont = dxCreateFont("Roboto.ttf", respc(12), false, "antialiased")

			addEventHandler("onClientRender", getRootElement(), renderPerformance, true, "low-9999999999")
			addEventHandler("onClientClick", getRootElement(), clickPerformance)
			addEventHandler("onClientKey", getRootElement(), keyPerformance)

			dataRefresh()
			dataRefreshTimer = setTimer(dataRefresh, sampleRate, 0)
			showChat(false)
		else
			removeEventHandler("onClientRender", getRootElement(), renderPerformance, true, "low-9999999999")
			removeEventHandler("onClientClick", getRootElement(), clickPerformance)
			removeEventHandler("onClientKey", getRootElement(), keyPerformance)
			showChat(true)

			if isElement(RobotoFont) then
				destroyElement(RobotoFont)
			end
			RobotoFont = nil
		end
	end)

addEvent("getServerPerformanceStats", true)
addEventHandler("getServerPerformanceStats", getRootElement(),
	function (columns, rows, playerName)
		statsColumn, statsRow = columns, rows
		performanceElement = source

		if #statsRow < 1 then
			local columns2 = {}

			for i = 1, #statsColumn do
				table.insert(columns2, "")
			end

			table.insert(statsRow, columns2)
		end

		dataProcess()
	end)

addEvent("clientFromAnotherClient", true)
addEventHandler("clientFromAnotherClient", getRootElement(),
	function (category)
		triggerServerEvent("sendToAnother", source, localPlayer, getPerformanceStats(category))
	end)

function dataRefresh()
	if performanceElementType == "anotherClient" then
		triggerServerEvent("performanceFromAnotherClient", localPlayer, performanceElement, performanceCategory)
	elseif performanceElementType == "client" then
		statsColumn, statsRow = getPerformanceStats(performanceCategory)
		dataProcess()
	else
		triggerServerEvent("getServerPerformanceStats", localPlayer, performanceCategory)
	end
end

function dataProcess()
	rowsLength = {}
	columnCount = 0
	panelWidth = 0

	for i = 1, #statsColumn do
		rowsLength[i] = {}

		table.insert(rowsLength[i], utf8.len(statsColumn[i]))

		for j = 1, #statsRow do
			table.insert(rowsLength[i], utf8.len(statsRow[j][i]))
		end

		table.sort(rowsLength[i],
			function (a, b)
				return b < a
			end
		)

		columnCount = columnCount + rowsLength[i][1]
	end

	for i = 1, #rowsLength do
		rowsWidth[i] = rowsLength[i][1] / columnCount * maxColumnWidth
		panelWidth = panelWidth + rowsWidth[i]
	end

	table.sort(statsRow,
		function (a, b)
			local data = a[rowsSortBy] and utf8.gsub(a[rowsSortBy], "%%", "") or ""
			local data2 = b[rowsSortBy] and utf8.gsub(b[rowsSortBy], "%%", "") or ""

			if tonumber(data) then
				data = tonumber(data)
			end

			if tonumber(data2) then
				data2 = tonumber(data2)
			end

			if (data and not data2 or type(data) ~= type(data2)) then
				data = tostring(data)
				data2 = tostring(data2)
			end

			if rowsSortAlign then
				return data > data2
			else
				return data < data2
			end
		end
	)

	if scrollOffset > #statsRow - visibleItem then
		scrollbarStartTick = getTickCount()
		scrollOffset = #statsRow - visibleItem
	end

	if scrollOffset < 0 then
		scrollbarStartTick = getTickCount()
		scrollOffset = 0
	end

	processRT()
end

function processRT()
	if isElement(renderTarget) then
		destroyElement(renderTarget)
	end

	renderTarget = dxCreateRenderTarget(panelWidth, rowHeight * #statsRow, true)

	dxSetRenderTarget(renderTarget)
	dxSetBlendMode("modulate_add")

	local x_offset = 0

	for i = 1, #statsColumn do
		local rowWidth = rowsWidth[i]

		for j = 1, #statsRow do
			local y = 0 + rowHeight * (j - 1)

			if j ~= 1 then
				dxDrawRectangle(0, y, panelWidth, 1, tocolor(0, 0, 0, 255))
			end

			if i ~= 1 then
				dxDrawRectangle(x_offset, y, 1, rowHeight, tocolor(0, 0, 0, 255))
			end

			if performanceCategory == "Lua timing" and (i == 2 or i == 7 or i == 12) then
				local rowColor = tocolor(61, 122, 188, 125)

				if statsRow[j] and statsRow[j][i] then
					local number = utf8.gsub(statsRow[j][i], "%%", "")

					if number and tonumber(number) then
						local progress = tonumber(number) / 30
						local r, g, b = 61, 122, 188

						if progress > 0.5 then
							r, g, b = interpolateBetween(220, 163, 0, 215, 89, 89, progress, "Linear")
						else
							r, g, b = interpolateBetween(61, 122, 188, 220, 163, 0, progress, "Linear")
						end

						rowColor = tocolor(r, g, b, 125)
					end
				end

				dxDrawRectangle(x_offset + 1, y + 1, rowWidth - 1, rowHeight - 1, rowColor)
			else
				if j % 2 == 0 then
					dxDrawRectangle(x_offset + 1, y + 1, rowWidth - 1, rowHeight - 1, tocolor(0, 0, 0, 125))
				else
					dxDrawRectangle(x_offset + 1, y + 1, rowWidth - 1, rowHeight - 1, tocolor(0, 0, 0, 75))
				end
			end

			dxDrawText(statsRow[j][i], x_offset + 1, y, x_offset + 1 + rowWidth - 1, y + rowHeight, tocolor(255, 255, 255), 1.0, RobotoFont, "center", "center", true)
		end

		x_offset = x_offset + rowWidth
	end

	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

function renderPerformance()
	local cx, cy = getCursorPosition()

	if cx and cy then
		cx, cy = cx * screenX, cy * screenY
	else
		cx, cy = -99, -99
	end

	activeButton = false

	local fullPanelHeight = rowHeight * #statsRow
	local panelHeight = fullPanelHeight

	if panelHeight < titleHeight + rowHeight then
		panelHeight = titleHeight + rowHeight
	elseif panelHeight > maxPanelHeight then
		panelHeight = maxPanelHeight
	end

	local x = (screenX - panelWidth) / 2
	local y = (screenY - panelHeight) / 2
	local y2 = y - titleHeight

	dxDrawRectangle(x, y - titleHeight, panelWidth, panelHeight + titleHeight + rowHeight, tocolor(0, 0, 0, 180))
	dxDrawRectangle(x, y2, panelWidth, titleHeight, tocolor(50, 50, 50, 75))

	local titleWidth = dxGetTextWidth("Strong#3d7abcMTA", 1, RobotoFont, true) + 5

	dxDrawText("Strong#3d7abcMTA", x + 5, y2, 0, y, tocolor(255, 255, 255), 1, RobotoFont, "left", "center", false, false, false, true)
	dxDrawText("Performance Browser - ", x + titleWidth + 10, y2, x, y, tocolor(255, 255, 255), 1, RobotoFont, "left", "center")

	titleWidth = titleWidth + dxGetTextWidth("Performance Browser - ", 1, RobotoFont)

	dxDrawText("SampleRate: " .. sampleRate, x + titleWidth + 10, y2, x, y, tocolor(255, 255, 255), 0.8, RobotoFont, "left", "center")
	
	titleWidth = titleWidth + dxGetTextWidth("SampleRate: " .. sampleRate, 0.8, RobotoFont) + 5

	if cx >= x + titleWidth + 10 and cy >= y - buttonSize2 and cx <= x + titleWidth + 10 + buttonSize and cy <= y - buttonSize2 + buttonSize then
		dxDrawRectangle(x + titleWidth + 10, y - buttonSize2, buttonSize, buttonSize, tocolor(61, 122, 188, 175))
		activeButton = "sampleRate:plus"
	else
		dxDrawRectangle(x + titleWidth + 10, y - buttonSize2, buttonSize, buttonSize, tocolor(50, 50, 50, 200))
	end
	dxDrawText("+", x + titleWidth + 10, y - buttonSize2, x + titleWidth + 10 + buttonSize, y - buttonSize2 + buttonSize, tocolor(255, 255, 255), 1, RobotoFont, "center", "center")

	titleWidth = titleWidth + buttonSize + 5

	if cx >= x + titleWidth + 10 and cy >= y - buttonSize2 and cx <= x + titleWidth + 10 + buttonSize and cy <= y - buttonSize2 + buttonSize then
		dxDrawRectangle(x + titleWidth + 10, y - buttonSize2, buttonSize, buttonSize, tocolor(61, 122, 188, 175))
		activeButton = "sampleRate:minus"
	else
		dxDrawRectangle(x + titleWidth + 10, y - buttonSize2, buttonSize, buttonSize, tocolor(50, 50, 50, 200))
	end
	dxDrawText("-", x + titleWidth + 10, y - buttonSize2, x + titleWidth + 10 + buttonSize, y - buttonSize2 + buttonSize, tocolor(255, 255, 255), 1, RobotoFont, "center", "center")

	titleWidth = titleWidth + buttonSize + 5

	dxDrawText("Type: " .. performanceElementType .. "-" .. performanceCategory, x + titleWidth + 10, y2, x, y, tocolor(255, 255, 255), 0.8, RobotoFont, "left", "center")

	titleWidth = titleWidth + dxGetTextWidth("Type: " .. performanceElementType .. "-" .. performanceCategory, 0.8, RobotoFont) + 10
	
	local performanceSide = performanceElementType == "client" and "server" or "client"
	local sideWidth = dxGetTextWidth("Switch to " .. performanceSide .. " side", 1, RobotoFont) + 10

	if cx >= x + titleWidth + 10 and cy >= y - buttonSize2 and cx <= x + titleWidth + 10 + sideWidth and cy <= y - buttonSize2 + buttonSize then
		dxDrawRectangle(x + titleWidth + 10, y - buttonSize2, sideWidth, buttonSize, tocolor(61, 122, 188, 175))
		activeButton = "side:" .. performanceSide
	else
		dxDrawRectangle(x + titleWidth + 10, y - buttonSize2, sideWidth, buttonSize, tocolor(50, 50, 50, 200))
	end
	dxDrawText("Switch to " .. performanceSide .. " side", x + titleWidth + 10, y - buttonSize2, x + titleWidth + 10 + sideWidth, y - buttonSize2 + buttonSize, tocolor(255, 255, 255), 1, RobotoFont, "center", "center")

	titleWidth = titleWidth + sideWidth + 5
	sideWidth = dxGetTextWidth(performanceCategories[performanceCategoryId + 1] or performanceCategories[1], 1, RobotoFont) + 10

	if cx >= x + titleWidth + 10 and cy >= y - buttonSize2 and cx <= x + titleWidth + 10 + sideWidth and cy <= y - buttonSize2 + buttonSize then
		dxDrawRectangle(x + titleWidth + 10, y - buttonSize2, sideWidth, buttonSize, tocolor(61, 122, 188, 175))
		activeButton = "switchCategory"
	else
		dxDrawRectangle(x + titleWidth + 10, y - buttonSize2, sideWidth, buttonSize, tocolor(50, 50, 50, 200))
	end
	dxDrawText(performanceCategories[performanceCategoryId + 1] or performanceCategories[1], x + titleWidth + 10, y - buttonSize2, x + titleWidth + 10 + sideWidth, y - buttonSize2 + buttonSize, tocolor(255, 255, 255), 1, RobotoFont, "center", "center")

	if performanceElementType == "anotherClient" and isElement(performanceElement) then
		dxDrawText("Client: " .. string.gsub(string.gsub(getPlayerName(performanceElement), "_", " "), "#%x%x%x%x%x%x", ""), x, y2, x + panelWidth - 10, y, tocolor(255, 255, 255), 0.8, RobotoFont, "right", "center")
	end

	dxDrawRectangle(x, y, panelWidth, rowHeight, tocolor(0, 0, 0, 125))

	local x_offset = x

	for i = 1, #statsColumn do
		local rowWidth = rowsWidth[i]

		if cx >= x_offset and cy >= y and cx <= x_offset + rowWidth and cy <= y + rowHeight and not activeButton then
			activeButton = "sortBy:" .. i
			dxDrawRectangle(x_offset, y, rowWidth, rowHeight, tocolor(61, 122, 188, 175))
		end

		if i ~= 1 then
			dxDrawRectangle(x_offset, y, 1, rowHeight, tocolor(0, 0, 0, 255))
		end
		dxDrawText(statsColumn[i], x_offset + 1, y, x_offset + 1 + rowWidth - 1, y + rowHeight, tocolor(255, 255, 255), 1.0, RobotoFont, "center", "center", true)

		x_offset = x_offset + rowWidth
	end

	dxDrawRectangle(x, y + rowHeight, panelWidth, 2, tocolor(0, 0, 0, 255))

	if isElement(renderTarget) then
		y = y + rowHeight

		local currentTick = getTickCount()

		if scrollbarStartTick and currentTick >= scrollbarStartTick then
			scrollbarPosition = interpolateBetween(scrollbarPosition, 0, 0, scrollOffset, 0, 0, (currentTick - scrollbarStartTick) / 500, "OutQuad")
		end

		dxDrawImageSection(x, y, panelWidth, panelHeight, 0, scrollbarPosition * rowHeight, panelWidth, panelHeight, renderTarget)

		if #statsRow > visibleItem then
			dxDrawRectangle(x + panelWidth - 5, y, 5, panelHeight, tocolor(30, 30, 30, 200))
			dxDrawRectangle(x + panelWidth - 5, y + (panelHeight / #statsRow) * scrollbarPosition, 5, (panelHeight / #statsRow) * visibleItem, tocolor(61, 122, 188, 200))
		end
	end
end

function keyPerformance(key)
	if #statsRow > visibleItem then
		if key == "mouse_wheel_down" and scrollOffset < #statsRow - visibleItem then
			scrollbarStartTick = getTickCount()
			scrollOffset = scrollOffset + visibleItem
	
			if scrollOffset > #statsRow - visibleItem then
				scrollOffset = #statsRow - visibleItem
			end
		elseif key == "mouse_wheel_up" and scrollOffset > 0 then
			scrollbarStartTick = getTickCount()
			scrollOffset = scrollOffset - visibleItem
			
			if scrollOffset < 0 then
				scrollOffset = 0
			end
		end
	end
end

function clickPerformance(button, state)
	if state == "up" then
		if activeButton then
			local selected = split(activeButton, ":")

			if selected[1] == "sortBy" then
				local columnId = tonumber(selected[2])

				if columnId == rowsSortBy then
					rowsSortAlign = not rowsSortAlign
				else
					rowsSortAlign = true
					rowsSortBy = columnId
				end
			elseif selected[1] == "sampleRate" then
				if selected[2] == "plus" then
					if isTimer(dataRefreshTimer) then
						killTimer(dataRefreshTimer)
					end

					if sampleRate < 10000 then
						sampleRate = sampleRate + 500
					end

					dataRefreshTimer = setTimer(dataRefresh, sampleRate, 0)
				elseif selected[2] == "minus" then
					if isTimer(dataRefreshTimer) then
						killTimer(dataRefreshTimer)
					end

					if sampleRate > 500 then
						sampleRate = sampleRate - 500
					end

					dataRefreshTimer = setTimer(dataRefresh, sampleRate, 0)
				end
			elseif selected[1] == "side" then
				performanceElementType = selected[2]
			elseif selected[1] == "switchCategory" then
				performanceCategoryId = performanceCategoryId + 1

				if performanceCategoryId > #performanceCategories then
					performanceCategoryId = 1
				end

				performanceCategory = performanceCategories[performanceCategoryId]
			end

			if selected[1] then
				dataRefresh()
			end
		end
	end
end

--[[local eventList = {}

setTimer(
  function () 
    if next(eventList) then
      outputConsole(inspect(eventList))
      eventList = {}
    end
  end, 10000, 0
)

addDebugHook( "preEvent", 
  function ( sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ... )
    local i = inspect(sourceResource).."/"..eventName.."/"..inspect(eventSource)
    eventList[i] = (eventList[i] and eventList[i] + 1) or 1
  end--, "onElementDataChange"
)--]]