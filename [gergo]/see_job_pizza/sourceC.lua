local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local lastNames = {
	"Bell", "Walsh", "Black", "Butler", "Thompson", "O'connor", "Marquez", "Morales", "Douglas", "Hendrix",
	"Chapman", "Adams", "Harper", "Saunders", "Reynolds", "Lara", "Wong", "Leon", "Mayo", "Donaldson",
	"Stewart", "Wallace", "Bell", "Sutton", "Shaw", "Carson", "Ferrell", "Donovan", "Carson", "Mathis",
	"Riley", "West", "Stone", "Hughes", "Lawson", "Zamora", "Cotton", "Silva", "Frye", "Townsend",
	"Hopkins", "Brown", "Kelly", "Harris", "Harvey", "Sparks", "Gonzales", "Lane", "Meyer", "Vazquez",
	"Day", "Hayes", "Wilson", "Howard", "Jordan", "Mills", "Daugherty", "Manning", "Franklin", "Duffy"
}

local maleNames = {
	"Jess", "Leigh", "Elliot", "Rory", "Silver", "Emerson", "Kris", "Tyler", "Riley", "Casey",
	"Ashton", "Sam", "Taylor", "Ollie", "Christoph", "Brennen", "Cedric", "Otto", "Colten", "Jameson",
	"Morgan", "Bobby", "Anthony", "Arthur", "Leo", "Gilbert", "Jaycob", "Wade", "Louis", "Arthur",
	"Jake", "Declan", "Kian", "Charles", "Anthony", "Kayson", "Bryan", "Caiden", "Foster", "Moshe",
	"Arthur", "Zak", "Alex", "Lucas", "Oliver", "Atticus", "Randall", "Prince", "Royce", "Jalen",
	"Kayden", "Matthew", "Ryan", "Ollie", "Edward", "Levi", "Fletcher", "William", "Hassan", "Ernesto"
}

local femaleNames = {
	"Amber", "Rosie", "Kayleigh", "Mollie", "Mya", "Jenna", "Brynlee", "Ryleigh", "Jillian", "Kylah",
	"Paige", "Lucy", "Alisha", "Daisy", "Zoe", "Caroline", "Alisha", "Jane", "Michaela", "Karla",
	"Holly", "Isabel", "Leah", "Erin", "Charlotte", "Carleigh", "Everly", "Audrianna", "Melanie", "Sky",
	"Evelyn", "Amelie", "Kayleigh", "Emma", "Abby", "Alyssa", "Miley", "Thalia", "Sasha", "Adley",
	"Matilda", "Abby", "Kayla", "Skye", "Paige", "Gisselle", "Angelina", "Iris", "Zahra", "Yareli",
	"Molly", "Lola", "Lara", "Amy", "Freya", "Eliana", "Carissa", "Laney", "Danica", "Clarissa"
}

local maleSkins = exports.see_binco:getSkinsByType("Férfi")
local femaleSkins = exports.see_binco:getSkinsByType("Női")

local jobPedElement = createPed(155, 2367.2255859375, 2549.41796875, 10.8203125, 270)
local jobPedBlip = false

setElementFrozen(jobPedElement, true)
setElementData(jobPedElement, "invulnerable", true)
setElementData(jobPedElement, "visibleName", "Joe", false)
setElementData(jobPedElement, "pedNameType", "Munka", false)

local pizzaOrders = false
local requestJobStart = false

local animControls = false
local carriedObjects = {}

