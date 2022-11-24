local screenWidth, screenHeight = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

panelState = false
vehicleElement = false

menuWidth = respc(400)
menuHeight = respc(600)
menuPosX = respc(20)
menuPosY = respc(120)
rowHeight = respc(40)

Roboto = false
Roboto2 = false
Roboto3 = false
Roboto4 = false

function createFonts()
	destroyFonts()

	Roboto = dxCreateFont("files/fonts/Roboto.ttf", resp(14), false, "antialiased")
	Roboto2 = dxCreateFont("files/fonts/Roboto.ttf", resp(18), false, "antialiased")
	Roboto3 = dxCreateFont("files/fonts/Roboto.ttf", resp(36), false, "antialiased")
	Roboto4 = dxCreateFont("files/fonts/Roboto.ttf", resp(11), false, "antialiased")
end

function destroyFonts()
	if isElement(Roboto) then
		destroyElement(Roboto)
	end

	if isElement(Roboto2) then
		destroyElement(Roboto2)
	end

	if isElement(Roboto3) then
		destroyElement(Roboto3)
	end

	if isElement(Roboto4) then
		destroyElement(Roboto4)
	end
end

local currentMoney = 0
local moneyChangeTick = 0
local moneyChangeValue = 0

local currentPP = 0
local ppChangeTick = 0
local ppChangeValue = 0

selectedMenu = 0
selectedSubMenu = 0
local activeMenu = {}

selectionLevel = 1
local oldSelectionLevel = selectionLevel
local selectionStart = 0
local selectionPosY = 0
local selectionColor = false

originalUpgrade = 0
originalHandling = false
vehicleColor = {}
vehicleLightColor = {}

local neonState = false
neonId = false
originalDoor = false
originalPaintjob = false
originalHeadLight = false
originalWheelPaintjob = false

local editPlate = false
local originalPlate = false

local variantEditor = false
local selectedVariant = false
local lastVariantChange = 0

local previewHorn = false

local camRotation = 0
local camOffsetZ = 0
local camDefPos = {}
local camPosition = {}
local camStartPos = {}
local camTargetPos = {}
local camMoveStart = false
local lastCursorPos = false
local camZoomLevel = 1
local camZoomStart = false
local camZoomInterpolation = {}
local camView = "base"

local spinnerVehicles = {
	[585] = true,
	[579] = true,
	[576] = true,
	[567] = true,
	[536] = true,
	[492] = true,
	[467] = true,
	[466] = true,
	[542] = true
}

local previewBlockObject = false
local blockObjects = {}
local blockOffsets = {
	[603] = {0, 1.35, 0.35},
	[576] = {0, 1.65, 0.5},
	[561] = {0, 1.75, 0.4},
	[567] = {0, 2.15, 0.2},
	[536] = {0, 1.65, 0.4},
	[527] = {0, 1.5, 0.4},
	[467] = {0, 1.925, 0.55},
	[439] = {0, 1.6, 0.25},
	[426] = {0, 1.8, 0.35},
	[402] = {0, 1.65, 0.35},
	[600] = {0, 1.55, 0.55},
	[605] = {0, 1.925, 0.275},
	[492] = {0, 1.85, 0.45},
	[479] = {0, 1.925, 0.45},
	[466] = {0, 1.925, 0.35},
	[412] = {0, 2, 0.5},
	[410] = {0, 1.55, 0.55},
	[542] = {0, 1.6, 0.35},
	[535] = {0, 1.75, 0.6},
	[517] = {0, 1.925, 0.35}
}

function isHaveSupercharger(vehicleModel)
	return blockOffsets[vehicleModel] and "#3d7abcvan" or "#d75959nincs"
end

buyingInProgress = false

local promptState = false
local promptWidth = respc(600)
local promptHeight = respc(200)
local promptPosX = screenWidth / 2 - promptWidth / 2
local promptPosY = screenHeight / 2 - promptHeight / 2

local buyProgressStart = 0
local buyProgressDuration = 0
local buyProgressText = false
local buyProgressSound = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local txd = engineLoadTXD("files/block.txd")
		engineImportTXD(txd, 2052)
		local dff = engineLoadDFF("files/block.dff")
		engineReplaceModel(dff, 2052)

		for k, v in pairs(getElementsByType("vehicle", getRootElement(), true)) do
			if getElementData(v, "vehicle.tuning.Turbo") == 5 then
				local vehicleModel = getElementModel(v)
				
				if blockOffsets[vehicleModel] then
					blockObjects[v] = createObject(2052, 0, 0, 0)
					
					attachElements(blockObjects[v], v, unpack(blockOffsets[vehicleModel]))
					setElementCollisionsEnabled(blockObjects[v], false)
					
					local x, y, z = getElementPosition(v)

					setElementPosition(v, x, y, z + 0.01)
					setElementPosition(v, x, y, z)
				end
			end
		end
	end)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if blockObjects[source] then
			if isElement(blockObjects[source]) then
				destroyElement(blockObjects[source])
			end

			blockObjects[source] = nil
		end
	end)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if blockObjects[source] then
			if isElement(blockObjects[source]) then
				destroyElement(blockObjects[source])
			end
			
			blockObjects[source] = nil
		end
	end)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if blockObjects[source] then
			if isElement(blockObjects[source]) then
				destroyElement(blockObjects[source])
			end
			
			blockObjects[source] = nil
		end

		if getElementData(source, "vehicle.tuning.Turbo") == 5 then
			local vehicleModel = getElementModel(source)
				
			if blockOffsets[vehicleModel] then
				blockObjects[source] = createObject(2052, 0, 0, 0)
				
				attachElements(blockObjects[source], source, unpack(blockOffsets[vehicleModel]))
				setElementCollisionsEnabled(blockObjects[source], false)
				
				local x, y, z = getElementPosition(source)

				setElementPosition(source, x, y, z + 0.01)
				setElementPosition(source, x, y, z)
			end
		end
	end)

