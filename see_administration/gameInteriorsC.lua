local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = 1

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local gameInteriors = {}
local interiorList = {}
local visibleItem = 0

local panelState = false
local activeButton = false

local activeSearchInput = false
local searchInputText = ""

local cursorStateChange = 0
local cursorState = true
local clickTick = 0

local Roboto = false
local RobotoL = false

addEventHandler("onClientResourceStart", getRootElement(),
	function (startedResource)
		if getResourceName(startedResource) == "see_hud" then
			responsiveMultipler = exports.see_hud:getResponsiveMultipler()
		elseif getResourceName(startedResource) == "see_interiors" then
			gameInteriors = exports.see_interiors:getGameInteriors()
		elseif startedResource == getThisResource() then
			local see_hud = getResourceFromName("see_hud")

			if see_hud and getResourceState(see_hud) == "running" then
				responsiveMultipler = exports.see_hud:getResponsiveMultipler()
			end

			local see_interiors = getResourceFromName("see_interiors")

			if see_interiors and getResourceState(see_interiors) == "running" then
				gameInteriors = exports.see_interiors:getGameInteriors()
			end
		end
	end
)

function createFonts()
	destroyFonts()

	Roboto = dxCreateFont("files/Roboto.ttf", respc(18), false, "antialiased")
	RobotoL = dxCreateFont("files/Roboto.ttf", respc(15), false, "antialiased")
end

function destroyFonts()
	if isElement(Roboto) then
		destroyElement(Roboto)
	end

	Roboto = nil

	if isElement(RobotoL) then
		destroyElement(RobotoL)
	end

	RobotoL = nil
end

addCommandHandler("gameinteriors",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 6 then
			panelState = not panelState

			if panelState then
				searchProcess()
				createFonts()

				addEventHandler("onClientRender", getRootElement(), renderThePanel)
				addEventHandler("onClientClick", getRootElement(), clickOnPanel)
				addEventHandler("onClientKey", getRootElement(), scrollInPanel)
				addEventHandler("onClientCharacter", getRootElement(), searchInList)

				playSound("files/open.mp3", false)
			else
				removeEventHandler("onClientRender", getRootElement(), renderThePanel)
				removeEventHandler("onClientClick", getRootElement(), clickOnPanel)
				removeEventHandler("onClientKey", getRootElement(), scrollInPanel)
				removeEventHandler("onClientCharacter", getRootElement(), searchInList)

				destroyFonts()

				playSound("files/close.mp3", false)
			end
		end
	end
)

function searchProcess()
	interiorList = {}

	if utf8.len(searchInputText) < 1 then
		for k, v in pairs(gameInteriors) do
			if k ~= "e" then
				table.insert(interiorList, {k, v})
			end
		end
	elseif tonumber(searchInputText) then
		searchInputText = tonumber(searchInputText)

		if gameInteriors[searchInputText] then
			table.insert(interiorList, {searchInputText, gameInteriors[searchInputText]})
		end
	else
		for k, v in pairs(gameInteriors) do
			if k ~= "e" then
				if utf8.find(utf8.lower(v.name), utf8.lower(searchInputText)) then
					table.insert(interiorList, {k, v})
				end
			end
		end
	end

	if visibleItem < 0 then
		visibleItem = 0
	end

	if #interiorList > 15 then
		if visibleItem > #interiorList - 15 then
			visibleItem = #interiorList - 15
		end
	else
		visibleItem = 0
	end
end

function searchInList(character)
	if activeSearchInput then
		searchInputText = searchInputText .. character
		searchProcess()
		cancelEvent()
	end
end