addEventHandler("onClientVehicleStartEnter", getRootElement(),
	function (enterPlayer)
		if enterPlayer == localPlayer then
			if carriedObjects[localPlayer] then
				cancelEvent()
			end
		end
	end
)

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (enterPlayer, seat)
		if enterPlayer == localPlayer then
			if seat == 0 then
				if getElementModel(source) == 448 then
					if getElementData(localPlayer, "char.Job") == jobID then
						if not pizzaOrders then
							outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffMenj #3d7abcJoe#ffffff-hoz, és vedd fel a rendeléseket. (Jobbklikk az NPC-n)", 255, 255, 255, true)
							
							if not isElement(jobPedBlip) then
								local x, y, z = getElementPosition(jobPedElement)
								jobPedBlip = createBlip(x, y, z, 0, 2, 61, 122, 188)
								setElementData(jobPedBlip, "blipTooltipText", "Joe")
							end
						end

						if animControls then
							animControls = false
							exports.see_controls:toggleControl({"steer_forward", "steer_back"}, animControls)
							addEventHandler("onClientRender", getRootElement(), checkVehicle)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientVehicleExit", getRootElement(),
	function (leftPlayer, seat)
		if leftPlayer == localPlayer then
			if seat == 0 then
				if getElementModel(source) == 448 then
					if isElement(jobPedBlip) then
						destroyElement(jobPedBlip)
					end

					jobPedBlip = nil
				end
			end
		end
	end
)

function checkVehicle()
	if not isPedInVehicle(localPlayer) then
		if not animControls then
			animControls = true
			exports.see_controls:toggleControl({"steer_forward", "steer_back"}, animControls)
			removeEventHandler("onClientRender", getRootElement(), checkVehicle)
		end
	end
end

local notesWidth = respc(256)
local notesHeight = respc(256)

local notesPosX = math.floor(screenX - notesWidth * 1.15)
local notesPosY = math.floor(screenY / 2 - notesHeight / 2)

local notesMoving = false
local handFont = false

local pizzaBoyInventory = false
local pizzaBoyElement = false

local activeButton = false

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
		if state == "up" then
			if isElement(clickedElement) then
				if clickedElement == jobPedElement then
					if getElementData(localPlayer, "char.Job") == jobID then
						local playerX, playerY, playerZ = getElementPosition(localPlayer)
						local targetX, targetY, targetZ = getElementPosition(clickedElement)

						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 3 then
							if not pizzaOrders and not requestJobStart then
								local jobVehicle = getElementData(localPlayer, "jobVehicle")

								if isPedInVehicle(localPlayer) then
									outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffElőbb szállj ki a járművedből.", 255, 255, 255, true)
									return
								end

								if not jobVehicle or getElementModel(jobVehicle) ~= 448 then
									outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffElőbb kérj egy robogót a #F0E76Cmunkajármű#ffffff ikonnál.", 255, 255, 255, true)
									return
								end

								requestJobStart = true
								triggerServerEvent("requestPizzaJobStart", localPlayer)
							end
						end
					end
				end
			end
		end
	end
)

addEvent("pizzaDeliveredSuccessfully", true)
addEventHandler("pizzaDeliveredSuccessfully", getRootElement(),
	function (orderId, remainingPizzas)
		pizzaOrders[orderId][6] = true

		if isElement(pizzaOrders[orderId][4]) then
			destroyElement(pizzaOrders[orderId][4])
		end

		if isElement(pizzaOrders[orderId][2]) then
			destroyElement(pizzaOrders[orderId][2])
		end

		if isElement(pizzaOrders[orderId][10]) then
			destroyElement(pizzaOrders[orderId][10])
		end

		setElementData(localPlayer, "carryingPizza", false)
		exports.see_controls:toggleControl({"jump", "aim_weapon", "fire", "enter_exit", "enter_passenger", "crouch"}, true)

		if remainingPizzas <= 0 then
			endTheJob()
		end
	end
)

