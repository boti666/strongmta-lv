local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(x)
	return math.ceil(x * responsiveMultipler)
end

local exp = exports.see_clothesshop

local openCategories = {}

local baseCategories = exp:getBaseCategories()

local currentTick = getTickCount()

local offsetItems = 0

local subTitles = exp:getTable("sub")
local categorizedItems = exp:getTable("cat")
local subCategorizedItems = exp:getTable("subCat")
local itemIndexes = exp:getTable("itemIndex")
local groupClothes = exp:getTable("gClothes")
local subCategories = exp:getTable("subCategories")
local myClothes = exp:getTable("myClothes")
local itemMods = exp:getTable("itemMods")
local itemNames = exp:getTable("itemNames")

local myLastPresets = {}

function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local pictureImage = "files/op.png"

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if panelState or alphaAnim then
			showCursor(false)
			showChat(true)
			exports.see_hud:showHUD()
		end

		if selectedTab == 7 then
				executeCommandHandler("openMyClothesCMD")
		elseif selectedTab == 3 then
				executeCommandHandler("pp")
		end
	end)

for k, v in pairs(renderData.petTypes) do
	renderData.petNameTypes[v] = k
end

renderData.petPrices = {9000, 6000, 8000, 9000, 7000, 10000}

function fetchAnimals()
	triggerServerEvent("requestAnimals", localPlayer, getElementData(localPlayer, "char.ID"))
end

addEvent("receiveAnimals", true)
addEventHandler("receiveAnimals", getRootElement(),
	function (datas)
		renderData.loadedAnimals = datas
	end
)

addEvent("sellVehicleNotification", true)
addEventHandler("sellVehicleNotification", getRootElement(), 
	function(playerElement, value, customArgument_2, vehicle, customArgument_4, customArgument_5, tradeContractDatas)
		exports.lv_accounts:showInfo("i", getElementData(playerElement, "visibleName"):gsub("_", " ") .. " el akar adni neked egy járművet " .. thousandsStepper(value) .. " $-ért!")
		outputChatBox("#FF9600[StrongMTA - Jármű]: #ffffff" .. getElementData(playerElement, "visibleName"):gsub("_", " ") .. " el akar adni neked egy járművet " .. thousandsStepper(value) .. " $-ért!", 0, 0, 0, true)
		outputChatBox("#FF9600[StrongMTA - Jármű]: #ffffff5 perced van reagálni! A részletekért nyisd meg a dashboard-ot.", 0, 0, 0, true)
		renderData.vehicleSellNotiDatas = {
			playerElement,
			value,
			getElementData(playerElement, "visibleName"):gsub("_", " "),
			customArgument_2,
			exports.lv_vehiclenames:getCustomVehicleName(vehicle),
			customArgument_4,
			customArgument_5
		}
		renderData.tradeContract = true
		if isElement(renderData.tradeContractFont) then
			destroyElement(renderData.tradeContractFont)
		end
		renderData.tradeContractFont = dxCreateFont("files/hand.otf", 23, false, "antialiased")
		if isElement(renderData.lunabar) then
			destroyElement(renderData.lunabar)
		end
		renderData.lunabar = dxCreateFont("files/lunabar.ttf", 38, false, "antialiased")
		renderData.tradeContractDatas = tradeContractDatas
		renderData.dummyTradeContract = false
		renderData.tradeState = 2
		renderData.signStart = false
	end
)

local tradeContractDatas = {
	"spinner"
}
renderData.tradeContract = false 
renderData.dummyTradeContract = false

addEvent("sellContractTaken", true)
addEventHandler("sellContractTaken", getRootElement(), function(_ARG_0_, _ARG_1_)
	_UPVALUE0_ = false
	renderData.sellingVehicle = false
	renderData.sellVehiclePrice = false
	if _ARG_0_ then
		if isElement(_UPVALUE1_.tradeContractFont) then
			destroyElement(_UPVALUE1_.tradeContractFont)
		end
		renderData.tradeContractFont = dxCreateFont("files/hand.otf", 23, false, "antialiased")
		if isElement(renderData.lunabar) then
			destroyElement(renderData.lunabar)
		end
		renderData.lunabar = dxCreateFont("files/lunabar.ttf", 38, false, "antialiased")
		renderData.dummyTradeContract = false
		renderData.tradeContractDatas.dateOf = getRealTime().year + 1900 .. "." .. getRealTime().month + 1 .. "." .. getRealTime().monthday
		--renderData.tradeContractDatas.price = _ARG_1_
		--renderData.tradeContractDatas.engine = _UPVALUE5_[screenX[screenY[_UPVALUE4_]]["vehicle.tuning.Engine"]]:gsub("#%x%x%x%x%x%x", "")
		--renderData.tradeContractDatas.gears = _UPVALUE5_[screenX[screenY[_UPVALUE4_]]["vehicle.tuning.Transmission"]]:gsub("#%x%x%x%x%x%x", "")
		--renderData.tradeContractDatas.brake = _UPVALUE5_[screenX[screenY[_UPVALUE4_]]["vehicle.tuning.Brakes"]]:gsub("#%x%x%x%x%x%x", "")
		--renderData.tradeContractDatas.wheels = _UPVALUE5_[screenX[screenY[_UPVALUE4_]]["vehicle.tuning.Tires"]]:gsub("#%x%x%x%x%x%x", "")
		--renderData.tradeContractDatas.turbo = _UPVALUE5_[screenX[screenY[_UPVALUE4_]]["vehicle.tuning.Turbo"]]:gsub("#%x%x%x%x%x%x", "")
		--renderData.tradeContractDatas.WeightReduction = _UPVALUE5_[screenX[screenY[_UPVALUE4_]]["vehicle.tuning.WeightReduction"]]:gsub("#%x%x%x%x%x%x", "")
		--renderData.tradeContractDatas.ecu = _UPVALUE5_[screenX[screenY[_UPVALUE4_]]["vehicle.tuning.ECU"]]:gsub("#%x%x%x%x%x%x", "")
		--renderData.tradeContractDatas.suspension = _UPVALUE5_[screenX[screenY[_UPVALUE4_]]["vehicle.tuning.Suspension"]]:gsub("#%x%x%x%x%x%x", "")
		if screenX[screenY[_UPVALUE4_]]["vehicle.nitroLevel"] == 0 then
			renderData.tradeContractDatas.nitro = "nincs"
		else
			renderData.tradeContractDatas.nitro = screenX[screenY[_UPVALUE4_]]["vehicle.nitroLevel"] .. "%"
		end
		renderData.tradeContractDatas.extras = {}
		if screenX[screenY[_UPVALUE4_]]["vehicle.tuning.AirRide"] == 1 then
			table.insert(_UPVALUE1_.tradeContractDatas.extras, "AirRide")
		end
		if screenX[screenY[_UPVALUE4_]]["tuning.neon"] > 10000 then
			table.insert(_UPVALUE1_.tradeContractDatas.extras, "Neon")
		end
		if getElementData(screenY[_UPVALUE4_], "tuningSpinners") then
			table.insert(renderData.tradeContractDatas.extras, "Spinner")
		end
		renderData.tradeContractDatas.extras = table.concat(_UPVALUE1_.tradeContractDatas.extras, ", ")
		renderData.tradeContractDatas.seller = getElementData(localPlayer, "visibleName"):gsub("_", " ")
		renderData.tradeContractDatas.buyer = getElementData(_UPVALUE1_.sellVehiclePersonElement, "visibleName"):gsub("_", " ")
		renderData.tradeContractDatas.cartype = exports.lv_vehiclenames:getCustomVehicleName(getElementModel(screenY[_UPVALUE4_]))
		for _FORV_9_ = 1, #split(getVehiclePlateText(screenY[_UPVALUE4_]), "-") do
			if 1 <= string.len(split(getVehiclePlateText(screenY[_UPVALUE4_]), "-")[_FORV_9_]) then
				table.insert({}, split(getVehiclePlateText(screenY[_UPVALUE4_]), "-")[_FORV_9_])
			end
		end
		--_FOR_.tradeContractDatas.plate = table.concat({}, "-")
		renderData.tradeContractDatas.currentDistance = math.floor(getElementData(screenY[_UPVALUE4_], "vehicle.distance") * 10) / 10
		renderData.tradeContract = true
		renderDatarenderData.tradeState = 1
		renderData.signStart = false
	else
		exports.lv_accounts:showInfo("e", "Nincs nálad üres adásvételi.")
	end
end)

tradeFont = dxCreateFont("files/fonts/Roboto.ttf", 17.5, false, "antialiased")
lunabar = dxCreateFont("files/fonts/lunabar.ttf", 23 * 1.6, false, "antialiased")


addEvent("showTradeContatact", true)
addEventHandler("showTradeContatact", getRootElement(),
	function(data)
		if panelState then
			togglePanel()
		end

		renderData.tradeContract = true
		renderData.dummyTradeContract = true
		renderData.tradeContractDatas = data
	end
)

writeTick = false


addEventHandler("onClientRender", getRootElement(), function()
	--print("ide futok")
	if renderData.tradeContract and renderData.dummyTradeContract then
		--print("itt is futok")
		--tradeContractDatas = {}
		--table.insert(renderData.tradeContractDatas.seller, "seller")

		local buyerText = dxGetTextWidth(renderData.tradeContractDatas.buyer, 0.5, lunabar)

		if not writeTick then
			interpolateTrade = 0
		else
			local now = getTickCount()
		    local endTime = writeTick + 4000
		    local elapsedTime = now - writeTick
		    local duration = endTime - writeTick
		    progressTrade = elapsedTime / duration

		    interpolateTrade = interpolateBetween(0, 0, 0, buyerText, 0, 0, progressTrade, "Linear")
		end

		

		dxDrawImage(math.floor(screenX / 2 - 236.5), math.floor(screenY / 2 - 322.5), 473, 645, "files/images/adasveteli.png")
		dxDrawText(renderData.tradeContractDatas.seller, math.floor(screenX / 2 - 236.5) + 140, math.floor(screenY / 2 - 322.5) + 55, math.floor(screenX / 2 - 236.5) + 330, math.floor(screenY / 2 - 322.5) + 55, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(renderData.tradeContractDatas.buyer, math.floor(screenX / 2 - 236.5) + 192, math.floor(screenY / 2 - 322.5) + 75, math.floor(screenX / 2 - 236.5) + 385, math.floor(screenY / 2 - 322.5) + 75, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(renderData.tradeContractDatas.plate, math.floor(screenX / 2 - 236.5) + 55, math.floor(screenY / 2 - 322.5) + 115, math.floor(screenX / 2 - 236.5) + 150, math.floor(screenY / 2 - 322.5) + 115, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(renderData.tradeContractDatas.cartype, math.floor(screenX / 2 - 236.5) + 215, math.floor(screenY / 2 - 322.5) + 115, math.floor(screenX / 2 - 236.5) + 385, math.floor(screenY / 2 - 322.5) + 115, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(renderData.tradeContractDatas.cartype, math.floor(screenX / 2 - 236.5) + 110, math.floor(screenY / 2 - 322.5) + 265, math.floor(screenX / 2 - 236.5) + 320, math.floor(screenY / 2 - 322.5) + 265, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(renderData.tradeContractDatas.plate, math.floor(screenX / 2 - 236.5) + 110, math.floor(screenY / 2 - 322.5) + 285, math.floor(screenX / 2 - 236.5) + 320, math.floor(screenY / 2 - 322.5) + 285, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(math.floor(renderData.tradeContractDatas.currentDistance * 10) / 10 .. " km", math.floor(screenX / 2 - 236.5) + 110, math.floor(screenY / 2 - 322.5) + 305, math.floor(screenX / 2 - 236.5) + 320, math.floor(screenY / 2 - 322.5) + 305, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(renderData.tradeContractDatas.engine, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 345, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 345, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.gears, math.floor(screenX / 2 - 236.5) + 325, math.floor(screenY / 2 - 322.5) + 345, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 345, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.brake, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 373, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 373, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.wheels, math.floor(screenX / 2 - 236.5) + 325, math.floor(screenY / 2 - 322.5) + 373, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 373, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.turbo, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 400, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 400, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.WeightReduction, math.floor(screenX / 2 - 236.5) + 325, math.floor(screenY / 2 - 322.5) + 400, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 400, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.ecu, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 432, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 432, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.suspension, math.floor(screenX / 2 - 236.5) + 325, math.floor(screenY / 2 - 322.5) + 432, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 432, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.extras, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 462, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 462, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.nitro, math.floor(screenX / 2 - 236.5) + 325, math.floor(screenY / 2 - 322.5) + 462, math.floor(screenX / 2 - 236.5) + 70, math.floor(screenY / 2 - 322.5) + 462, tocolor(20, 100, 200), 0.5, tradeFont, "left", "bottom")
		dxDrawText(renderData.tradeContractDatas.price, math.floor(screenX / 2 - 236.5) + 190, math.floor(screenY / 2 - 322.5) + 520, math.floor(screenX / 2 - 236.5) + 320, math.floor(screenY / 2 - 322.5) + 520, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(renderData.tradeContractDatas.dateOf, math.floor(screenX / 2 - 236.5) + 345, math.floor(screenY / 2 - 322.5) + 605, math.floor(screenX / 2 - 236.5) + 432, math.floor(screenY / 2 - 322.5) + 605, tocolor(20, 100, 200), 0.5, tradeFont, "center", "bottom")
		dxDrawText(renderData.tradeContractDatas.seller, math.floor(screenX / 2 - 236.5) + 20 + 77.5 - dxGetTextWidth(renderData.tradeContractDatas.seller, 0.5, lunabar) / 2, math.floor(screenY / 2 - 322.5) + 500, math.floor(screenX / 2 - 236.5) + 20 + 77.5 - dxGetTextWidth(renderData.tradeContractDatas.seller, 0.5, lunabar) / 2 + interpolateBetween(0, 0, 0, dxGetTextWidth(renderData.tradeContractDatas.seller, 0.5, lunabar), 0, 0, 1, "Linear"), math.floor(screenY / 2 - 322.5) + 570, tocolor(20, 100, 200), 0.5, lunabar, "left", "bottom", true, false, false, false, true)
		dxDrawText(renderData.tradeContractDatas.buyer, math.floor(screenX / 2 - 236.5) + 275 + 77.5 - buyerText / 2, math.floor(screenY / 2 - 322.5) + 500, math.floor(screenX / 2 - 236.5) + 275 + 77.5 - buyerText / 2 + interpolateTrade, math.floor(screenY / 2 - 322.5) + 570, tocolor(20, 100, 200), 0.5, lunabar, "left", "bottom", true, false, false, false, true)
		
		if not inRange(renderData.tradeContractDatas.sellerPed, localPlayer, 20) or not inRange(renderData.tradeContractDatas.selledVeh, localPlayer, 20) then
			triggerServerEvent("cancelOffer", localPlayer, localPlayer, "elutasít")

			writeTick = false

			renderData.tradeContract = false
			renderData.dummyTradeContract = false
			renderData.tradeContractDatas = nil
		end

		if progressTrade and progressTrade >= 1 then
			triggerServerEvent("acceptOffer", localPlayer, localPlayer, "elfogad")

			writeTick = false
			renderData.tradeContract = false
			renderData.dummyTradeContract = false
			renderData.tradeContractDatas = nil
		end

	end
end)


function inRange(firstElement, secondElement, range)
	local returnData = false

	if isElement(firstElement) and isElement(secondElement) and tonumber(range) then
		local p1X, p1Y, p2Z = getElementPosition(firstElement)
		local p2X, p2Y, p2Z = getElementPosition(secondElement)

		if getDistanceBetweenPoints3D(p1X, p1Y, p2Z, p2X, p2Y, p2Z) < range then
			returnData = true
		end
	end

	return returnData
end

addEventHandler("onClientClick", getRootElement(),
	function(key, state)
		if key == "left" and state == "down" then
			if isMouseInPosition(math.floor(screenX / 2 - 236.5) + 280, math.floor(screenY / 2 - 322.5) + 500 + 40, 150, 40) then
				if not writeTick and renderData.tradeContract and renderData.dummyTradeContract then
					if renderData.tradeContractDatas.price then
						local currentMoney = getElementData(localPlayer, "char.Money") or 0
						currentMoney = currentMoney - renderData.tradeContractDatas.price

						if currentMoney >= 0 then
							writeTick = getTickCount()
						else
							exports.see_accounts:showInfo("e", "Nincs elég pénzed!")
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientKey", getRootElement(),
	function(key, state)
		if key == "backspace" and state then
			if not writeTick and renderData.tradeContract and renderData.dummyTradeContract then
				triggerServerEvent("cancelOffer", localPlayer, localPlayer, "elutasít")

				writeTick = false

				renderData.tradeContract = false
				renderData.dummyTradeContract = false
				renderData.tradeContractDatas = nil
			end
		end
	end
)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end
addEvent("openDummyTradeContract", true)
addEventHandler("openDummyTradeContract", getRootElement(), 
	function(tradeContractDatas, tradeContractOriginal)
		if renderData.tradeContract and not renderData.dummyTradeContract then
			return
		end
		if isElement(renderData.tradeContractFont) then
			destroyElement(renderData.tradeContractFont)
		end
		if isElement(renderData.lunabar) then
			destroyElement(renderData.lunabar)
		end
		renderData.tradeContract = not renderData.tradeContract
		renderData.tradeContractOriginal = tradeContractOriginal
		renderData.dummyTradeContract = false
		if renderData.tradeContract then
			renderData.vehicleSellNotiDatas = false
			renderData.tradeContract = true
			renderData.tradeContractFont = dxCreateFont("files/hand.otf", 23, false, "antialiased")
			renderData.lunabar = dxCreateFont("files/lunabar.ttf", 38, false, "antialiased")
			renderData.tradeContractDatas = tradeContractDatas
			renderData.dummyTradeContract = true
			if active then
				toggleDashboard()
			end
			renderData.tradeState = 2
			renderData.signStart = false
		end
	end
)

addEvent("sellInteriorNotification", true)
addEventHandler("sellInteriorNotification", getRootElement(), function(playerElement, value, selectedInterior)
	exports.lv_accounts:showInfo("i", getElementData(playerElement, "visibleName"):gsub("_", " ") .. " el akar adni neked egy ingatlant " .. thousandsStepper(value) .. " $-ért!")
	outputChatBox("#FF9600[StrongMTA - Ingatlan]: #ffffff" .. getElementData(playerElement, "visibleName"):gsub("_", " ") .. " el akar adni neked egy ingatlant " .. thousandsStepper(value) .. " $-ért!", 0, 0, 0, true)
	outputChatBox("#FF9600[StrongMTA - Ingatlan]: #ffffff5 perced van reagálni! A részletekért nyisd meg a dashboard-ot.", 0, 0, 0, true)
	_UPVALUE0_.interiorSellingNotification = {
		playerElement,
		value,
		getElementData(playerElement, "visibleName"):gsub("_", " "),
		selectedInterior,
		exports.lv_interiors:getInteriorName(selectedInterior)
	}
end)

function fetchGroups()
	playerGroups = exports.see_groups:getPlayerGroups(localPlayer)
	playerGroupsKeyed = {}
	playerGroupsCount = 0

	if playerGroups then
		triggerServerEvent("requestGroupData", localPlayer, playerGroups)
	end

	for k, v in pairs(playerGroups) do
		playerGroupsCount = playerGroupsCount + 1
		playerGroupsKeyed[playerGroupsCount] = k

		if not playerGroups[selectedGroup] then
			selectedGroup = playerGroupsCount
		end

		groupVehicles[k] = {}
	end

	for k, v in ipairs(getElementsByType("vehicle")) do
		local groupId = getElementData(v, "vehicle.group")

		if groupVehicles[groupId] then
			table.insert(groupVehicles[groupId], v)
			table.insert(monitoredGroupVeh, v)

			vehicleDatas[v] = {}

			for k in pairs(monitoredDatasForVehicle) do
				vehicleDatas[v][k] = getElementData(v, k)
			end

			local vehicleType = getVehicleType(v)

			if vehicleType == "Train" or vehicleType == "Trailer" or vehicleType == "Monster Truck" then
				vehicleType = "Automobile"
			end

			vehicleDatas[v].vehicleType = vehicleType
			vehicleDatas[v].vehModelID = getElementModel(v)
			vehicleDatas[v].vehicleName = exports.see_vehiclenames:getCustomVehicleName(getElementModel(v)) or exports.see_infinity:getVehicleCustomName(getElementData(v, "vehicleSpecialMod"))
		end
	end
end

addEvent("receiveGroups", true)
addEventHandler("receiveGroups", getRootElement(),
	function (datas)
		groups = datas

		if selectedTab == 4 then
			fetchGroups()
		end
	end)

addEvent("receiveGroupMembers", true)
addEventHandler("receiveGroupMembers", getRootElement(),
	function (members, characterId, groupId)
		local onlinePlayers = {}

		for k, v in pairs(getElementsByType("player")) do
			local id = getElementData(v, "char.ID")

			if id then
				onlinePlayers[id] = v
			end
		end

		local me = getElementData(localPlayer, "char.ID")

		for k, v in pairs(members) do
			rankCount[k] = {}

			for k2, v2 in pairs(v) do
				local id = v2.id

				if id == me then
					meInGroup[k] = v2
				end

				if onlinePlayers[id] then
					if getElementData(onlinePlayers[id], "hideOnline") then
						members[k][k2].online = false
					else
						members[k][k2].online = onlinePlayers[id]
					end
				else
					members[k][k2].online = false
				end

				rankCount[k][v2.rank] = (rankCount[k][v2.rank] or 0) + 1
			end
		end

		groupMembers = members

		for k, v in pairs(groupMembers) do
			table.sort(v, function (a, b)
				return a.rank < b.rank
			end)

			for k2, v2 in pairs(v) do
				if k == groupId and v2.id == characterId then
					selectedMember = k2
				end
			end
		end
	end)

addEvent("modifyGroupData", true)
addEventHandler("modifyGroupData", getRootElement(),
	function (groupId, dataType, rankId, data)
		if groups[groupId] then
			if dataType == "rankName" then
				if groups[groupId].ranks[rankId] then
					groups[groupId].ranks[rankId].name = data
				end
			elseif dataType == "rankPayment" then
				if groups[groupId].ranks[rankId] then
					groups[groupId].ranks[rankId].pay = tonumber(data)
				end
			elseif dataType == "description" then
				groups[groupId].description = data
			elseif dataType == "balance" then
				groups[groupId].balance = tonumber(data)
			end
		end
	end)

addCommandHandler("togonline",
	function ()
		if exports.see_groups:isPlayerInGroup(localPlayer, 40) then
			setElementData(localPlayer, "hideOnline", not getElementData(localPlayer, "hideOnline"))

			if getElementData(localPlayer, "hideOnline") then
				outputChatBox("#477fa8[StrongMTA - Mama]:#ffffff Mostantól #d75959offline#ffffff-nak látszol.", 255, 255, 255, true)
			else
				outputChatBox("#477fa8[StrongMTA - Mama]:#ffffff Mostantól #477fa8online#ffffff-nak látszol.", 255, 255, 255, true)
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (data)
		if source == localPlayer and myMonitoredDatas[data] then
			myDatas[data] = getElementData(localPlayer, data)
		end

		if panelState then
			if getElementType(source) == "vehicle" then
				local key = false

				for k, v in pairs(playerVehicles) do
					if v == source then
						key = k
						break
					end
				end

				if tonumber(key) and monitoredDatasForVehicle[data] then
					if getElementData(source, "vehicle.owner") == myDatas["char.ID"] or monitoredGroupVeh[source] then
						if not vehicleDatas[source] then
							vehicleDatas[source] = {}
						end

						vehicleDatas[source][data] = getElementData(source, data)
					else
						playerVehicles[key] = nil
					end
				end
			end
		end

		if getElementType(source) == "ped" then
			local animalId = getElementData(source, "animal.animalId")
			if animalId then
				local ownerId = getElementData(source, "animal.ownerId")
				if ownerId and ownerId == myDatas["char.ID"] then
					renderData.spawnedAnimal = animalId
					renderData.spawnedPetElement = source
					renderData.petDatas[data] = getElementData(source, data)
				end
			end
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if getElementType(source) == "ped" then
			local animalId = getElementData(source, "animal.animalId")
			if animalId then
				local ownerId = getElementData(source, "animal.ownerId")
				if ownerId and ownerId == myDatas["char.ID"] then
					renderData.spawnedAnimal = 0
					renderData.spawnedPetElement = false
					renderData.petDatas = {}
				end
			end
		end
	end)

renderData.clientSettings = {}
renderData.loadedSettings = {}
renderData.offsetSettings = 0

renderData.sayStyle = {"prtial_gngtlka", "prtial_gngtlkb", "prtial_gngtlkc", "prtial_gngtlkd", "prtial_gngtlke", "prtial_gngtlkf", "prtial_gngtlkg", "prtial_gngtlkh", "prtial_hndshk_01", "prtial_hndshk_biz_01", "false"}
renderData.sayStyleEx = {
	["prtial_gngtlka"] = 1,
	["prtial_gngtlkb"] = 2,
	["prtial_gngtlkc"] = 3,
	["prtial_gngtlkd"] = 4,
	["prtial_gngtlke"] = 5,
	["prtial_gngtlkf"] = 6,
	["prtial_gngtlkg"] = 7,
	["prtial_gngtlkh"] = 8,
	["prtial_hndshk_01"] = 9,
	["prtial_hndshk_biz_01"] = 10,
	["false"] = 11,
}

renderData.walkingStyles = {118, 119, 120, 121, 122, 123, 124, 126, 128, 129, 130, 131, 132, 133, 134, 135, 137}

renderData.walkingStylesEx = {
	[118] = 1,
	[119] = 2,
	[120] = 3,
	[121] = 4,
	[122] = 5,
	[123] = 6,
	[124] = 7,
	[126] = 8,
	[128] = 9,
	[129] = 10,
	[130] = 11,
	[131] = 12,
	[132] = 13,
	[133] = 14,
	[134] = 15,
	[135] = 16,
	[137] = 17
}

renderData.fightStyles = {4, 5, 6}
renderData.fightStylesEx = {
	[4] = 1,
	[5] = 2,
	[6] = 3
}

renderData.shaderRealNames = {
	shader_vehicle = {
		"Klasszikus",
		"Normál",
		"Csökkentett"
	},
	shader_water = {
		"Klasszikus",
		"Csökkentett"
	},
	chatType = {
		[-1] = "Kikapcsolva",
		[0] = "Alap",
		[1] = "Custom"
	},
	hudStyle = {
		[0] = "Bar",
		[1] = "Circle"
	}
}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setElementData(localPlayer, "strong.Accept", false)
		setElementData(localPlayer, "strong.Selling", false)
		setElementData(localPlayer, "strong.Veh", false)
		setElementData(localPlayer, "strong.Price", false)
		setElementData(localPlayer, "strong.Tplayer", false)
		setElementData(localPlayer, "strong.Selling", false)

		if fileExists("config.json") then
			local config = fileOpen("config.json")
			if config then
				renderData.loadedSettings = fromJSON(fileRead(config, fileGetSize(config)))
				fileClose(config)
			end
		else
			local config = fileCreate("config.json")
			if config then
				fileWrite(config, toJSON({}))
				fileClose(config)
			end
		end

		if getElementData(localPlayer, "loggedIn") then
			for k, v in pairs(renderData.loadedSettings) do
				if k == "viewDistance" then
					setFarClipDistance(tonumber(v))
				elseif string.find(k, "shader") then
					if v then
						exports.see_shader:setActiveShader(k:gsub("shader_", ""), v)
					else
						exports.see_shader:setActiveShader(k:gsub("shader_", ""), false)
					end
				end
			end
		end
	end)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if fileExists("config.json") then
			fileDelete("config.json")
		end

		local config = fileCreate("config.json")
		if config then
			fileWrite(config, toJSON(renderData.loadedSettings))
			fileClose(config)
		end
	end)

addEventHandler("onClientPlayerSpawn", localPlayer,
	function ()
		for k, v in pairs(renderData.loadedSettings) do
			if k == "viewDistance" then
				setFarClipDistance(tonumber(v))
			elseif string.find(k, "shader") then
				if v then
					exports.see_shader:setActiveShader(k:gsub("shader_", ""), v)
				else
					exports.see_shader:setActiveShader(k:gsub("shader_", ""), false)
				end
			end
		end
	end)

function togglePanel()
	if renderData.dummyTradeContract then 
		return 
	end 

	if not getElementData(localPlayer, "loggedIn") then
		return
	end

	if alphaAnim then
		return
	end

	if getTickCount() - renderData.openedTime <= 2000 and not panelState then
		outputChatBox("#d75959[StrongMTA]: #FFFFFFMaximum 2 másodpercenként nyithatod meg a dashboard-ot.", 0, 0, 0, true)
		playSound("files/sounds/promptdecline.mp3")
		return
	end

	panelState = not panelState

	if panelState then
		--dxDrawPieChart(x + respc(1100), y + respc(405), respc(100), valueList, colorList, labelList)
		--exports.see_3dview:setPreviewFOV(dashPed, 1)

		renderData.openedTime = getTickCount()

		for k, v in pairs(myMonitoredDatas) do
			myDatas[k] = getElementData(localPlayer, k)
		end

		playerVehicles = {}
		playerInteriors = exports.see_interiors:requestInteriors(localPlayer)

		for k, veh in ipairs(getElementsByType("vehicle")) do
			if getElementData(veh, "vehicle.owner") == myDatas["char.ID"] then
				if (getElementData(veh, "vehicle.group") or 0) == 0 then
					table.insert(playerVehicles, veh)

					vehicleDatas[veh] = {}

					for key in pairs(monitoredDatasForVehicle) do
						vehicleDatas[veh][key] = getElementData(veh, key)
					end

					local vehicleType = getVehicleType(veh)

					if vehicleType == "Train" or vehicleType == "Trailer" or vehicleType == "Monster Truck" then
						vehicleType = "Automobile"
					end

					vehicleDatas[veh].vehicleType = vehicleType
					vehicleDatas[veh].vehModelID = getElementModel(veh)
					vehicleDatas[veh].vehicleName = exports.see_vehiclenames:getCustomVehicleName(getElementModel(veh)) or exports.see_infinity:getVehicleCustomName(getElementData(veh, "vehicleSpecialMod"))
				end
			end
		end

		jobNames = exports.see_jobhandler:getJobNames()
		groupTypes = exports.see_groups:getGroupTypes()

		for k, v in pairs(playerInteriors) do
			v.data.iconPicture = exports.see_interiors:getIconByMarkerType(v.data.type)
		end

		if selectedTab == 4 then
			triggerServerEvent("requestGroups", localPlayer)
		elseif selectedTab == 5 then
			getAdmins()
		elseif selectedTab == 6 then
			fetchAnimals()
		elseif selectedTab == 7 then
			executeCommandHandler("openMyClothesCMD")
		elseif selectedTab == 3 then
			executeCommandHandler("pp")
		end

		activeFakeInput = false
		fakeInputText = ""
		fakeInputError = false
		
		memberFirePrompt = false
		fireErrorText = ""

		renderData.clientSettings = {}
		renderData.crosshairData = getElementData(localPlayer, "crosshairData") or {0, 255, 255, 255}

		table.insert(renderData.clientSettings, {"Célkereszt", renderData.crosshairData[1] or 0, "crosshair", "crosshair"})

		table.insert(renderData.clientSettings, {"Séta stílus", renderData.walkingStylesEx[getPedWalkingStyle(localPlayer)] or 1, "walkingStyle", true})
		table.insert(renderData.clientSettings, {"Harc stílus", renderData.fightStylesEx[getPedFightingStyle(localPlayer)] or 1, "fightingStyle", true})
		table.insert(renderData.clientSettings, {"Látótávolság", renderData.loadedSettings.viewDistance or getFarClipDistance(), "viewDistance", {100, 3000, "yard"}})

		table.insert(renderData.clientSettings, {"Paletta", renderData.loadedSettings.shader_palette, "shader_palette", true})
		table.insert(renderData.clientSettings, {"HDR Kontraszt", renderData.loadedSettings.shader_contrast, "shader_contrast"})
		table.insert(renderData.clientSettings, {"Bloom", renderData.loadedSettings.shader_bloom, "shader_bloom"})
		table.insert(renderData.clientSettings, {"Karosszéria tükröződés", renderData.loadedSettings.shader_vehicle, "shader_vehicle", true})
		table.insert(renderData.clientSettings, {"Valósághűbb víz", renderData.loadedSettings.shader_water, "shader_water", true})
		table.insert(renderData.clientSettings, {"Részletes HD textúrák", renderData.loadedSettings.shader_detail, "shader_detail"})
		table.insert(renderData.clientSettings, {"Mozgási elmosódás", renderData.loadedSettings.shader_radial, "shader_radial"})
		table.insert(renderData.clientSettings, {"Mélységélesség", renderData.loadedSettings.shader_dof, "shader_dof"})

		table.insert(renderData.clientSettings, {"Chat típus", exports.see_hud:getChatType(), "chatType", true})
		table.insert(renderData.clientSettings, {"Custom chat háttér", reMap(exports.see_hud:getChatBackgroundAlpha(), 0, 255, 0, 100), "chatBackgroundAlpha", {0, 100, "%"}})
		table.insert(renderData.clientSettings, {"Custom chat árnyék", reMap(exports.see_hud:getChatFontBackgroundAlpha(), 0, 255, 0, 100), "chatFontBackgroundAlpha", {0, 100, "%"}})
		table.insert(renderData.clientSettings, {"Custom chat betűméret", exports.see_hud:getChatFontSize(), "chatFontSize", {50, 135, "%"}})
		table.insert(renderData.clientSettings, {"Beszéd animáció", renderData.sayStyleEx[getElementData(localPlayer, "talkingAnim")], "sayStyle", true})
		table.insert(renderData.clientSettings, {"Octans HUD", getElementData(localPlayer, "hudStyle"), "hudStyleChange", false})

		renderData.chatInstance = exports.see_hud:getChatInstance()

		if renderData.chatInstance then
			executeBrowserJavascript(renderData.chatInstance, "document.getElementById(\"preview\").style.visibility = \"visible\";")
			executeBrowserJavascript(renderData.chatInstance, "document.getElementById(\"actual\").style.visibility = \"hidden\";")
		end

		Roboto = dxCreateFont("files/fonts/Roboto.ttf", respc(17.5), false, "antialiased")
		Roboto2 = dxCreateFont("files/fonts/Roboto.ttf", respc(26), false, "antialiased")
		RobotoL = dxCreateFont("files/fonts/RobotoL.ttf", respc(17.5), false, "antialiased")
		RobotoB = dxCreateFont("files/fonts/RobotoB.ttf", respc(26), false, "antialiased")
		RobotoB2 = dxCreateFont("files/fonts/RobotoB.ttf", respc(17.5), false, "antialiased")

		--screenSource = dxCreateScreenSource(screenX, screenY)
		--screenShader = dxCreateShader("files/BlurShader.fx")
		--dxSetShaderValue(screenShader, "screenSource", screenSource)
		blurShader, blurTec = dxCreateShader("files/BlurShader.fx")

		moneyLineX, moneyLineY = respc(1100), respc(405)

		myScreenSource = dxCreateScreenSource(screenX, screenY)

		if not blurShader then
				outputChatBox("[DASHBOARD] Hiba a blur shaderben.")
			end

		addEventHandler("onClientRender", getRootElement(), onRenderHandler, true, "low-100000")
		addEventHandler("onClientClick", getRootElement(), onClickHandler)
		addEventHandler("onClientCharacter", getRootElement(), handleInputs)

		playSound("files/sounds/open.mp3")
		alphaAnim = {getTickCount(), 0, 1}

		panelMoneyRotate = 0
	else

		exports.see_hud:setChatBackgroundAlpha(reMap(renderData.clientSettings[13][2], 0, 100, 0, 255))
		exports.see_hud:setChatFontBackgroundAlpha(reMap(renderData.clientSettings[14][2], 0, 100, 0, 255))
		exports.see_hud:setChatFontSize(renderData.clientSettings[15][2])

		if renderData.chatInstance then
			executeBrowserJavascript(renderData.chatInstance, "document.getElementById(\"preview\").style.visibility = \"hidden\";")
			executeBrowserJavascript(renderData.chatInstance, "document.getElementById(\"actual\").style.visibility = \"visible\";")
		end

		playSound("files/sounds/close.mp3")
		alphaAnim = {getTickCount(), 1, 0}

		if selectedTab == 7 then
				executeCommandHandler("openMyClothesCMD")
		elseif selectedTab == 3 then
				executeCommandHandler("pp")
		end
	end

	showCursor(panelState)
	showChat(not panelState)

	if panelState then
		exports.see_hud:hideHUD()
	else
		exports.see_hud:showHUD()
	end

	buttons = {}
	activeButton = false
end

function getAdmins()
	local gotAdmins = {}

	gotAdmins["as1"] = {}
	gotAdmins["as2"] = {}

	for i = 1, 7 do
		gotAdmins[i] = {}
	end

	for k, v in ipairs(getElementsByType("player")) do
		if not getElementData(v, "hideOnline") then
			local level = getElementData(v, "acc.adminLevel") or 0

			if level > 0 and level <= 7 then
				table.insert(gotAdmins[level], v)
			else
				local level2 = getElementData(v, "acc.helperLevel") or 0

				if level2 > 0 then
					table.insert(gotAdmins["as" .. level2], v)
				end
			end
		end
	end

	renderData.adminSlots = {}

	table.insert(renderData.adminSlots, {"title", "Ideiglenes adminsegédek"})
	
	if #gotAdmins["as1"] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins["as1"]) do
			table.insert(renderData.adminSlots, {"as", "#f49ac1" .. --[[getElementData(v, "char.Name")]]getPlayerName(v):gsub("_", " ") .. "#ffffff (" .. getElementData(v, "playerID") .. ")"})
		end
	end

	table.insert(renderData.adminSlots, {"title", "S.G.H. adminsegédek"})
	
	if #gotAdmins["as2"] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins["as2"]) do
			if getElementData(v, "loggedIn") then 
				table.insert(renderData.adminSlots, {"as", "#f49ac1" .. --[[getElementData(v, "char.Name")]]getPlayerName(v):gsub("_", " ") .. "#ffffff (" .. getElementData(v, "playerID") .. ")"})
			end
		end
	end

	table.insert(renderData.adminSlots, {"title", "1-es adminok"})
	
	if #gotAdmins[1] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[1]) do
			if getElementData(v, "adminDuty") == 1 then
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", true})
			elseif getElementData(localPlayer, "acc.adminLevel") >= 6 then 
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", false})
			else
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick"), false})
			end
		end
	end

	table.insert(renderData.adminSlots, {"title", "2-es adminok"})
	
	if #gotAdmins[2] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[2]) do
			if getElementData(v, "adminDuty") == 1 then
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", true})
			elseif getElementData(localPlayer, "acc.adminLevel") >= 6 then 
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", false})
			else
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick"), false})
			end
		end
	end

	table.insert(renderData.adminSlots, {"title", "3-as adminok"})
	
	if #gotAdmins[3] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[3]) do
			if getElementData(v, "adminDuty") == 1 then
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", true})
			elseif getElementData(localPlayer, "acc.adminLevel") >= 6 then 
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", false})
			else
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick"), false})
			end
		end
	end

	table.insert(renderData.adminSlots, {"title", "4-es adminok"})
	
	if #gotAdmins[4] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[4]) do
			if getElementData(v, "adminDuty") == 1 then
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", true})
			elseif getElementData(localPlayer, "acc.adminLevel") >= 6 then 
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", false})
			else
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick"), false})
			end
		end
	end

	table.insert(renderData.adminSlots, {"title", "5-ös adminok"})
	
	if #gotAdmins[5] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[5]) do
			if getElementData(v, "adminDuty") == 1 then
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", true})
			elseif getElementData(localPlayer, "acc.adminLevel") >= 6 then 
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", false})
			else
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(1) .. getElementData(v, "acc.adminNick"), false})
			end
		end
	end

	table.insert(renderData.adminSlots, {"title", "Főadminok"})
	
	if #gotAdmins[6] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[6]) do
			if getElementData(v, "adminDuty") == 1 then
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(6) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", true})
			else
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(6) .. getElementData(v, "acc.adminNick"), false})
			end
		end
	end

	table.insert(renderData.adminSlots, {"title", "SuperAdminok"})
	
	if #gotAdmins[7] < 1 then
		table.insert(renderData.adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[7]) do
			if getElementData(v, "adminDuty") == 1 then
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(7) .. getElementData(v, "acc.adminNick") .. "#ffffff (" .. getElementData(v, "playerID") .. ")", true})
			else
				table.insert(renderData.adminSlots, {"admin", exports.see_administration:getAdminLevelColor(7) .. getElementData(v, "acc.adminNick"), false})
			end
		end
	end