function scrollInPanel(key, press)
	local relX, relY = getCursorPosition()

	if tonumber(relX) and tonumber(relY) then
		if key == "mouse_wheel_up" then
			if visibleItem > 0 then
				visibleItem = visibleItem - 15

				if visibleItem < 0 then
					visibleItem = 0
				end
			end
		elseif key == "mouse_wheel_down" then
			visibleItem = visibleItem + 15

			if #interiorList > 15 then
				if visibleItem > #interiorList - 15 then
					visibleItem = #interiorList - 15
				end
			else
				visibleItem = 0
			end
		end
	end

	if activeSearchInput then
		if key == "backspace" then
			if press then
				searchInputText = utf8.sub(searchInputText, 1, utf8.len(searchInputText) - 1)
				searchProcess()
			end
		end

		if key ~= "escape" then
			cancelEvent()
		end
	end
end

function clickOnPanel(button, state, absX, absY)
	if button == "left" then
		if state == "up" then
			if activeButton then
				if activeButton == "exit" then
					executeCommandHandler("gameinteriors")
				elseif activeButton == "searchInput" then
					if not activeSearchInput then
						activeSearchInput = true

						cursorStateChange = getTickCount()
						cursorState = true

						playSound("files/select.mp3", false)
					end
				else
					local selected = split(activeButton, "_")

					if selected[1] == "view" then
						local id = tonumber(selected[2])

						if id then
							if getTickCount() - clickTick >= 1000 then
								if not isPedInVehicle(localPlayer) then
									if gameInteriors[id] then
										executeCommandHandler("gameinteriors")

										triggerServerEvent("warpToGameInterior", localPlayer, id, gameInteriors[id])

										clickTick = getTickCount()

										playSound("files/select.mp3", false)
									else
										exports.see_hud:showInfobox("e", "Nem létező interior!")
									end
								else
									exports.see_hud:showInfobox("e", "Előbb szállj ki a járműből!")
								end
							else
								exports.see_hud:showInfobox("e", "Ne ilyen gyorsan!")
							end
						end
					end
				end
			end
		elseif state == "down" then
			if activeButton ~= "searchInput" then
				if activeSearchInput then
					activeSearchInput = false
				end
			end
		end
	end
end