addEvent("onPizzaJobStarted", true)
addEventHandler("onPizzaJobStarted", localPlayer,
	function (recipients, positions, pizzas)
		if isElement(jobPedBlip) then
			destroyElement(jobPedBlip)
		end
		
		requestJobStart = false
		pizzaOrders = {}

		shuffleTable(lastNames)
		shuffleTable(maleNames)
		shuffleTable(femaleNames)

		local carryingPizza = {}

		for i = 1, recipients do
			local visibleName = "_" .. lastNames[i]
			local skinId = 0

			if math.random(2) == 1 then
				skinId = maleSkins[math.random(1, #maleSkins)][1]
				visibleName = maleNames[i] .. visibleName
			else
				skinId = femaleSkins[math.random(1, #femaleSkins)][1]
				visibleName = femaleNames[i] .. visibleName
			end

			local position = positions[i]
			local pedElement = createPed(skinId, unpack(position))
			local markerElement = createMarker(position[1], position[2], position[3] + 1.5, "arrow", 0.3, 61, 122, 188)
			local blipElement = createBlip(position[1], position[2], position[3], 0, 2, 61, 122, 188)
			local zoneName = getZoneName(position[1], position[2], position[3])

			setElementFrozen(pedElement, true)
			setElementData(pedElement, "visibleName", visibleName, false)
			setElementData(pedElement, "pedNameType", "Munka", false)
			setElementData(pedElement, "invulnerable", true)
			setElementData(blipElement, "blipTooltipText", visibleName:gsub("_", " ") .. " - " .. zoneName)

			table.insert(pizzaOrders, {
				pedElement,
				false,
				pizzas[i],
				markerElement,
				math.random(2),
				false,
				visibleName:gsub("_", " "),
				zoneName,
				pizzaTypes[pizzas[i]],
				blipElement
			})

			table.insert(carryingPizza, pizzas[i])
		end

		setElementData(localPlayer, "carryingPizza", carryingPizza)

		triggerServerEvent("pizzaCarryAnimation", localPlayer)
		exports.see_controls:toggleControl({"jump", "aim_weapon", "fire", "enter_exit", "enter_passenger", "crouch"}, false)

		handFont = dxCreateFont("files/hand.otf", respc(24), false, "antialiased")
		addEventHandler("onClientRender", getRootElement(), renderStickyNotes)

		outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffFelvetted a rendeléseket. Tedd be a motorba a pizzákat. (Jobbklikk a motoron)", 255, 255, 255, true)
		outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffA #3d7abcrendeléseket#ffffff a térképen látod.", 255, 255, 255, true)
		outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffVidd a #3d7abcmegrendelőhöz#ffffff a pizzát.", 255, 255, 255, true)
		outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffA robogó csomagtartóját a jobbklikk segitségével nyithatod meg.", 255, 255, 255, true)
	end
)

function renderStickyNotes()
	local cursorX, cursorY = getCursorPosition()

	if cursorX then
		cursorX = cursorX * screenX
		cursorY = cursorY * screenY

		if getKeyState("mouse1") then
			if notesMoving then
				notesPosX = math.floor(notesMoving[3] + cursorX - notesMoving[1])
				notesPosY = math.floor(notesMoving[4] + cursorY - notesMoving[2])
			else
				if cursorX > notesPosX and cursorY > notesPosY and cursorX < notesPosX + notesWidth and cursorY < notesPosY + notesHeight then
					notesMoving = {cursorX, cursorY, notesPosX, notesPosY}
				end
			end
		else
			notesMoving = false
		end
	end

	dxDrawImage(notesPosX, notesPosY, notesWidth, notesHeight, "files/notes.png")
	
	for i = 1, #pizzaOrders do
		local order = pizzaOrders[i]

		local x = notesPosX + respc(13)
		local y = notesPosY + respc(40) + respc(35) * (i - 1)

		dxDrawText(order[7] .. " - " .. order[9], x, y, 0, 0, tocolor(0, 84, 166), 0.475, handFont, "left", "top")
		dxDrawText(order[8], x, y + 16, 0, 0, tocolor(0, 84, 166), 0.45, handFont, "left", "top")
		
		if order[6] then
			dxDrawLine(x - 2, y + respc(10), x + dxGetTextWidth(order[7] .. " - " .. order[9], 0.475, handFont) + 2, y + respc(10), tocolor(0, 84, 166), 2.5)
			dxDrawLine(x - 2, y + respc(26), x + dxGetTextWidth(order[8], 0.45, handFont) + 2, y + respc(26), tocolor(0, 84, 166), 2.5)
		end
	end
end

addEvent("openPizzaBoy", true)
addEventHandler("openPizzaBoy", getRootElement(),
	function ()
		pizzaBoyInventory = getElementData(source, "pizzaBoyInventory") or {}
		pizzaBoyElement = source

		if isElement(pizzaBoyElement) then
			Roboto = dxCreateFont("files/Roboto.ttf", 12, false, "antialiased")

			showCursor(true)
			addEventHandler("onClientRender", getRootElement(), renderInventory)
			addEventHandler("onClientClick", getRootElement(), clickInventory)
		end
	end
)

function clickInventory(button, state)
	if state == "up" then
		if activeButton then
			if string.find(activeButton, "get_out:") then
				local pizzaType = tonumber(gettok(activeButton, 2, ":"))

				if pizzaType then
					if pizzaBoyInventory[pizzaType] and pizzaBoyInventory[pizzaType] > 0 then
						triggerServerEvent("getOutPizza", localPlayer, pizzaBoyElement, pizzaType)

						exports.see_chat:localActionC(localPlayer, "kivett egy " .. pizzaTypes[pizzaType] .. "-t a robogóból.")
					else
						exports.see_hud:showInfobox("e", "Ebből a fajta pizzából nincs a motorodban!")
						return
					end
				end
			end

			if activeButton == "exit" then
				setElementData(localPlayer, "usingPizzaBoy", false)
			end

			if isElement(Roboto) then
				destroyElement(Roboto)
			end

			showCursor(false)
			removeEventHandler("onClientRender", getRootElement(), renderInventory)
			removeEventHandler("onClientClick", getRootElement(), clickInventory)
		end
	end
end

function renderInventory()
	if not isElement(pizzaBoyElement) then
		setElementData(localPlayer, "usingPizzaBoy", false)

		if isElement(Roboto) then
			destroyElement(Roboto)
		end

		showCursor(false)
		removeEventHandler("onClientRender", getRootElement(), renderInventory)
		removeEventHandler("onClientClick", getRootElement(), clickInventory)

		return
	end

	local buttons = {}

	local sx, sy = 255, 32 * (#pizzaTypes + 1)
	local x = screenX / 2 - sx / 2
	local y = screenY / 2 - sy / 2

	-- ** Keret
	dxDrawRectangle(x - 2, y, 2, sy, tocolor(0, 0, 0, 255)) -- bal
	dxDrawRectangle(x + sx, y, 2, sy, tocolor(0, 0, 0, 255)) -- jobb
	dxDrawRectangle(x - 2, y - 2, sx + 4, 2, tocolor(0, 0, 0, 255)) -- felső
	dxDrawRectangle(x - 2, y + sy, sx + 4, 2, tocolor(0, 0, 0, 255)) -- alsó
	
	-- ** Háttér
	dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 100))
	dxDrawImage(x, y + 32, sx, sy - 32, ":see_hud/files/images/vin.png")

	-- ** Cím
	dxDrawRectangle(x, y, sx, 32, tocolor(0, 0, 0, 200))
	dxDrawText("Pizzaboy", x + 4, y, x + sx, y + 32, tocolor(61, 122, 188), 1, Roboto, "left", "center")

	-- ** Content
	buttons.exit = {x + sx - 4 - 28, y + 16 - 14, 28, 28}

	if activeButton == "exit" then
		dxDrawImage(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], "files/close.png", 0, 0, 0, tocolor(215, 89, 89))
	else
		dxDrawImage(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], "files/close.png", 0, 0, 0, tocolor(255, 255, 255, 200))
	end

	y = y + 32

	for i = 1, #pizzaTypes do
		local buttonName = "get_out:" .. i

		dxDrawText(pizzaTypes[i], x + 8, y, 0, y + 32, tocolor(255, 255, 255), 0.85, Roboto, "left", "center")

		buttons[buttonName] = {x + sx - 8 - 64, y + 4, 64, 32 - 8}

		dxDrawText((pizzaBoyInventory[i] or 0) .. " db", x, y, buttons[buttonName][1] - 8, y + 32, tocolor(255, 255, 255), 0.825, Roboto, "right", "center")

		if activeButton == buttonName then
			dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(61, 122, 188))
		else
			dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(61, 122, 188, 165))
		end

		dxDrawText("Kivesz", buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][1] + buttons[buttonName][3], buttons[buttonName][2] + buttons[buttonName][4], tocolor(0, 0, 0), 0.825, Roboto, "center", "center")

		y = y + 32
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

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setElementData(localPlayer, "usingPizzaBoy", false)
		setElementData(localPlayer, "carryingPizza", false)
	end
)