end

function rgba(r, g, b, a)
	return tocolor(r, g, b, (a or 255) * alpha)
end

function handleInputs(character)
	if buyingVehicleSlot or buyingInteriorSlot or sellVehicleTargetID or sellVehiclePrice then
		local newText = fakeInputText .. character

		if tonumber(newText) then
			if tonumber(newText) >= 1 and not string.find(newText, "e") and tonumber(newText) <= 99999999999999 then
				fakeInputText = newText
			end
		end
	end
	if activeFakeInput == "ChangeDescription" then 
		if string.len(fakeInputText) <= 60 then
			fakeInputText = fakeInputText .. character
		end
	elseif activeFakeInput == "inviting" then 
		if string.len(fakeInputText) <= 20 then
			fakeInputText = fakeInputText .. character
		end
	elseif activeFakeInput == "setrankname" then
		if utf8.len(fakeInputText) <= 20 and not string.find(character, ",") then
			fakeInputText = fakeInputText .. character
		end
	elseif activeFakeInput == "setrankpay" then
		if string.len(fakeInputText) <= 20 and tonumber(character) then
			fakeInputText = fakeInputText .. character
		end
	elseif activeFakeInput == "groupdesc" then
		if utf8.len(fakeInputText) <= 300 then
			fakeInputText = fakeInputText .. character
		end
	elseif activeFakeInput == "groupbalance" then
		if string.len(fakeInputText) <= 20 and tonumber(character) then
			fakeInputText = fakeInputText .. character
		end
	end

	if tonumber(renderData.buyDogType) then
		if not tonumber(character) then
			if utf8.len((renderData.dogName or "")) <= 20 then
				renderData.dogName = (renderData.dogName or "") .. character
			end
		end
	end

	if renderData.renamingPet then
		if not tonumber(character) then
			if utf8.len((renderData.newDogName or "")) <= 20 then
				renderData.newDogName = (renderData.newDogName or "") .. character
			end
		end
	end
end

addEvent("buySlotOK", true)
addEventHandler("buySlotOK", getRootElement(),
	function ()
		buyingVehicleSlot = false
		buyingInteriorSlot = false
		fakeInputText = ""
	end)

local findVehicleId = false
local locatorElements = {}

addEventHandler("onClientElementDestroy", getResourceRootElement(),
	function ()
		for i = 1, #locatorElements do
			local data = locatorElements[i]

			if data and source == data[3] then
				for j = 1, 2 do
					if isElement(data[j]) then
						destroyElement(data[j])
					end
				end
			end
		end
	end)

addEventHandler("onClientMarkerHit", getResourceRootElement(),
	function (hitPlayer, matchingDimension)
		if hitPlayer == localPlayer and matchingDimension then
			for i = 1, #locatorElements do
				local data = locatorElements[i]

				if data and source == data[2] then
					for j = 1, 2 do
						if isElement(data[j]) then
							destroyElement(data[j])
						end
					end

					exports.see_hud:showInfobox("s", "Sikeresen megérkeztél a járművedhez!")
					break
				end
			end
		end
	end)

renderData.canSelectDutySkin = false
renderData.dutySkinMarker = false

local bincoColShape = createColSphere(207.306640625, -100.328125, 1005.2578125, 4)
setElementInterior(bincoColShape, 15)
setElementDimension(bincoColShape, 14)

addEventHandler("onClientColShapeHit", getRootElement(),
	function (hitElement, matchingDimension)
		if hitElement == localPlayer then
			if isElement(source) then
				if matchingDimension then
					if source == bincoColShape then
						renderData.canSelectDutySkin = true
						renderData.dutySkinMarker = false
					else
						local groupId = getElementData(source, "groupId")

						if groupId then
							renderData.canSelectDutySkin = true
							renderData.dutySkinMarker = groupId
						end
					end
				end
			end
		end
	end)

addEventHandler("onClientColShapeLeave", getRootElement(),
	function (hitElement, matchingDimension)
		if hitElement == localPlayer then
			if isElement(source) then
				if source == bincoColShape or getElementData(source, "groupId") then
					renderData.canSelectDutySkin = false
					renderData.dutySkinMarker = false
				end
			end
		end
	end)

local bankCols = {
	createColSphere(2474.9501953125, 1029.6218261719, -1.5933448076248, 10),
	createColSphere(-178.04180908203, 1133.0228271484, 13.118314743042, 10)
}

addEvent("setInputError", true)
addEventHandler("setInputError", getRootElement(),
	function (msg)
		if panelState and selectedTab == 4 and selectedGroupTab == 4 then
			fakeInputError = msg
		end
	end)

addEvent("buyDogNoPP", true)
addEventHandler("buyDogNoPP", getRootElement(),
	function ()
		renderData.buyDogProcessing = false
		playSound("files/sounds/notification.mp3")
	end)

addEvent("buyDogOK", true)
addEventHandler("buyDogOK", getRootElement(),
	function ()
		renderData.buyingPet = false
		renderData.dogName = ""
		renderData.buyDogType = false
		renderData.buyDogProcessing = false
		renderData.renamingPet = false

		playSound("files/sounds/notification.mp3")

		if panelState then
			togglePanel()
		end
	end)

addEvent("toggleDashboardOff", true)
addEventHandler("toggleDashboardOff", getRootElement(),
	function ()
		if panelState then
			togglePanel()
		end
	end)

addEvent("buyPetReviveNoPP", true)
addEventHandler("buyPetReviveNoPP", getRootElement(),
	function ()
		renderData.buyReviveProcessing = false
		playSound("files/sounds/notification.mp3")
	end)

addEvent("buyPetReviveOK", true)
addEventHandler("buyPetReviveOK", getRootElement(),
	function ()
		renderData.buyReviveProcessing = false
		renderData.buyingPetRevive = false
		playSound("files/sounds/notification.mp3")
	end)

addEvent("gpsLocalizeCar", true)
addEventHandler("gpsLocalizeCar", getRootElement(),
	function ()
		for i = 1, #locatorElements do
			local data = locatorElements[i]

			if data and source == data[3] then
				for j = 1, 2 do
					if isElement(data[j]) then
						destroyElement(data[j])
					end
				end
			end
		end

		local x, y, z = getElementPosition(source)
		local blip = createBlip(x, y, z, _, _, 255, 125, 0)

		attachElements(blip, source)
		setElementData(blip, "blipTooltipText", "Járműved (#" .. getElementData(source, "vehicle.dbID") .. ")", false)

		local marker = createMarker(x, y, z, "checkpoint", 4, 255, 125, 0, 100)
		attachElements(marker, source)

		table.insert(locatorElements, {blip, marker, source})
	end)

buySlotProcessing = false

addEvent("buyTheClothesSlot", true)
addEventHandler("buyTheClothesSlot", localPlayer,
	function (infoType, infoText)
		if infoType and infoText then
			exports.see_hud:showInfobox(infoType, infoText)
		end

		buySlotProcessing = false
	end
)