addEvent("toggleTuning", true)
addEventHandler("toggleTuning", getRootElement(),
	function (state)
		panelState = state
		showCursor(state)

		camRotation = 0
		camOffsetZ = 0
		camZoomLevel = 1

		if panelState then
			--setPedControlState(localPlayer, false)
			vehicleElement = getPedOccupiedVehicle(localPlayer)

			if not vehicleElement then
				panelState = false
				return
			end

			createFonts()
			exports.see_hud:hideHUD()

			local vehPosition = {getElementPosition(vehicleElement)}
			local vehRotation = {getElementRotation(vehicleElement)}
			local rotatedX, rotatedY = rotateAround(vehRotation[3], 5, 5)

			camDefPos = {vehPosition[1] + rotatedX, vehPosition[2] + rotatedY, vehPosition[3] + 2.5, vehPosition[1], vehPosition[2], vehPosition[3]}
			camPosition = camDefPos
			camTargetPos = camPosition

			vehicleColor = {getVehicleColor(vehicleElement, true)}
			vehicleLightColor = {getVehicleHeadLightColor(vehicleElement)}

			currentMoney = getElementData(localPlayer, "char.Money") or 0
			currentPP = getElementData(localPlayer, "acc.premiumPoints") or 0

			selectedMenu = 0
			selectedSubMenu = 0
			activeMenu = {}

			selectionLevel = 1
			oldSelectionLevel = selectionLevel
			selectionStart = 0
			selectionPosY = 0
			selectionColor = false
		else
			setPedControlState(localPlayer, "accelerate", false)
			destroyFonts()
			setCameraTarget(localPlayer)
			exports.see_hud:showHUD()
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if source == localPlayer then
			if dataName == "char.Money" then
				local dataValue = getElementData(source, dataName) or 0

				if dataValue < currentMoney then
					moneyChangeValue = currentMoney - dataValue
					moneyChangeTick = getTickCount()
				end

				currentMoney = dataValue
			end

			if dataName == "acc.premiumPoints" then
				local dataValue = getElementData(source, dataName) or 0

				if dataValue < currentPP then
					ppChangeValue = currentPP - dataValue
					ppChangeTick = getTickCount()
				end

				currentPP = dataValue
			end

			if dataName == "loggedIn" then
				for i, veh in ipairs(getElementsByType("vehicle")) do -- MTA bug fix
					local currUpgrades = getElementData(veh, "vehicle.tuning.Optical") or ""
					local currUpgradesTable = split(currUpgrades, ",")

					for k, upgrade in pairs(currUpgradesTable) do
						addVehicleUpgrade(veh, upgrade)
					end
				end
			end
		end

		if dataName == "vehicle.tuning.Turbo" then
			if blockObjects[source] then
				if isElement(blockObjects[source]) then
					destroyElement(blockObjects[source])
				end
				
				blockObjects[source] = nil
			end

			if getElementData(source, "vehicle.tuning.Turbo") == 5 then
				if isElementStreamedIn(source) then
					local vehicleModel = getElementModel(source)
						
					if blockOffsets[vehicleModel] then
						blockObjects[source] = createObject(2052, 0, 0, 0)
						
						attachElements(blockObjects[source], source, unpack(blockOffsets[vehicleModel]))
						setElementCollisionsEnabled(blockObjects[source], false)
						
						local x, y, z = getElementPosition(source)

						setElementPosition(source, x, y, z + 0.01)
						setElementPosition(source, x, y, z)
					end
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if panelState then
			local currentTime = getTickCount()
			local visibleCount = 0
			
			activeMenu = tuningContainer

			if selectedMenu ~= 0 then
				if selectedSubMenu == 0 then
					activeMenu = tuningContainer[selectedMenu].subMenu
				else
					activeMenu = tuningContainer[selectedMenu].subMenu[selectedSubMenu].subMenu
				end
			end

			local currentMenu = activeMenu[selectionLevel]

			if #activeMenu > 8 then
				visibleCount = 8
			else
				visibleCount = #activeMenu
			end

			menuHeight = visibleCount * rowHeight

			-- ** Felső rész
			dxDrawRectangle(0, 0, screenWidth, respc(100), tocolor(0, 0, 0, 160))

			dxDrawImage(respc(20), 0, respc(100), respc(100), "files/logo.png")
			dxDrawText("#3d7abcStrongMTA #ffffff- Tuning", respc(130), respc(20), 0, 0, tocolor(255, 255, 255), 1, Roboto3, "left", "top", false, false, true, true, true)

			if moneyChangeTick + 3000 >= currentTime then
				dxDrawText("#3d7abcKészpénz:#ffffff\n" .. formatNumber(currentMoney) .. " #3d7abc$    #d75959(-" .. formatNumber(moneyChangeValue) .. " $)", screenWidth - respc(300), respc(3), 0, 0, tocolor(255, 255, 255), 1, Roboto4, "left", "top", false, false, true, true, true)
			else
				dxDrawText("#3d7abcKészpénz:#ffffff\n" .. formatNumber(currentMoney) .. " #3d7abc$", screenWidth - respc(300), respc(3), 0, 0, tocolor(255, 255, 255), 1, Roboto4, "left", "top", false, false, true, true, true)
			end

			if ppChangeTick + 3000 >= currentTime then
				dxDrawText("#32b3efPrémium pont:#ffffff\n" .. formatNumber(currentPP) .. " #32b3efPP    #d75959(-" .. formatNumber(ppChangeValue) .. " PP)", screenWidth - respc(300), respc(50), 0, 0, tocolor(255, 255, 255), 1, Roboto4, "left", "top", false, false, true, true, true)
			else
				dxDrawText("#32b3efPrémium pont:#ffffff\n" .. formatNumber(currentPP) .. " #32b3efPP", screenWidth - respc(300), respc(50), 0, 0, tocolor(255, 255, 255), 1, Roboto4, "left", "top", false, false, true, true, true)
			end

			-- ** Alsó rész
			dxDrawRectangle(0, screenHeight - respc(80), screenWidth, respc(80), tocolor(0, 0, 0, 160))

			local hex = ""
			local price = ""

			if currentMenu.priceType and currentMenu.price then
				if currentMenu.priceType == "money" then
					hex = "#3d7abc"
					price = formatNumber(currentMenu.price) .. " $"
				elseif currentMenu.priceType == "premium" then
					hex = "#32b3ef"
					price = formatNumber(currentMenu.price) .. " PP"
				elseif currentMenu.priceType == "free" then
					hex = "#d75959"
					price = "Ingyenes"
				end

				if currentMenu.priceType then
					dxDrawText("Ár: " .. hex .. price, respc(10), screenHeight - respc(75), 0, 0, tocolor(255, 255, 255), 1, Roboto, "left", "top", false, false, true, true, true)
				end
			end

			if currentMenu.hint then
				dxDrawText(currentMenu.hint, respc(10), screenHeight - respc(75) + respc(25), 0, 0, tocolor(255, 255, 255), 1, Roboto4, "left", "top", false, false, true, true, true)
			end

			-- ** Menü háttér
			dxDrawRectangle(menuPosX, menuPosY, menuWidth, menuHeight, tocolor(0, 0, 0, 150))

			-- ** Keret
			dxDrawRectangle(menuPosX, menuPosY, menuWidth, 2, tocolor(0, 0, 0, 200))
			dxDrawRectangle(menuPosX, menuPosY + menuHeight - 2, menuWidth, 2, tocolor(0, 0, 0, 200))
			dxDrawRectangle(menuPosX, menuPosY + 2, 2, menuHeight - 4, tocolor(0, 0, 0, 200))
			dxDrawRectangle(menuPosX + menuWidth - 2, menuPosY + 2, 2, menuHeight - 4, tocolor(0, 0, 0, 200))

			-- ** Content
			local visibleSelection = selectionLevel

			if visibleSelection > 8 then
				visibleSelection = 8
			end

			for i = 0, visibleCount - 1 do
				if (visibleSelection - 1) ~= i and i % 2 ~= 0 then
					dxDrawRectangle(menuPosX, menuPosY + i * rowHeight, menuWidth, rowHeight, tocolor(0, 0, 0, 200))
				end
			end

			local progress = (currentTime - selectionStart) / 150
			local moveY = interpolateBetween(
				selectionPosY, 0, 0,
				(selectionLevel - 1) * rowHeight, 0, 0,
				progress, "OutQuad"
			)

			selectionPosY = moveY

			if selectionPosY > menuHeight - rowHeight then
				selectionPosY = menuHeight - rowHeight
			end

			local col = {61, 122, 188}
		
			if currentMenu.priceType == "free" then
				col = {215, 89, 89}
			elseif currentMenu.priceType == "money" then
				col = {61, 122, 188}
			elseif currentMenu.priceType == "premium" then
				col = {50, 179, 239}
			end

			if not selectionColor then
				selectionColor = col
			end
			
			local r, g, b = interpolateBetween(
				selectionColor[1], selectionColor[2], selectionColor[3],
				col[1], col[2], col[3],
				progress, "OutQuad"
			)

			selectionColor = {r, g, b}
			
			dxDrawRectangle(menuPosX, menuPosY + selectionPosY, menuWidth, rowHeight, tocolor(selectionColor[1], selectionColor[2], selectionColor[3], 200))
			
			local menuOffset = 1

			if selectionLevel > 8 then
				menuOffset = 1 + selectionLevel - 8
			end

			for i = 0, 7 do
				local dat = activeMenu[i + menuOffset]
				
				if dat then
					local rowY = menuPosY + i * rowHeight
					local equipped = false

					if selectedSubMenu > 0 then
						if tuningContainer[selectedMenu].subMenu[selectedSubMenu].clientFunction and dat.value then
							if tuningContainer[selectedMenu].subMenu[selectedSubMenu].clientFunction(vehicleElement, dat.value) then
								equipped = true
							end
						end
					end

					if equipped then
						dxDrawImage(menuPosX + respc(10), rowY + rowHeight / 2 - respc(16), respc(32), respc(32), "files/icons/felszerelt.png")
						dxDrawText(dat.name .. " #32b3ef(Felszerelve)", menuPosX, rowY, menuPosX + menuWidth - respc(20), rowY + rowHeight, tocolor(255, 255, 255), 1, Roboto, "right", "center", false, false, false, true)
					else
						dxDrawImage(menuPosX + respc(10), rowY + rowHeight / 2 - respc(16), respc(32), respc(32), dat.icon)
						dxDrawText(dat.name, menuPosX, rowY, menuPosX + menuWidth - respc(20), rowY + rowHeight, tocolor(255, 255, 255), 1, Roboto, "right", "center", false, false, false, true)
					end
				end
			end

			if #activeMenu > 8 then
				local gripSize = (rowHeight * 8) / #activeMenu
				dxDrawRectangle(menuPosX + menuWidth, menuPosY + (menuOffset - 1) * gripSize, 3, 8 * gripSize, tocolor(255, 255, 255))
			end

			-- ** Rendszám
			if editPlate then
				-- Keret
				dxDrawRectangle(menuPosX, menuPosY + menuHeight, menuWidth, respc(60), tocolor(0, 0, 0, 200))
				dxDrawRectangle(menuPosX, menuPosY + menuHeight, menuWidth, 2, tocolor(0, 0, 0, 200))
				dxDrawRectangle(menuPosX, menuPosY + menuHeight + respc(60) - 2, respc(400), 2, tocolor(0, 0, 0, 200))
				dxDrawRectangle(menuPosX, menuPosY + menuHeight + 2, 2, respc(60) - 4, tocolor(0, 0, 0, 200))
				dxDrawRectangle(menuPosX + menuWidth - 2, menuPosY + menuHeight + 2, 2, respc(60) - 4, tocolor(0, 0, 0, 200))

				-- Háttér
				dxDrawRectangle(menuPosX + respc(10), menuPosY + menuHeight + respc(10), menuWidth - respc(20), respc(40), tocolor(100, 100, 100, 160))

				-- Content
				dxDrawText((getVehiclePlateText(vehicleElement) or ""):upper(), menuPosX + respc(4), menuPosY + menuHeight + respc(14), menuPosX + menuWidth - respc(9), 0, tocolor(255, 255, 255), 1, Roboto2, "center", "top")
			end

			-- ** Variáns
			if variantEditor then
				dxDrawRectangle(menuPosX, menuPosY + menuHeight, menuWidth, respc(60), tocolor(0, 0, 0, 200))
				dxDrawRectangle(menuPosX + menuWidth / 2 - respc(35), menuPosY + menuHeight + respc(10), respc(75), respc(40), tocolor(0, 0, 0, 200))
				dxDrawText(selectedVariant, menuPosX + menuWidth / 2 - respc(25), menuPosY + menuHeight + respc(10), menuPosX + menuWidth / 2 + respc(25), menuPosY + menuHeight + respc(10) + respc(40), tocolor(255, 255, 255), 0.55, Roboto3, "center", "center")
			end

			-- ** Megerősítés
			if promptState then
				dxDrawRectangle(promptPosX, promptPosY, promptWidth, promptHeight, tocolor(0, 0, 0, 150))
		
				dxDrawText("#3d7abcStrongMTA - #FF9600Tuning", promptPosX, promptPosY - respc(20), promptPosX, promptPosY, tocolor(255, 255, 255), 1, Roboto, "left", "center", false, false, false, true)

				dxDrawText("#FFFFFFBiztosan megszeretnéd vásárolni a kiválasztott tuningot?\nA tuning ára: " .. hex .. price, promptPosX, promptPosY + respc(30), promptPosX + promptWidth, 0, tocolor(255, 255, 255), 1, Roboto, "center", "top", false, false, false, true)
				
				dxDrawRectangle(promptPosX + respc(30), promptPosY + promptHeight - respc(80), promptWidth / 2 - respc(60), respc(40), tocolor(215, 89, 89, 200))
				dxDrawText("Mégsem (Backspace)", promptPosX + respc(30), promptPosY + promptHeight - respc(80), promptPosX + respc(30) + promptWidth / 2 - respc(60), promptPosY + promptHeight - respc(40), tocolor(255, 255, 255), 1, Roboto, "center", "center")
			
				dxDrawRectangle(promptPosX + promptWidth / 2 + respc(30), promptPosY + promptHeight - respc(80), promptWidth / 2 - respc(60), respc(40), tocolor(61, 122, 188, 200))
				dxDrawText("Vásárlás (Enter)", promptPosX + promptWidth / 2 + respc(30), promptPosY + promptHeight - respc(80), promptPosX + promptWidth / 2 + respc(30) + promptWidth / 2 - respc(60), promptPosY + promptHeight - respc(40), tocolor(255, 255, 255), 1, Roboto, "center", "center", false, false, false, true)
			end

			-- ** Megvétel állapotsáv
			if buyProgressStart + buyProgressDuration > currentTime then
				local sx, sy = respc(400), respc(30)
				local x = screenWidth / 2 - sx / 2
				local y = screenHeight - respc(120)

				dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 160))
				
				dxDrawRectangle(x, y, reMap(currentTime - buyProgressStart, 0, buyProgressDuration, 0, sx), sy, tocolor(61, 122, 188, 160))
				
				dxDrawText(buyProgressText, x, y, x + sx, y + sy, tocolor(255, 255, 255), 1, Roboto4, "center", "center")
			end

			-- ** Navigációs segédlet
			local startX = screenWidth - respc(582)
			local startY = math.floor(screenHeight - respc(75))

			dxDrawImage(math.floor(startX), startY, respc(128), respc(32), "files/nav/enter.png")
			dxDrawText("Vásárlás", startX + respc(66), startY, 0, startY + respc(32), tocolor(255, 255, 255), 1, Roboto4, "left", "center")
			
			dxDrawImage(math.floor(startX + respc(130)), startY, respc(128), respc(32), "files/nav/backspace.png")
			dxDrawText("Kilépés", startX + respc(216), startY, 0, startY + respc(32), tocolor(255, 255, 255), 1, Roboto4, "left", "center")
			
			dxDrawImage(math.floor(startX + respc(268)), startY, respc(32), respc(32), "files/nav/up.png")
			dxDrawImage(math.floor(startX + respc(300)), startY, respc(32), respc(32), "files/nav/down.png")
			dxDrawText("Navigáció", startX + respc(336), startY, 0, startY + respc(32), tocolor(255, 255, 255), 1, Roboto4, "left", "center")
			
			dxDrawImage(math.floor(startX + respc(408)), startY, respc(32), respc(32), "files/nav/mouse.png")
			dxDrawText("Kamera mozgatás", startX + respc(442), startY, 0, startY + respc(32), tocolor(255, 255, 255), 1, Roboto4, "left", "center")
		end
	end)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if panelState then
			if key ~= "escape" and key ~= "l" then
				cancelEvent()
			end

			if not press then
				return
			end

			if isCursorShowing() and not isMTAWindowActive() then
				if (key == "mouse_wheel_up" or key == "mouse_wheel_down") and not camZoomStart and not camMoveStart and not buyingInProgress then
					if key == "mouse_wheel_down" then
						if camZoomLevel > 1 and camView == "base" or camZoomLevel > 0.75 and camView ~= "base" then
							local val = camZoomLevel - 0.2 * camZoomLevel

							if camView ~= "base" then
								if val < 0.75 then
									val = 0.75
								end
							elseif val < 1 then
								val = 1
							end
							
							camZoomInterpolation = {camZoomLevel, val}
							camZoomStart = getTickCount()
						end
					elseif camZoomLevel <= 3 then
						camZoomInterpolation = {camZoomLevel, camZoomLevel + 0.2 * camZoomLevel}
						camZoomStart = getTickCount()
					end
				end
			end

			if activeColorInput then
				cancelEvent()
				return
			end

			if buyingInProgress or buyProgressStart + buyProgressDuration > getTickCount() then
				return
			end

			if key == "enter" then
				if promptState then
					buyTuning()
					promptState = false
					playSound("files/sounds/promptaccept.mp3")
					return
				end

				local currentMenu = activeMenu[selectionLevel]

				if selectedMenu == 0 then
					if currentMenu.subMenu then
						selectedMenu = selectionLevel
						oldSelectionLevel = selectionLevel
						selectionLevel = 1

						if tuningContainer[selectedMenu].subMenu[selectionLevel].colorPicker then
							colorPicker = true
							colorX = false
						else
							colorPicker = false
						end

						playSound("files/sounds/menuselect.mp3")
					end
				else
					if selectedSubMenu == 0 then
						if variantEditor then
							confirmTuning()
							return
						end

						if currentMenu.handlingPrefix == "WHEEL_F_" or currentMenu.handlingPrefix == "WHEEL_R_" then
							if getElementData(vehicleElement, "tuningSpinners") then
								exports.see_accounts:showInfo("e", "Előbb szereld le a spinnert!")
								return
							end
						end

						if currentMenu.isTheWheelTuning then
							if (getElementData(vehicleElement, "vehicle.currentWheelTexture") or 0) ~= 0 then
								exports.see_accounts:showInfo("e", "Előbb vedd le a kerék paintjobot!")
								return
							end
						end

						if currentMenu.isSpinner then
							if not spinnerVehicles[getElementModel(vehicleElement)] or getVehicleType(vehicleElement) ~= "Automobile" then
								exports.see_accounts:showInfo("e", "Ez az alkatrész nem kompatibilis a járműveddel!")
								return
							end

							local flagsKeyed = getVehicleHandlingFlags(vehicleElement)

							for flag in pairs(flagsKeyed) do
								if string.sub(flag, 1, 6) == "WHEEL_" then
									exports.see_accounts:showInfo("e", "Előbb szereld át a kerekeid szélességét normálra!")
									return
								end
							end

							exports.see_spinner:getSizeForPreview(vehicleElement)
							exports.see_spinner:setPreviewColor(vehicleElement, colorInputs.r, colorInputs.g, colorInputs.b)
							exports.see_spinner:previewSpinner(vehicleElement, currentMenu.subMenu[1].value, currentMenu.subMenu[1].colorPicker)
						end

						if currentMenu.variantEditor then
							variantEditor = true
							selectedVariant = getElementData(vehicleElement, "vehicle.variant") or 0
							triggerServerEvent("previewVariant", vehicleElement, selectedVariant)
							return
						else
							variantEditor = false
						end

						if currentMenu.upgradeSlot then
							local upgrades = getVehicleCompatibleUpgrades(vehicleElement, currentMenu.upgradeSlot)

							currentMenu.subMenu = {}

							if upgrades and #upgrades > 0 then
								table.insert(currentMenu.subMenu, {
									name = "Gyári",
									icon = currentMenu.icon,
									priceType = "free",
									price = 0,
									value = 0
								})

								for k, v in ipairs(upgrades) do
									local name = currentMenu.name .. " " .. k

									if componentNames[v] then
										name = componentNames[v]
									end

									table.insert(currentMenu.subMenu, {
										name = name,
										icon = currentMenu.icon,
										priceType = currentMenu.priceType,
										price = currentMenu.price,
										value = v
									})
								end
							else
								currentMenu.subMenu = false
							end
						end

						if currentMenu.id == "color" then
							colorPicker = true
							colorX = false
						end

						if currentMenu.id == "paintjob" then
							local textureCount = exports.see_paintjob:getPaintJobCount(getElementModel(vehicleElement))

							currentMenu.subMenu = {}

							if textureCount and textureCount > 0 then
								table.insert(currentMenu.subMenu, {
									name = "Gyári",
									icon = "files/icons/free.png",
									priceType = "free",
									price = 0,
									value = 0
								})

								for i = 1, textureCount do
									table.insert(currentMenu.subMenu, {
										name = "Paintjob " .. i,
										icon = "files/icons/pp.png",
										priceType = "premium",
										price = 1000,
										value = i
									})
								end
							else
								currentMenu.subMenu = false
							end
						end

						if currentMenu.id == "wheelPaintjob" then
							local textureCount = exports.see_wheeltexture:getWheelTextureCount(vehicleElement)

							currentMenu.subMenu = {}

							if textureCount and textureCount > 0 then
								table.insert(currentMenu.subMenu, {
									name = "Nincs",
									icon = "files/icons/free.png",
									priceType = "free",
									price = 0,
									value = 0
								})

								for i = 1, textureCount do
									table.insert(currentMenu.subMenu, {
										name = "Paintjob " .. i,
										icon = "files/icons/pp.png",
										priceType = "premium",
										price = 1500,
										value = i
									})
								end
							else
								currentMenu.subMenu = false
							end
						end

						if currentMenu.id == "headlight" then
							local textureCount = exports.see_headlight:getHeadLightCount(getElementModel(vehicleElement))

							currentMenu.subMenu = {}

							if textureCount and textureCount > 0 then
								table.insert(currentMenu.subMenu, {
									name = "Gyári",
									icon = "files/icons/free.png",
									priceType = "free",
									price = 0,
									value = 0,
									hint = "Vásárlás előtt ajánlott fel- és lekapcsolt lámpával is megtekinteni a járművet. (L gomb)"
								})

								for i = 1, textureCount do
									table.insert(currentMenu.subMenu, {
										name = "Fényszóró " .. i,
										icon = "files/icons/pp.png",
										priceType = "premium",
										price = 1200,
										value = i,
										hint = "Vásárlás előtt ajánlott fel- és lekapcsolt lámpával is megtekinteni a járművet. (L gomb)"
									})
								end
							else
								currentMenu.subMenu = false
							end
						end

						if currentMenu.subMenu then
							selectedSubMenu = selectionLevel
							oldSelectionLevel = selectionLevel
							selectionLevel = 1
							playSound("files/sounds/menuselect.mp3")

							if currentMenu.camera then
								changeCamera(currentMenu.camera)
							end

							installPreviewTuning()
						elseif currentMenu.id == "color" then
							confirmTuning()
						else
							exports.see_accounts:showInfo("e", "Sajnos a kiválasztott alkatrész nem kompatibilis a járműveddel!")
						end
					else
						if currentMenu.supercharger then
							if not blockOffsets[getElementModel(vehicleElement)] then
								exports.see_accounts:showInfo("e", "Ezzel az autóval nem kompatibilis a supercharger.")
								return
							end
						end

						confirmTuning()
					end
				end
			end

			if key == "backspace" then
				if promptState then
					promptState = false
					playSound("files/sounds/promptdecline.mp3")
					return
				end

				local currentMenu = activeMenu[selectionLevel]

				if selectedMenu > 0 then
					if variantEditor then
						variantEditor = false
						triggerServerEvent("previewVariant", vehicleElement, false)
						return
					end

					if editPlate then
						local plateText = getVehiclePlateText(vehicleElement) or ""

						if utfLen(plateText) >= 1 then
							setVehiclePlateText(vehicleElement, utf8.sub(plateText, 1, -2))
						end

						return
					end

					togglePlateEdit(false)

					if currentMenu.id == "color" or currentMenu.colorPicker then
						setVehicleColor(vehicleElement, vehicleColor[1], vehicleColor[2], vehicleColor[3], vehicleColor[4], vehicleColor[5], vehicleColor[6], vehicleColor[7], vehicleColor[8], vehicleColor[9], vehicleColor[10], vehicleColor[11], vehicleColor[12])
						setVehicleHeadLightColor(vehicleElement, vehicleLightColor[1], vehicleLightColor[2], vehicleLightColor[3])
						triggerEvent("resetSpeedoColor", vehicleElement)
					end
					
					if selectedSubMenu > 0 then
						changeCamera("base")
						restorePreviewTuning()

						selectionLevel = selectedSubMenu
						selectedSubMenu = 0
					else
						selectionLevel = selectedMenu
						selectedMenu = 0
					end

					colorPicker = false
					colorX = false
				else
					triggerServerEvent("exitTuning", localPlayer)
				end

				playSound("files/sounds/menuback.mp3")
			end

			if key == "arrow_u" then
				if promptState then
					return
				end

				if variantEditor then
					if getTickCount() - lastVariantChange >= 250 then
						selectedVariant = selectedVariant + 1
						
						if selectedVariant > 6 then
							selectedVariant = 0
						end

						triggerServerEvent("previewVariant", vehicleElement, selectedVariant)

						lastVariantChange = getTickCount()
					end

					return
				end
					
				if selectionLevel > 1 then
					selectionStart = getTickCount()
					selectionLevel = selectionLevel - 1
					playSound("files/sounds/menunavigate.mp3")

					if selectedSubMenu > 0 then
						installPreviewTuning()
					end
				end
			end

			if key == "arrow_d" then
				if promptState then
					return
				end

				if variantEditor then
					if getTickCount() - lastVariantChange >= 250 then
						selectedVariant = selectedVariant - 1
						
						if selectedVariant < 0 then
							selectedVariant = 6
						end

						triggerServerEvent("previewVariant", vehicleElement, selectedVariant)

						lastVariantChange = getTickCount()
					end

					return
				end

				if selectionLevel < #activeMenu then
					selectionStart = getTickCount()
					selectionLevel = selectionLevel + 1
					playSound("files/sounds/menunavigate.mp3")
					
					if selectedSubMenu > 0 then
						installPreviewTuning()
					end
				end
			end
		end
	end)