function endTheJob(forced)
	if pizzaOrders then
		local pedElements = {}

		for i = 1, #pizzaOrders do
			table.insert(pedElements, pizzaOrders[i][1])
		end

		pizzaOrders = false

		if not forced then
			if not isElement(jobPedBlip) then
				local x, y, z = getElementPosition(jobPedElement)
				jobPedBlip = createBlip(x, y, z, 0, 2, 61, 122, 188)
				setElementData(jobPedBlip, "tooltipText", "Joe")
			end

			outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffLeszállítottad az összes pizzát. Új rendelések felvételéhez menj #3d7abcJoe#ffffff-hoz.", 255, 255, 255, true)
		else
			if isElement(jobPedBlip) then
				destroyElement(jobPedBlip)
			end

			jobPedBlip = nil
		end

		setTimer(
			function ()
				for i = 1, #pedElements do
					if isElement(pedElements[i]) then
						destroyElement(pedElements[i])
					end
				end
			end,
		10000, 1)

		if isElement(handFont) then
			destroyElement(handFont)
		end

		handFont = nil

		removeEventHandler("onClientRender", getRootElement(), renderStickyNotes)
	end
end

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		if carriedObjects[source] then
			for i = 1, #carriedObjects[source] do
				local objectElement = carriedObjects[source][i]

				if isElement(objectElement) then
					destroyElement(objectElement)
				end
			end

			carriedObjects[source] = nil
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "carryingPizza" then
			local dataValue = getElementData(source, dataName)

			if dataValue and #dataValue > 0 then
				if not carriedObjects[source] then
					carriedObjects[source] = {}
				end

				if #carriedObjects[source] < #dataValue then
					for i = #carriedObjects[source] + 1, #dataValue do
						local objectElement = createObject(1582, 0, 0, 0)

						if isElement(objectElement) then
							setObjectScale(objectElement, 0.9)
							exports.see_boneattach:attachElementToBone(objectElement, source, 12, 0.15 + 0.015 * (i - 1), 0 + 0.055 * (i - 1), 0.15, -100, 0, -20)

							table.insert(carriedObjects[source], objectElement)
						end
					end
				elseif #carriedObjects[source] > #dataValue then
					for i = #carriedObjects[source], #dataValue + 1, -1 do
						local objectElement = carriedObjects[source][i]

						if isElement(objectElement) then
							destroyElement(objectElement)
						end

						carriedObjects[source][i] = nil
					end
				end
			else
				if carriedObjects[source] then
					for i = 1, #carriedObjects[source] do
						local objectElement = carriedObjects[source][i]

						if isElement(objectElement) then
							destroyElement(objectElement)
						end
					end

					carriedObjects[source] = nil
				end
			end
		elseif dataName == "char.Job" or dataName == "jobVehicle" then
			if source == localPlayer then
				local characterJob = getElementData(localPlayer, "char.Job")
				local jobVehicle = getElementData(localPlayer, "jobVehicle")

				if characterJob ~= jobID or not jobVehicle then
					if pizzaOrders then
						if getElementData(localPlayer, "carryingPizza") then
							exports.see_controls:toggleControl({"jump", "aim_weapon", "fire", "enter_exit", "enter_passenger", "crouch"}, true)
						end

						for i = 1, #pizzaOrders do
							local datas = pizzaOrders[i]

							for j = 1, #datas do
								if isElement(datas[j]) then
									destroyElement(datas[j])
								end
							end
						end
					end

					endTheJob(true)

					local usingPizzaBoy = getElementData(localPlayer, "usingPizzaBoy")

					if isElement(usingPizzaBoy) then
						setElementData(usingPizzaBoy, "pizzaBoyInventory", false)
					end

					setElementData(localPlayer, "usingPizzaBoy", false)
					setElementData(localPlayer, "carryingPizza", false)
				end
			end
		end
	end
)