function onClickHandler(button, state)
	if button == "right" and state == "up" then
		if activeButton then
			if string.find(activeButton, "selectVehicle") then
				findVehicleId = tonumber(gettok(activeButton, 2, ":"))

				if isElement(playerVehicles[findVehicleId]) then
					triggerEvent("gpsLocalizeCar", playerVehicles[findVehicleId])
					exports.see_accounts:showInfo("s", "Járműved lokalizálva! Keresd a NARANCSSÁRGA jelzésnél.")
				end
			end
		end
	end

	if button == "left" then
		if activeButton then
			local buttonDetails = split(activeButton, ":")

			if state == "down" then
				if buttonDetails[1] == "openMyClothes" then
					togglePanel()
					executeCommandHandler("openMyClothesCMD")
					return
				end

				if selectedTab == 1 then
					if activeButton == "ChangeDescription" then
						ChangeDescription = true
						activeFakeInput = "ChangeDescription"
						fakeInputText = ""
						fakeInputError = false
					end
					
					if activeButton == "cancel_" .. "desc" .. "_slot" then
						ChangeDescription = false
						activeFakeInput = false
						fakeInputText = ""
						fakeInputError = false
					elseif activeButton == "buy_" .. "desc" .. "_slot" then
						setElementData(localPlayer, "char.description", fakeInputText)
						triggerServerEvent("updatePlayerDescription", localPlayer, fakeInputText)
						ChangeDescription = false
						activeFakeInput = false
						fakeInputText = ""
						fakeInputError = false
					end
				end

				if selectedTab == 7 then
					if buttonDetails[1] == "unlockSlot" then
						if not buySlotProcessing then
							if unlockSlotPrompt then
								buySlotProcessing = true
								triggerServerEvent("tryToBuyClothSlot", localPlayer)

								unlockSlotPrompt = false
								--playSound("files/sounds/promptaccept.mp3")
							else
								unlockSlotPrompt = true
								--playSound("files/sounds/prompt.mp3")
							end
						end
					elseif buttonDetails[1] == "cancelUnlockSlot" then
						if unlockSlotPrompt then
							unlockSlotPrompt = false
							--playSound("files/sounds/promptdecline.mp3")
						end
					elseif buttonDetails[1] == "selectSlot" then
						local slot = tonumber(buttonDetails[2])

						if slot then
							selectedSlot = slot
							currentSlotSelected()
							--playSound("files/sounds/notification.mp3")
						end
					elseif buttonDetails[1] == "openCategory" then
						local cat = tonumber(buttonDetails[2])

						if cat then
							openCategories[cat] = not openCategories[cat]

							currentSlotSelected()

							--playSound("files/sounds/category.mp3")
						end
					elseif buttonDetails[1] == "addCloth" then
							local model = tonumber(buttonDetails[2])

							if model then
								local id = categorizedItems[model]
								local cat = baseCategories[id][2]

								if cat then
									if not myLastPresets[cat] then
										myLastPresets[cat] = {}
									end

									myLastPresets[cat][1] = model

									togglePanel()
									openTheEditor(cat, myLastPresets[cat], selectedSlot)

									playSound("files/sounds/notification.mp3")
								end
							end
					end
				end

				if buttonDetails[1] == "selectVehicle" then
					local vehicleId = tonumber(buttonDetails[2])

					if selectedVeh ~= vehicleId then
						selectedVeh = vehicleId
						playSound("files/sounds/switchoption.mp3")
					end
				end

				if buttonDetails[1] == "sellVehicle" then
					exports.see_accounts:showInfo("e", "Migya")

					sellVehicleTargetID = true
					fakeInputText = ""
					playSound("files/sounds/prompt.mp3")
				end

				if buttonDetails[1] == "selectInterior" then
					local interiorId = tonumber(buttonDetails[2])

					if selectedInt ~= interiorId then
						selectedInt = interiorId
						playSound("files/sounds/switchoption.mp3")
					end
				end

				if buttonDetails[1] == "selectGroup" then
					local groupId = tonumber(buttonDetails[2])

					if selectedGroup ~= groupId then
						selectedGroup = groupId
						playSound("files/sounds/switchoption.mp3")
					end
				end

				if buttonDetails[1] == "selectGroupTab" then
					local tabId = tonumber(buttonDetails[2])

					if selectedGroupTab ~= tabId then
						selectedGroupTab = tabId

						activeFakeInput = false
						fakeInputText = ""
						fakeInputError = false
						
						memberFirePrompt = false
						fireErrorText = ""

						playSound("files/sounds/menuswitch2.mp3")
					end
				end

				if buttonDetails[1] == "selectMember" then
					local memberId = tonumber(buttonDetails[2])

					if selectedMember ~= memberId then
						selectedMember = memberId
						playSound("files/sounds/switchoption.mp3")
					end
				end

				if buttonDetails[1] == "selectRank" then
					local rankId = tonumber(buttonDetails[2])

					if selectedRank ~= rankId then
						selectedRank = rankId
						playSound("files/sounds/switchoption.mp3")
					end
				end

				if buttonDetails[1] == "selectGroupVeh" then
					local vehicleId = tonumber(buttonDetails[2])

					if selectedGroupVeh ~= vehicleId then
						selectedGroupVeh = vehicleId
						playSound("files/sounds/switchoption.mp3")
					end
				end

				if activeButton == "more_vehslot" then
					if not buyingVehicleSlot then
						buyingVehicleSlot = true
						fakeInputText = ""
						playSound("files/sounds/prompt.mp3")
					end
				elseif activeButton == "cancel_veh_slot" then
					buyingVehicleSlot = false
					fakeInputText = ""
					playSound("files/sounds/promptdecline.mp3")
				elseif activeButton == "buy_veh_slot" then
					triggerServerEvent("buyVehSlot", localPlayer, tonumber(fakeInputText))
					playSound("files/sounds/promptaccept.mp3")
				end

				if activeButton == "vehicles" then
					vagyonPanelState = false
				end

				if activeButton == "interiors" then
					vagyonPanelState = true
				end

				if activeButton == "more_intslot" then
					if not buyingInteriorSlot then
						buyingInteriorSlot = true
						fakeInputText = ""
						playSound("files/sounds/prompt.mp3")
					end
				elseif activeButton == "cancel_int_slot" then
					buyingInteriorSlot = false
					fakeInputText = ""
					playSound("files/sounds/promptdecline.mp3")
				elseif activeButton == "buy_int_slot" then
					triggerServerEvent("buyIntSlot", localPlayer, tonumber(fakeInputText))
					playSound("files/sounds/promptaccept.mp3")
				end

				if activeButton == "cancel_targetID_slot" then

					sellVehicleTargetID = false
					fakeInputText = ""

					selectedPlayer = false
					playSound("files/sounds/promptdecline.mp3")
				elseif activeButton == "buy_targetID_slot" then
					if selectedPlayer and selectedPlayer ~= localPlayer then
						sellVehicleTargetID = false
						fakeInputText = ""
						sellVehiclePrice = true
						
						playSound("files/sounds/promptaccept.mp3")
					else
						exports.see_accounts:showInfo("e", "Hibás adatok!")
					end
				elseif activeButton == "cancel_targetPrice_slot" then 
					sellVehiclePrice = false
					sellVehicleTargetID = true
					fakeInputText = ""
					playSound("files/sounds/promptdecline.mp3")
				elseif activeButton == "buy_targetPrice_slot" then
					if selectedPlayer and selectedPlayer ~= localPlayer and tonumber(fakeInputText) then
						local veh = playerVehicles[selectedVeh]

						if inRange(selectedPlayer, localPlayer, 20) and inRange(veh, localPlayer, 20) then

							triggerServerEvent("sendNudes", getRootElement(), localPlayer, veh, selectedPlayer, tonumber(fakeInputText))
							sellVehiclePrice = false
							fakeInputText = ""
							playSound("files/sounds/promptaccept.mp3")
						else
							exports.see_accounts:showInfo("e", "Túl messsze a jármű vagy a player!")
						end


					else
						exports.see_accounts:showInfo("e", "Hibás adatok!")
					end
				end

				if activeButton == "sell_vehicle" then
					exports.see_accounts:showInfo("e", "Jelenleg nem elérhető.")
					-- local veh = playerVehicles[selectedVeh]

					-- if (vehicleDatas[veh]["vehicle.group"] or 0) == 0 then
					-- 	exports.see_tradecontract:sellingVehicle(veh, vehicleDatas[veh])
					-- end
				end

				if activeButton == "sell_interior" then
					exports.see_accounts:showInfo("e", "Jelenleg nem elérhető.")
				end

				if buttonDetails[1] == "selectAnimal" then
					local animalId = tonumber(buttonDetails[2])

					if renderData.selectedAnimal ~= animalId then
						renderData.selectedAnimal = animalId
						playSound("files/sounds/switchoption.mp3")
					end
				end

				if activeButton == "newAnimal" then
					renderData.buyingPet = true
					renderData.buyDogProcessing = false
					playSound("files/sounds/prompt.mp3")
				elseif activeButton == "cancelPetBuy" then
					renderData.buyingPet = false
					renderData.dogName = ""
					renderData.buyDogType = false
					playSound("files/sounds/promptdecline.mp3")
				elseif buttonDetails[1] == "selectPetForBuy" then
					renderData.buyDogType = tonumber(buttonDetails[2])
					playSound("files/sounds/promptaccept.mp3")
				elseif activeButton == "buySelectedPet" then
					if not renderData.buyDogProcessing then
						if utf8.len((renderData.dogName or "")) > 0 then
							triggerServerEvent("buyPet", localPlayer, renderData.dogName, renderData.petNameTypes[renderData.buyDogType], renderData.petPrices[renderData.buyDogType])

							renderData.buyDogProcessing = true

							playSound("files/sounds/promptaccept.mp3")
						else
							exports.see_accounts:showInfo("e", "Név nélkül nem vehetsz kutyát!")
						end
					end
				end

				if activeButton == "spawnAnimal" then
					if getTickCount() - (renderData.lastSpawnAnimal or 0) >= 5000 then
						local animal = renderData.loadedAnimals[renderData.selectedAnimal]

						if animal and animal.animalId then
							if 0 < renderData.spawnedAnimal then
								if renderData.spawnedAnimal == animal.animalId then
									triggerServerEvent("destroyAnimal", localPlayer, renderData.spawnedAnimal)
									renderData.lastSpawnAnimal = getTickCount()
									playSound("files/sounds/switchoption.mp3")
								else
									exports.see_accounts:showInfo("e", "Másik állat lespawnolása előtt, először despawnold az aktívat!")
								end
							else
								triggerServerEvent("spawnAnimal", localPlayer, animal.animalId)
								renderData.lastSpawnAnimal = getTickCount()
								playSound("files/sounds/switchoption.mp3")
							end
						end
					else
						exports.see_accounts:showInfo("e", "5 másodpercenként csak egyszer használhatod ezt a gombot.")
					end
				end

				if activeButton == "renameAnimal" then
					local animal = renderData.loadedAnimals[renderData.selectedAnimal]

					if animal then
						renderData.renamingPet = true
						renderData.newDogName = animal.name or ""
						playSound("files/sounds/prompt.mp3")
					end
				elseif activeButton == "cancelPetRename" then
					renderData.renamingPet = false
					playSound("files/sounds/promptdecline.mp3")
				elseif activeButton == "renameSelectedPet" then
					local animal = renderData.loadedAnimals[renderData.selectedAnimal]

					if animal then
						if utfLen(renderData.newDogName) > 0 then
							if renderData.newDogName ~= animal.name then
								triggerServerEvent("renamePet", localPlayer, animal.animalId, renderData.newDogName)
								playSound("files/sounds/promptaccept.mp3")
							else
								exports.see_accounts:showInfo("e", "Nem lehet ugyan az a név, mint volt.")
							end
						else
							exports.see_accounts:showInfo("e", "Nem lehet üres a pet neve.")
						end
					end
				end

				if activeButton == "reviveAnimal" then
					renderData.buyingPetRevive = true
					playSound("files/sounds/prompt.mp3")
				elseif activeButton == "cancelReviveAnimal" then
					renderData.buyingPetRevive = false
					playSound("files/sounds/promptdecline.mp3")
				elseif activeButton == "buyReviveAnimal" then
					local animal = renderData.loadedAnimals[renderData.selectedAnimal]

					if animal.health < 1 then
						renderData.buyReviveProcessing = true
						triggerServerEvent("buyPetRevive", localPlayer, animal.animalId)
						playSound("files/sounds/promptaccept.mp3")
					else
						exports.see_accounts:showInfo("e", "Ez a kutya nem halott.")
					end
				end

				if activeButton == "sellAnimal" then
					exports.see_accounts:showInfo("e", "Jelenleg nem elérhető.")
				end

				print(activeButton)

				if activeButton == "setting_toggle:hudStyleChange" then

				end

				if string.find(activeButton, "setting_") then
					local id = -1

					for i = 1, #renderData.clientSettings do
						if renderData.clientSettings[i] and renderData.clientSettings[i][3] == buttonDetails[2] then
							id = i
							break
						end
					end

					if buttonDetails[1] == "setting_toggle" then
						if string.find(buttonDetails[2], "shader") then
							if renderData.clientSettings[id] then
								renderData.clientSettings[id][2] = not renderData.clientSettings[id][2]
								renderData.loadedSettings[buttonDetails[2]] = renderData.clientSettings[id][2]
								exports.see_shader:setActiveShader(string.gsub(buttonDetails[2], "shader_", ""), renderData.clientSettings[id][2])
								playSound("files/sounds/switchoption.mp3")
							end
						elseif string.find(buttonDetails[2], "hudStyleChange") then
							setElementData(localPlayer, "hudStyle", not getElementData(localPlayer, "hudStyle"))
							renderData.clientSettings[id][2] = getElementData(localPlayer, "hudStyle")
							playSound("files/sounds/menuswitch2.mp3")
						end
					end

					if buttonDetails[1] == "setting_next" then
						if string.find(buttonDetails[2], "shader") then
							if renderData.clientSettings[id] then
								local shader = string.gsub(buttonDetails[2], "shader_", "")

								if not renderData.clientSettings[id][2] then
									renderData.clientSettings[id][2] = 1
								else
									renderData.clientSettings[id][2] = renderData.clientSettings[id][2] + 1

									local maxValue = 1

									if shader == "palette" then
										maxValue = 14
									elseif shader == "vehicle" then
										maxValue = 3
									elseif shader == "water" then
										maxValue = 2
									end

									if renderData.clientSettings[id][2] > maxValue then
										renderData.clientSettings[id][2] = maxValue
									end
								end

								renderData.loadedSettings[buttonDetails[2]] = renderData.clientSettings[id][2]

								exports.see_shader:setActiveShader(shader, renderData.clientSettings[id][2])

								playSound("files/sounds/menuswitch2.mp3")
							end
						else
							if buttonDetails[2] == "walkingStyle" then
								local nextId = (renderData.walkingStylesEx[getPedWalkingStyle(localPlayer)] or 1) + 1
					
								if renderData.walkingStyles[nextId] then
									renderData.clientSettings[id][2] = nextId
									triggerServerEvent("setPedWalkingStyle", localPlayer, renderData.walkingStyles[nextId])
									playSound("files/sounds/menuswitch2.mp3")
								end
							elseif buttonDetails[2] == "fightingStyle" then
								local nextId = (renderData.fightStylesEx[getPedFightingStyle(localPlayer)] or 1) + 1
					
								if renderData.fightStyles[nextId] then
									renderData.clientSettings[id][2] = nextId
									triggerServerEvent("setPedFightingStyle", localPlayer, renderData.fightStyles[nextId])
									playSound("files/sounds/menuswitch2.mp3")
								end
							elseif buttonDetails[2] == "sayStyle" then
								local nextId = (renderData.sayStyleEx[getElementData(localPlayer, "talkingAnim")] or 1) + 1

								if renderData.sayStyle[nextId] then
									renderData.clientSettings[id][2] = nextId
									setElementData(localPlayer, "talkingAnim", renderData.sayStyle[nextId])
									playSound("files/sounds/menuswitch2.mp3")
								end
							
							elseif buttonDetails[2] == "chatType" then
								local chatType = renderData.clientSettings[id][2]

								if chatType == -1 then
									chatType = 0
								elseif chatType == 0 then
									chatType = 1
								end

								renderData.clientSettings[id][2] = chatType
								exports.see_hud:setChatType(chatType)

								playSound("files/sounds/menuswitch2.mp3")
							elseif buttonDetails[2] == "crosshair" then
								local currentShape = renderData.crosshairData[1] or 0

								currentShape = currentShape + 1

								if currentShape > 12 then
									currentShape = 12
								else
									playSound("files/sounds/menuswitch2.mp3")
								end

								renderData.crosshairData[1] = currentShape

								setElementData(localPlayer, "crosshairData", renderData.crosshairData, false)
							end
						end
					end

					if buttonDetails[1] == "setting_prev" then
						if string.find(buttonDetails[2], "shader") then
							if renderData.clientSettings[id] and renderData.clientSettings[id][2] then
								renderData.clientSettings[id][2] = renderData.clientSettings[id][2] - 1

								if renderData.clientSettings[id][2] <= 0 then
									renderData.clientSettings[id][2] = false
								end

								renderData.loadedSettings[buttonDetails[2]] = renderData.clientSettings[id][2]

								exports.see_shader:setActiveShader(string.gsub(buttonDetails[2], "shader_", ""), renderData.clientSettings[id][2])

								playSound("files/sounds/menuswitch2.mp3")
							end
						else
							if buttonDetails[2] == "walkingStyle" then
								local nextId = (renderData.walkingStylesEx[getPedWalkingStyle(localPlayer)] or 1) - 1
					
								if renderData.walkingStyles[nextId] then
									renderData.clientSettings[id][2] = nextId
									triggerServerEvent("setPedWalkingStyle", localPlayer, renderData.walkingStyles[nextId])
									playSound("files/sounds/menuswitch2.mp3")
								end
							elseif buttonDetails[2] == "fightingStyle" then
								local nextId = (renderData.fightStylesEx[getPedFightingStyle(localPlayer)] or 1) - 1
					
								if renderData.fightStyles[nextId] then
									renderData.clientSettings[id][2] = nextId
									triggerServerEvent("setPedFightingStyle", localPlayer, renderData.fightStyles[nextId])
									playSound("files/sounds/menuswitch2.mp3")
								end
							elseif buttonDetails[2] == "sayStyle" then
								local nextId = (renderData.sayStyleEx[getElementData(localPlayer, "talkingAnim")]) - 1

								if renderData.sayStyle[nextId] then
									renderData.clientSettings[id][2] = nextId
									setElementData(localPlayer, "talkingAnim", renderData.sayStyle[nextId])
									playSound("files/sounds/menuswitch2.mp3")
								end
							elseif buttonDetails[2] == "chatType" then
								local chatType = renderData.clientSettings[id][2]

								if chatType == 1 then
									chatType = 0
								elseif chatType == 0 then
									chatType = -1
								end

								renderData.clientSettings[id][2] = chatType
								exports.see_hud:setChatType(chatType)

								playSound("files/sounds/menuswitch2.mp3")
							elseif buttonDetails[2] == "crosshair" then
								local currentShape = renderData.crosshairData[1] or 0

								currentShape = currentShape - 1

								if currentShape < 0 then
									currentShape = 0
								else
									playSound("files/sounds/menuswitch2.mp3")
								end

								renderData.crosshairData[1] = currentShape

								setElementData(localPlayer, "crosshairData", renderData.crosshairData, false)
							end
						end
					end
				end

				if buttonDetails[1] == "crosshair_color" then
					local r, g, b = renderData.crosshairData[2], renderData.crosshairData[3], renderData.crosshairData[4]

					if r == 255 and g == 255 and b == 255 then
						r, g, b = 71, 127, 168
					elseif r == 124 and g == 197 and b == 118 then
						r, g, b = 215, 89, 89
					elseif r == 215 and g == 89 and b == 89 then
						r, g, b = 89, 142, 215
					elseif r == 89 and g == 142 and b == 215 then
						r, g, b = 255, 127, 0
					elseif r == 255 and g == 127 and b == 0 then
						r, g, b = 220, 163, 0
					else
						r, g, b = 255, 255, 255
					end

					renderData.crosshairData[2] = r
					renderData.crosshairData[3] = g
					renderData.crosshairData[4] = b

					setElementData(localPlayer, "crosshairData", renderData.crosshairData, false)

					playSound("files/sounds/switchoption.mp3")
				end
			elseif state == "up" then
				if buttonDetails[1] == "selectTab" then
					local selected = tonumber(buttonDetails[2])

					if selectedTab ~= selected then
						oldTab = selectedTab

						selectedTab = selected

						if oldTab == 7 then
							executeCommandHandler("openMyClothesCMD")
						elseif oldTab == 3 then
							executeCommandHandler("pp")
						end

						if selectedTab == 4 then
							triggerServerEvent("requestGroups", localPlayer)
						elseif selectedTab == 5 then
							getAdmins()
						elseif selectedTab == 6 then
							fetchAnimals()
						elseif selectedTab == 7 then
							executeCommandHandler("openMyClothesCMD")
						elseif selectedTab == 3 then
							executeCommandHandler("pp")
						end

						activeFakeInput = false
						fakeInputText = ""
						fakeInputError = false

						memberFirePrompt = false
						fireErrorText = ""

						playSound("files/sounds/menuswitch.mp3")
					end
				end

				if buttonDetails[1] == "rankaction" then
					local actionNum = tonumber(buttonDetails[2])
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" and not activeFakeInput then
							fakeInputText = ""
							fakeInputError = false

							if actionNum == 1 then
								activeFakeInput = "setrankname"
							end

							if actionNum == 2 then
								activeFakeInput = "setrankpay"
							end

							playSound("files/sounds/switchoption.mp3")
						end
					end
				end

				if activeButton == "setrankname" then
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId and selectedRank then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							if string.len(fakeInputText) < 1 then
								fakeInputError = "#d75959Nem hagyhatod üresen a mezőt!"
								playSound("files/sounds/promptdecline.mp3")
							else
								fakeInputError = "#477fa8Sikeresen átnevezve!"
								triggerServerEvent("renameGroupRank", localPlayer, selectedRank, fakeInputText, groupId)
								playSound("files/sounds/promptaccept.mp3")
							end
						end
					end

					fakeInputText = ""
				end

				if activeButton == "setrankpay" then
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId and selectedRank then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							if string.len(fakeInputText) < 1 then
								fakeInputError = "#d75959Nem hagyhatod üresen a mezőt!"
								playSound("files/sounds/promptdecline.mp3")
							elseif not tonumber(fakeInputText) then
								fakeInputError = "#d75959Ez nem szám!"
								playSound("files/sounds/promptdecline.mp3")
							elseif string.find(fakeInputText, "e") then
								fakeInputError = "#d75959Ez nem szám!"
								playSound("files/sounds/promptdecline.mp3")
							elseif tonumber(fakeInputText) < 0 then
								fakeInputError = "#d75959Minuszba?!"
								playSound("files/sounds/promptdecline.mp3")
							elseif tonumber(fakeInputText) > 500000 then
								fakeInputError = "#d75959Sok lesz ez!"
								playSound("files/sounds/promptdecline.mp3")
							else
								fakeInputError = "#477fa8Sikeresen átállítva!"
								triggerServerEvent("setGroupRankPayment", localPlayer, selectedRank, math.floor(tonumber(fakeInputText)), groupId)
								playSound("files/sounds/promptaccept.mp3")
							end
						end
					end

					fakeInputText = ""
				end

				if activeButton == "groupdesc" and not activeFakeInput then
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId and selectedRank then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							activeFakeInput = activeButton
							fakeInputText = groups[groupId].description
							fakeInputError = false
							playSound("files/sounds/switchoption.mp3")
						end
					end
				elseif activeButton == "setgroupdesc" then
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId and selectedRank then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							groups[groupId].description = fakeInputText
							triggerServerEvent("rewriteGroupDescription", localPlayer, fakeInputText, groupId)

							activeFakeInput = false
							fakeInputText = ""
							playSound("files/sounds/promptaccept.mp3")
						end
					end
				end

				if activeButton == "groupbalance" and not activeFakeInput then
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId and selectedRank then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							activeFakeInput = activeButton
							fakeInputText = ""
							fakeInputError = false
							playSound("files/sounds/switchoption.mp3")
						end
					end
				elseif activeButton == "getoutmoney" or activeButton == "putbackmoney" then
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId and selectedRank then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							if not isElementWithinColShape(localPlayer, bankCols[1]) and not isElementWithinColShape(localPlayer, bankCols[2]) then
								fakeInputError = "#d75959Nem vagy bankban!"
								playSound("files/sounds/notification.mp3")
								return
							end

							if string.len(fakeInputText) < 1 then
								fakeInputError = "#d75959Nem hagyhatod üresen a mezőt!"
								playSound("files/sounds/promptdecline.mp3")
							elseif not tonumber(fakeInputText) then
								fakeInputError = "#d75959Ez nem szám!"
								playSound("files/sounds/promptdecline.mp3")
							elseif string.find(fakeInputText, "e") then
								fakeInputError = "#d75959Ez nem szám!"
								playSound("files/sounds/promptdecline.mp3")
							elseif tonumber(fakeInputText) < 1000 then
								fakeInputError = "#d75959Minimum 1000$-t kezelhetsz!"
								playSound("files/sounds/promptdecline.mp3")
							else
								fakeInputText = math.floor(tonumber(fakeInputText))

								if activeButton == "getoutmoney" then
									fakeInputText = -fakeInputText
								end

								fakeInputError = "#477fa8Feldolgozás..."
								triggerServerEvent("setGroupBalance", localPlayer, fakeInputText, groupId)
								playSound("files/sounds/promptaccept.mp3")
							end

							fakeInputText = ""
							activeFakeInput = false
						end
					end
				end

				if buttonDetails[1] == "groupaction" then
					local actionNum = tonumber(buttonDetails[2])
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							if actionNum == 1 then
								triggerServerEvent("modifyRankForPlayer", localPlayer, member.id, member.rank, groupId, "up", member.online, playerGroups)
							end

							if actionNum == 2 then
								triggerServerEvent("modifyRankForPlayer", localPlayer, member.id, member.rank, groupId, "down", member.online, playerGroups)
							end

							if actionNum == 3 then
								memberFirePrompt = true
								fireErrorText = "#d75959Tényleg ki szeretnéd rúgni?"
								playSound("files/sounds/prompt.mp3")
							end

							if actionNum == 4 then
								activeFakeInput = "inviting"
								fakeInputText = ""
								fakeInputError = false
								playSound("files/sounds/prompt.mp3")
							end

							playSound("files/sounds/switchoption.mp3")
						end
					end
				end

				if activeButton == "cancelFire" then
					fireErrorText = ""
					memberFirePrompt = false
					playSound("files/sounds/promptdecline.mp3")
				end

				if activeButton == "fireMember" then
					local groupId = playerGroupsKeyed[selectedGroup]

					fireErrorText = ""
					memberFirePrompt = false
					playSound("files/sounds/promptdecline.mp3")

					if groupId then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							triggerServerEvent("deletePlayerFromGroup", localPlayer, member.id, groupId, member.online, playerGroups)
							playSound("files/sounds/promptaccept.mp3")
						end
					end
				end

				if activeButton == "errorOk" then
					activeFakeInput = false
					fakeInputError = false
					fireErrorText = ""
					playSound("files/sounds/notification.mp3")
				end

				if activeButton == "groupInvite" then
					local groupId = playerGroupsKeyed[selectedGroup]

					if groupId then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]

						if member and meInGroup[groupId].isLeader == "Y" then
							if string.len(fakeInputText) < 1 then
								fakeInputError = "#d75959Nem hagyhatod üresen a mezőt!"
								playSound("files/sounds/notification.mp3")
							else
								local found = false
								local multipleFounds = false
								local invitingText = string.lower(string.gsub(fakeInputText, " ", "_"))

								for k, v in ipairs(getElementsByType("player")) do
									if getElementData(v, "loggedIn") then
										local id = getElementData(v, "playerID")
										local name = string.lower(getElementData(v, "visibleName"):gsub(" ", "_"))

										if id == tonumber(invitingText) or string.find(name, invitingText) then
											if found then
												found = false
												multipleFounds = true
												break
											else
												found = v
											end
										end
									end
								end

								if multipleFounds then
									fakeInputError = "#d75959Több találat!"
									playSound("files/sounds/promptdecline.mp3")
								elseif isElement(found) then
									local name = getElementData(found, "visibleName")
									fakeInputError = "#477fa8" .. name:gsub("_", " ") .. " felvétele sikeres!"

									triggerServerEvent("invitePlayerToGroup", localPlayer, getElementData(found, "char.ID"), groupId, found, playerGroups)
									playSound("files/sounds/promptaccept.mp3")
								else
									fakeInputError = "#d75959Nincs találat!"
									playSound("files/sounds/promptdecline.mp3")
								end
							end
						end
					end
				end

				if activeButton == "setDutySkin" and not activeFakeInput then
					toggleDutySkinSelect(true, playerGroupsKeyed[selectedGroup])
					togglePanel()
				end
			end
		end
	end
end

function drawDataRow(startX, startY, h, caption, data, scale)
	local w1 = dxGetTextWidth(caption, scale or 1, RobotoB2)
	local w2 = dxGetTextWidth(string.gsub(data, "#......", ""), scale or 1, Roboto)
	
	dxDrawText(caption, startX, startY, startX + w1, startY + h, rgba(255, 255, 255), scale or 1, RobotoB2, "center", "center", false, false, false, true)
	dxDrawText(data, startX + w1, startY, startX + w1 + w2, startY + h, rgba(71, 127, 168), scale or 1, Roboto, "center", "center", false, false, false, true)

	return startY + h, w1 + w2
end