addEventHandler("onClientCharacter", getRootElement(),
	function (character)
		if panelState and editPlate then
			if string.find(character, "[a-z]") or string.find(character, "[0-9]") or character == "-" then
				local plateText = getVehiclePlateText(vehicleElement) or ""

				if utfLen(plateText) < 8 then
					setVehiclePlateText(vehicleElement, plateText .. character:upper())
				end
			end
		end
	end)

function togglePlateEdit(state)
	editPlate = state

	if editPlate then
		if not originalPlate then
			originalPlate = getVehiclePlateText(vehicleElement) or ""
		end
	elseif originalPlate then
		setVehiclePlateText(vehicleElement, originalPlate)
		originalPlate = false
	end
end

function confirmTuning()
	if panelState and not buyingInProgress and not promptState then
		promptState = true
		playSound("files/sounds/prompt.mp3")
	end
end

function buyTuning()
	if panelState and not buyingInProgress and promptState then
		if variantEditor then
			variantEditor = false
			buyingInProgress = true
			triggerServerEvent("buyVariantTuning", localPlayer, selectedVariant, tuningContainer[selectedMenu].subMenu[selectionLevel].price)
			return
		end

		if selectedSubMenu > 0 then
			local mainMenu = tuningContainer[selectedMenu]
			local subMenu = mainMenu.subMenu[selectedSubMenu]
			local currentSelection = subMenu.subMenu[selectionLevel]

			if currentSelection.isSpinnerItem then
				local r, g, b, sx, sy, sz = exports.see_spinner:getPreviewColor()
				triggerServerEvent("buySpinnerTuning", localPlayer, currentSelection.value, r, g, b, sx, sy, sz, currentSelection.colorPicker, currentSelection.price)
				buyingInProgress = true
			elseif subMenu.upgradeSlot then
				triggerServerEvent("buyOpticalTuning", localPlayer, subMenu.upgradeSlot, currentSelection.value, currentSelection.priceType, currentSelection.price)
				buyingInProgress = true
			elseif subMenu.id == "paintjob" then
				triggerServerEvent("buyPaintjob", localPlayer, currentSelection.value, currentSelection.priceType, currentSelection.price)
				buyingInProgress = true
			elseif subMenu.id == "wheelPaintjob" then
				triggerServerEvent("buyWheelPaintjob", localPlayer, currentSelection.value, currentSelection.priceType, currentSelection.price)
				buyingInProgress = true
			elseif subMenu.id == "headlight" then
				triggerServerEvent("buyHeadLight", localPlayer, currentSelection.value, currentSelection.priceType, currentSelection.price)
				buyingInProgress = true
			elseif subMenu.id == "color" then
				local currVehColor = {getVehicleColor(vehicleElement, true)}
				local currLightColor = {getVehicleHeadLightColor(vehicleElement)}

				if not compareTables(vehicleColor, currVehColor) or not compareTables(vehicleLightColor, currLightColor) or currentSelection.colorId >= 7 then
					triggerServerEvent("buyColor", localPlayer, currentSelection.colorId, currVehColor, currLightColor, subMenu.priceType, subMenu.price)
					buyingInProgress = true
				else
					exports.see_accounts:showInfo("e", "A kiválasztott szín nem lehet ugyan az, mint a jelenlegi.")
					buyingInProgress = false
				end
			elseif subMenu.id == "licensePlate" then
				local plateText = getVehiclePlateText(vehicleElement)

				if plateText then
					triggerServerEvent("buyLicensePlate", localPlayer, currentSelection.value, plateText, currentSelection.priceType, currentSelection.price)
					buyingInProgress = true
				else
					exports.see_accounts:showInfo("e", "A jármű nem maradhat rendszám nélkül!")
					buyingInProgress = false
					togglePlateEdit(false)
				end
			else
				local isTheOriginal = false

				if selectedSubMenu > 0 then
					if subMenu.clientFunction and currentSelection.value then
						if subMenu.clientFunction(vehicleElement, currentSelection.value) then
							isTheOriginal = true
						end
					end
				end

				triggerServerEvent("buyTuning", localPlayer, selectedMenu, selectedSubMenu, selectionLevel, isTheOriginal)
				buyingInProgress = true
			end
		elseif selectedMenu > 0 then
			local mainMenu = tuningContainer[selectedMenu]
			local currentSelection = mainMenu.subMenu[selectionLevel]

			if currentSelection.id == "color" then
				local currVehColor = {getVehicleColor(vehicleElement, true)}
				local currLightColor = {getVehicleHeadLightColor(vehicleElement)}

				if not compareTables(vehicleColor, currVehColor) or not compareTables(vehicleLightColor, currLightColor) or currentSelection.colorId >= 7 then
					triggerServerEvent("buyColor", localPlayer, currentSelection.colorId, currVehColor, currLightColor, currentSelection.priceType, currentSelection.price)
					buyingInProgress = true
				else
					exports.see_accounts:showInfo("e", "A kiválasztott szín nem lehet ugyan az, mint a jelenlegi.")
					buyingInProgress = false
				end
			end
		end
	end
