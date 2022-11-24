local screenW, screenH = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

local panelState = false
local panelWidth = 500
local panelHeight = 400
local panelPosX = (screenW - panelWidth) / 2
local panelPosY = (screenH - panelHeight) / 2
local Roboto = false

local toggables = {}

function respc(x)
	return math.ceil(x * responsiveMultipler)
end

local mods = {}
local modsNum = 0
local vehiclesXML = xmlLoadFile("save.xml") or xmlCreateFile("save.xml", "vehicles")

local function registerVehicleMod(fileName, model, isNotToggable)
	model = model or fileName

	modsNum = #mods + 1
	mods[modsNum] = {}
	mods[modsNum].model = tonumber(model) or getVehicleModelFromName(model)
	mods[modsNum].path = fileName

	if isNotToggable then
		mods[modsNum].toggable = false
	else
		mods[modsNum].toggable = true
	end

	mods[modsNum].state = true
end

registerVehicleMod("csher", 427, true)
registerVehicleMod("baggage")
registerVehicleMod("perennial")
registerVehicleMod("camper")
registerVehicleMod("dune", 573, true)
registerVehicleMod("taxi")
registerVehicleMod("cabbie")
registerVehicleMod("zr-350")
registerVehicleMod("regina")
registerVehicleMod("previon")
registerVehicleMod("intruder")
registerVehicleMod("phoenix")
registerVehicleMod("emperor")
registerVehicleMod("primo")
registerVehicleMod("voodoo")
registerVehicleMod("cheetah")
registerVehicleMod("supergt", "super gt")
registerVehicleMod("moonbeam")
registerVehicleMod("bravura")
registerVehicleMod("raindance")
--registerVehicleMod("alpha")
registerVehicleMod("banshee")
registerVehicleMod("turismo")
registerVehicleMod("hotrina", 502)
registerVehicleMod("admiral")
registerVehicleMod("blistac", 496)
registerVehicleMod("cadrona")
registerVehicleMod("elegant")
registerVehicleMod("faggio")
registerVehicleMod("freeway")
registerVehicleMod("infernus")
registerVehicleMod("journey")
registerVehicleMod("majestic")
registerVehicleMod("merit")
registerVehicleMod("mesa")
registerVehicleMod("nebula")
registerVehicleMod("oceanic")
registerVehicleMod("bullet")
registerVehicleMod("pony")
registerVehicleMod("rancher")
registerVehicleMod("feltzer")
--registerVehicleMod("premier")
registerVehicleMod("sadlshit", 605)
registerVehicleMod("sentinel")
registerVehicleMod("speeder")
registerVehicleMod("squalo")
registerVehicleMod("stafford")
registerVehicleMod("stallion")
registerVehicleMod("sunrise")
registerVehicleMod("towtruck")
registerVehicleMod("tractor")
registerVehicleMod("vincent")
registerVehicleMod("washington")
registerVehicleMod("wayfarer")
registerVehicleMod("yosemite")
registerVehicleMod("clover")
registerVehicleMod("huntley")
registerVehicleMod("landstalker")
registerVehicleMod("euros")
registerVehicleMod("willard")
registerVehicleMod("stretch")
registerVehicleMod("buffalo")
registerVehicleMod("tahoma")
registerVehicleMod("glendale")
registerVehicleMod("patriot")
registerVehicleMod("fortune")
registerVehicleMod("club")
registerVehicleMod("walton", 478, true)
registerVehicleMod("greenwood")
registerVehicleMod("picador")
registerVehicleMod("manana")
registerVehicleMod("nrg-500")
registerVehicleMod("fcr-900")
registerVehicleMod("virgo")
registerVehicleMod("sabre")
registerVehicleMod("solair")
registerVehicleMod("sanchez")
registerVehicleMod("hustler")
registerVehicleMod("dozer")
--registerVehicleMod("lancia", 494)
registerVehicleMod("comet")
registerVehicleMod("bmx")
registerVehicleMod("windsor")
registerVehicleMod("boxville")
registerVehicleMod("hermes")
registerVehicleMod("tropic")
registerVehicleMod("sandking")
registerVehicleMod("mtbike", 510)
registerVehicleMod("hotring3", 503)
registerVehicleMod("polmav", 497, true)
registerVehicleMod("sparrow", "seasparrow", true)
registerVehicleMod("reefer", "reefer", true)
registerVehicleMod("copcarla", 596, true)
registerVehicleMod("copcarvg", 598, true)
registerVehicleMod("copcarsf", 599, true)
registerVehicleMod("copcarru", 597, true)
registerVehicleMod("fbiranch", 490, true)
registerVehicleMod("pizzaboy", "pizzaboy", true)
registerVehicleMod("ambulan", "ambulance", true)
registerVehicleMod("bus", "bus", true)
registerVehicleMod("yankee", "yankee", true)
registerVehicleMod("trash", "trashmaster", true)
registerVehicleMod("packer", "packer", true)
registerVehicleMod("m3e92", 494, true)
registerVehicleMod("buccaneer")