function onRenderHandler()
	if alphaAnim then
		local now = getTickCount()
		local elapsedTime = now - alphaAnim[1]
		local progress = elapsedTime / 250

		alpha = interpolateBetween(alphaAnim[2], 0, 0, alphaAnim[3], 0, 0, progress, "Linear")

		if screenShader then
			dxSetShaderValue(screenShader, "alpha", alpha)
		end

		if progress >= 1 then
			if alphaAnim[3] == 0 then
				removeEventHandler("onClientRender", getRootElement(), onRenderHandler)
				removeEventHandler("onClientClick", getRootElement(), onClickHandler)
				removeEventHandler("onClientCharacter", getRootElement(), handleInputs)


				if isElement(Roboto) then
					destroyElement(Roboto)
				end

				if isElement(RobotoL) then
					destroyElement(RobotoL)
				end

				if isElement(RobotoB) then
					destroyElement(RobotoB)
				end

				if isElement(RobotoB2) then
					destroyElement(RobotoB2)
				end

				Roboto = nil
				RobotoL = nil
				RobotoB = nil
				RobotoB2 = nil
			end

			alphaAnim = false
		end
	end

	if not (panelState or alphaAnim) then
		return
	end

	if blurShader then
		dxUpdateScreenSource(myScreenSource, true)
		dxSetShaderValue(blurShader, "ScreenSource", myScreenSource)
		dxSetShaderValue(blurShader, "BlurStrength", 5)
		dxSetShaderValue(blurShader, "UVSize", screenX, screenY)
		dxDrawImage(0, 0, screenX, screenY, blurShader)
	end

	local cursorX, cursorY = getCursorPosition()

	if tonumber(cursorX) then
		cursorX = cursorX * screenX
		cursorY = cursorY * screenY
	end

	buttons = {}

	if getTickCount() - lastChangeCursorState >= 500 then
		cursorState = not cursorState
		lastChangeCursorState = getTickCount()
	end

	if renderData.renamingPet then
		local sx, sy = respc(600), respc(300)
		local x = screenX / 2 - sx / 2
		local y = screenY / 2 - sy / 2

		-- ** Háttér
		dxDrawRectangle(x, y, sx, sy, rgba(0, 0, 0, 180))

		-- ** Keret
		dxDrawRectangle(x - 3, y - 3, sx + 6, 3, rgba(0, 0, 0, 200)) -- felső
		dxDrawRectangle(x - 3, y + sy, sx + 6, 3, rgba(0, 0, 0, 200)) -- alsó
		dxDrawRectangle(x - 3, y, 3, sy, rgba(0, 0, 0, 200)) -- bal
		dxDrawRectangle(x + sx, y, 3, sy, rgba(0, 0, 0, 200)) -- jobb

		-- ** Cím
		dxDrawText("Pet átnevezés", x + 1, y - respc(40) + 1, x + sx + 1, y + 1, rgba(0, 0, 0), 1, RobotoL, "center", "center")
		dxDrawText("Pet átnevezés", x, y - respc(40), x + sx, y, rgba(255, 255, 255), 1, RobotoL, "center", "center")

		-- ** Content
		dxDrawText("Add meg a pet új nevét.\nSzükséged lesz egy kutya átnevező kártyára,\namit prémiumpontból tudsz megvásárolni.", x, y, x + sx, y + sy - respc(100), rgba(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)

		local y2 = y + respc(180)
		local formattedText = renderData.newDogName or ""

		dxDrawText("Név:", x + respc(15), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.5, RobotoB, "left", "center")

		dxDrawRectangle(x + respc(65), y2, sx - respc(80), respc(40), rgba(0, 0, 0, 150))

		dxDrawText(formattedText, x + respc(70), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.75, Roboto, "left", "center")

		if cursorState then
			local w = dxGetTextWidth(formattedText, 0.75, Roboto)
			dxDrawRectangle(x + respc(70) + w, y2 + respc(5), 2, respc(40) - respc(10), rgba(255, 255, 255))
		end

		y2 = y2 + respc(60)

		local buttonWidth = (sx - respc(60)) / 2

		-- Mégsem
		buttons["cancelPetRename"] = {x + respc(15), y2, buttonWidth, respc(40)}

		if activeButton == "cancelPetRename" then
			dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 200))
		else
			dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 150))
		end

		dxDrawText("Mégsem", x + respc(15), y2, x + respc(15) + buttonWidth, y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")

		-- Vásárlás
		buttons["renameSelectedPet"] = {x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40)}

		if activeButton == "renameSelectedPet" then
			dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 200))
		else
			dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 150))
		end

		dxDrawText("Átnevezés", x + sx - respc(15) - buttonWidth, y2, x + sx - respc(15), y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")

		-- Egyenleg
		dxDrawText("Prémium egyenleg: " .. formatNumber(myDatas["acc.premiumPoints"] or 0) .. " PP", x + 1, y + sy + 1, x + sx + 1, y + sy + respc(40) + 1, rgba(0, 0, 0), 0.6, Roboto, "center", "center")
		dxDrawText("#477fa8Prémium egyenleg: #ffffff" .. formatNumber(myDatas["acc.premiumPoints"] or 0) .. " #32b3efPP", x, y + sy, x + sx, y + sy + respc(40), rgba(255, 255, 255), 0.6, Roboto, "center", "center", false, false, false, true)

		-- ** Button handler
		activeButton = false

		if isCursorShowing() then
			for k, v in pairs(buttons) do
				if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end

		return
	end

	if renderData.buyingPetRevive then
		local sx, sy = respc(600), respc(150)
		local x = screenX / 2 - sx / 2
		local y = screenY / 2 - sy / 2

		-- ** Háttér
		dxDrawRectangle(x, y, sx, sy, rgba(0, 0, 0, 180))

		-- ** Keret
		dxDrawRectangle(x - 3, y - 3, sx + 6, 3, rgba(0, 0, 0, 200)) -- felső
		dxDrawRectangle(x - 3, y + sy, sx + 6, 3, rgba(0, 0, 0, 200)) -- alsó
		dxDrawRectangle(x - 3, y, 3, sy, rgba(0, 0, 0, 200)) -- bal
		dxDrawRectangle(x + sx, y, 3, sy, rgba(0, 0, 0, 200)) -- jobb

		-- ** Cím
		dxDrawText("Pet felélesztés", x + 1, y - respc(40) + 1, x + sx + 1, y + 1, rgba(0, 0, 0), 1, RobotoL, "center", "center")
		dxDrawText("Pet felélesztés", x, y - respc(40), x + sx, y, rgba(255, 255, 255), 1, RobotoL, "center", "center")

		-- ** Content
		dxDrawText("Tényleg szeretnéd feléleszteni a peted?\n#477fa8A felélesztés ára #32b3ef100 PP#477fa8!", x, y, x + sx, y + sy - respc(70), rgba(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
		
		local y2 = y + sy - respc(60)
		local buttonWidth = (sx - respc(60)) / 2

		-- Mégsem
		buttons["cancelReviveAnimal"] = {x + respc(15), y2, buttonWidth, respc(40)}

		if activeButton == "cancelReviveAnimal" then
			dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 200))
		else
			dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 150))
		end

		dxDrawText("Mégsem", x + respc(15), y2, x + respc(15) + buttonWidth, y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")

		-- Vásárlás
		buttons["buyReviveAnimal"] = {x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40)}

		if activeButton == "buyReviveAnimal" then
			dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 200))
		else
			dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 150))
		end

		dxDrawText("Vásárlás", x + sx - respc(15) - buttonWidth, y2, x + sx - respc(15), y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")

		-- Egyenleg
		dxDrawText("Prémium egyenleg: " .. formatNumber(myDatas["acc.premiumPoints"] or 0) .. " PP", x + 1, y + sy + 1, x + sx + 1, y + sy + respc(40) + 1, rgba(0, 0, 0), 0.6, Roboto, "center", "center")
		dxDrawText("#477fa8Prémium egyenleg: #ffffff" .. formatNumber(myDatas["acc.premiumPoints"] or 0) .. " #32b3efPP", x, y + sy, x + sx, y + sy + respc(40), rgba(255, 255, 255), 0.6, Roboto, "center", "center", false, false, false, true)

		-- ** Button handler
		activeButton = false

		if isCursorShowing() then
			for k, v in pairs(buttons) do
				if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end

		return
	end

	if renderData.buyingPet then
		local sx, sy = respc(1200), respc(350)

		if tonumber(renderData.buyDogType) then
			sx, sy = respc(600), respc(300)
		end

		local x = screenX / 2 - sx / 2
		local y = screenY / 2 - sy / 2

		-- ** Háttér
		dxDrawRectangle(x, y, sx, sy, rgba(0, 0, 0, 180))

		-- ** Keret
		dxDrawRectangle(x - 3, y - 3, sx + 6, 3, rgba(0, 0, 0, 200)) -- felső
		dxDrawRectangle(x - 3, y + sy, sx + 6, 3, rgba(0, 0, 0, 200)) -- alsó
		dxDrawRectangle(x - 3, y, 3, sy, rgba(0, 0, 0, 200)) -- bal
		dxDrawRectangle(x + sx, y, 3, sy, rgba(0, 0, 0, 200)) -- jobb

		-- ** Cím
		dxDrawText("Pet vásárlás", x + 1, y - respc(40) + 1, x + sx + 1, y + 1, rgba(0, 0, 0), 1, RobotoL, "center", "center")
		dxDrawText("Pet vásárlás", x, y - respc(40), x + sx, y, rgba(255, 255, 255), 1, RobotoL, "center", "center")

		-- ** Content
		if tonumber(renderData.buyDogType) then
			if renderData.buyDogProcessing then
				dxDrawText("#477fa8Feldolgozás folyamatban...", x, y, x + sx, y + sy - respc(100), rgba(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
			else
				dxDrawText("Add meg a vásárolni kívánt kutya nevét.\n#477fa8A kutya #32b3ef" .. formatNumber(renderData.petPrices[renderData.buyDogType]) .. " PP#477fa8-be kerül!", x, y, x + sx, y + sy - respc(100), rgba(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
			end

			local y2 = y + respc(180)
			local formattedText = renderData.dogName or ""

			dxDrawText("Név:", x + respc(15), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.5, RobotoB, "left", "center")

			dxDrawRectangle(x + respc(65), y2, sx - respc(80), respc(40), rgba(0, 0, 0, 150))

			dxDrawText(formattedText, x + respc(70), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.75, Roboto, "left", "center")

			if cursorState then
				local w = dxGetTextWidth(formattedText, 0.75, Roboto)
				dxDrawRectangle(x + respc(70) + w, y2 + respc(5), 2, respc(40) - respc(10), rgba(255, 255, 255))
			end

			y2 = y2 + respc(60)

			local buttonWidth = (sx - respc(60)) / 2

			-- Mégsem
			buttons["cancelPetBuy"] = {x + respc(15), y2, buttonWidth, respc(40)}

			if activeButton == "cancelPetBuy" then
				dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 200))
			else
				dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 150))
			end

			dxDrawText("Mégsem", x + respc(15), y2, x + respc(15) + buttonWidth, y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")

			-- Vásárlás
			buttons["buySelectedPet"] = {x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40)}

			if activeButton == "buySelectedPet" then
				dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 200))
			else
				dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 150))
			end

			dxDrawText("Vásárlás", x + sx - respc(15) - buttonWidth, y2, x + sx - respc(15), y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
		else
			dxDrawText("Kattints egy kutyára a típus kiválasztásához.", x, y + respc(20), x + sx, 0, rgba(255, 255, 255), 0.75, RobotoL, "center", "top", false, false, false, true)

			local oneSize = (sx - respc(20) * 7) / 6

			for i = 1, 6 do
				local x2 = x + respc(20) + (oneSize + respc(20)) * (i - 1)
				local y2 = y + respc(70)

				buttons["selectPetForBuy:" .. i] = {x2, y2, oneSize, oneSize}

				if activeButton == "selectPetForBuy:" .. i then
					dxDrawRectangle(x2, y2, oneSize, oneSize, rgba(40, 40, 40, 200))
				else
					dxDrawRectangle(x2, y2, oneSize, oneSize, rgba(40, 40, 40, 100))
				end

				dxDrawImage(x2 + oneSize / 2 - respc(371) / 2, y2 + oneSize / 2 - respc(146) / 2, respc(371), respc(146), "files/images/dogs/" .. i .. ".png", 0, 0, 0, rgba(255, 255, 255))
				
				dxDrawText(renderData.petNameTypes[i], x2, y2 + oneSize, x2 + oneSize, y2 + oneSize + respc(20), rgba(71, 127, 168), 0.65, Roboto, "center", "top")
			end

			buttons["cancelPetBuy"] = {x + respc(20), y + sy - respc(60), sx - respc(40), respc(40)}

			if activeButton == "cancelPetBuy" then
				dxDrawRectangle(x + respc(20), y + sy - respc(60), sx - respc(40), respc(40), rgba(215, 89, 89, 200))
			else
				dxDrawRectangle(x + respc(20), y + sy - respc(60), sx - respc(40), respc(40), rgba(215, 89, 89, 150))
			end

			dxDrawText("Mégsem", x + respc(20), y + sy - respc(60), x + sx - respc(40), y + sy - respc(20), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
		end

		-- Egyenleg
		dxDrawText("Prémium egyenleg: " .. formatNumber(myDatas["acc.premiumPoints"] or 0) .. " PP", x + 1, y + sy + 1, x + sx + 1, y + sy + respc(40) + 1, rgba(0, 0, 0), 0.6, Roboto, "center", "center")
		dxDrawText("#477fa8Prémium egyenleg: #ffffff" .. formatNumber(myDatas["acc.premiumPoints"] or 0) .. " #32b3efPP", x, y + sy, x + sx, y + sy + respc(40), rgba(255, 255, 255), 0.6, Roboto, "center", "center", false, false, false, true)

		-- ** Button handler
		activeButton = false

		if isCursorShowing() then
			for k, v in pairs(buttons) do
				if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end

		return
	end

	if ChangeDescription then
		local sx, sy = respc(600), respc(140)
		local x = screenX / 2 - sx / 2
		local y = screenY / 2 - sy / 2

		-- ** Háttér
		dxDrawRectangle(x, y, sx, sy, rgba(0, 0, 0, 180))

		dxDrawRectangle(x - 3, y - 3, sx + 6, 3, rgba(0, 0, 0, 200)) -- felső
		dxDrawRectangle(x - 3, y + sy, sx + 6, 3, rgba(0, 0, 0, 200)) -- alsó
		dxDrawRectangle(x - 3, y, 3, sy, rgba(0, 0, 0, 200)) -- bal
		dxDrawRectangle(x + sx, y, 3, sy, rgba(0, 0, 0, 200)) -- jobb

		--dxDrawText("Karakter leírás szerekeztése", x + 1, y - respc(40) + 1, x + sx + 1, y + 1, rgba(0, 0, 0), 1, RobotoL, "center", "center")
		dxDrawText("Karakter leírás szerkesztése", x, y - respc(40), x + sx, y, rgba(255, 255, 255), 1, RobotoL, "center", "center")

		local y2 = y + respc(20)

		dxDrawRectangle(x + respc(5), y2, sx - respc(10), respc(40), rgba(0, 0, 0, 150))
		dxDrawText(fakeInputText, x + respc(10), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.75, Roboto, "left", "center")

		y2 = y2 + respc(60)

		local buttonWidth = (sx - respc(60)) / 2

		-- Mégsem
		buttons["cancel_" .. "desc" .. "_slot"] = {x + respc(15), y2, buttonWidth, respc(40)}

		if activeButton == "cancel_" .. "desc" .. "_slot" then
			dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 200))
		else
			dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 150))
		end

		
		dxDrawText("Mégsem", x + respc(15), y2, x + respc(15) + buttonWidth, y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")

		-- Vásárlás
		buttons["buy_" .. "desc" .. "_slot"] = {x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40)}

		if activeButton == "buy_" .. "desc" .. "_slot" then
			dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 200))
		else
			dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 150))
		end

		dxDrawText("Mentés", x + sx - respc(15) - buttonWidth, y2, x + sx - respc(15), y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")

		activeButton = false

		if isCursorShowing() then
			for k, v in pairs(buttons) do
				if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end

		return
	end

	if buyingVehicleSlot or buyingInteriorSlot or sellVehicleTargetID or sellVehiclePrice then
		local sx, sy = respc(600), respc(300)
		local x = screenX / 2 - sx / 2
		local y = screenY / 2 - sy / 2

		-- ** Háttér
		dxDrawRectangle(x, y, sx, sy, rgba(0, 0, 0, 180))

		-- ** Keret
		dxDrawRectangle(x - 3, y - 3, sx + 6, 3, rgba(0, 0, 0, 200)) -- felső
		dxDrawRectangle(x - 3, y + sy, sx + 6, 3, rgba(0, 0, 0, 200)) -- alsó
		dxDrawRectangle(x - 3, y, 3, sy, rgba(0, 0, 0, 200)) -- bal
		dxDrawRectangle(x + sx, y, 3, sy, rgba(0, 0, 0, 200)) -- jobb

		-- ** Cím
		local slotTypeText = "Járműslot vásárlás"
		local buttonPrefix = "veh"

		if buyingInteriorSlot then
			slotTypeText = "Interior slot vásárlás"
			buttonPrefix = "int"
		elseif sellVehicleTargetID then
			slotTypeText = "Jármű eladás"
			buttonPrefix = "targetID"
		elseif sellVehiclePrice then
			slotTypeText = "Jármű eladás"
			buttonPrefix = "targetPrice"
		end

		dxDrawText(slotTypeText, x + 1, y - respc(40) + 1, x + sx + 1, y + 1, rgba(0, 0, 0), 1, RobotoL, "center", "center")
		dxDrawText(slotTypeText, x, y - respc(40), x + sx, y, rgba(255, 255, 255), 1, RobotoL, "center", "center")

		-- ** Content
		local formattedText = tonumber(fakeInputText) or 0

		if sellVehicleTargetID then
			local targetPlayer, targetName = findPlayer(localPlayer, formattedText)

			if not targetName and not targetPlayer then
				targetName = "Nincs találat"
				selectedPlayer = false
			else
				selectedPlayer = targetPlayer
			end

			if targetName == getElementData(localPlayer, "visibleName"):gsub("_", " ") then
				targetName = "Magadnak nem adhatod el!"
			end

			if targetName then
				dxDrawText("#477fa8Add meg a játékos id-jét a billentyűzeteddel!\n" .. targetName, x, y, x + sx, y + sy - respc(100), rgba(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
			end
		elseif sellVehiclePrice then
			dxDrawText("#477fa8Add meg a jármű árát a billentyűzeteddel!\n", x, y, x + sx, y + sy - respc(100), rgba(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
		else
			dxDrawText("#477fa8Add meg a mennyiséget a billentyűzeteddel!\n\n#ffffff(#d759591 db #ffffffslot = #32b3ef500PP#ffffff)\n\nÖsszesen - #ff9600" .. formattedText .. " #477fa8slot #ffffff= " .. formattedText * 500 .. " #32b3efPP", x, y, x + sx, y + sy - respc(100), rgba(255, 255, 255), 0.75, RobotoL, "center", "center", false, false, false, true)
		end
		local y2 = y + respc(180)


		if sellVehicleTargetID then
			dxDrawText("ID:", x + respc(15), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.5, RobotoB, "left", "center")
		elseif sellVehiclePrice then
			dxDrawText("$:", x + respc(15), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.5, RobotoB, "left", "center")
		else
			dxDrawText("Slot:", x + respc(15), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.5, RobotoB, "left", "center")
			dxDrawText("db", 0, y2, x + sx - respc(15), y2 + respc(40), rgba(255, 255, 255), 0.5, RobotoB, "right", "center")
		end

		dxDrawRectangle(x + respc(65), y2, sx - respc(110), respc(40), rgba(0, 0, 0, 150))
		dxDrawText(formattedText, x + respc(70), y2, 0, y2 + respc(40), rgba(255, 255, 255), 0.75, Roboto, "left", "center")

		y2 = y2 + respc(60)

		local buttonWidth = (sx - respc(60)) / 2

		-- Mégsem
		buttons["cancel_" .. buttonPrefix .. "_slot"] = {x + respc(15), y2, buttonWidth, respc(40)}

		if activeButton == "cancel_" .. buttonPrefix .. "_slot" then
			dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 200))
		else
			dxDrawRectangle(x + respc(15), y2, buttonWidth, respc(40), rgba(215, 89, 89, 150))
		end

		if sellVehiclePrice then 
			dxDrawText("Vissza", x + respc(15), y2, x + respc(15) + buttonWidth, y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
		else
			dxDrawText("Mégsem", x + respc(15), y2, x + respc(15) + buttonWidth, y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
		end

		-- Vásárlás
		buttons["buy_" .. buttonPrefix .. "_slot"] = {x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40)}

		if activeButton == "buy_" .. buttonPrefix .. "_slot" then
			dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 200))
		else
			dxDrawRectangle(x + sx - respc(15) - buttonWidth, y2, buttonWidth, respc(40), rgba(71, 127, 168, 150))
		end

		if sellVehicleTargetID then
			dxDrawText("Tovább", x + sx - respc(15) - buttonWidth, y2, x + sx - respc(15), y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
		elseif sellVehiclePrice then
			dxDrawText("Eladás", x + sx - respc(15) - buttonWidth, y2, x + sx - respc(15), y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
		else
			dxDrawText("Vásárlás", x + sx - respc(15) - buttonWidth, y2, x + sx - respc(15), y2 + respc(40), rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
		end

		-- Egyenleg

		if not sellVehicleTargetID and not sellVehiclePrice then
			dxDrawText("Prémium egyenleg: " .. formatNumber(myDatas["acc.premiumPoints"] or 0) .. " PP", x + 1, y + sy + 1, x + sx + 1, y + sy + respc(40) + 1, rgba(0, 0, 0), 0.6, Roboto, "center", "center")
			dxDrawText("#477fa8Prémium egyenleg: #ffffff" .. formatNumber(myDatas["acc.premiumPoints"] or 0) .. " #32b3efPP", x, y + sy, x + sx, y + sy + respc(40), rgba(255, 255, 255), 0.6, Roboto, "center", "center", false, false, false, true)
		end
		-- ** Button handler
		activeButton = false

		if isCursorShowing() then
			for k, v in pairs(buttons) do
				if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end

		return
	end

	-- ** Dashboard
	local sx, sy = screenX, screenY
	local x = 0
	local y = 0

	-- ** Háttér
	local headerHeight = respc(80)

	imageAlpha = 255 * getEasingValue(math.abs(getTickCount() % 10000 - 5000) / 5000, "Linear")

	if imageAlpha <= 8 then
		if currentTick and getTickCount() - currentTick > 2500 then
			currentTick = getTickCount()

			if pictureImage == "files/op.png" then
				pictureImage = "files/op-ex.png"
			else
				pictureImage = "files/op.png"
			end
		end
	end

	dxDrawRectangle(x, y, sx, sy, rgba(0, 0, 0, 120))
	dxDrawImage(x, y, respc(420), sy, "files/69e0c027", 0, 0, 0, rgba(255, 255, 255, 180))
	dxDrawImage(x + respc(210) - respc(140), y + respc(60), respc(280), respc(180), pictureImage, 0, 0, 0, rgba(255, 255, 255, imageAlpha))

	dxDrawText(tabCaptions[selectedTab], x + respc(480), y + respc(75), nil, nil, rgba(255, 255, 255), 1, RobotoB, "left", "center", false, false, false, true)

	-- ** Szekciók
	local oneTabSize = respc(120)
	local tabIconSize = respc(45)

	for k = 1, #tabCaptions do
		local x2 = x
		local y2 = y + respc(60) * k
		local colorOfTab = rgba(200, 200, 200)

		if selectedTab == k then
			dxDrawRectangle(0, y2 + respc(60) + respc(205), respc(420), respc(60), rgba(0, 0, 0, 180))
			dxDrawRectangle(respc(415), y2 + respc(60) + respc(205), respc(5), respc(60), rgba(42, 110, 217, 255))
			colorOfTab = rgba(71, 127, 168)
		elseif activeButton == "selectTab:" .. k then
			dxDrawRectangle(0, y2 + respc(60) + respc(205), respc(420), respc(60), rgba(0, 0, 0, 180))
			colorOfTab = rgba(255, 255, 255)
		end

			
			dxDrawText(tabCaptions[k], respc(405), y2 + respc(60) + respc(235), nil, nil, rgba(255, 255, 255), 1, Roboto, "right", "center")
			buttons["selectTab:" .. k] = {0, y2 + respc(60) + respc(205), respc(420), respc(60)}
	end

	y = y + headerHeight

	-- Információk
	if selectedTab == 1 then
		dxDrawText(myDatas["char.Name"]:gsub("_", " "), x + respc(510), y + respc(45), nil, nil, rgba(255, 255, 255), 1, Roboto2, "left", "center", false, false, false, true)
		local textSize = dxGetTextWidth(myDatas["char.Name"]:gsub("_", " "), 1, Roboto2)
		dxDrawRectangle(x + respc(510), y + respc(65), textSize, respc(3), rgba(79, 150, 176))

		dxDrawImage(screenX - respc(400), screenY / 2 - respc(800) / 2, respc(320), respc(800), ":see_binco/files/skins2/" .. getElementModel(localPlayer) .. ".png", 0, 0, 0, rgba(255, 255, 255))

		local Description = getElementData(localPlayer, "char.description")

		dxDrawText(Description, x + respc(535), y + respc(110), nil, nil, rgba(255, 255, 255), 0.9, RobotoL, "left", "center", false, false, false, true)

		local TextSize = dxGetTextWidth(Description, 0.9, RobotoL)

		if activeButton == "ChangeDescription" then	
			dxDrawImage(x + respc(535) + TextSize + respc(24) / 2, y + respc(110) - respc(24) / 2, respc(24), respc(24), "files/edit.png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))
		else
			dxDrawImage(x + respc(535) + TextSize + respc(24) / 2, y + respc(110) - respc(24) / 2, respc(24), respc(24), "files/edit.png", 0, 0, 0, tocolor(255, 255, 255, 180 * alpha))
		end

		buttons["ChangeDescription"] = {x + respc(535) + TextSize + respc(24) / 2, y + respc(110) - respc(24) / 2, respc(24), respc(24)}

		dxDrawLinedRectangle("Account ID: " .. myDatas["char.accID"], x + respc(535), y + respc(140), respc(355), respc(40), rgba(31, 72, 131, 130), 2, false, false) -- "files/images/tabs/0.png"
		dxDrawLinedRectangle("Karakter ID: " .. myDatas["char.ID"], x + respc(535) + respc(355) + respc(20), y + respc(140), respc(355), respc(40), rgba(31, 72, 131, 130), 2, false, false) -- "files/images/tabs/1.png"
		--dxDrawLinedRectangle(myDatas["char.ID"] .. " éves", x + respc(535), y + respc(200), respc(355) / 2 - respc(10), respc(40), rgba(31, 72, 131, 130), 2, false,  false) -- "files/images/tabs/2.png"
		dxDrawLinedRectangle("Szinted: " ..exports.see_core:getLevel(nil, getElementData(localPlayer, "char.playedMinutes") or 0), x + respc(535), y + respc(200), respc(355) / 2 - respc(10), respc(40), rgba(31, 72, 131, 130), 2, false,  false) -- "files/images/tabs/2.png"
		exports.see_core:getLevel(nil, getElementData(localPlayer, "char.playedMinutes") or 0)
		dxDrawLinedRectangle(myDatas["char.playedMinutes"] .. " perc", x + respc(535) + respc(355) / 2 + respc(10), y + respc(200), respc(355) / 2 - respc(10), respc(40), rgba(31, 72, 131, 130), 2, false, false) -- "files/images/tabs/3.png"

		dxDrawLinedRectangle(#playerVehicles .. " jármű", x + respc(535) + respc(375), y + respc(200), respc(355) / 2 - respc(10), respc(40), rgba(31, 72, 131, 130), 2, false, false) -- "files/images/tabs/5.png"
		dxDrawLinedRectangle(#playerInteriors .. " ingatlan", x + respc(535) + respc(355) / 2 + respc(10) + respc(375), y + respc(200), respc(355) / 2 - respc(10), respc(40), rgba(31, 72, 131, 130), 2, false, false) --"files/images/tabs/4.png"

		--dxDrawLinedRectangle("13 perc a fizetésig", x + respc(535), y + respc(260), respc(355), respc(40), rgba(31, 72, 131, 130), 2, false)
		dxDrawLinedRectangle(myDatas["char.playTimeForPayday"] ..  " perc a fizetésig", x + respc(535), y + respc(260), respc(355), respc(40), rgba(31, 72, 131, 130), 2, false)

		local posY = y + respc(365)

		dxDrawText("Skin: #3CA2DB" .. getElementModel(localPlayer), x + respc(535), posY, nil, nil, rgba(255, 255, 255), 0.85, Roboto, "left", "center", false, false, false, true)
		posY = posY + respc(35)
		dxDrawText("Játszott percek: #3CA2DB" .. myDatas["char.playedMinutes"] .. " #ffffffperc", x + respc(535), posY, nil, nil, rgba(255, 255, 255), 0.85, Roboto, "left", "center", false, false, false, true)
		posY = posY + respc(35)
		dxDrawText("Casino Coins: #3CA2DB" .. myDatas["char.slotCoins"] .. " #ffffffdb", x + respc(535), posY, nil, nil, rgba(255, 255, 255), 0.85, Roboto, "left", "center", false, false, false, true)
		posY = posY + respc(35)
		dxDrawText("Prémium egyenleg: #3CA2DB" .. myDatas["acc.premiumPoints"] .. " #ffffffPP", x + respc(535), posY, nil, nil, rgba(255, 255, 255), 0.85, Roboto, "left", "center", false, false, false, true)
		posY = posY + respc(35)
		dxDrawText("Nem: #3CA2DB" .. "Férfi", x + respc(535), posY, nil, nil, rgba(255, 255, 255), 0.85, Roboto, "left", "center", false, false, false, true)
		posY = posY + respc(35)
		--dxDrawText("Születési idő: #3CA2DB", x + respc(535), posY, nil, nil, rgba(255, 255, 255), 0.85, Roboto, "left", "center", false, false, false, true)
		--posY = posY + respc(35)
		--dxDrawText("Születési hely: #3CA2DB", x + respc(535), posY, nil, nil, rgba(255, 255, 255), 0.85, Roboto, "left", "center", false, false, false, true)

		local playerMoney = myDatas["char.Money"]
		local playerBankMoney = myDatas["char.bankMoney"]

		moneyLineX = respc(1100)
		moneyLineY = respc(405)

		local valueList = {playerBankMoney, playerMoney, 0}
		local colorList = {{124, 197, 118}, {215, 89, 89}, {255, 127, 0}}
		local labelList = {"Bank: $%s", "Készpénz: $%s", "Vállalkozás: $%s"}

		dxDrawPieChart(x + respc(1100), y + respc(405), respc(100), valueList, colorList, labelList)
	end

	-- Vagyon
	if selectedTab == 2 then
		local startX = x
		local startY = y + respc(25)

		local oneSectionWidth = sx / 3

		dxDrawText("Készpénz: #477fa8$" .. formatNumber(myDatas["char.Money"]) .. " #ffffffBankban elhelyezett pénzösszeg összesen: #477fa8$" .. formatNumber(myDatas["char.bankMoney"]) .. " #ffffffPrémiumpontok: #477fa8" .. formatNumber(myDatas["acc.premiumPoints"]) .. " PP", screenX / 2 + respc(200), startY + respc(30), nil, nil, rgba(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)

		startX = x + respc(460)
		startY = y + respc(90)

		local oneSegmentSizeX = respc(410)
		local oneSegmentSizeY = sy - headerHeight - respc(150)

		-- Járművek
		local maxThings = #playerVehicles

		--dxDrawRectangle(startX, startY - respc(50), oneSegmentSizeX, respc(45), rgba(0, 0, 0, 150))
		--dxDrawText("Járműveim (#477fa8" .. maxThings .. " #ffffffdb/#477fa8" .. myDatas["char.maxVehicles"] .. " #ffffffdb)", startX, startY - respc(50), startX + oneSegmentSizeX, startY - respc(5), rgba(255, 255, 255), 0.85, RobotoL, "center", "center", false, false, false, true)

		--if activeButton == "more_vehslot" then
			--dxDrawRectangle(startX + oneSegmentSizeX - respc(105), startY - respc(50) + respc(45) / 2 - respc(35) / 2, respc(100), respc(35), rgba(50, 179, 239, 240))
		--else
			--dxDrawRectangle(startX + oneSegmentSizeX - respc(105), startY - respc(50) + respc(45) / 2 - respc(35) / 2, respc(100), respc(35), rgba(50, 179, 239, 180))
		--end

		--dxDrawText("+ slot", startX + oneSegmentSizeX - respc(105), startY - respc(50), startX + oneSegmentSizeX - respc(5), startY - respc(5), rgba(255, 255, 255), 0.5, RobotoB, "center", "center")

		--buttons["more_vehslot"] = {startX + oneSegmentSizeX - respc(105), startY - respc(50) + respc(45) / 2 - respc(35) / 2, respc(100), respc(35)}

		--dxDrawRectangle(startX, startY, oneSegmentSizeX, oneSegmentSizeY, rgba(0, 0, 0, 100))

		local num = 19
		local oneSize = oneSegmentSizeY / num

		drawLine(startX - 2, startY - 2, respc(410) + 2, num * oneSize + 4, rgba(31, 72, 131, 130), 2, false)

		if not vagyonPanelState then
			for i = 1, num do
				local lineY = startY + (i - 1) * oneSize
				local veh = playerVehicles[i + offsetVeh]

				if i + offsetVeh == selectedVeh and isElement(veh) then
					dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(31, 72, 131, 180))
					selectedVehName = vehicleDatas[veh].vehicleName 
					selectedVehID = vehicleDatas[veh].vehModelID
				elseif activeButton == "selectVehicle:" .. i + offsetVeh then
					dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(31, 72, 131, 180))
				else
					if i % 2 == 0 then
						dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 120))
					else
						dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 50))
					end
				end

				if isElement(veh) then
					local datas = vehicleDatas[veh]

					local plateText = split(getVehiclePlateText(veh), "-")
					local plateSections = {}

					for i = 1, #plateText do
						if utf8.len(plateText[i]) > 0 then
							table.insert(plateSections, plateText[i])
						end
					end

					local colorOfText = rgba(255, 255, 255)

					if i + offsetVeh == selectedVeh then
						colorOfText = rgba(255, 255, 255)
					elseif activeButton == "selectVehicle:" .. i + offsetVeh then
						colorOfText = rgba(255, 255, 255)
					end

					buttons.sellVehicle = {oneSegmentSizeX + respc(900) - respc(50), sy - headerHeight, respc(285), respc(25)}

					if sellState then

					end

					if activeButton == "sellVehicle" then 
						dxDrawRectangle(oneSegmentSizeX + respc(900) - respc(50), sy - headerHeight, respc(285), respc(25), tocolor(124, 128, 100))
						dxDrawText("Jármű eladása", oneSegmentSizeX + respc(900) - respc(50) + respc(160+respc(15))/2, sy - headerHeight + respc(25)/2, nil, nil, rgba(255, 255, 255), 0.6, Roboto, "left", "center", false, false, false, true)
					else
						dxDrawRectangle(oneSegmentSizeX + respc(900) - respc(50), sy - headerHeight, respc(285), respc(25), tocolor(50, 179, 239))
						dxDrawText("Jármű eladása", oneSegmentSizeX + respc(900) - respc(50) + respc(160+respc(15))/2, sy - headerHeight + respc(25)/2, nil, nil, rgba(255, 255, 255), 0.6, Roboto, "left", "center", false, false, false, true)
					end
					dxDrawText(i + offsetVeh .. ". " .. datas.vehicleName .. "\n" .. table.concat(plateSections, "-") .. " | " .. formatNumber(datas["vehicle.dbID"], ","), startX + respc(10), lineY + respc(5), nil, nil, colorOfText, 0.5, Roboto, "left", "top")

					buttons["selectVehicle:" .. i + offsetVeh] = {startX, lineY, oneSegmentSizeX, oneSize}
				elseif veh then
					dxDrawText("Hiányzó jármű.", startX + 10, lineY, 0, lineY + oneSize, rgba(255, 150, 0), 0.5, RobotoB, "left", "center")
				end
			end
		else
			for i = 1, num do
			local lineY = startY + (i - 1) * oneSize
			local int = playerInteriors[i + offsetInt]

			if i + offsetInt == selectedInt and int then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(31, 72, 131, 180))
			elseif activeButton == "selectInterior:" .. i + offsetInt then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(31, 72, 131, 180))
			else
				if i % 2 == 0 then
					dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 120))
				else
					dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 50))
				end
			end

			if i ~= num then
				--dxDrawRectangle(startX, lineY + oneSize, oneSegmentSizeX, 2, rgba(255, 255, 255, 25))
			end

			if int then
				local datas = int.data
				local colorOfText = rgba(255, 255, 255)

				if i + offsetInt == selectedInt then
					colorOfText = rgba(255, 255, 255)
					selectedIntName = datas.name
					selectedIntType = datas.type
					intLocked = datas.locked
					intID = datas.interiorId
					gameInterior = datas.gameInterior
					intDatas = playerInteriors[i + offsetInt]
				elseif activeButton == "selectInterior:" .. i + offsetInt then
					colorOfText = rgba(255, 255, 255)
				end

				if datas.iconPicture then
					--dxDrawImage(math.floor(startX + 10), math.floor(lineY + oneSize / 2 - respc(32) / 2), respc(32), respc(32), datas.iconPicture, 0, 0, 0, colorOfText)
				end

				dxDrawText(i .. ". " ..datas.name .. "\n" .. formatNumber(datas.interiorId, ","), startX + respc(10), lineY + respc(5), nil, nil, colorOfText, 0.5, Roboto, "left", "top")

				--dxDrawText(datas.name, startX + 20 + respc(32), lineY, 0, lineY + oneSize, colorOfText, 0.75, Roboto, "left", "center")
				dxDrawText((datas.locked == "Y" and "Zárva" or "Nyitva"), 0, lineY, startX + oneSegmentSizeX - 10, lineY + oneSize, colorOfText, 0.75, Roboto, "right", "center")

				buttons["selectInterior:" .. i + offsetInt] = {startX, lineY, oneSegmentSizeX, oneSize}
			end
		end
		end

		local veh = playerVehicles[selectedVeh]

		local startX = oneSegmentSizeX + respc(420)
		local datas = vehicleDatas[veh]

		local startY = startY + oneSegmentSizeY + respc(10)
		local sectionSize = (y + sy - headerHeight) - startY

		local holderSizeX = oneSegmentSizeX / 2
		local scale = 0.65
		local height = respc(30) * scale

		if activeButton == "vehicles" or not vagyonPanelState then
			dxDrawRectangle(respc(460) + respc(170), respc(50), respc(150), respc(50), tocolor(31, 72, 131))
		else
			dxDrawRectangle(respc(460) + respc(170), respc(50), respc(150), respc(50), tocolor(31, 72, 131, 120))
		end

		if activeButton == "interiors" or vagyonPanelState  then
			dxDrawRectangle(respc(460) + respc(170) + respc(150), respc(50), respc(150), respc(50), tocolor(31, 72, 131))
		else
			dxDrawRectangle(respc(460) + respc(170) + respc(150), respc(50), respc(150), respc(50), tocolor(31, 72, 131, 120))
		end

		if activeButton == "more_vehslot" or activeButton == "more_intslot" then
			dxDrawRectangle(respc(460) + respc(170) + respc(300) + respc(150), respc(50), respc(150), respc(50), tocolor(31, 72, 131))
		else
			dxDrawRectangle(respc(460) + respc(170) + respc(300) + respc(150), respc(50), respc(150), respc(50), tocolor(31, 72, 131, 120))
		end

		dxDrawText("+ slot", respc(460) + respc(170) + respc(300) + respc(150) + respc(150) / 2, respc(50) + respc(25), nil, nil, rgba(255, 255, 255), 1, RobotoL, "center", "center")

		dxDrawText("Járművek", respc(460) + respc(170) + respc(150) / 2, respc(75), nil, nil, rgba(255, 255, 255), 1, RobotoL, "center", "center")
		
		dxDrawText("Ingatlanok", respc(460) + respc(170) + respc(150) / 2 + respc(150), respc(75), nil, nil, rgba(255, 255, 255), 1, RobotoL, "center", "center")

		dxDrawText(maxThings .. "/" .. myDatas["char.maxVehicles"], respc(460) + respc(170) + respc(150) / 2 + respc(300), respc(75), nil, nil, rgba(255, 255, 255), 1, RobotoL, "center", "center")

		buttons["vehicles"] = {respc(460) + respc(170), respc(50), respc(150), respc(50)}
		buttons["interiors"] = {respc(460) + respc(170) + respc(150), respc(50), respc(150), respc(50)}

		if vagyonPanelState then
			buttons["more_intslot"] = {respc(460) + respc(170) + respc(300) + respc(150), respc(50), respc(150), respc(50)}
		else
			buttons["more_vehslot"] = {respc(460) + respc(170) + respc(300) + respc(150), respc(50), respc(150), respc(50)}
		end
		if not vagyonPanelState then
			if isElement(veh) then
				--[[
				if (datas["vehicle.group"] or 0) == 0 then
					if activeButton == "sell_vehicle" then
						dxDrawRectangle(startX + oneSegmentSizeX - respc(105), startY + sectionSize - respc(55), respc(100), respc(35), rgba(255, 115, 0, 240))
					else
						dxDrawRectangle(startX + oneSegmentSizeX - respc(105), startY + sectionSize - respc(55), respc(100), respc(35), rgba(255, 115, 0, 180))
					end

					dxDrawText("Eladás", startX + oneSegmentSizeX - respc(105), startY + sectionSize - respc(55), startX + oneSegmentSizeX - respc(5), startY + sectionSize - respc(20), rgba(0, 0, 0), 0.5, RobotoB, "center", "center")

					buttons["sell_vehicle"] = {startX + oneSegmentSizeX - respc(105), startY + sectionSize - respc(55), respc(100), respc(35)}
				end]]

				if fileExists("files/cars/" .. selectedVehID .. ".png") then
					dxDrawImage(screenX / 2 + (respc(460) + oneSegmentSizeX) / 2 - respc(900) / 4, (num - 1) * oneSize - respc(600) / 2 - respc(60), respc(900) / 2, respc(600) / 2, "files/cars/" .. selectedVehID .. ".png", 0, 0, 0, rgba(255, 255, 255, 255))
				end

				local airrideData = "Nincs" 

				if (datas["vehicle.tuning.AirRide"] or 0) == 1 then
					airrideData = "Van"
				end

				dxDrawText(selectedVehName, screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize - respc(35), nil, nil, rgba(255, 255, 255), 1, Roboto2, "center", "center", false, false, false, true)
				local textSize = dxGetTextWidth(selectedVehName, 1, Roboto2)
				dxDrawRectangle(screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize - respc(35) + respc(25), textSize / 2, respc(3), rgba(79, 150, 176))
				dxDrawRectangle(screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize - respc(35) + respc(25), - textSize / 2, respc(3), rgba(79, 150, 176))

				dxDrawText(
					"Turbó tuning: " .. tuningName[datas["vehicle.tuning.Turbo"] or 0] .. "  Váltó tuning: " .. tuningName[datas["vehicle.tuning.Transmission"] or 0] .. "  Felfüggesztés: " .. tuningName[datas["vehicle.tuning.Suspension"] or 0] .. 
					"\n Motor: " .. tuningName[datas["vehicle.tuning.Engine"] or 0] .. "  ECU: " .. tuningName[datas["vehicle.tuning.ECU"] or 0] .. "  Fék: " .. tuningName[datas["vehicle.tuning.Brakes"] or 0] ..
					"\n Motor: " .. (datas["vehicle.engine"] == 1 and "Felindítva" or "Leállítva") .. "  Lámpa: " .. (getVehicleOverrideLights(veh) == 2 and "felkapcsolva" or "lekapcsolva") .. "  Kézifék: " .. (datas["vehicle.handBrake"] and "behúzva" or "kiengedve") ..
					"\n Kerék tuning: " .. tuningName[datas["vehicle.tuning.Tires"] or 0] .. "  Súlycsökkentés tuning: " .. tuningName[datas["vehicle.tuning.WeightReduction"] or 0] ..
					"\n AirRide: " .. airrideData, 
					screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize, nil, nil, rgba(255, 255, 255), 0.7, Roboto, "center", "top", false, false, false, true
				)
			else
				dxDrawText("Nincs jármű kiválasztva.", screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize, nil, nil, rgba(255, 255, 255), 0.7, Roboto, "center", "top", false, false, false, true)
			end
		else
			if intDatas then
				dxDrawText(selectedIntName, screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize - respc(35), nil, nil, rgba(255, 255, 255), 1, Roboto2, "center", "center", false, false, false, true)
				local textSize = dxGetTextWidth(selectedIntName, 1, Roboto2)
				dxDrawRectangle(screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize - respc(35) + respc(25), textSize / 2, respc(3), rgba(79, 150, 176))
				dxDrawRectangle(screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize - respc(35) + respc(25), - textSize / 2, respc(3), rgba(79, 150, 176))

				dxDrawText(
					"Típus: " .. (selectedIntType or "Ismeretlen") .. "  Ajtók: " .. (intLocked == "Y" and "Zárva" or "Nyitva") .. "\nInterior ID: " .. formatNumber(intID, ","), 
					screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize, nil, nil, rgba(255, 255, 255), 0.7, Roboto, "center", "top", false, false, false, true
				)

				if fileExists(":see_interiors/files/pics/" .. gameInterior .. ".jpg") then
					dxDrawImage(screenX / 2 + (respc(460) + oneSegmentSizeX) / 2 - respc(900) / 4, (num - 1) * oneSize - respc(600) / 2 - respc(60), respc(900) / 2, respc(600) / 2, ":see_interiors/files/pics/" .. gameInterior .. ".jpg", 0, 0, 0, rgba(255, 255, 255, 255))
				end
			else
				dxDrawText(
				"Nincs ingatlan kiválasztva.", 
				screenX / 2 + (respc(460) + oneSegmentSizeX) / 2, (num - 1) * oneSize, nil, nil, rgba(255, 255, 255), 0.7, Roboto, "center", "top", false, false, false, true
				)
			end
		end
	end

	-- Frakciók
	if selectedTab == 4 then
		local startX = x + respc(460)
		local startY = y + respc(50)

		local oneSegmentSizeX = (screenX - respc(460)) / 3.5
		local oneSegmentSizeY = sy - headerHeight - respc(20) - respc(100)

		dxDrawRectangle(startX, startY, oneSegmentSizeX, oneSegmentSizeY, rgba(0, 0, 0, 100))

		local num = 20
		local oneSize = oneSegmentSizeY / num

		for i = 1, num do
			local lineY = startY + (i - 1) * oneSize
			local groupId = playerGroupsKeyed[i + offsetGroup]

			if i + offsetGroup == selectedGroup and tonumber(groupId) then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(71, 127, 168, 150))
			elseif activeButton == "selectGroup:" .. i + offsetGroup then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(255, 255, 255, 25))
			else
				if i % 2 == 0 then
					dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 30))
				end
			end

			if i ~= num then
				dxDrawRectangle(startX, lineY + oneSize, oneSegmentSizeX, 2, rgba(255, 255, 255, 25))
			end

			if playerGroupsCount < 1 and i == 10 then
				dxDrawText("Nem vagy frakcióban.", startX, lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 150, 0), 0.5, RobotoB, "center", "center")
			end

			if tonumber(groupId) then
				local datas = groups[groupId]
				local colorOfText = rgba(255, 255, 255)

				if i + offsetGroup == selectedGroup then
					colorOfText = rgba(0, 0, 0)
				elseif activeButton == "selectGroup:" .. i + offsetGroup then
					colorOfText = rgba(71, 127, 168)
				end

				dxDrawText(datas.name, startX + 10, lineY, 0, lineY + oneSize, colorOfText, 0.65, Roboto, "left", "center")
				--dxDrawText(groupTypes[datas.type], 0, lineY, startX + oneSegmentSizeX - 10, lineY + oneSize, colorOfText, 0.65, Roboto, "right", "center")

				buttons["selectGroup:" .. i + offsetGroup] = {startX, lineY, oneSegmentSizeX, oneSize}
			end
		end

		if playerGroupsCount > num then
			local trackSize = num * oneSize
			dxDrawRectangle(startX + oneSegmentSizeX, startY, 5, trackSize, rgba(255, 255, 255, 25))
			dxDrawRectangle(startX + oneSegmentSizeX, startY + offsetGroup * (trackSize / playerGroupsCount), 5, trackSize / playerGroupsCount * num, rgba(71, 127, 168, 150))
		end

		local groupId = playerGroupsKeyed[selectedGroup]

		if tonumber(groupId) and playerGroups[groupId] and groups[groupId] and meInGroup[groupId] then
			local group = groups[groupId]
			local myRank = meInGroup[groupId].rank

			dxDrawText(group.name .. " (" .. groupId .. ")", startX + oneSegmentSizeX, startY, x + sx, startY + respc(50), rgba(71, 127, 168), 0.85, RobotoB, "center", "center")

			startX = startX + oneSegmentSizeX + respc(25)
			startY = startY + respc(60)

			local oneSize = (x + sx - oneSegmentSizeX - respc(150)) / 3
			local scale = 0.65
			local height = respc(30) * scale

			local w = dxGetTextWidth("Rangod: ", scale, RobotoB2)
			w = w + dxGetTextWidth(group.ranks[myRank].name .. " (" .. myRank .. ")", scale, Roboto)

			local w2 = dxGetTextWidth("Fizetésed: ", scale, RobotoB2)
			w2 = w2 + dxGetTextWidth(formatNumber(group.ranks[myRank].pay) .. " $", scale, Roboto)

			local w3 = dxGetTextWidth("Duty skined: ", scale, RobotoB2)

			if meInGroup[groupId].dutySkin == 0 then
				w3 = w3 + dxGetTextWidth("nincs beállítva", scale, Roboto)
			else
				w3 = w3 + dxGetTextWidth(meInGroup[groupId].dutySkin, scale, Roboto)
			end

			drawDataRow(startX + (oneSize - w) / 2, startY, height, "Rangod: ", group.ranks[myRank].name .. " #ffffff(" .. myRank .. ")", scale)
			
			drawDataRow(startX + oneSize + (oneSize - w2) / 2, startY, height, "Fizetésed: ", "#dddddd" .. formatNumber(group.ranks[myRank].pay) .. " #477fa8$", scale)
			
			if meInGroup[groupId].dutySkin == 0 then
				drawDataRow(startX + oneSize * 2 + (oneSize - w3) / 2, startY, height, "Duty skined: ", "#d75959nincs beállítva", scale)
			else
				drawDataRow(startX + oneSize * 2 + (oneSize - w3) / 2, startY, height, "Duty skined: ", "#afafaf" .. meInGroup[groupId].dutySkin, scale)
			end

			-- Tabok
			startY = startY + height + respc(10)

			local oneSize = (x + sx - respc(500) - oneSegmentSizeX - respc(100)) / 4

			for i = 1, 4 do
				local lineX = startX + (i - 1) * oneSize
				local colorOfText = rgba(255, 255, 255)

				if selectedGroupTab == i then
					dxDrawRectangle(lineX, startY, oneSize, respc(35), rgba(71, 127, 168, 150))
				else
					if activeButton == "selectGroupTab:" .. i then
						dxDrawRectangle(lineX, startY, oneSize, respc(35), rgba(255, 255, 255, 25))

						colorOfText = rgba(71, 127, 168)
					else
						dxDrawRectangle(lineX, startY, oneSize, respc(35), rgba(0, 0, 0, 150))
					end
				end

				if i ~= 4 then
					dxDrawRectangle(lineX + oneSize - 1, startY, 2, respc(35), rgba(255, 255, 255, 25))
				end

				dxDrawText(groupTabs[i], lineX, startY, lineX + oneSize, startY + respc(35), colorOfText, 0.75, RobotoL, "center", "center")

				buttons["selectGroupTab:" .. i] = {lineX, startY, oneSize, respc(35)}
			end

			startY = startY + respc(50)

			local oneSectionSizeX = (x + sx - oneSegmentSizeX - respc(30) - screenX / 4) / 2
			local oneSectionSizeY = (y + sy - headerHeight) - startY - respc(20) - respc(40)

			-- Tagok
			if selectedGroupTab == 1 then
				dxDrawRectangle(startX, startY, oneSectionSizeX, oneSectionSizeY, rgba(0, 0, 0, 100))

				local num = 14
				local oneSize = oneSectionSizeY / num
				local thisMembers = groupMembers[groupId]

				if selectedMember > #thisMembers then
					selectedMember = #thisMembers
				end

				for i = 1, num do
					local lineY = startY + (i - 1) * oneSize
					local member = thisMembers[i + offsetMember]

					if i + offsetMember == selectedMember and member then
						if member.online then
							dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(71, 127, 168, 150)) -- 
						else
							dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(215, 89, 89, 150))
						end
					elseif activeButton == "selectMember:" .. i + offsetMember then
						dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(255, 255, 255, 25))
					else
						if i % 2 == 0 then
							dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(0, 0, 0, 30))
						end
					end

					if i ~= num then
						dxDrawRectangle(startX, lineY + oneSize, oneSectionSizeX, 2, rgba(255, 255, 255, 25))
					end

					if member then
						local colorOfText = rgba(255, 255, 255)

						if i + offsetMember == selectedMember then
							colorOfText = rgba(0, 0, 0)
						elseif activeButton == "selectMember:" .. i + offsetMember then
							if member.online then
								colorOfText = rgba(71, 127, 168)
							else
								colorOfText = rgba(215, 89, 89)
							end
						elseif not member.online then
							colorOfText = rgba(215, 89, 89)
						else
							colorOfText = rgba(71, 127, 168)
						end

						dxDrawText(member.characterName:gsub("_", " "), startX + 10, lineY, 0, lineY + oneSize, colorOfText, 0.65, Roboto, "left", "center")
						dxDrawText(group.ranks[member.rank].name .. " (" .. member.rank .. ")", 0, lineY, startX + oneSectionSizeX - 10, lineY + oneSize, colorOfText, 0.65, Roboto, "right", "center")

						buttons["selectMember:" .. i + offsetMember] = {startX, lineY, oneSectionSizeX, oneSize}
					end
				end

				local trackSize = num * oneSize

				if #thisMembers > num then
					dxDrawRectangle(startX + oneSectionSizeX, startY, 5, trackSize, rgba(255, 255, 255, 25))
					dxDrawRectangle(startX + oneSectionSizeX, startY + offsetMember * (trackSize / #thisMembers), 5, trackSize / #thisMembers * num, rgba(71, 127, 168, 150))
				end

				dxDrawText(math.ceil(offsetMember / num) + 1 .. "/" .. math.ceil(#thisMembers / num) .. ". oldal (" .. selectedMember .. "/" .. #thisMembers .. "db tag)", startX, startY + trackSize, startX + oneSectionSizeX, startY + trackSize + respc(40), rgba(255, 255, 255), 0.6, Roboto, "center", "center")
				
				local member = thisMembers[selectedMember]

				if member then
					local startX = startX + oneSectionSizeX

					dxDrawText(member.characterName:gsub("_", " "), startX, startY, startX + oneSectionSizeX, startY + respc(50), rgba(255, 255, 255), 0.75, RobotoB, "center", "center")

					startX = startX + respc(20)
					startY = startY + respc(50)

					dxDrawRectangle(startX, startY - respc(5), oneSectionSizeX - respc(10), 2, rgba(255, 255, 255, 40))

					local scale = 0.85
					local height = respc(45) * scale

					startY = drawDataRow(startX, startY, height, "Rang: ", "#477fa8" .. group.ranks[member.rank].name .. " #ffffff(" .. member.rank .. ")", scale)
					startY = drawDataRow(startX, startY, height, "Fizetés: ", "#dddddd" .. formatNumber(group.ranks[member.rank].pay) .. " #477fa8$", scale)
					
					if member.dutySkin == 0 then
						startY = drawDataRow(startX, startY, height, "Duty skin: ", "#d75959nincs beállítva", scale)
					else
						startY = drawDataRow(startX, startY, height, "Duty skin: ", "#afafaf" .. member.dutySkin, scale)
					end

					local lastOnline = split(member.lastOnline or "#d75959nem_volt_még_online", " ")

					startY = drawDataRow(startX, startY, height, "Utoljára online: ", "#477fa8" .. lastOnline[1]:gsub("_", " "), scale)

					if member.isLeader == "Y" then
						startY = drawDataRow(startX, startY, height, "Leader: ", "igen", scale)
					else
						startY = drawDataRow(startX, startY, height, "Leader: ", "#d75959nem", scale)
					end

					if member.online then
						startY = drawDataRow(startX, startY, height, "Online: ", "#477fa8igen", scale)
					else
						startY = drawDataRow(startX, startY, height, "Online: ", "#d75959nem", scale)
					end

					startY = startY + respc(80)

					if meInGroup[groupId].isLeader == "Y" then
						local buttonMargin = respc(20)
						local buttonSizeX = oneSectionSizeX - respc(10)
						local buttonSizeY = ((y + sy - headerHeight) - startY - buttonMargin * 4) / 4

						local groupButtonColors = {
							rgba(71, 127, 168, 200),
							rgba(255, 150, 0, 200),
							rgba(215, 89, 89, 200),
							rgba(71, 127, 168, 200)
						}

						local groupButtonColorsHover = {
							rgba(71, 127, 168, 240),
							rgba(255, 150, 0, 240),
							rgba(215, 89, 89, 240),
							rgba(71, 127, 168, 240)
						}

						for i = 1, 4 do
							local buttonY = startY + (buttonSizeY + buttonMargin) * (i - 1)
							local fontFamily = RobotoL

							if i == 4 and fakeInputError then
								local acceptWidth = respc(75)

								dxDrawText(fakeInputError, startX, buttonY, 0, buttonY + buttonSizeY, rgba(255, 255, 255), 0.75, RobotoB2, "left", "center", false, false, false, true)

								if activeButton == "errorOk" then
									dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColorsHover[1])
								else
									dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColors[1])
								end

								dxDrawText("OK", startX + buttonSizeX - acceptWidth, buttonY, startX + buttonSizeX, buttonY + buttonSizeY, rgba(0, 0, 0), 0.65, fontFamily, "center", "center")
								
								buttons["errorOk"] = {startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY}
							elseif i == 4 and activeFakeInput == "inviting" then
								local acceptWidth = respc(75)

								dxDrawRectangle(startX, buttonY, buttonSizeX - acceptWidth - respc(10), buttonSizeY, rgba(40, 40, 40, 200))

								if string.len(fakeInputText) < 1 then
									dxDrawText("Hozzáadandó névrészlete/id-je", startX + respc(10), buttonY, startX + buttonSizeX - acceptWidth - respc(20), buttonY + buttonSizeY, rgba(100, 100, 100), 0.75, Roboto, "left", "center")
								else
									dxDrawText(fakeInputText, startX + respc(10), buttonY, startX + buttonSizeX - acceptWidth - respc(20), buttonY + buttonSizeY, rgba(255, 255, 255), 0.75, Roboto, "left", "center")
								end

								if cursorState then
									local w = dxGetTextWidth(fakeInputText, 0.75, Roboto)
									dxDrawRectangle(startX + respc(10) + w, buttonY + respc(5), 2, buttonSizeY - respc(10), rgba(255, 255, 255))
								end

								if activeButton == "groupInvite" then
									dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColorsHover[1])
								else
									dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColors[1])
								end

								dxDrawText("Hozzáad", startX + buttonSizeX - acceptWidth, buttonY, startX + buttonSizeX, buttonY + buttonSizeY, rgba(0, 0, 0), 0.65, fontFamily, "center", "center")
								
								buttons["groupInvite"] = {startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY}
							elseif i == 3 and memberFirePrompt then
								local acceptWidth = respc(75)

								dxDrawText(fireErrorText, startX, buttonY, 0, buttonY + buttonSizeY, rgba(255, 255, 255), 0.75, RobotoB2, "left", "center", false, false, false, true)

								if activeButton == "cancelFire" then
									dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColorsHover[3])
								else
									dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColors[3])
								end

								if activeButton == "fireMember" then
									dxDrawRectangle(startX + buttonSizeX - acceptWidth * 2 - respc(10), buttonY, acceptWidth, buttonSizeY, groupButtonColorsHover[1])
								else
									dxDrawRectangle(startX + buttonSizeX - acceptWidth * 2 - respc(10), buttonY, acceptWidth, buttonSizeY, groupButtonColors[1])
								end

								dxDrawText("Mégsem", startX + buttonSizeX - acceptWidth, buttonY, startX + buttonSizeX, buttonY + buttonSizeY, rgba(0, 0, 0), 0.65, fontFamily, "center", "center")
								dxDrawText("Kirúgás", startX + buttonSizeX - acceptWidth * 2 - respc(10), buttonY, startX + buttonSizeX - acceptWidth - respc(10), buttonY + buttonSizeY, rgba(0, 0, 0), 0.65, fontFamily, "center", "center")
								
								buttons["cancelFire"] = {startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY}
								buttons["fireMember"] = {startX + buttonSizeX - acceptWidth * 2 - respc(10), buttonY, acceptWidth, buttonSizeY}
							else
								if activeButton == "groupaction:" .. i then
									dxDrawRectangle(startX, buttonY, buttonSizeX, buttonSizeY, groupButtonColorsHover[i])
									fontFamily = Roboto
								else
									dxDrawRectangle(startX, buttonY, buttonSizeX, buttonSizeY, groupButtonColors[i])
								end

								dxDrawText(groupButtonCaptions[i], startX, buttonY, startX + buttonSizeX, buttonY + buttonSizeY, rgba(0, 0, 0), 0.75, fontFamily, "center", "center")

								buttons["groupaction:" .. i] = {startX, buttonY, buttonSizeX, buttonSizeY}
							end
						end
					end
				end
			-- Rangok
			elseif selectedGroupTab == 2 then
				dxDrawRectangle(startX, startY, oneSectionSizeX, oneSectionSizeY, rgba(0, 0, 0, 100))

				local num = 14
				local oneSize = oneSectionSizeY / num
				local thisRanks = group.ranks

				for i = 1, num do
					local lineY = startY + (i - 1) * oneSize
					local rank = thisRanks[i + offsetRank]

					if i + offsetRank == selectedRank and rank then
						dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(71, 127, 168, 150))
					elseif activeButton == "selectRank:" .. i + offsetRank then
						dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(255, 255, 255, 25))
					else
						if i % 2 == 0 then
							dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(0, 0, 0, 30))
						end
					end

					if i ~= num then
						dxDrawRectangle(startX, lineY + oneSize, oneSectionSizeX, 2, rgba(255, 255, 255, 25))
					end

					if rank then
						local colorOfText = rgba(255, 255, 255)

						if i + offsetRank == selectedRank then
							colorOfText = rgba(0, 0, 0)
						elseif activeButton == "selectRank:" .. i + offsetRank then
							colorOfText = rgba(71, 127, 168)
						end

						dxDrawText("[" .. i + offsetRank .. "] " .. rank.name, startX + 10, lineY, 0, lineY + oneSize, colorOfText, 0.65, Roboto, "left", "center")
						dxDrawText(formatNumber(rank.pay) .. " $", 0, lineY, startX + oneSectionSizeX - 10, lineY + oneSize, colorOfText, 0.65, Roboto, "right", "center")

						buttons["selectRank:" .. i + offsetRank] = {startX, lineY, oneSectionSizeX, oneSize}
					end
				end

				local trackSize = num * oneSize

				if #thisRanks > num then
					dxDrawRectangle(startX + oneSectionSizeX, startY, 5, trackSize, rgba(255, 255, 255, 25))
					dxDrawRectangle(startX + oneSectionSizeX, startY + offsetRank * (trackSize / #thisRanks), 5, trackSize / #thisRanks * num, rgba(71, 127, 168, 150))
				end

				dxDrawText(math.ceil(offsetRank / num) + 1 .. "/" .. math.ceil(#thisRanks / num) .. ". oldal (" .. selectedRank .. "/" .. #thisRanks .. "db rang)", startX, startY + trackSize, startX + oneSectionSizeX, startY + trackSize + respc(40), rgba(255, 255, 255), 0.6, Roboto, "center", "center")
				
				local thisRank = thisRanks[selectedRank]

				if thisRank then
					local startX = startX + oneSectionSizeX

					dxDrawText(thisRank.name, startX, startY, startX + oneSectionSizeX, startY + respc(50), rgba(255, 255, 255), 0.75, RobotoB, "center", "center")

					startX = startX + respc(20)
					startY = startY + respc(50)

					dxDrawRectangle(startX, startY - respc(5), oneSectionSizeX - respc(10), 2, rgba(255, 255, 255, 40))

					local scale = 0.85
					local height = respc(45) * scale

					startY = drawDataRow(startX, startY, height, "Tagok száma ezen a rangon: ", "#477fa8" .. (rankCount[groupId][selectedRank] or 0) .. " #ffffffdb", scale)
					startY = drawDataRow(startX, startY, height, "Fizetés: ", "#dddddd" .. formatNumber(thisRank.pay) .. " #477fa8$", scale)
					
					startY = startY + respc(30)

					if meInGroup[groupId].isLeader == "Y" then
						local buttonMargin = respc(20)
						local buttonSizeX = oneSectionSizeX - respc(10)
						local buttonSizeY = respc(45)--((y + sy - headerHeight) - startY - buttonMargin * 2) / 2

						local groupButtonColors = {
							rgba(71, 127, 168, 200),
							rgba(71, 127, 168, 200)
						}

						local groupButtonColorsHover = {
							rgba(71, 127, 168, 240),
							rgba(71, 127, 168, 240)
						}

						for i = 1, 2 do
							local buttonY = startY + (buttonSizeY + buttonMargin) * (i - 1)
							local fontFamily = RobotoL

							if (i == 1 and activeFakeInput == "setrankname") or (i == 2 and activeFakeInput == "setrankpay") then
								if fakeInputError then
									local acceptWidth = respc(75)

									dxDrawText(fakeInputError, startX, buttonY, 0, buttonY + buttonSizeY, rgba(255, 255, 255), 0.75, RobotoB2, "left", "center", false, false, false, true)

									if activeButton == "errorOk" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColorsHover[1])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColors[1])
									end

									dxDrawText("OK", startX + buttonSizeX - acceptWidth, buttonY, startX + buttonSizeX, buttonY + buttonSizeY, rgba(0, 0, 0), 0.65, fontFamily, "center", "center")
									
									buttons["errorOk"] = {startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY}
								else
									local acceptWidth = respc(75)

									dxDrawRectangle(startX, buttonY, buttonSizeX - acceptWidth - respc(10), buttonSizeY, rgba(40, 40, 40, 200))

									if utf8.len(fakeInputText) < 1 then
										if i == 1 then
											dxDrawText(thisRank.name, startX + respc(10), buttonY, startX + buttonSizeX - acceptWidth - respc(20), buttonY + buttonSizeY, rgba(100, 100, 100), 0.75, Roboto, "left", "center")
										elseif i == 2 then
											dxDrawText(thisRank.pay, startX + respc(10), buttonY, startX + buttonSizeX - acceptWidth - respc(20), buttonY + buttonSizeY, rgba(100, 100, 100), 0.75, Roboto, "left", "center")
										end
									else
										dxDrawText(fakeInputText, startX + respc(10), buttonY, startX + buttonSizeX - acceptWidth - respc(20), buttonY + buttonSizeY, rgba(255, 255, 255), 0.75, Roboto, "left", "center")
									end

									if cursorState then
										local w = dxGetTextWidth(fakeInputText, 0.75, Roboto)
										dxDrawRectangle(startX + respc(10) + w, buttonY + respc(5), 2, buttonSizeY - respc(10), rgba(255, 255, 255))
									end

									if activeButton == activeFakeInput then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColorsHover[1])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY, groupButtonColors[1])
									end

									dxDrawText("Módosít", startX + buttonSizeX - acceptWidth, buttonY, startX + buttonSizeX, buttonY + buttonSizeY, rgba(0, 0, 0), 0.65, fontFamily, "center", "center")
									
									buttons[activeFakeInput] = {startX + buttonSizeX - acceptWidth, buttonY, acceptWidth, buttonSizeY}
								end
							else
								if activeButton == "rankaction:" .. i then
									dxDrawRectangle(startX, buttonY, buttonSizeX, buttonSizeY, groupButtonColorsHover[i])
									fontFamily = Roboto
								else
									dxDrawRectangle(startX, buttonY, buttonSizeX, buttonSizeY, groupButtonColors[i])
								end

								dxDrawText(groupButtonCaptions2[i], startX, buttonY, startX + buttonSizeX, buttonY + buttonSizeY, rgba(0, 0, 0), 0.75, fontFamily, "center", "center")

								buttons["rankaction:" .. i] = {startX, buttonY, buttonSizeX, buttonSizeY}
							end
						end
					end
				end
			-- Kocsik
			elseif selectedGroupTab == 3 then
				dxDrawRectangle(startX, startY, oneSectionSizeX, oneSectionSizeY, rgba(0, 0, 0, 100))

				local num = 14
				local oneSize = oneSectionSizeY / num
				local vehicles = groupVehicles[groupId]

				for i = 1, num do
					local lineY = startY + (i - 1) * oneSize
					local veh = vehicles[i + offsetGroupVeh]

					if i + offsetGroupVeh == selectedGroupVeh and isElement(veh) then
						dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(71, 127, 168, 150))
					elseif activeButton == "selectGroupVeh:" .. i + offsetGroupVeh then
						dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(255, 255, 255, 25))
					else
						if i % 2 == 0 then
							dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(0, 0, 0, 30))
						end
					end

					if i ~= num then
						dxDrawRectangle(startX, lineY + oneSize, oneSectionSizeX, 2, rgba(255, 255, 255, 25))
					end

					if isElement(veh) then
						local datas = vehicleDatas[veh]

						local plateText = split(getVehiclePlateText(veh), "-")
						local plateSections = {}

						for i = 1, #plateText do
							if utf8.len(plateText[i]) > 0 then
								table.insert(plateSections, plateText[i])
							end
						end

						local colorOfText = rgba(255, 255, 255)

						if i + offsetGroupVeh == selectedGroupVeh then
							colorOfText = rgba(0, 0, 0)
						elseif activeButton == "selectGroupVeh:" .. i + offsetGroupVeh then
							colorOfText = rgba(71, 127, 168)
						end

						dxDrawImage(math.floor(startX + 10), math.floor(lineY + oneSize / 2 - respc(32) / 2), respc(32), respc(32), "files/images/vehicletypes/" .. datas.vehicleType .. ".png", 0, 0, 0, colorOfText)
						if utfLen(datas.vehicleName) > 6 then 
							datas.vehicleName = utfSub(datas.vehicleName, 1, 20) .. "..."
						end
						dxDrawText(datas.vehicleName, startX + 20 + respc(32), lineY, 0, lineY + oneSize, colorOfText, 0.75, Roboto, "left", "center")
						dxDrawText("ID: " .. formatNumber(datas["vehicle.dbID"], ",") .. " | " .. table.concat(plateSections, "-"), 0, lineY, startX + oneSectionSizeX - 10, lineY + oneSize, colorOfText, 0.75, Roboto, "right", "center")

						buttons["selectGroupVeh:" .. i + offsetGroupVeh] = {startX, lineY, oneSectionSizeX, oneSize}
					elseif veh then
						dxDrawText("Hiányzó jármű.", startX + 10, lineY, 0, lineY + oneSize, rgba(255, 150, 0), 0.5, RobotoB, "left", "center")
					end
				end

				local trackSize = num * oneSize

				if #vehicles > num then
					dxDrawRectangle(startX + oneSectionSizeX, startY, 5, trackSize, rgba(255, 255, 255, 25))
					dxDrawRectangle(startX + oneSectionSizeX, startY + offsetGroupVeh * (trackSize / #vehicles), 5, trackSize / #vehicles * num, rgba(71, 127, 168, 150))
				end

				dxDrawText(math.ceil(offsetGroupVeh / num) + 1 .. "/" .. math.ceil(#vehicles / num) .. ". oldal (" .. selectedGroupVeh .. "/" .. #vehicles .. "db jármű)", startX, startY + trackSize, startX + oneSectionSizeX, startY + trackSize + respc(40), rgba(255, 255, 255), 0.6, Roboto, "center", "center")
				
				local veh = vehicles[selectedGroupVeh]

				if isElement(veh) then
					local datas = vehicleDatas[veh]

					local startX = startX + oneSectionSizeX

					dxDrawText(datas.vehicleName, startX, startY, startX + oneSectionSizeX, startY + respc(50), rgba(255, 255, 255), 0.75, RobotoB, "center", "center")

					startX = startX + respc(20)
					startY = startY + respc(50)

					dxDrawRectangle(startX, startY - respc(5), oneSectionSizeX - respc(10), 2, rgba(255, 255, 255, 40))

					local scale = 0.75
					local height = respc(30) * scale

					if datas["vehicle.engine"] == 1 then
						startY = drawDataRow(startX, startY, height, "Motor: ", "#477fa8elindítva", scale)
					else
						startY = drawDataRow(startX, startY, height, "Motor: ", "#d75959leállítva", scale)
					end

					if getVehicleOverrideLights(veh) == 2 then
						startY = drawDataRow(startX, startY, height, "Lámpa: ", "#477fa8felkapcsolva", scale)
					else
						startY = drawDataRow(startX, startY, height, "Lámpa: ", "#d75959lekapcsolva", scale)
					end

					if datas["vehicle.handBrake"] then
						startY = drawDataRow(startX, startY, height, "Kézifék: ", "#477fa8behúzva", scale)
					else
						startY = drawDataRow(startX, startY, height, "Kézifék: ", "#d75959kiengedve", scale)
					end

					if datas["vehicle.locked"] == 1 then
						startY = drawDataRow(startX, startY, height, "Ajtók: ", "#477fa8zárva", scale)
					else
						startY = drawDataRow(startX, startY, height, "Ajtók: ", "#d75959nyitva", scale)
					end

					startY = startY + height

					if (datas["vehicle.nitroLevel"] or 0) == 0 then
						startY = drawDataRow(startX, startY, height, "Nitro: ", "#d75959" .. math.floor(datas["vehicle.nitroLevel"] or 0) .. "%", scale)
					elseif (datas["vehicle.nitroLevel"] or 0) <= 50 then
						startY = drawDataRow(startX, startY, height, "Nitro: ", "#FF9600" .. math.floor(datas["vehicle.nitroLevel"] or 0) .. "%", scale)
					elseif (datas["vehicle.nitroLevel"] or 0) > 50 then
						startY = drawDataRow(startX, startY, height, "Nitro: ", "#477fa8" .. math.floor(datas["vehicle.nitroLevel"] or 0) .. "%", scale)
					end

					if (datas["vehicle.tuning.AirRide"] or 0) == 1 then
						startY = drawDataRow(startX, startY, height, "AirRide: ", "#477fa8van", scale)
					else
						startY = drawDataRow(startX, startY, height, "AirRide: ", "#d75959nincs", scale)
					end

					if (datas["tuning.neon"] or 0) > 10000 then
						startY = drawDataRow(startX, startY, height, "Neon: ", "#477fa8van", scale)
					else
						startY = drawDataRow(startX, startY, height, "Neon: ", "#d75959nincs", scale)
					end

					startY = drawDataRow(startX, startY, height, "Motor: ", tuningName[datas["vehicle.tuning.Engine"] or 0], scale)
					startY = drawDataRow(startX, startY, height, "Fék: ", tuningName[datas["vehicle.tuning.Brakes"] or 0], scale)
					startY = drawDataRow(startX, startY, height, "Turbo: ", tuningName[datas["vehicle.tuning.Turbo"] or 0], scale)
					startY = drawDataRow(startX, startY, height, "ECU: ", tuningName[datas["vehicle.tuning.ECU"] or 0], scale)
					startY = drawDataRow(startX, startY, height, "Váltó: ", tuningName[datas["vehicle.tuning.Transmission"] or 0], scale)
					startY = drawDataRow(startX, startY, height, "Gumi: ", tuningName[datas["vehicle.tuning.Tires"] or 0], scale)
					startY = drawDataRow(startX, startY, height, "Súlycsökkentés: ", tuningName[datas["vehicle.tuning.WeightReduction"] or 0], scale)
					startY = drawDataRow(startX, startY, height, "Felfüggesztés: ", tuningName[datas["vehicle.tuning.Suspension"] or 0], scale)

					local health = math.floor(getElementHealth(veh) / 10)

					if health < 32 then
						health = 32
					end

					health = math.floor(reMap(health, 32, 100, 0, 100))

					local kilometersToChangeOil = 500 - math.floor(math.floor(datas["lastOilChange"] or 0) / 1000)

					if kilometersToChangeOil <= 0 then
						kilometersToChangeOil = "Olajcsere szükséges"
					else
						kilometersToChangeOil = formatNumber(kilometersToChangeOil) .. " km múlva"
					end

					startY = startY + height
					startY = drawDataRow(startX, startY, height, "Állapot: ", health .. "%", scale)
					startY = drawDataRow(startX, startY, height, "Üzemanyag: ", math.floor((datas["vehicle.fuel"] or datas["vehicle.maxFuel"]) / datas["vehicle.maxFuel"] * 100) .. "%", scale)
					startY = drawDataRow(startX, startY, height, "Olajcsere: ", kilometersToChangeOil, scale)
					startY = drawDataRow(startX, startY, height, "Kilóméterszámláló állása: ", formatNumber(math.floor(datas["vehicle.distance"] * 10) / 10) .. " km", scale)
				end
			-- Egyéb
			elseif selectedGroupTab == 4 then
				if (renderData.canSelectDutySkin and not renderData.dutySkinMarker) or (renderData.canSelectDutySkin and renderData.dutySkinMarker == groupId) then
					dxDrawText("Szolgálati öltözék:", startX, startY, 0, startY + respc(50), rgba(255, 255, 255), 0.75, RobotoB, "left", "center")

					startY = startY + respc(50)

					buttons["setDutySkin"] = {startX, startY, oneSectionSizeX * 2, respc(40)}

					if activeButton == "setDutySkin" then
						dxDrawRectangle(startX, startY, oneSectionSizeX * 2, respc(40), rgba(71, 127, 168, 240))
					else
						dxDrawRectangle(startX, startY, oneSectionSizeX * 2, respc(40), rgba(71, 127, 168, 200))
					end

					dxDrawText("Duty skin beállítása", startX, startY, startX + oneSectionSizeX * 2, startY + respc(40), rgba(0, 0, 0), 0.75, RobotoL, "center", "center")

					startY = startY + respc(50)
				end

				dxDrawText("Megjegyzés:", startX, startY, 0, startY + respc(50), rgba(255, 255, 255), 0.75, RobotoB, "left", "center")

				startY = startY + respc(50)

				if meInGroup[groupId].isLeader == "N" then
					dxDrawText(group.description, startX + respc(10), startY + respc(10), startX + oneSectionSizeX * 2 - respc(10), startY + respc(10) + respc(200), rgba(255, 255, 255), 0.75, Roboto, "left", "top", false, true)
				else
					dxDrawRectangle(startX, startY, oneSectionSizeX * 2, respc(200), rgba(40, 40, 40, 200))

					if activeFakeInput == "groupdesc" then
						if utf8.len(fakeInputText) < 1 then
							dxDrawText(group.description, startX + respc(10), startY + respc(10), startX + oneSectionSizeX * 2 - respc(10), startY + respc(10) + respc(200), rgba(100, 100, 100), 0.75, Roboto, "left", "top", false, true)
							
							if cursorState then
								dxDrawText("|", startX + respc(10), startY + respc(10), startX + oneSectionSizeX * 2 - respc(10), startY + respc(10) + respc(200), rgba(255, 255, 255), 0.75, Roboto, "left", "top", false, true)
							end
						elseif cursorState then
							dxDrawText(fakeInputText .. "|", startX + respc(10), startY + respc(10), startX + oneSectionSizeX * 2 - respc(10), startY + respc(10) + respc(200), rgba(255, 255, 255), 0.75, Roboto, "left", "top", false, true)
						else
							dxDrawText(fakeInputText, startX + respc(10), startY + respc(10), startX + oneSectionSizeX * 2 - respc(10), startY + respc(10) + respc(200), rgba(255, 255, 255), 0.75, Roboto, "left", "top", false, true)
						end

						startY = startY + respc(220)

						if activeButton == "setgroupdesc" then
							dxDrawRectangle(startX, startY, oneSectionSizeX * 2, respc(40), rgba(71, 127, 168, 240))
						else
							dxDrawRectangle(startX, startY, oneSectionSizeX * 2, respc(40), rgba(71, 127, 168, 200))
						end

						dxDrawText("Módosít", startX, startY, startX + oneSectionSizeX * 2, startY + respc(40), rgba(0, 0, 0), 0.75, RobotoL, "center", "center")

						buttons["setgroupdesc"] = {startX, startY, oneSectionSizeX * 2, respc(40)}

						startY = startY + respc(50)
					else
						dxDrawText(group.description, startX + respc(10), startY + respc(10), startX + oneSectionSizeX * 2 - respc(10), startY + respc(10) + respc(200), rgba(100, 100, 100), 0.75, Roboto, "left", "top")
						
						buttons["groupdesc"] = {startX, startY, oneSectionSizeX * 2, respc(200)}

						startY = startY + respc(220)
					end
				end

				if meInGroup[groupId].isLeader == "Y" then
					dxDrawText("Pénzügyek:", startX, startY, 0, startY + respc(50), rgba(255, 255, 255), 0.75, RobotoB, "left", "center")

					startY = startY + respc(50)

					if group.balance >= 0 then
						startY = drawDataRow(startX, startY, respc(40), "Egyenleg: ", formatNumber(group.balance) .. " $", 0.75)
					else
						startY = drawDataRow(startX, startY, respc(40), "Egyenleg: ", "#d75959" .. formatNumber(group.balance) .. " $", 0.75)
					end

					startY = startY + respc(10)

					local buttonSizeX = (oneSectionSizeX * 2) / 3
					local buttonSizeY = respc(40)

					if fakeInputError then
						dxDrawText(fakeInputError, startX, startY, 0, startY + buttonSizeY, rgba(255, 255, 255), 0.75, RobotoB2, "left", "center", false, false, false, true)

						if activeButton == "errorOk" then
							dxDrawRectangle(startX + buttonSizeX * 2, startY, buttonSizeX, buttonSizeY, rgba(255, 125, 0, 240))
						else
							dxDrawRectangle(startX + buttonSizeX * 2, startY, buttonSizeX, buttonSizeY, rgba(255, 125, 0, 200))
						end

						dxDrawText("Ok", startX + buttonSizeX * 2, startY, startX + buttonSizeX * 3, startY + buttonSizeY, rgba(0, 0, 0), 0.75, RobotoL, "center", "center")

						buttons["errorOk"] = {startX + buttonSizeX * 2, startY, buttonSizeX, buttonSizeY}
					elseif activeFakeInput == "groupbalance" then
						dxDrawRectangle(startX + buttonSizeX, startY, buttonSizeX, buttonSizeY, rgba(40, 40, 40, 200))

						local inputText = fakeInputText

						if cursorState then
							inputText = inputText .. "|"
						end

						if string.len(inputText) > 0 then
							dxDrawText(inputText, startX + buttonSizeX, startY, startX + buttonSizeX * 2, startY + buttonSizeY, rgba(255, 255, 255), 0.75, Roboto, "center", "center")
						end

						buttons["getoutmoney"] = {startX, startY, buttonSizeX, buttonSizeY}

						if activeButton == "getoutmoney" then
							dxDrawRectangle(startX, startY, buttonSizeX, buttonSizeY, rgba(215, 89, 89, 240))
						else
							dxDrawRectangle(startX, startY, buttonSizeX, buttonSizeY, rgba(215, 89, 89, 200))
						end

						dxDrawText("Kivétel", startX, startY, startX + buttonSizeX, startY + buttonSizeY, rgba(0, 0, 0), 0.75, RobotoL, "center", "center")

						buttons["putbackmoney"] = {startX + buttonSizeX * 2, startY, buttonSizeX, buttonSizeY}

						if activeButton == "putbackmoney" then
							dxDrawRectangle(startX + buttonSizeX * 2, startY, buttonSizeX, buttonSizeY, rgba(71, 127, 168, 240))
						else
							dxDrawRectangle(startX + buttonSizeX * 2, startY, buttonSizeX, buttonSizeY, rgba(71, 127, 168, 200))
						end

						dxDrawText("Berakás", startX + buttonSizeX * 2, startY, startX + buttonSizeX * 3, startY + buttonSizeY, rgba(0, 0, 0), 0.75, RobotoL, "center", "center")
					else
						buttons["groupbalance"] = {startX, startY, oneSectionSizeX * 2, buttonSizeY}

						if activeButton == "groupbalance" then
							dxDrawRectangle(startX, startY, oneSectionSizeX * 2, buttonSizeY, rgba(255, 125, 0, 240))
						else
							dxDrawRectangle(startX, startY, oneSectionSizeX * 2, buttonSizeY, rgba(255, 125, 0, 200))
						end

						dxDrawText("Pénzügyek kezelése", startX, startY, startX + oneSectionSizeX * 2, startY + buttonSizeY, rgba(0, 0, 0), 0.75, RobotoL, "center", "center")
					end
				end
			end
		else
			dxDrawText("Nincs kiválasztva frakció.", startX + oneSegmentSizeX, y + headerHeight, x + sx, y + sy - headerHeight * 2, rgba(255, 255, 255), 1, RobotoB, "center", "center")
		end
	end

	if selectedTab == 7 then
		
	end

	-- Adminok
	if selectedTab == 5 then
		local adminSlots = renderData.adminSlots

		local startX = x + respc(460)
		local startY = y + respc(40)

		local oneSegmentSizeX = (screenX - respc(460) - respc(20)) / 3
		local oneSegmentSizeY = sy - headerHeight - respc(40) - respc(100)

		local num = 20
		local oneSize = oneSegmentSizeY / num

		for i = 1, num do
			local lineY = startY + (i - 1) * oneSize

			if i % 2 ~= 0 then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 100))
			else
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 50))
			end

			local slot = i

			if adminSlots[slot] then
				if adminSlots[slot][1] == "admin" or adminSlots[slot][1] == "as" then
					dxDrawText(adminSlots[slot][2], startX + respc(10), lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)

					if adminSlots[slot][1] == "admin" then
						if adminSlots[slot][3] then
							dxDrawText("Szolgálatban: #477fa8igen", 0, lineY, startX + oneSegmentSizeX - respc(10), lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "right", "center", false, false, false, true)
						else
							dxDrawText("Szolgálatban: #d75959nem", 0, lineY, startX + oneSegmentSizeX - respc(10), lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "right", "center", false, false, false, true)
						end
					end
				elseif adminSlots[slot][1] == "title" then
					dxDrawText(adminSlots[slot][2], startX, lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(	71, 127, 168), 0.65, RobotoB2, "center", "center")
				else
					dxDrawText(adminSlots[slot][2], startX, lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "center", "center")
				end
			end
		end

		startX = startX + oneSegmentSizeX

		for i = 1, num do
			local lineY = startY + (i - 1) * oneSize

			if i % 2 == 0 then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 100))
			else
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 50))
			end

			local slot = i + num

			if adminSlots[slot] then
				if adminSlots[slot][1] == "admin" or adminSlots[slot][1] == "as" then
					dxDrawText(adminSlots[slot][2], startX + respc(10), lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)

					if adminSlots[slot][1] == "admin" then
						if adminSlots[slot][3] then
							dxDrawText("Szolgálatban: #477fa8igen", 0, lineY, startX + oneSegmentSizeX - respc(10), lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "right", "center", false, false, false, true)
						else
							dxDrawText("Szolgálatban: #d75959nem", 0, lineY, startX + oneSegmentSizeX - respc(10), lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "right", "center", false, false, false, true)
						end
					end
				elseif adminSlots[slot][1] == "title" then
					dxDrawText(adminSlots[slot][2], startX, lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 150, 0), 0.65, RobotoB2, "center", "center")
				else
					dxDrawText(adminSlots[slot][2], startX, lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "center", "center")
				end
			end
		end

		startX = startX + oneSegmentSizeX

		for i = 1, num do
			local lineY = startY + (i - 1) * oneSize

			if i % 2 ~= 0 then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 100))
			else
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 50))
			end

			local slot = i + num * 2

			if adminSlots[slot] then
				if adminSlots[slot][1] == "admin" or adminSlots[slot][1] == "as" then
					dxDrawText(adminSlots[slot][2], startX + respc(10), lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)

					if adminSlots[slot][1] == "admin" then
						if adminSlots[slot][3] then
							dxDrawText("Szolgálatban: #477fa8igen", 0, lineY, startX + oneSegmentSizeX - respc(10), lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "right", "center", false, false, false, true)
						else
							dxDrawText("Szolgálatban: #d75959nem", 0, lineY, startX + oneSegmentSizeX - respc(10), lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "right", "center", false, false, false, true)
						end
					end
				elseif adminSlots[slot][1] == "title" then
					dxDrawText(adminSlots[slot][2], startX, lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 150, 0), 0.65, RobotoB2, "center", "center")
				else
					dxDrawText(adminSlots[slot][2], startX, lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 255, 255), 0.65, Roboto, "center", "center")
				end
			end
		end

		local startY = startY + oneSegmentSizeY
		local sectionSize = (y + sy - headerHeight) - startY

		--dxDrawText('Az alábbi panelen a szerveren lévő adminokat/adminsegédeket láthatod. Amennyiben probléma van keress egy admint, aki szolgálatban van, majd a "/pm ID ÜZENETED" paranccsal tudsz írni nekik. Az adminisztrátor ID-jét ezen a panelen akkor látod, ha az adott online adminisztrátor szolgálatban van.', x + respc(300), startY, x + sx - respc(300), startY + sectionSize, rgba(255, 255, 255), 0.6, Roboto, "center", "center", false, true)
	end

	-- Petek
	if selectedTab == 6 then
		local startX = x + respc(460)
		local startY = y + respc(50)

		local oneSegmentSizeX = (sx - respc(40) - respc(25)) / 3.5
		local oneSegmentSizeY = sy - headerHeight - respc(40) - respc(100)

		dxDrawRectangle(startX, startY, oneSegmentSizeX, oneSegmentSizeY, rgba(0, 0, 0, 100))

		local num = 18
		local oneSize = oneSegmentSizeY / num
		local maxThings = #renderData.loadedAnimals

		for i = 1, num do
			local lineY = startY + (i - 1) * oneSize
			local animal = renderData.loadedAnimals[i + renderData.offsetAnimal]

			if i + renderData.offsetAnimal == renderData.selectedAnimal and animal then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(71, 127, 168, 150))
			elseif activeButton == "selectAnimal:" .. i + renderData.offsetAnimal then
				dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(255, 255, 255, 25))
			else
				if i % 2 == 0 then
					dxDrawRectangle(startX, lineY, oneSegmentSizeX, oneSize, rgba(0, 0, 0, 30))
				end
			end

			if i ~= num then
				dxDrawRectangle(startX, lineY + oneSize, oneSegmentSizeX, 2, rgba(255, 255, 255, 25))
			end

			if maxThings < 1 and i == math.ceil(num / 2) then
				dxDrawText("Nincs peted.", startX, lineY, startX + oneSegmentSizeX, lineY + oneSize, rgba(255, 150, 0), 0.5, RobotoB, "center", "center")
			end

			if animal then
				local colorOfText = rgba(255, 255, 255)

				if i + renderData.offsetAnimal == renderData.selectedAnimal then
					colorOfText = rgba(0, 0, 0)
				elseif activeButton == "selectAnimal:" .. i + renderData.offsetAnimal then
					colorOfText = rgba(71, 127, 168)
				end

				if renderData.spawnedAnimal == animal.animalId then
					dxDrawText(animal.name .. " (Aktív)", startX + 10, lineY, 0, lineY + oneSize, colorOfText, 0.65, Roboto, "left", "center")
				else
					dxDrawText(animal.name, startX + 10, lineY, 0, lineY + oneSize, colorOfText, 0.65, Roboto, "left", "center")
				end
				dxDrawText(animal.type, 0, lineY, startX + oneSegmentSizeX - 10, lineY + oneSize, colorOfText, 0.65, Roboto, "right", "center")

				buttons["selectAnimal:" .. i + renderData.offsetAnimal] = {startX, lineY, oneSegmentSizeX, oneSize}
			end
		end

		local trackSize = num * oneSize

		buttons["newAnimal"] = {startX, startY + trackSize + respc(10), oneSegmentSizeX, respc(40)}
		if activeButton == "newAnimal" then
			dxDrawRectangle(startX, startY + trackSize + respc(10), oneSegmentSizeX, respc(40), rgba(71, 127, 168, 240))
		else
			dxDrawRectangle(startX, startY + trackSize + respc(10), oneSegmentSizeX, respc(40), rgba(71, 127, 168, 200))
		end
		dxDrawText("Pet vásárlása", startX, startY + trackSize + respc(10), startX + oneSegmentSizeX, startY + trackSize + respc(50), rgba(0, 0, 0), 0.75, RobotoL, "center", "center")

		if maxThings > num then
			dxDrawRectangle(startX + oneSegmentSizeX, startY, 5, trackSize, rgba(255, 255, 255, 25))
			dxDrawRectangle(startX + oneSegmentSizeX, startY + renderData.offsetAnimal * (trackSize / maxThings), 5, trackSize / maxThings * num, rgba(71, 127, 168, 150))
		end

		local animal = renderData.loadedAnimals[renderData.selectedAnimal]

		if animal then
			startX = startX + oneSegmentSizeX + respc(20)
			startY = y + headerHeight + respc(20)

			local oneSectionSizeX = (x + sx) - startX - respc(20)
			local oneSectionSizeY = (y + sy - headerHeight) - startY - respc(20)

			dxDrawText(animal.name, startX, startY - respc(80), startX + oneSectionSizeX, startY, rgba(71, 127, 168), 1, RobotoB, "center", "center")

			--dxDrawRectangle(startX, startY, oneSectionSizeX, oneSectionSizeY, rgba(0, 0, 0, 100))
			dxDrawRectangle(startX, startY, oneSectionSizeX, 2, rgba(255, 255, 255, 40))

			startY = startY + respc(30)

			--dxDrawRectangle(startX + oneSectionSizeX - respc(371), startY - respc(15), respc(371), respc(140), rgba(255, 255, 255, 25))
			dxDrawImage(startX + oneSectionSizeX - respc(260), startY - respc(15), respc(371), respc(140), "files/images/dogs/" .. renderData.petTypes[animal.type] .. ".png", 0, 0, 0, rgba(255, 255, 255))

			local scale = 0.85
			local height = respc(40) * scale

			startY = drawDataRow(startX, startY, height, "ID: ", animal.animalId, scale)
			startY = drawDataRow(startX, startY, height, "Típus: ", animal.type, scale)

			startY = startY + height

			local healthLevel = renderData.petDatas.health or animal.health
			startY = drawDataRow(startX, startY, height, "Élet: ", math.floor(healthLevel) .. " %", scale)

			dxDrawRectangle(startX, startY, oneSectionSizeX, respc(30), rgba(255, 255, 255, 25))
			dxDrawRectangle(startX + 3, startY + 3, (oneSectionSizeX - 6) * healthLevel / 100, respc(30) - 6, rgba(71, 127, 168))

			startY = startY + respc(40)

			local hungerLevel = renderData.petDatas.hunger or animal.hunger
			startY = drawDataRow(startX, startY, height, "Éhség: ", "#598ed7" .. math.floor(hungerLevel) .. " %", scale)

			dxDrawRectangle(startX, startY, oneSectionSizeX, respc(30), rgba(255, 255, 255, 25))
			dxDrawRectangle(startX + 3, startY + 3, (oneSectionSizeX - 6) * hungerLevel / 100, respc(30) - 6, rgba(89, 142, 215))

			startY = startY + respc(40)

			local loveLevel = renderData.petDatas.love or animal.love
			startY = drawDataRow(startX, startY, height, "Szeretet: ", "#ff9900" .. math.floor(loveLevel) .. " %", scale)

			dxDrawRectangle(startX, startY, oneSectionSizeX, respc(30), rgba(255, 255, 255, 25))
			dxDrawRectangle(startX + 3, startY + 3, (oneSectionSizeX - 6) * loveLevel / 100, respc(30) - 6, rgba(255, 125, 0))

			startY = startY + respc(40)

			startY = drawDataRow(startX, startY, height, "Elkölthető prémiumpontok: ", "#32b3ef" .. formatNumber(myDatas["acc.premiumPoints"], " ") .. " PP", scale)

			local buttonSizeY = respc(45)
			local buttonMargin = respc(10)

			startY = (y + headerHeight + respc(20) + oneSectionSizeY) - buttonSizeY * 4 - buttonMargin * 3

			-- Eladás
			buttons["sellAnimal"] = {startX, startY, oneSectionSizeX, buttonSizeY}

			if activeButton == "sellAnimal" then
				dxDrawRectangle(startX, startY, oneSectionSizeX, buttonSizeY, rgba(215, 89, 89, 200))
			else
				dxDrawRectangle(startX, startY, oneSectionSizeX, buttonSizeY, rgba(215, 89, 89, 100))
			end

			dxDrawText("Eladás", startX, startY, startX + oneSectionSizeX, startY + buttonSizeY, rgba(255, 255, 255), 0.9, RobotoL, "center", "center")

			-- Felélesztés
			buttons["reviveAnimal"] = {startX, startY + buttonSizeY + buttonMargin, oneSectionSizeX, buttonSizeY}

			if activeButton == "reviveAnimal" then
				dxDrawRectangle(startX, startY + buttonSizeY + buttonMargin, oneSectionSizeX, buttonSizeY, rgba(50, 179, 239, 200))
			else
				dxDrawRectangle(startX, startY + buttonSizeY + buttonMargin, oneSectionSizeX, buttonSizeY, rgba(50, 179, 239, 100))
			end

			dxDrawText("Felélesztés", startX, startY + buttonSizeY + buttonMargin, startX + oneSectionSizeX, startY + buttonSizeY * 2 + buttonMargin, rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
			
			-- Spawn/Despawn
			buttons["spawnAnimal"] = {startX, startY + buttonSizeY * 2 + buttonMargin * 2, oneSectionSizeX, buttonSizeY}

			if renderData.spawnedAnimal ~= animal.animalId then
				if activeButton == "spawnAnimal" then
					dxDrawRectangle(startX, startY + buttonSizeY * 2 + buttonMargin * 2, oneSectionSizeX, buttonSizeY, rgba(71, 127, 168, 200))
				else
					dxDrawRectangle(startX, startY + buttonSizeY * 2 + buttonMargin * 2, oneSectionSizeX, buttonSizeY, rgba(71, 127, 168, 100))
				end

				dxDrawText("Spawn", startX, startY + buttonSizeY * 2 + buttonMargin * 2, startX + oneSectionSizeX, startY + buttonSizeY * 3 + buttonMargin * 2, rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
			elseif renderData.petDatas and renderData.spawnedPetElement then
				if activeButton == "spawnAnimal" then
					dxDrawRectangle(startX, startY + buttonSizeY * 2 + buttonMargin * 2, oneSectionSizeX, buttonSizeY, rgba(255, 125, 0, 200))
				else
					dxDrawRectangle(startX, startY + buttonSizeY * 2 + buttonMargin * 2, oneSectionSizeX, buttonSizeY, rgba(255, 125, 0, 100))
				end

				dxDrawText("Despawn", startX, startY + buttonSizeY * 2 + buttonMargin * 2, startX + oneSectionSizeX, startY + buttonSizeY * 3 + buttonMargin * 2, rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
			end

			-- Átnevezés
			buttons["renameAnimal"] = {startX, startY + buttonSizeY * 3 + buttonMargin * 3, oneSectionSizeX, buttonSizeY}

			if activeButton == "renameAnimal" then
				dxDrawRectangle(startX, startY + buttonSizeY * 3 + buttonMargin * 3, oneSectionSizeX, buttonSizeY, rgba(50, 179, 239, 200))
			else
				dxDrawRectangle(startX, startY + buttonSizeY * 3 + buttonMargin * 3, oneSectionSizeX, buttonSizeY, rgba(50, 179, 239, 100))
			end

			dxDrawText("Átnevezés", startX, startY + buttonSizeY * 3 + buttonMargin * 3, startX + oneSectionSizeX, startY + buttonSizeY * 4 + buttonMargin * 3, rgba(255, 255, 255), 0.9, RobotoL, "center", "center")
		else
			dxDrawText("Nincs kiválasztva pet.", startX + oneSegmentSizeX, y + headerHeight, x + sx, y + sy - headerHeight * 2, rgba(255, 255, 255), 1, RobotoB, "center", "center")
		end
	end

	-- Beállítások
	if selectedTab == 8 then
		local startX = x + respc(460)
		local startY = y + respc(20)

		local oneSectionSizeX = screenX - respc(460) - respc(20)
		local oneSectionSizeY = (y + sy - headerHeight) - startY - respc(60)

		local tabNum = 12
		local oneSize = oneSectionSizeY / tabNum
		local maxThings = #renderData.clientSettings

		for i = 1, tabNum do
			local lineY = startY + (i - 1) * oneSize
			
			if i % 2 == 0 then
				dxDrawRectangle(startX, lineY, oneSectionSizeX, oneSize, rgba(0, 0, 0, 30))
			end

			if i ~= tabNum then
				dxDrawRectangle(startX, lineY + oneSize, oneSectionSizeX, 2, rgba(255, 255, 255, 25))
			end

			local set = renderData.clientSettings[i + renderData.offsetSettings]

			if set then
				dxDrawText(set[1], startX + respc(20), lineY, 0, lineY + oneSize, rgba(255, 255, 255), 0.85, RobotoB2, "left", "center")

				if set[4] then
					if type(set[4]) == "table" then
						local sliderWidth = respc(300)
						local sliderHeight = oneSize * 0.75

						local sliderBaseX = startX + oneSectionSizeX - sliderWidth - respc(20)
						local sliderBaseY = lineY + (oneSize - respc(10)) / 2

						local sliderX = sliderBaseX + reMap(tonumber(set[2]), set[4][1], set[4][2], 0, sliderWidth - respc(15))
						local sliderY = lineY + (oneSize - sliderHeight) / 2

						if set[4][3] then
							dxDrawText(math.ceil(set[2]) .. " " .. set[4][3], 0, lineY, sliderBaseX - respc(20), lineY + oneSize, rgba(150, 150, 150), 0.75, Roboto, "right", "center")
						else
							dxDrawText(math.ceil(set[2]), 0, lineY, sliderBaseX - respc(20), lineY + oneSize, rgba(150, 150, 150), 0.75, Roboto, "right", "center")
						end
			
						dxDrawRectangle(sliderBaseX, sliderBaseY, sliderWidth, respc(10), rgba(75, 75, 75))
						dxDrawRectangle(sliderX, sliderY, respc(15), sliderHeight, rgba(50, 179, 239))

						if getKeyState("mouse1") and renderData.sliderMoveX then
							if renderData.activeSlider == set[3] then
								local sliderValue = (cursorX - renderData.sliderMoveX - sliderBaseX) / (sliderWidth - respc(15))

								if sliderValue < 0 then
									sliderValue = 0
								end

								if sliderValue > 1 then
									sliderValue = 1
								end

								set[2] = reMap(sliderValue, 0, 1, set[4][1], set[4][2])
								
								if set[3] == "viewDistance" then
									setFarClipDistance(set[2])
								elseif set[3] == "chatBackgroundAlpha" then
									if renderData.chatInstance then
										executeBrowserJavascript(renderData.chatInstance, "document.getElementById(\"preview\").style.background = \"rgba(0, 0, 0, " .. math.floor(set[2]) / 100 .. ")\"; document.getElementById(\"preview2\").style.background = \"rgba(0, 0, 0, " .. math.floor(set[2]) / 100 .. ")\"; document.getElementById(\"preview\").style.left = \"" .. cursorX .. "px\"; document.getElementById(\"preview\").style.top = \"" .. cursorY .. "px\";")
									end
								elseif set[3] == "chatFontBackgroundAlpha" then
									if renderData.chatInstance then
										executeBrowserJavascript(renderData.chatInstance, "document.getElementById(\"shadow\").innerHTML = \"* { text-shadow: 1px 1px rgba(0, 0, 0, " .. math.floor(set[2]) / 100 .. "); }\"; document.getElementById(\"preview\").style.left = \"" .. cursorX .. "px\"; document.getElementById(\"preview\").style.top = \"" .. cursorY .. "px\";")
									end
								elseif set[3] == "chatFontSize" then
									if renderData.chatInstance then
										executeBrowserJavascript(renderData.chatInstance, "document.getElementById(\"preview\").style.fontSize = \"" .. math.floor(set[2]) .. "%\"; document.getElementById(\"preview\").style.left = \"" .. cursorX .. "px\"; document.getElementById(\"preview\").style.top = \"" .. cursorY .. "px\";")
									end
								end

								renderData.loadedSettings[set[3]] = set[2]
							end
						else
							renderData.sliderMoveX = false
							renderData.activeSlider = false
						end

						if not renderData.sliderMoveX and activeButton == "setting_slider:" .. set[3] then
							renderData.sliderMoveX = cursorX - sliderX
							renderData.activeSlider = set[3]
						end

						buttons["setting_slider:" .. set[3]] = {sliderX, sliderY, respc(15), sliderHeight}
					else
						local buttonSizeX = respc(50)
						local buttonSizeY = oneSize * 0.75

						local buttonStartX = startX + oneSectionSizeX - buttonSizeX - respc(20)
						local buttonStartY = lineY + oneSize / 2 - buttonSizeY / 2

						if set[4] == "crosshair" then
							local colorX = startX + oneSectionSizeX - respc(128) - respc(20)

							if activeButton == "crosshair_color" then
								dxDrawRectangle(colorX, buttonStartY, respc(128), buttonSizeY, rgba(71, 127, 168, 240))
							else
								dxDrawRectangle(colorX, buttonStartY, respc(128), buttonSizeY, rgba(71, 127, 168, 200))
							end
							dxDrawText("Szín", colorX, buttonStartY, colorX + respc(128), buttonStartY + buttonSizeY, rgba(0, 0, 0), 0.75, RobotoL, "center", "center")

							buttons["crosshair_color"] = {colorX, buttonStartY, respc(128), buttonSizeY}
							buttonStartX = buttonStartX - respc(128 + 20)
						end

						buttons["setting_next:" .. set[3]] = {buttonStartX, buttonStartY, buttonSizeX, buttonSizeY}
						if activeButton == "setting_next:" .. set[3] then
							dxDrawRectangle(buttonStartX, buttonStartY, buttonSizeX, buttonSizeY, rgba(71, 127, 168, 240))
						else
							dxDrawRectangle(buttonStartX, buttonStartY, buttonSizeX, buttonSizeY, rgba(71, 127, 168, 200))
						end
						dxDrawText(">", buttonStartX, buttonStartY, buttonStartX + buttonSizeX, buttonStartY + buttonSizeY, rgba(0, 0, 0), 1, RobotoL, "center", "center")

						if set[4] == "crosshair" then
							local shapeSize = oneSize * 0.35
							local shapeX = buttonStartX - buttonSizeX * 2
							local shapeY = lineY + oneSize / 2 - shapeSize / 2 - respc(8)
							local shapeId = renderData.crosshairData[1] or 0
							local r, g, b = renderData.crosshairData[2], renderData.crosshairData[3], renderData.crosshairData[4]

							if shapeId == 0 then
								r, g, b = 255, 255, 255
							end

							buttons["crosshair_zoom"] = {shapeX, shapeY, shapeSize * 2, shapeSize * 2}

							if activeButton == "crosshair_zoom" then
								shapeSize = 32
								shapeX = cursorX - shapeSize / 2
								shapeY = cursorY - shapeSize / 2
							end

							dxDrawImage(math.floor(shapeX), math.floor(shapeY), shapeSize, shapeSize, ":see_crosshair/files/" .. shapeId .. ".png", 0, 0, 0, rgba(r, g, b))
							dxDrawImage(math.floor(shapeX + shapeSize * 2), math.floor(shapeY), -shapeSize, shapeSize, ":see_crosshair/files/" .. shapeId .. ".png", 0, 0, 0, rgba(r, g, b))
							dxDrawImage(math.floor(shapeX), math.floor(shapeY + shapeSize * 2), shapeSize, -shapeSize, ":see_crosshair/files/" .. shapeId .. ".png", 0, 0, 0, rgba(r, g, b))
							dxDrawImage(math.floor(shapeX + shapeSize * 2), math.floor(shapeY + shapeSize * 2), -shapeSize, -shapeSize, ":see_crosshair/files/" .. shapeId .. ".png", 0, 0, 0, rgba(r, g, b))
						else
							if type(set[2]) == "boolean" or not set[2] then
								dxDrawText("Kikapcsolva", buttonStartX - buttonSizeX * 2, lineY, buttonStartX - buttonSizeX, lineY + oneSize, rgba(255, 255, 255), 0.75, Roboto, "center", "center")
							else
								if renderData.shaderRealNames[set[3]] and renderData.shaderRealNames[set[3]][set[2]] then
									dxDrawText(renderData.shaderRealNames[set[3]][set[2]], buttonStartX - buttonSizeX * 2, lineY, buttonStartX - buttonSizeX, lineY + oneSize, rgba(255, 255, 255), 0.75, Roboto, "center", "center")
								else
									dxDrawText(set[2], buttonStartX - buttonSizeX * 2, lineY, buttonStartX - buttonSizeX, lineY + oneSize, rgba(255, 255, 255), 0.75, Roboto, "center", "center")
								end
							end
						end

						buttons["setting_prev:" .. set[3]] = {buttonStartX - buttonSizeX * 4, buttonStartY, buttonSizeX, buttonSizeY}
						if activeButton == "setting_prev:" .. set[3] then
							dxDrawRectangle(buttonStartX - buttonSizeX * 4, buttonStartY, buttonSizeX, buttonSizeY, rgba(71, 127, 168, 240))
						else
							dxDrawRectangle(buttonStartX - buttonSizeX * 4, buttonStartY, buttonSizeX, buttonSizeY, rgba(71, 127, 168, 200))
						end
						dxDrawText("<", buttonStartX - buttonSizeX * 4, buttonStartY, buttonStartX - buttonSizeX * 3, buttonStartY + buttonSizeY, rgba(0, 0, 0), 1, RobotoL, "center", "center")
					end
				else
					local enabled = false

					if type(set[2]) == "boolean" and set[2] then
						enabled = true
					end

					local buttonSizeX = respc(150)
					local buttonSizeY = oneSize * 0.75

					local buttonStartX = startX + oneSectionSizeX - buttonSizeX - respc(20)
					local buttonStartY = lineY + oneSize / 2 - buttonSizeY / 2

					if not enabled then
						if activeButton == "setting_toggle:" .. set[3] then
							dxDrawRectangle(buttonStartX, buttonStartY, buttonSizeX, buttonSizeY, rgba(215, 89, 89, 240))
							dxDrawText("Kikapcsolva", buttonStartX, lineY, buttonStartX + buttonSizeX, lineY + oneSize, rgba(0, 0, 0), 0.75, Roboto, "center", "center")
						else
							dxDrawRectangle(buttonStartX, buttonStartY, buttonSizeX, buttonSizeY, rgba(215, 89, 89, 200))
							dxDrawText("Kikapcsolva", buttonStartX, lineY, buttonStartX + buttonSizeX, lineY + oneSize, rgba(0, 0, 0), 0.75, RobotoL, "center", "center")
						end
						buttons["setting_toggle:" .. set[3]] = {buttonStartX, buttonStartY, buttonSizeX, buttonSizeY}
					else
						if activeButton == "setting_toggle:" .. set[3] then
							dxDrawRectangle(buttonStartX, buttonStartY, buttonSizeX, buttonSizeY, rgba(71, 127, 168, 240))
							dxDrawText("Bekapcsolva", buttonStartX, lineY, buttonStartX + buttonSizeX, lineY + oneSize, rgba(0, 0, 0), 0.75, Roboto, "center", "center")
						else
							dxDrawRectangle(buttonStartX, buttonStartY, buttonSizeX, buttonSizeY, rgba(71, 127, 168, 200))
							dxDrawText("Bekapcsolva", buttonStartX, lineY, buttonStartX + buttonSizeX, lineY + oneSize, rgba(0, 0, 0), 0.75, RobotoL, "center", "center")
						end
						buttons["setting_toggle:" .. set[3]] = {buttonStartX, buttonStartY, buttonSizeX, buttonSizeY}
					end
				end
			end
		end

		if maxThings > tabNum then
			local trackSize = tabNum * oneSize
			dxDrawRectangle(startX + oneSectionSizeX, startY, 5, trackSize, rgba(255, 255, 255, 25))
			dxDrawRectangle(startX + oneSectionSizeX, startY + renderData.offsetSettings * (trackSize / maxThings), 5, trackSize / maxThings * tabNum, rgba(71, 127, 168, 150))
		end

		if getKeyState("mouse1") and renderData.sliderMoveX then
			if renderData.activeSlider == "chatBackgroundAlpha" or renderData.activeSlider == "chatFontBackgroundAlpha" or renderData.activeSlider == "chatFontSize" then
				if renderData.chatInstance then
					dxDrawImage(0, 0, screenX, screenY, renderData.chatInstance)
				end
			end
		end
	end

	-- ** Button handler
	activeButton = false

	if isCursorShowing() then
		for k, v in pairs(buttons) do
			if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

addCommandHandler("dashboard",
	function ()
		if getElementData(localPlayer, "loggedIn") then
			togglePanel()
		end
	end)

addCommandHandler("admins",
	function ()
		if getElementData(localPlayer, "loggedIn") then
			if not panelState then
				selectedTab = 4
				togglePanel()
			elseif selectedTab ~= 4 then
				playSound("files/sounds/menuswitch.mp3")
			end

			selectedTab = 4
		end
	end)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if press then
			if key == "home" and not ChangeDescription and not buyingVehicleSlot and not buyingInteriorSlot and not renderData.buyingPet and not sellVehicleTargetID and not sellVehiclePrice then
				if getElementData(localPlayer, "loggedIn") then
					togglePanel()
				end

				cancelEvent()
				return
			elseif key == "F3" and not ChangeDescription and not buyingVehicleSlot and not buyingInteriorSlot and not renderData.buyingPet and not sellVehicleTargetID and not sellVehiclePrice then
				if getElementData(localPlayer, "loggedIn") then
					if not panelState then
						selectedTab = 4
						togglePanel()
					elseif selectedTab ~= 4 then
						playSound("files/sounds/menuswitch.mp3")
					end

					selectedTab = 4
				end

				cancelEvent()
				return
			end
		end

		if panelState then
			if key ~= "esc" then
				cancelEvent()
			end
            if selectedTab == 1 then

				if key == "backspace" and press then
					if activeFakeInput == "ChangeDescription" then
						if utf8.len(fakeInputText) >= 1 then
							fakeInputText = utf8.sub(fakeInputText, 1, -2)
						end
					end
				end
			end
			if selectedTab == 2 then
				local cx, cy = getCursorPosition()

				cx = cx * screenX
				cy = cy * screenY

				if key == "mouse_wheel_down" then
					if cx < screenX / 2 then
						if offsetVeh < #playerVehicles - 11 then
							offsetVeh = offsetVeh + 1
						end
					else
						if offsetInt < #playerInteriors - 11 then
							offsetInt = offsetInt + 1
						end
					end
				elseif key == "mouse_wheel_up" then
					if cx < screenX / 2 then
						if offsetVeh > 0 then
							offsetVeh = offsetVeh - 1
						end
					else
						if offsetInt > 0 then
							offsetInt = offsetInt - 1
						end
					end
				end

				if key == "backspace" and press then
					if buyingVehicleSlot or ChangeDescription or buyingInteriorSlot or sellVehicleTargetID or sellVehiclePrice then
						print("asd")
						if string.len(fakeInputText) >= 1 then
							fakeInputText = string.sub(fakeInputText, 1, -2)
						end
					end
				end
			elseif selectedTab == 4 then
				local cx, cy = getCursorPosition()

				cx = cx * screenX
				cy = cy * screenY

				if key == "mouse_wheel_down" then
					if cx < respc(30) + (screenX - respc(60)) / 3.5 then
						if offsetGroup < playerGroupsCount - 20 then
							offsetGroup = offsetGroup + 1
						end
					else
						local groupId = playerGroupsKeyed[selectedGroup]

						if groupId then
							if selectedGroupTab == 1 then
								if offsetMember < #groupMembers[groupId] - 14 then
									offsetMember = offsetMember + 1
								end
							elseif selectedGroupTab == 2 then
								if offsetRank < #groups[groupId].ranks - 14 then
									offsetRank = offsetRank + 1
								end
							elseif selectedGroupTab == 3 then
								if offsetGroupVeh < #groupVehicles[groupId] - 14 then
									offsetGroupVeh = offsetGroupVeh + 1
								end
							end
						end
					end
				elseif key == "mouse_wheel_up" then
					if cx < respc(30) + (screenX - respc(60)) / 3.5 then
						if offsetGroup > 0 then
							offsetGroup = offsetGroup - 1
						end
					else
						local groupId = playerGroupsKeyed[selectedGroup]

						if groupId then
							if selectedGroupTab == 1 then
								if offsetMember > 0 then
									offsetMember = offsetMember - 1
								end
							elseif selectedGroupTab == 2 then
								if offsetRank > 0 then
									offsetRank = offsetRank - 1
								end
							elseif selectedGroupTab == 3 then
								if offsetGroupVeh > 0 then
									offsetGroupVeh = offsetGroupVeh - 1
								end
							end
						end
					end
				end

				if key == "backspace" and press then
					if activeFakeInput == "inviting" or activeFakeInput == "ChangeDescription" or activeFakeInput == "setrankname" or activeFakeInput == "setrankpay" or activeFakeInput == "groupdesc" or activeFakeInput == "groupbalance" then
						if utf8.len(fakeInputText) >= 1 then
							fakeInputText = utf8.sub(fakeInputText, 1, -2)
						end
					end
				end
			elseif selectedTab == 5 then
				if key == "backspace" and press then
					if tonumber(renderData.buyDogType) then
						if renderData.dogName and utf8.len(renderData.dogName) >= 1 then
							renderData.dogName = utf8.sub(renderData.dogName, 1, -2)
						end
					end

					if renderData.renamingPet then
						if renderData.newDogName and utf8.len(renderData.newDogName) >= 1 then
							renderData.newDogName = utf8.sub(renderData.newDogName, 1, -2)
						end
					end
				end

				if key == "mouse_wheel_down" then
					if renderData.offsetAnimal < renderData.loadedAnimals - 18 then
						renderData.offsetAnimal = renderData.offsetAnimal + 1
					end
				elseif key == "mouse_wheel_up" then
					if renderData.offsetAnimal > 0 then
						renderData.offsetAnimal = renderData.offsetAnimal - 1
					end
				end
			elseif selectedTab == 8 then
				if key == "mouse_wheel_down" then
					if renderData.offsetSettings < #renderData.clientSettings - 12 then
						renderData.offsetSettings = renderData.offsetSettings + 1
					end
				elseif key == "mouse_wheel_up" then
					if renderData.offsetSettings > 0 then
						renderData.offsetSettings = renderData.offsetSettings - 1
					end
				end
			end
		end
	end)

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local dutySkinSelectState = false
local originalSkin = 0
local currentSkinOffset = 0
local skinForGroup = false
local skinSelectFont = false

function toggleDutySkinSelect(state, groupId)
	if dutySkinSelectState ~= state then
		if state then
			dutySkinSelectState = true
			exports.see_controls:toggleControl("all", false)

			skinForGroup = groupId
			originalSkin = getElementModel(localPlayer)
			currentSkinOffset = 0

			bindKey("arrow_r", "up", nextSkin)
			bindKey("arrow_l", "up", previousSkin)
			bindKey("enter", "up", processDutySkinSelection)

			skinSelectFont = dxCreateFont("files/fonts/Roboto.ttf", 15, false, "antialiased")

			addEventHandler("onClientRender", getRootElement(), dutySkinRender)
		else
			removeEventHandler("onClientRender", getRootElement(), dutySkinRender)

			if isElement(skinSelectFont) then
				destroyElement(skinSelectFont)
			end

			skinSelectFont = nil

			unbindKey("arrow_r", "up", nextSkin)
			unbindKey("arrow_l", "up", previousSkin)
			unbindKey("enter", "up", processDutySkinSelection)

			skinForGroup = false
			exports.see_controls:toggleControl("all", true)
			dutySkinSelectState = false
		end
	end
end

function nextSkin()
	if skinForGroup and groups[skinForGroup] then
		if groups[skinForGroup].duty.skins[currentSkinOffset + 1] then
			currentSkinOffset = currentSkinOffset + 1
			setElementModel(localPlayer, groups[skinForGroup].duty.skins[currentSkinOffset])
		end
	end
end

function previousSkin()
	if skinForGroup and groups[skinForGroup] then
		if groups[skinForGroup].duty.skins[currentSkinOffset - 1] then
			currentSkinOffset = currentSkinOffset - 1
			setElementModel(localPlayer, groups[skinForGroup].duty.skins[currentSkinOffset])
		end
	end
end

function processDutySkinSelection()
	local selectedSkin = getElementModel(localPlayer)
	
	if selectedSkin ~= originalSkin then
		setElementModel(localPlayer, originalSkin)

		triggerServerEvent("updateDutySkin", localPlayer, skinForGroup, selectedSkin, originalSkin)
	end

	toggleDutySkinSelect(false)
	exports.see_accounts:showInfo("s", "Sikeresen megváltoztattad a csoporthoz tartozó szolgálati öltözékedet.")
	togglePanel()
end

function dutySkinRender()
	dxDrawText("Lapozás: [<-] és [->] Kiválasztás: [ENTER]", 0 + 1, 0 + 1, screenX + 1, screenY - 150 + 1, tocolor(0, 0, 0), 1, skinSelectFont, "center", "bottom")
	dxDrawText("Lapozás: #477fa8[<-] és [->] #ffffffKiválasztás: #477fa8[ENTER]", 0, 0, screenX, screenY - 150, tocolor(255, 255, 255), 1, skinSelectFont, "center", "bottom", false, false, false, true)
end

function checkDistance(sourceElement, targetElement)
	if getElementInterior(sourceElement) ~= getElementInterior(targetElement) then
		return 999999
	end

	if getElementDimension(sourceElement) ~= getElementDimension(targetElement) then
		return 999999
	end

	local sourceX, sourceY, sourceZ = getElementPosition(sourceElement)
	local targetX, targetY, targetZ = getElementPosition(targetElement)

	return getDistanceBetweenPoints3D(sourceX, sourceY, sourceZ, targetX, targetY, targetZ)
end

function drawText(text, x, y, w, h, color, size, font)
		dxDrawText(text, x + w / 2 , y + h / 2, x + w / 2, y + h / 2, color, size, font, "center", "center", false, false, false, true)
end

function dxDrawLinedRectangle(text, x, y, width, height, color, _width, postGUI, image)
	_width = _width or 1
	text = text or ""

	

	dxDrawRectangle(x, y, width, height, rgba(0, 0, 0, 120))
	if image then
		dxDrawImage(x + respc(10) / 2, y + respc(10) / 2, height - respc(10), height - respc(10), image, 0, 0, 0, rgba(255, 255, 255))
	end
	drawText(text, x, y, width, height, rgba(255, 255, 255, 200), 1, RobotoL)
	dxDrawLine ( x, y, x+width, y, color, _width, postGUI ) -- Top
	dxDrawLine ( x, y, x, y+height, color, _width, postGUI ) -- Left
	dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI ) -- Bottom

	return dxDrawLine ( x+width, y, x+width, y+height, color, _width, postGUI ) -- Right
end

function drawLine(x, y, width, height, color, _width, postGUI)
	dxDrawLine ( x, y, x+width, y, color, _width, postGUI ) -- Top
	dxDrawLine ( x, y, x, y+height, color, _width, postGUI ) -- Left
	dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI ) -- Bottom

	return dxDrawLine ( x+width, y, x+width, y+height, color, _width, postGUI ) -- Right