end

function compareTables(t1, t2)
	if #t1 ~= #t2 then
		return false
	end

	for i = 1, #t1 do
		if t1[i] ~= t2[i] then
			return false
		end
	end

	return true
end

addEvent("buyTuning", true)
addEventHandler("buyTuning", getRootElement(),
	function (state, item, value)
		if state == "success" then
			if item == "neon" then
				neonId = value
			end

			if item == "handling" then
				originalHandling = value
			end

			if item == "door" then
				originalDoor = value
			end

			if not value or value == 0 then
				startBuyProgress("newpart", "Leszerelés...")
			else
				startBuyProgress("newpart", "Felszerelés...")
			end
		elseif state == "failed" then
		end

		buyingInProgress = false
	end)

addEvent("buyOpticalTuning", true)
addEventHandler("buyOpticalTuning", getRootElement(),
	function (state, upgrade)
		if state == "success" then
			if upgrade then
				originalUpgrade = upgrade

				if upgrade == 0 then
					startBuyProgress("newpart", "Leszerelés...")
				else
					startBuyProgress("newpart", "Felszerelés...")
				end
			end
		end

		buyingInProgress = false
	end)

addEvent("buyVariant", true)
addEventHandler("buyVariant", getRootElement(),
	function (state)
		if state == "success" then
			startBuyProgress("newpart", "Felszerelés...")
		elseif state == "successdown" then
			startBuyProgress("newpart", "Leszerelés...")
		end

		buyingInProgress = false
	end)