registerVehicleMod("barracks")
registerVehicleMod("hunter")
registerVehicleMod("hydra")
registerVehicleMod("rhino")
registerVehicleMod("newsvan", 582, true)


local loadingThread = false
local loadingInProgress = false
local threadTimer = false
local pendingLoading = 0

local function loadMod(id)
	if id then
		if mods and mods[id] and mods[id].state == true then

			if fileExists("mods/" .. mods[id].path .. ".txd") then
				local txd = engineLoadTXD("mods/" .. mods[id].path .. ".txd", true)

				if txd then
					engineImportTXD(txd, mods[id].model)
				end
			end

			if fileExists("mods/" .. mods[id].path .. ".col") then
				local col = engineLoadCOL("mods/" .. mods[id].path .. ".col")

				if col then
					engineReplaceCOL(col, mods[id].model)
				end
			end

			if fileExists("mods/" .. mods[id].path .. ".dff") then
				local dff = engineLoadDFF("mods/" .. mods[id].path .. ".dff", mods[id].model)

				if dff then
					engineReplaceModel(dff, mods[id].model)
				end
			end
		end
	end
end

local function preLoadMod(id)
	if id then
		if mods and mods[id] and mods[id].state == true then
			if isTimer(threadTimer) then
				killTimer(threadTimer)
			end

			threadTimer = setTimer(
				function ()
					pendingLoading = 0
				end,
			200, 1)

			if pendingLoading > 0 then
				setTimer(loadMod, pendingLoading * 2500, 1, id)
				return
			end

			pendingLoading = pendingLoading + 1

			loadMod(id)
		end
	end
end

local function unloadMod(id)
	if id and mods and mods[id] then
		local xmlFile = xmlFindChild(vehiclesXML, mods[id].path, 0) or xmlCreateChild(vehiclesXML, mods[id].path)

		if xmlFile then
			mods[id].state = false
			xmlNodeSetValue(xmlFile, "0")
			xmlSaveFile(vehiclesXML)
		end

		engineRestoreCOL(mods[id].model)
		engineRestoreModel(mods[id].model)
	end
end

function dummyFunction()
	loadingInProgress = false
end

function toggleMod(id, state)
	if state then
		loadingInProgress = true

		preLoadMod(id)

		if isTimer(threadTimer) then
			killTimer(threadTimer)
		end

		threadTimer = setTimer(dummyFunction, 2500, 1)
	else
		unloadMod(id)
	end
end

function loadMods()
	local nextLoadTime = 50

	for k in pairs(mods) do
		setTimer(toggleMod, nextLoadTime, 1, k, true)
		nextLoadTime = nextLoadTime + 50
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if vehiclesXML then
			for k, v in ipairs(mods) do
				local xmlFile = xmlFindChild(vehiclesXML, v.path, 0) or xmlCreateChild(vehiclesXML, v.path)

				if xmlNodeGetValue(xmlFile) and xmlNodeGetValue(xmlFile) ~= "" then
					if xmlNodeGetValue(xmlFile) == "0" then
						mods[k].state = false
					end
				else
					mods[k].state = true
					xmlNodeSetValue(xmlFile, "1")
					xmlSaveFile(vehiclesXML)
				end
			end
		end

		loadingThread = coroutine.create(loadMods)
		coroutine.resume(loadingThread)
	end)