end

function dxDrawPieChart(centreX, centreY, chartRadius, dataList, colorList, textList)
	local sumOfData = 0

	for i = 1, #dataList do
		sumOfData = sumOfData + (dataList[i] > 0 and dataList[i] or 0)
	end

	local angleBegin = (getTickCount() / 50) % 360
	local labelArray = {}

	for i = 1, #dataList do
		local angleEnd = angleBegin + 360 * (dataList[i] / sumOfData)

		if dataList[i] > 0 then
			local innerColor = 0xFFCCCCCC
			local outerColor = 0xFFFFFFFF
			local labelColor = 0xFF000000

			if type(colorList[i]) == "table" then
				local R, G, B = colorList[i][1], colorList[i][2], colorList[i][3]

				innerColor = rgba(R, G, B, 255)
				outerColor = rgba(R * 0.6, G * 0.6, B * 0.6, 255)
				labelColor = rgba(R + (R * 0.6 - R) / 2, G + (G * 0.6 - G) / 2, B + (B * 0.6 - B) / 2, 255)
			end

			dxDrawCircle(centreX, centreY, chartRadius, angleBegin, angleEnd, innerColor, outerColor, 1024)

			if textList[i] then
				labelArray[#labelArray + 1] = {
					textList[i],
					dataList[i],
					math.rad(angleBegin + (angleEnd - angleBegin) / 2),
					labelColor
				}
			end
		else
			angleEnd = angleBegin
		end

		angleBegin = angleEnd
	end

	for i = 1, #labelArray do
		local v = labelArray[i]

		local edgeX = centreX + math.cos(v[3]) * (chartRadius * 0.5)
		local edgeY = centreY + math.sin(v[3]) * (chartRadius * 0.5)

		local pointX = edgeX + math.cos(v[3]) * chartRadius
		local pointY = edgeY + math.sin(v[3]) * chartRadius

		dxDrawLine(edgeX, edgeY, pointX, pointY, v[4], 2)

		local sliceValueText = tostring(v[2])
		local decimalCounter = 0

		while true do
			sliceValueText, decimalCounter = string.gsub(sliceValueText, "^(-?%d+)(%d%d%d)", "%1,%2")
			if decimalCounter == 0 then
				break
			end
		end

		local textString = string.format(v[1], sliceValueText)
		local textSizeX = dxGetTextWidth(textString, 1.0, RobotoL) + 10
		local textSizeY = 25

		dxDrawRectangle(pointX, pointY, textSizeX, textSizeY, v[4], false, true)
		dxDrawText(textString, pointX, pointY, pointX + textSizeX, pointY + textSizeY, 0xffffffff, 1.0, RobotoL, "center", "center", false, false, false, false, true)
	end