addEvent("buySpinner", true)
addEventHandler("buySpinner", getRootElement(),
	function (state, value)
		if state == "success" then
			startBuyProgress("newpart", "Felszerelés...")
		elseif state == "successdown" then
			startBuyProgress("newpart", "Leszerelés...")
		end

		buyingInProgress = false
	end)

addEvent("buyPaintjob", true)
addEventHandler("buyPaintjob", getRootElement(),
	function (state, value)
		if state == "success" then
			if value then
				originalPaintjob = value
			end

			exports.see_paintjob:applyPaintJob(value, true)

			startBuyProgress("paint", "Festés...")
		end

		buyingInProgress = false
	end)

addEvent("buyWheelPaintjob", true)
addEventHandler("buyWheelPaintjob", getRootElement(),
	function (state, value)
		if state == "success" then
			if value then
				originalWheelPaintjob = value
			end

			exports.see_wheeltexture:applyWheelTexture(value, true)

			startBuyProgress("paint", "Festés...")
		end

		buyingInProgress = false
	end)

addEvent("buyHeadLight", true)
addEventHandler("buyHeadLight", getRootElement(),
	function (state, value)
		if state == "success" then
			if value then
				originalHeadLight = value
			end

			exports.see_headlight:applyHeadLight(value, true)

			startBuyProgress("newpart", "Felszerelés...")
		end

		buyingInProgress = false
	end)