local function spairs(t, order)
	local keys = {}

	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	if order then
		table.sort(keys, function(a, b)
			return order(t, a, b)
		end)
	else
		table.sort(keys)
	end

	local i = 0

	return function()
		i = i + 1

		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

local function togglePanel(state)
	if state ~= panelState then
		if state then
			local switchable = {}

			if mods then
				for k, v in ipairs(mods) do
					if v.toggable then
						table.insert(switchable, {
							exports.see_vehiclenames:getCustomVehicleName(v.model),
							getVehicleNameFromModel(v.model),
							v.state,
							k
						})
					end
				end
			end

			toggables = {}

			for _, v in spairs(switchable, function (t, a, b)
					return utf8.lower(t[b][1]) > utf8.lower(t[a][1])
			end) do
				table.insert(toggables, v)
			end

			panelState = true
			Roboto = dxCreateFont("files/Roboto.ttf", respc(12), false, "antialiased")

			addEventHandler("onClientRender", getRootElement(), renderTheModsPanel)
			addEventHandler("onClientKey", getRootElement(), onClientKey)
			addEventHandler("onClientClick", getRootElement(), onClientClick)
		else
			removeEventHandler("onClientKey", getRootElement(), onClientKey)
			removeEventHandler("onClientClick", getRootElement(), onClientClick)
			removeEventHandler("onClientRender", getRootElement(), renderTheModsPanel)

			panelState = false

			if isElement(Roboto) then
				destroyElement(Roboto)
			end

			Roboto = nil
		end
	end
end

addCommandHandler("modpanel",
	function ()
		togglePanel(not panelState)
	end)

local cursorX, cursorY = 0, 0
local activeButton = false
local buttons = {}
local currentPage = 0