end

function loadShopDatas()
		itemList = {}
		visibleItems = 0
		offsetItems = 0
		openCategories = {}
		activeFakeInput = false
end



function currentSlotSelected()
	local clothesLimit = getElementData(localPlayer, "clothesLimit") or 2
	local currentClothes = getElementData(localPlayer, "currentClothes") or ""

	myCurrentClothes = fromJSON(currentClothes) or {}
	iprint(myCurrentClothes)

	for k, v in pairs(myCurrentClothes) do
		if not tonumber(v[11]) or clothesLimit < v[11] then
			myCurrentClothes[k] = nil
		end
	end

	local items = {}
	local cats = {}
	local subs = {}

	for i = 1, #baseCategories do
		local cat = baseCategories[i][2]

		if myCurrentClothes[cat] then
			table.insert(items, {"haveitem" .. i, i})
		else
			if myClothes[i] then
				local clothes = {}

				for j = 1, #myClothes[i] do
					table.insert(clothes, myClothes[i][j])
				end

				table.sort(clothes,
					function (a, b)
						return itemIndexes[b] > itemIndexes[a]
					end
				)

				for j = 1, #clothes do
					table.insert(items, {clothes[j], i})
				end
			else
				table.insert(items, {"noitem" .. i, i})
			end
		end
	end

	itemList = {}
	visibleItems = 0

	for i = 1, #items do
		local text = items[i][1]
		local id = items[i][2]

		if not cats[id] then
			cats[id] = true
			table.insert(itemList, {"cat", id})
		end

		if openCategories[id] then
			if text == "noitem" .. id then
				table.insert(itemList, {"noitem", id})
			elseif text == "haveitem" .. id then
				table.insert(itemList, {"haveitem", id})
			else
				local name = baseCategories[id][2]

				if subCategories[name] then
					local index = subCategorizedItems[text]

					if not subs[index] then
						subs[index] = true
						table.insert(itemList, {"sub", subTitles[index]})
					end
				end

				table.insert(itemList, {"item", text})
			end
		end
	end

	visibleItems = #itemList

	if visibleItems > 15 then
		if offsetItems > visibleItems - 15 then
			offsetItems = visibleItems - 15
		end
	else
		offsetItems = 0
	end