addEvent("buyColor", true)
addEventHandler("buyColor", getRootElement(),
	function (state, bodyColor, lightColor)
		if state == "success" then
			if not compareTables(bodyColor, vehicleColor) then
				vehicleColor = bodyColor
				startBuyProgress("paint", "Festés...")
			end

			if not compareTables(lightColor, vehicleLightColor) then
				vehicleLightColor = lightColor
				startBuyProgress("newpart", "Izzó cseréje...")
			end
		end

		buyingInProgress = false
	end)

addEvent("buyLicensePlate", true)
addEventHandler("buyLicensePlate", getRootElement(),
	function (state, value)
		if state == "success" then
			if value then
				originalPlate = value
			end

			startBuyProgress("newpart", "Felszerelés...")
			togglePlateEdit(false)
		end

		buyingInProgress = false
	end)

function startBuyProgress(typ, text)
	if isElement(buyProgressSound) then
		destroyElement(buyProgressSound)
	end

	buyProgressStart = getTickCount()
	buyProgressText = text

	if typ == "newpart" then
		buyProgressDuration = 6000
	elseif typ == "paint" then
		buyProgressDuration = 8250
	end

	buyProgressSound = playSound("files/sounds/" .. typ .. ".mp3", false)
end

function installPreviewTuning()
	local currentMenu = tuningContainer[selectedMenu].subMenu[selectedSubMenu]
	local currentSelection = currentMenu.subMenu[selectionLevel]

	if currentMenu.upgradeSlot then
		local upgrade = getVehicleUpgradeOnSlot(vehicleElement, currentMenu.upgradeSlot)

		if upgrade and upgrade > 0 then
			removeVehicleUpgrade(vehicleElement, upgrade)

			if not originalUpgrade then
				originalUpgrade = upgrade
			end
		elseif not originalUpgrade then
			originalUpgrade = 0
		end

		if currentSelection.value and currentSelection.value > 0 then
			addVehicleUpgrade(vehicleElement, currentMenu.subMenu[selectionLevel].value)
		end
	end

	if currentMenu.id == "handling" and currentMenu.handlingPrefix then
		if not originalHandling then
			originalHandling = getVehicleHandling(vehicleElement)["handlingFlags"]
		end

		if currentSelection.value then
			local flagsKeyed, flagBytes = getVehicleHandlingFlags(vehicleElement)

			for flag in pairs(flagsKeyed) do
				if string.find(flag, currentMenu.handlingPrefix) then
					flagBytes = flagBytes - handlingFlags[flag]
				end
			end

			if currentSelection.value ~= "NORMAL" then
				flagBytes = flagBytes + handlingFlags[currentMenu.handlingPrefix .. currentSelection.value]
			end

			triggerServerEvent("setVehicleHandling", localPlayer, "handlingFlags", flagBytes)
		end
	end

	if currentMenu.id == "color" or currentSelection.colorPicker then
		setVehicleColor(vehicleElement, vehicleColor[1], vehicleColor[2], vehicleColor[3], vehicleColor[4], vehicleColor[5], vehicleColor[6], vehicleColor[7], vehicleColor[8], vehicleColor[9], vehicleColor[10], vehicleColor[11], vehicleColor[12])
		setVehicleHeadLightColor(vehicleElement, vehicleLightColor[1], vehicleLightColor[2], vehicleLightColor[3])
		triggerEvent("resetSpeedoColor", vehicleElement)
	end

	if currentSelection.colorPicker then
		colorPicker = true
		colorX = false
	else
		colorPicker = false
	end

	if currentMenu.id == "neon" then
		if not neonId then
			neonId = getElementData(vehicleElement, "tuning.neon") or 0
		end

		if not neonState then
			neonState = getElementData(vehicleElement, "tuning.neon.state") or 0
		end

		setElementData(vehicleElement, "tuning.neon", currentSelection.value, false)
		setElementData(vehicleElement, "tuning.neon.state", 1, false)
	end

	if currentSelection.isSpinnerItem then
		if colorPicker then
			exports.see_spinner:setPreviewColor(vehicleElement, colorInputs.r, colorInputs.g, colorInputs.b)
			exports.see_spinner:previewSpinner(vehicleElement, currentSelection.value, true)
		else
			exports.see_spinner:previewSpinner(vehicleElement, currentSelection.value)
		end
	end

	if isElement(previewBlockObject) then
		destroyElement(previewBlockObject)
	end
	
	previewBlockObject = nil

	if currentSelection.supercharger then
		local vehicleModel = getElementModel(vehicleElement)

		if blockOffsets[vehicleModel] then
			previewBlockObject = createObject(2052, 0, 0, 0)
			
			attachElements(previewBlockObject, vehicleElement, unpack(blockOffsets[vehicleModel]))
			setElementCollisionsEnabled(previewBlockObject, false)
			
			local x, y, z = getElementPosition(vehicleElement)

			setElementPosition(vehicleElement, x, y, z + 0.01)
			setElementPosition(vehicleElement, x, y, z)
		end
	end

	if currentMenu.id == "door" then
		if not originalDoor then
			originalDoor = getElementData(vehicleElement, "vehicle.tuning.DoorType") or 0
		end

		setElementData(vehicleElement, "vehicle.tuning.DoorType", currentSelection.value, false)

		if not currentSelection.value then
			setVehicleDoorOpenRatio(vehicleElement, 2, 0, 500)
			setVehicleDoorOpenRatio(vehicleElement, 3, 0, 500)
		else
			setVehicleDoorOpenRatio(vehicleElement, 2, 1, 500)
			setVehicleDoorOpenRatio(vehicleElement, 3, 1, 500)
		end
	end

	if currentMenu.id == "paintjob" then
		if not originalPaintjob then
			originalPaintjob = getElementData(vehicleElement, "vehicle.tuning.Paintjob")
		end

		if currentSelection.value then
			exports.see_paintjob:applyPaintJob(currentSelection.value, false)
		end
	end

	if currentMenu.id == "wheelPaintjob" then
		if not originalWheelPaintjob then
			originalWheelPaintjob = getElementData(vehicleElement, "vehicle.tuning.WheelPaintjob")
		end

		if currentSelection.value then
			exports.see_wheeltexture:applyWheelTexture(currentSelection.value, false)
		end
	end

	if currentMenu.id == "headlight" then
		if not originalHeadLight then
			originalHeadLight = getElementData(vehicleElement, "vehicle.tuning.HeadLight")
		end

		if currentSelection.value then
			exports.see_headlight:applyHeadLight(currentSelection.value, false)
		end
	end

	if currentSelection.licensePlate then
		togglePlateEdit(true)
	else
		togglePlateEdit(false)
	end

	if currentMenu.hornSound then
		if isElement(previewHorn) then
			destroyElement(previewHorn)
		end

		if currentSelection.value > 0 then
			previewHorn = playSound(":see_customhorn/horns/" .. currentSelection.value .. ".mp3")
		end
	end