function renderTheModsPanel()
	if panelState then
		cursorX, cursorY = 0, 0

		if isCursorShowing() then
			local relX, relY = getCursorPosition()
			cursorX, cursorY = relX * screenW, relY * screenH
		end

		panelWidth = respc(500)
		panelHeight = respc(400)
		panelPosX = (screenW - panelWidth) / 2
		panelPosY = (screenH - panelHeight) / 2

		buttons = {}

		dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 150))
		dxDrawRectangle(panelPosX, panelPosY, panelWidth, respc(30), tocolor(0, 0, 0, 200))
		dxDrawText("Strong#3d7abcMTA #ffffff- Modok", panelPosX + respc(7.5), panelPosY, respc(490), panelPosY + respc(30), tocolor(255, 255, 255), 1, Roboto, "left", "center", false, false, false, true)

		if activeButton == "close" then
			dxDrawRectangle(panelPosX + respc(390), panelPosY + respc(5), respc(100), respc(280) / 10 - respc(10), tocolor(215, 89, 89, 225))
		else
			dxDrawRectangle(panelPosX + respc(390), panelPosY + respc(5), respc(100), respc(280) / 10 - respc(10), tocolor(215, 89, 89, 175))
		end
		dxDrawText("Bezárás", panelPosX + respc(390), panelPosY + respc(5), panelPosX + respc(490), panelPosY - respc(5) + respc(280) / 10, tocolor(0, 0, 0), 0.8, Roboto, "center", "center")
		buttons.close = {panelPosX + respc(390), panelPosY + respc(5), panelPosX + respc(490), panelPosY - respc(5) + respc(280) / 10}

		dxDrawRectangle(panelPosX + respc(5), panelPosY + respc(35), respc(490), respc(280) / 10, tocolor(0, 0, 0, 225))
		dxDrawText("Jármű neve", panelPosX + respc(10), panelPosY + respc(35), respc(490), panelPosY + respc(35) + respc(280) / 10, tocolor(61, 122, 188), 0.8, Roboto, "left", "center")
		dxDrawText("Eredeti jármű", panelPosX + respc(260), panelPosY + respc(35), respc(490), panelPosY + respc(35) + respc(280) / 10, tocolor(61, 122, 188), 0.8, Roboto, "left", "center")

		for i = 1, 9 do
			local currentModId = i + currentPage
			local modData = toggables[currentModId]

			dxDrawRectangle(panelPosX + respc(5), panelPosY + respc(280) / 10 * i + respc(35), respc(490), respc(280) / 10, tocolor(0, 0, 0, 200))

			if modData then
				dxDrawText(modData[1], panelPosX + respc(10), panelPosY + respc(35) + respc(280) / 10 * i, respc(490), panelPosY + respc(35) + respc(280) / 10 * i + respc(280) / 10, tocolor(255, 255, 255), 0.8, Roboto, "left", "center")
				dxDrawText(modData[2], panelPosX + respc(260), panelPosY + respc(35) + respc(280) / 10 * i, respc(490), panelPosY + respc(35) + respc(280) / 10 * i + respc(280) / 10, tocolor(255, 255, 255), 0.8, Roboto, "left", "center")

				if modData[3] then
					dxDrawRectangle(panelPosX + respc(385), panelPosY + respc(35) + respc(280) / 10 * i + respc(5), respc(100), respc(280) / 10 - respc(10), tocolor(215, 89, 89, (activeButton == ("toggleMod_" .. currentModId) and 255 or 225)))
					dxDrawText("Kikapcsolás", panelPosX + respc(385), panelPosY + respc(35) + respc(280) / 10 * i + respc(5), panelPosX + respc(385) + respc(100), panelPosY + respc(35) + respc(280) / 10 * i + respc(5) + respc(280) / 10 - respc(10), tocolor(0, 0, 0), 0.8, Roboto, "center", "center")
				else
					dxDrawRectangle(panelPosX + respc(385), panelPosY + respc(35) + respc(280) / 10 * i + respc(5), respc(100), respc(280) / 10 - respc(10), tocolor(61, 122, 188, (activeButton == ("toggleMod_" .. currentModId) and 255 or 225)))
					dxDrawText("Bekapcsolás", panelPosX + respc(385), panelPosY + respc(35) + respc(280) / 10 * i + respc(5), panelPosX + respc(385) + respc(100), panelPosY + respc(35) + respc(280) / 10 * i + respc(5) + respc(280) / 10 - respc(10), tocolor(0, 0, 0), 0.8, Roboto, "center", "center")
				end

				buttons["toggleMod_" .. currentModId] = {
					panelPosX + respc(385),
					panelPosY + respc(35) + respc(280) / 10 * i + respc(5),
					panelPosX + respc(385) + respc(100),
					panelPosY + respc(35) + respc(280) / 10 * i + respc(5) + respc(280) / 10 - respc(10)
				}
			end
		end

		if #toggables > 9 then
			dxDrawRectangle(panelPosX - respc(5) + respc(500) - respc(5), panelPosY + (respc(280) / 10 * 2 + respc(5)), respc(5), respc(280) / 10 * 9, tocolor(0, 0, 0, 200))
			dxDrawRectangle(panelPosX - respc(5) + respc(500) - respc(5), panelPosY + (respc(280) / 10 * 2 + respc(5)) + currentPage * (respc(280) / 10 * 9 / (#toggables - 9 + 1)), respc(5), respc(280) / 10 * 9 / (#toggables - 9 + 1), tocolor(61, 122, 188, 150))
		end

		dxDrawRectangle(panelPosX - respc(5) + respc(5) + respc(5), panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(80), respc(490), respc(35), tocolor(61, 122, 188, (activeButton == "allOn" and 255 or 225)))
		dxDrawText("Összes bekapcsolása", panelPosX - respc(5) + respc(5) + respc(5), panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(80), panelPosX - respc(5) + respc(5) + respc(5) + respc(490), panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(80) + respc(35), tocolor(0, 0, 0), 0.8, Roboto, "center", "center")
		buttons.allOn = {
			panelPosX - respc(5) + respc(5) + respc(5),
			panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(80),
			panelPosX - respc(5) + respc(5) + respc(5) + respc(490),
			panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(80) + respc(35)
		}

		dxDrawRectangle(panelPosX - respc(5) + respc(5) + respc(5), panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(40), respc(490), respc(35), tocolor(215, 89, 89, (activeButton == "allOff" and 255 or 225)))
		dxDrawText("Összes kikapcsolása", panelPosX - respc(5) + respc(5) + respc(5), panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(40), panelPosX - respc(5) + respc(5) + respc(5) + respc(490), panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(40) + respc(35), tocolor(0, 0, 0), 0.8, Roboto, "center", "center")
		buttons.allOff = {
			panelPosX - respc(5) + respc(5) + respc(5),
			panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(40),
			panelPosX - respc(5) + respc(5) + respc(5) + respc(490),
			panelPosY + (respc(280) / 10 * 2 + respc(5)) - (respc(280) / 10 * 2 + respc(5)) + respc(400) - respc(40) + respc(35)
		}

		activeButton = false

		if cursorX >= panelPosX and cursorX <= panelPosX + panelWidth and cursorY >= panelPosY and cursorY <= panelPosY + panelHeight then
			for k, v in pairs(buttons) do
				if cursorX >= v[1] and cursorX <= v[3] and cursorY >= v[2] and cursorY <= v[4] then
					activeButton = k
				end
			end
		end
	end
end

function onClientKey(key)
	if toggables and cursorX >= panelPosX and cursorX <= panelPosX + panelWidth and cursorY >= panelPosY and cursorY <= panelPosY + panelHeight then
		if key == "mouse_wheel_up" then
			if currentPage > 0 then
				currentPage = currentPage - 1
			end
		elseif key == "mouse_wheel_down" and currentPage < #toggables - 9 then
			currentPage = currentPage + 1
		end
	end
end

function onClientClick(button, state)
	if loadingInProgress then
		return
	end

	if toggables and activeButton and button == "left" and state == "up" then
		local pedveh = getPedOccupiedVehicle(localPlayer)
		local selected = split(activeButton, "_")

		if selected[1] == "toggleMod" then
			local id = toggables[tonumber(selected[2])][4]

			if mods and mods[id] then
				if isElement(pedveh) and mods[id].model == getElementModel(pedveh) then
					exports.see_hud:showInfobox("e", "Éppen egy ilyen típusú járműben ülsz!")
					return
				end

				if mods[id].state == false then
					mods[id].state = true
					toggleMod(id, true)

					local xmlFile = xmlFindChild(vehiclesXML, mods[id].path, 0) or xmlCreateChild(vehiclesXML, mods[id].path)

					if xmlFile then
						xmlNodeSetValue(xmlFile, "1")
						xmlSaveFile(vehiclesXML)
					end
				else
					unloadMod(id)
					mods[id].state = false
				end

				toggables[tonumber(selected[2])][3] = mods[id].state
			end
		elseif activeButton == "allOff" then
			if isElement(pedveh) then
				exports.see_hud:showInfobox("e", "Előbb szállj ki a járművedből!")
				return
			end

			for i = 1, #toggables do
				if toggables[i] and mods[toggables[i][4]].state then
					mods[toggables[i][4]].state = false
					unloadMod(toggables[i][4])
					toggables[i][3] = mods[toggables[i][4]].state
				end
			end
		elseif activeButton == "allOn" then
			if isElement(pedveh) then
				exports.see_hud:showInfobox("e", "Előbb szállj ki a járművedből!")
				return
			end

			for i = 1, #toggables do
				if toggables[i] and not mods[toggables[i][4]].state then
					mods[toggables[i][4]].state = true
					toggables[i][3] = mods[toggables[i][4]].state

					local xmlFile = xmlFindChild(vehiclesXML, mods[toggables[i][4]].path, 0) or xmlCreateChild(vehiclesXML, mods[toggables[i][4]].path)

					if xmlFile then
						xmlNodeSetValue(xmlFile, "1")
						xmlSaveFile(vehiclesXML)
					end
				end
			end

			loadMods()
		elseif activeButton == "close" then
			togglePanel(false)
		end
	end
end