end

function spairs(t, order)
	local keys = {}

	for k in pairs(t) do
		keys[#keys+1] = k
	end

	if order then
		table.sort(keys,
			function (a, b)
				return order(t, a, b)
			end
		)
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


function findPlayer(sourcePlayer, partialNick)
	if not partialNick and not isElement(sourcePlayer) and type(sourcePlayer) == "string" then
		partialNick = sourcePlayer
		sourcePlayer = nil
	end
	
	local candidates = {}
	local matchPlayer = nil
	local matchNickAccuracy = -1

	partialNick = string.lower(partialNick)
	
	if sourcePlayer and partialNick == "*" then
		return sourcePlayer, string.gsub(getPlayerName(sourcePlayer), "_", " ")
	elseif tonumber(partialNick) then
		local players = getElementsByType("player")

		for i = 1, #players do
			local player = players[i]

			if isElement(player) then
				if getElementData(player, "loggedIn") then
					if getElementData(player, "playerID") == tonumber(partialNick) then
						matchPlayer = player
						break
					end
				end
			end
		end

		candidates = {matchPlayer}
	else
		local players = getElementsByType("player")

		partialNick = string.gsub(partialNick, "-", "%%-")

		for i = 1, #players do
			local player = players[i]

			if isElement(player) then
				local playerName = getElementData(player, "visibleName")

				if not playerName then
					playerName = getPlayerName(player)
				end

				playerName = string.gsub(playerName, "_", " ")
				playerName = string.lower(playerName)

				if playerName then
					local startPos, endPos = string.find(playerName, tostring(partialNick))

					if startPos and endPos then
						if endPos - startPos > matchNickAccuracy then
							matchNickAccuracy = endPos - startPos
							matchPlayer = player
							candidates = {player}
						elseif endPos - startPos == matchNickAccuracy then
							matchPlayer = nil
							table.insert(candidates, player)
						end
					end
				end
			end
		end
	end
	
	if not matchPlayer or not isElement(matchPlayer) then
		if isElement(sourcePlayer) then
			if #candidates == 0 then
				--outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem található.", sourcePlayer, 255, 255, 255, true)
			else
				--outputChatBox("#3d7abc[StrongMTA]: #ffffffEzzel a névrészlettel #32b3ef" .. #candidates .. " db #ffffffjátékos található:", sourcePlayer, 255, 255, 255, true)
			
				for i = 1, #candidates do
					local player = candidates[i]

					if isElement(player) then
						local playerId = getElementData(player, "playerID")
						local playerName = string.gsub(getPlayerName(player), "_", " ")

						--outputChatBox("#3d7abc    (" .. tostring(playerId) .. ") #ffffff" .. playerName, sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
		
		return false
	else
		if getElementData(matchPlayer, "loggedIn") then
			local playerName = getElementData(matchPlayer, "visibleName")

			if not playerName then
				playerName = getPlayerName(matchPlayer)
			end

			return matchPlayer, string.gsub(playerName, "_", " ")
		else
			--outputChatBox("#d75959[StrongMTA]:  #ffffffA kiválasztott játékos nincs bejelentkezve.", sourcePlayer, 255, 255, 255, true)
			return false
		end
	end
end