function renderThePanel()
	local sx = respc(600)
	local sy = respc(40 + 600 + 40)

	local x = math.floor(screenX / 2 - sx / 2)
	local y = math.floor(screenY / 2 - sy / 2)

	-- ** Keret
	dxDrawRectangle(x - 2, y, 2, sy, tocolor(0, 0, 0, 255)) -- bal
	dxDrawRectangle(x + sx, y, 2, sy, tocolor(0, 0, 0, 255)) -- jobb
	dxDrawRectangle(x - 2, y - 2, sx + 4, 2, tocolor(0, 0, 0, 255)) -- felső
	dxDrawRectangle(x - 2, y + sy, sx + 4, 2, tocolor(0, 0, 0, 255)) -- alsó
	
	-- ** Háttér
	dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 100))
		
	-- ** Cím
	dxDrawRectangle(x, y, sx, respc(40), tocolor(0, 0, 0, 200))
	dxDrawText("#ffffffStrong#3d7abcMTA #ffffff- Interior belsők", x + respc(7), y, x + sx, y + respc(40), tocolor(255, 255, 255), 0.8, Roboto, "left", "center", false, false, false, true)
		
	-- ** Content
	local buttons = {}

	buttons.exit = {x + sx - respc(28) - respc(5), y + respc(40) / 2 - respc(14), respc(28), respc(28)}

	if activeButton == "exit" then
		dxDrawImage(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], "files/close.png", 0, 0, 0, tocolor(215, 89, 89))
	else
		dxDrawImage(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], "files/close.png", 0, 0, 0, tocolor(255, 255, 255))
	end

	-- Lista
	local oneButtonHeight = (sy - respc(40) - respc(40)) / 15

	for i = 1, 15 do
		local y2 = y + respc(40) + oneButtonHeight * (i - 1)

		if i % 2 ~= visibleItem % 2 then
			dxDrawRectangle(x, y2, sx, oneButtonHeight, tocolor(0, 0, 0, 125))
		else
			dxDrawRectangle(x, y2, sx, oneButtonHeight, tocolor(0, 0, 0, 150))
		end

		local v = interiorList[i + visibleItem]

		if v then
			dxDrawText("#3d7abc[" .. v[1] .. "] #ffffff" .. v[2].name, x + respc(5), y2, x + sx, y2 + oneButtonHeight, tocolor(255, 255, 255), 0.65, Roboto, "left", "center", false, true, false, true)
			
			local btnSizeX = dxGetTextWidth("Megtekint", 0.9, RobotoL) + respc(2.5)
			local btnSizeY = dxGetFontHeight(0.9, RobotoL)
			local btnName = "view_" .. v[1]

			buttons[btnName] = {x + sx - btnSizeX - respc(15), y2 + oneButtonHeight / 2 - btnSizeY / 2, btnSizeX, btnSizeY}

			if activeButton == btnName then
				dxDrawRectangle(buttons[btnName][1], buttons[btnName][2], buttons[btnName][3], buttons[btnName][4], tocolor(61, 122, 188, 200))
			else
				dxDrawRectangle(buttons[btnName][1], buttons[btnName][2], buttons[btnName][3], buttons[btnName][4], tocolor(61, 122, 188, 150))
			end

			dxDrawText("Megtekint", buttons[btnName][1], buttons[btnName][2], buttons[btnName][1] + buttons[btnName][3], buttons[btnName][2] + buttons[btnName][4], tocolor(0, 0, 0), 0.725, RobotoL, "center", "center")
		end
	end

	if #interiorList > 15 then
		local contentRatio = (oneButtonHeight * 15) / #interiorList

		dxDrawRectangle(x + sx - respc(5), y + respc(40), respc(5), oneButtonHeight * 15, tocolor(0, 0, 0, 200))
		dxDrawRectangle(x + sx - respc(5), y + respc(40) + visibleItem * contentRatio, respc(5), contentRatio * 15, tocolor(61, 122, 188, 150))
	end

	-- Kereső mező
	dxDrawRectangle(x, y + sy - respc(40), sx, respc(40), tocolor(0, 0, 0, 200))
	
	buttons.searchInput = {x + respc(5), y + sy - respc(40) + respc(5), sx - respc(10), respc(40) - respc(10)}

	dxDrawRectangle(buttons.searchInput[1], buttons.searchInput[2], buttons.searchInput[3], buttons.searchInput[4], tocolor(100, 100, 100, 50))

	if utf8.len(searchInputText) < 1 and not activeSearchInput then
		dxDrawText("Keresés...", buttons.searchInput[1] + respc(5), buttons.searchInput[2], buttons.searchInput[1] + buttons.searchInput[3] - respc(5), buttons.searchInput[2] + buttons.searchInput[4], tocolor(255, 255, 255), 0.75, Roboto, "left", "center", true)
	else
		if activeSearchInput and cursorState then
			dxDrawText(searchInputText .. "|", buttons.searchInput[1] + respc(5), buttons.searchInput[2], buttons.searchInput[1] + buttons.searchInput[3] - respc(5), buttons.searchInput[2] + buttons.searchInput[4], tocolor(255, 255, 255), 0.75, Roboto, "left", "center", true)
		else
			dxDrawText(searchInputText, buttons.searchInput[1] + respc(5), buttons.searchInput[2], buttons.searchInput[1] + buttons.searchInput[3] - respc(5), buttons.searchInput[2] + buttons.searchInput[4], tocolor(255, 255, 255), 0.75, Roboto, "left", "center", true)
		end
	end

	if activeSearchInput then
		if getTickCount() - cursorStateChange >= 500 then
			cursorStateChange = getTickCount()
			cursorState = not cursorState
		end
	end

	-- ** Button handler
	activeButton = false

	if isCursorShowing() then
		local relX, relY = getCursorPosition()
		local absX, absY = relX * screenX, relY * screenY

		for k, v in pairs(buttons) do
			if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end