end

function restorePreviewTuning()
	local currentMenu = tuningContainer[selectedMenu].subMenu[selectedSubMenu]

	if currentMenu.upgradeSlot then
		local upgrade = getVehicleUpgradeOnSlot(vehicleElement, currentMenu.upgradeSlot)

		if upgrade and upgrade > 0 then
			removeVehicleUpgrade(vehicleElement, upgrade)
		end

		if originalUpgrade and originalUpgrade > 0 then
			addVehicleUpgrade(vehicleElement, originalUpgrade)
		end
	end

	if currentMenu.id == "handling" and originalHandling then
		triggerServerEvent("setVehicleHandling", localPlayer, "handlingFlags", originalHandling)
	end

	if currentMenu.id == "neon" then
		if neonState then
			setElementData(vehicleElement, "tuning.neon.state", neonState)
			neonState = false
		end

		if neonId then
			setElementData(vehicleElement, "tuning.neon", neonId)
			neonId = false
		end
	end

	if currentMenu.isSpinner then
		exports.see_spinner:resetSpinner(vehicleElement)
	end

	if currentMenu.id == "door" then
		setVehicleDoorOpenRatio(vehicleElement, 2, 0, 500)
		setVehicleDoorOpenRatio(vehicleElement, 3, 0, 500)

		if not originalDoor or originalDoor == 0 then
			setElementData(vehicleElement, "vehicle.tuning.DoorType", false, false)
		else
			setElementData(vehicleElement, "vehicle.tuning.DoorType", originalDoor, false)
		end
	end

	if currentMenu.id == "paintjob" then
		setElementData(vehicleElement, "vehicle.tuning.Paintjob", originalPaintjob)
	end

	if currentMenu.id == "wheelPaintjob" then
		setElementData(vehicleElement, "vehicle.tuning.WheelPaintjob", originalWheelPaintjob)
	end

	if currentMenu.id == "headlight" then
		setElementData(vehicleElement, "vehicle.tuning.HeadLight", originalHeadLight)
	end

	if isElement(previewBlockObject) then
		destroyElement(previewBlockObject)
	end

	if isElement(previewHorn) then
		destroyElement(previewHorn)
	end

	previewHorn = nil
	previewBlockObject = nil
	originalUpgrade = false
	originalHandling = false
	originalDoor = false
	originalPaintjob = false
	originalWheelPaintjob = false
	originalHeadLight = false
end

function formatNumber(amount, stepper)
	if not tonumber(amount) then return amount end
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end

function setCameraMatrixRotated(x, y, z, cx, cy, cz)
	camPosition = {x, y, z, cx, cy, cz}

	if not tonumber(camRotation) then
		camRotation = 0
	end

	if not tonumber(camOffsetZ) then
		camOffsetZ = 0
	end

	if not tonumber(camZoomLevel) then
		camZoomLevel = 1
	end

	x, y = rotateAround(camRotation + 10, x - cx, y - cy, cx, cy)

	setCameraMatrix(x, y, z + camOffsetZ, cx, cy, cz, 0, 70 / (camZoomLevel or 1))
end

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		if panelState then
			if not tonumber(camRotation) then
				camRotation = 0
			end

			if not tonumber(camOffsetZ) then
				camOffsetZ = 0
			end

			if getKeyState("mouse1") and not camMoveStart and not isMTAWindowActive() and not isColorPicking and not isLuminancePicking then
				local cursorX, cursorY = getCursorPosition()

				if not lastCursorPos then
					lastCursorPos = {cursorX, cursorY, camRotation, camOffsetZ}
				end
				
				camRotation = lastCursorPos[3] - (cursorX - lastCursorPos[1]) / screenWidth * 270
				camOffsetZ = lastCursorPos[4] + (cursorY - lastCursorPos[2]) / screenHeight * 10
				
				if camRotation > 360 then
					camRotation = camRotation - 360
				elseif camRotation < 0 then
					camRotation = camRotation + 360
				end
				
				if camOffsetZ < -2 then
					camOffsetZ = -2
				elseif camOffsetZ > 2 then
					camOffsetZ = 2
				end
			else
				lastCursorPos = false
			end

			if camZoomStart and not camMoveStart then
				local progress = (getTickCount() - camZoomStart) / 150

				camZoomLevel = interpolateBetween(
					camZoomInterpolation[1], 0, 0,
					camZoomInterpolation[2], 0, 0,
					progress, "InOutQuad"
				)
				
				if progress >= 1 then
					camZoomStart = false
				end
			end

			if camMoveStart then
				local progress = (getTickCount() - camMoveStart) / 600
				
				local x, y, z = interpolateBetween(
					camStartPos[1], camStartPos[2], camStartPos[3],
					camTargetPos[1], camTargetPos[2], camTargetPos[3],
					progress, "InOutQuad"
				)

				local cx, cy, cz = interpolateBetween(
					camStartPos[4], camStartPos[5], camStartPos[6],
					camTargetPos[4], camTargetPos[5], camTargetPos[6],
					progress, "InOutQuad"
				)
				
				camOffsetZ, camZoomLevel = interpolateBetween(
					camStartPos[8], camStartPos[9], 0,
					0, 1, 0,
					progress, "InOutQuad"
				)

				camRotation = getShortestAngle(camStartPos[7], 0, getEasingValue(progress, "InOutQuad"))
				
				setCameraMatrixRotated(x, y, z, cx, cy, cz)
				
				if progress >= 1 then
					camMoveStart = false
					camZoomStart = false
				end
			else
				setCameraMatrixRotated(unpack(camPosition))
			end
		end
	end)

function getShortestAngle(start, stop, amount)
	local shortest_angle = ((((stop - start) % 360) + 540) % 360) - 180
	return start + (shortest_angle * amount) % 360
end

function shallowcopy(t)
	if type(t) ~= "table" then
		return t
	end
	
	local target = {}

	for k, v in pairs(t) do
		target[k] = v
	end

	return target
end

function changeCamera(view)
	if not view or camView == view then
		return
	end
	
	local component = string.gsub(view, "_excomp", "")
	
	camStartPos = shallowcopy(camPosition)
	camStartPos[7] = camRotation
	camStartPos[8] = camOffsetZ
	camStartPos[9] = camZoomLevel
	
	if view == "base" then
		camTargetPos = camDefPos
	elseif view == "lightpaint" then
		local vehPosX, vehPosY, vehPosZ = getElementPosition(vehicleElement)
		local vehRotX, vehRotY, vehRotZ = getElementRotation(vehicleElement)
		local rotatedX, rotatedY = rotateAround(vehRotZ, 0, 10)
		
		camTargetPos = {vehPosX + rotatedX, vehPosY + rotatedY, vehPosZ, vehPosX, vehPosY, vehPosZ}
	elseif component then
		if getVehicleComponents(vehicleElement)[component] then
			local componentX, componentY, componentZ = getVehicleComponentPosition(vehicleElement, component, "world")
			local vehRotX, vehRotY, vehRotZ = getElementRotation(vehicleElement)

			local offsets = componentOffsets[view]
			local x, y = rotateAround(vehRotZ, offsets[1], offsets[2], componentX, componentY)
			local cx, cy = rotateAround(vehRotZ, offsets[4], offsets[5], componentX, componentY)

			camTargetPos = {x, y, componentZ + offsets[3], cx, cy, componentZ + offsets[6]}
		end
	end
	
	if view == "base" then
		for k in pairs(getVehicleComponents(vehicleElement)) do
			setVehicleComponentVisible(vehicleElement, k, true)
		end
		
		exports.see_drm:hideComponent(vehicleElement)
	else
		local component = tuningContainer[selectedMenu].subMenu[selectedSubMenu].hideComponent

		if component then
			setVehicleComponentVisible(vehicleElement, component, false)
		end
	end
	
	if view ~= camView then
		playSound("files/sounds/cammove.mp3")
	end
	
	camMoveStart = getTickCount()
	camView = view
end

local getCursorPositionEx = getCursorPosition
function getCursorPosition()
	if isCursorShowing() then
		local cursorX, cursorY = getCursorPositionEx()
		return cursorX * screenWidth, cursorY * screenHeight
	else
		return 0, 0
	end
end