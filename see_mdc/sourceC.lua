local getZoneNameEx = getZoneName

function getZoneName(x, y, z, cities)
	local zone = getZoneNameEx(x, y, z, cities)

	if zone == "Greenglass College" then
		return "Las Venturas City Hall"
	end

	return zone
end

local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local renderData = {}

local buttons = {}
local activeButton = false

local fakeInputValue = {}
local activeFakeInput = false
local caretIndex = false
local repeatTimer = false
local repeatStartTimer = false
local inputError = false
local inputErrorText = ""

local mdcVehicles = {
	[597] = true,
	[596] = true,
	[497] = true,
	[598] = true,
	[427] = true,
	[599] = true,
	[601] = true,
	[490] = true,
	[528] = true,
	[604] = true,
	[470] = true,
	[332] = true,
}

local groupPrefixes = {
	[1] = "LVMPD",
	[26] = "SWAT",
	[13] = "SASD",
	[12] = "FBI",
	[18] = "USSOF"
}

local availableTabs = {
	{
		name = "wantedCars",
		title = "Körözött járművek"
	},
	{
		name = "wantedPeople",
		title = "Körözött személyek"
	},
	{
		name = "punishedPeople",
		title = "Büntetések"
	},
	{
		name = "btk",
		title = "BTK"
	}
}

local panelState = false

local Roboto = false
local RobotoB = false
local RobotoL = false

local loggedInMDC = false
local currentPage = "login"

local lastVehicle = false

function createFonts()
	destroyFonts()

	Roboto = dxCreateFont("files/fonts/Roboto.ttf", respc(14), false, "antialiased")
	RobotoL = dxCreateFont("files/fonts/RobotoL.ttf", respc(15), false, "antialiased")
	RobotoB = dxCreateFont("files/fonts/RobotoB.ttf", respc(32), false, "antialiased")
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

	if isElement(RobotoB) then
		destroyElement(RobotoB)
	end
	RobotoB = nil
end


function policeMessage(text)
	outputChatBox("#3d7abc[StrongMTA - Rendőrség]:#FFFFFF " .. text, 255, 255, 255, true)
end

local mdcNotifications = true

addCommandHandler("togmdcmsg",
	function ()
		if exports.see_groups:isPlayerOfficer(localPlayer) then
			if mdcNotifications then
				policeMessage("Sikeresen kikapcsoltad az MDC értesítéseket!")
				mdcNotifications = false
			else
				policeMessage("Sikeresen bekapcsoltad az MDC értesítéseket!")
				mdcNotifications = true
			end
		end
	end)

addEvent("mdcAlertFromServer", true)
addEventHandler("mdcAlertFromServer", getRootElement(),
	function (plate, cctv, reason)
		if mdcNotifications then
			if isElement(source) and exports.see_groups:isPlayerOfficer(localPlayer) then
				local x, y, z = getElementPosition(source)

				if cctv then
					policeMessage("Figyelem! Az egyik biztonsági kamerán (#3d7abc" .. getZoneName(x, y, z) .. "#FFFFFF) egy #d75959körözött járművet#ffffff észleltek!")
				else
					policeMessage("Figyelem! Az egyik ellenőrzőponton (#3d7abc" .. getZoneName(x, y, z) .. "#FFFFFF) egy #d75959körözött jármű#ffffff haladt át!")
				end

				local r1, g1, b1, r2, g2, b2 = getVehicleColor(source, true)

				policeMessage("Rendszám: #3d7abc" .. plate .. "#FFFFFF Típus: #3d7abc" .. exports.see_vehiclenames:getCustomVehicleName(getElementModel(source)) .. "#FFFFFF Színek: " .. rgbToHex(r1, g1, b1) .. "szín1 " .. rgbToHex(r2, g2, b2) .. "szín2")
				policeMessage("Ezért körözik: " .. reason)

				local blipElement = createBlip(x, y, z, 0, 2, 215, 89, 89)

				attachElements(blipElement, source)
				setTimer(destroyElement, 15000, 1, blipElement)
				setElementData(blipElement, "blipTooltipText", "Körözött jármű: " .. plate)

				exports.see_groupscripting:mdcAlertFromServer(plate, cctv, reason)
			end
		end
	end)

addEvent("shootAlertFromServer", true)
addEventHandler("shootAlertFromServer", getRootElement(),
	function (suspectName, vehicleElement, personReason, vehicleReason, zoneName)
		if mdcNotifications then
			if isElement(source) and exports.see_groups:isPlayerOfficer(localPlayer) then
				local x, y, z = getElementPosition(source)
				local text = "lövést"

				if isElement(vehicleElement) then
					text = "lövést (járműből)"
				end

				if suspectName ~= "ismeretlen" then
					policeMessage("Figyelem! Az egyik biztonsági kamera (#3d7abc" .. zoneName .. "#FFFFFF) #d75959" .. text .. "#ffffff észlelt! Elkövető: #3d7abc" .. suspectName .. " #d75959(körözött bűnöző)")
					policeMessage("Ezt a személyt jelenleg körözik: " .. personReason)
				else
					policeMessage("Figyelem! Az egyik biztonsági kamera (#3d7abc" .. zoneName .. "#FFFFFF) #d75959" .. text .. "#ffffff észlelt! Elkövető: #d75959" .. suspectName)
				end

				if vehicleReason then
					if isElement(vehicleElement) then
						local plateText = getVehiclePlateText(vehicleElement)

						if plateText then
							local plateSection = {}
							local plateTextTable = split(plateText, "-")

							for i = 1, #plateTextTable do
								if utf8.len(plateTextTable[i]) > 0 then
									table.insert(plateSection, plateTextTable[i])
								end
							end

							plateText = table.concat(plateSection, "-")

							policeMessage("Egy járműből lőttek. Rendszáma: " .. plateText .. ". Típusa: " .. exports.see_vehiclenames:getCustomVehicleName(getElementModel(vehicleElement)) .. ".")
							policeMessage("Ezt a járművet eddig ezért körözik: " .. vehicleReason)
						end
					end
				end

				local blipElement = createBlip(x, y, z, 0, 2, 215, 89, 89)

				attachElements(blipElement, source)
				setTimer(destroyElement, 5500, 1, blipElement)

				if suspectName ~= "ismeretlen" then
					setElementData(blipElement, "blipTooltipText", "Körözött személy (lövés): " .. suspectName .. " (körözött bűnöző)")
				else
					setElementData(blipElement, "blipTooltipText", "Körözött személy (lövés): " .. suspectName)
				end
			end
		end
	end)

addEvent("killAlertFromServer", true)
addEventHandler("killAlertFromServer", getRootElement(),
	function (suspectName, vehicleElement, personReason, vehicleReason, zoneName)
		if mdcNotifications then
			if isElement(source) and exports.see_groups:isPlayerOfficer(localPlayer) then
				local x, y, z = getElementPosition(source)
				local text = "emberölést"

				if isElement(vehicleElement) then
					text = "emberölést (járműből)"
				end

				if suspectName ~= "ismeretlen" then
					policeMessage("Figyelem! Az egyik biztonsági kamera (#3d7abc" .. zoneName .. "#FFFFFF) #d75959" .. text .. "#ffffff észlelt! Elkövető: #3d7abc" .. suspectName .. " #d75959(körözött bűnöző)")
					policeMessage("Ezt a személyt jelenleg körözik: " .. personReason)
				else
					policeMessage("Figyelem! Az egyik biztonsági kamera (#3d7abc" .. zoneName .. "#FFFFFF) #d75959" .. text .. "#ffffff észlelt! Elkövető: #d75959" .. suspectName)
				end

				if vehicleReason then
					if isElement(vehicleElement) then
						local plateText = getVehiclePlateText(vehicleElement)

						if plateText then
							local plateSection = {}
							local plateTextTable = split(plateText, "-")

							for i = 1, #plateTextTable do
								if utf8.len(plateTextTable[i]) > 0 then
									table.insert(plateSection, plateTextTable[i])
								end
							end

							plateText = table.concat(plateSection, "-")

							policeMessage("Egy járműből lőttek. Rendszáma: " .. plateText .. ". Típusa: " .. exports.see_vehiclenames:getCustomVehicleName(getElementModel(vehicleElement)) .. ".")
							policeMessage("Ezt a járművet eddig ezért körözik: " .. vehicleReason)
						end
					end
				end

				local blipElement = createBlip(x, y, z, 0, 2, 215, 89, 89)

				attachElements(blipElement, source)
				setTimer(destroyElement, 5500, 1, blipElement)

				if suspectName ~= "ismeretlen" then
					setElementData(blipElement, "blipTooltipText", "Körözött személy (gyilkosság): " .. suspectName .. " (körözött bűnöző)")
				else
					setElementData(blipElement, "blipTooltipText", "Körözött személy (gyilkosság): " .. suspectName)
				end
			end
		end
	end)

function rgbToHex(r, g, b, a)
	if (r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255) or (a and (a < 0 or a > 255)) then
		return nil
	end

	if a then
		return string.format("#%.2X%.2X%.2X%.2X", r, g, b, a)
	else
		return string.format("#%.2X%.2X%.2X", r, g, b)
	end
end

local vowels = {
	a = true,
	["á"] = true,
	e = true,
	["é"] = true,
	i = true,
	["í"] = true,
	o = true,
	["ó"] = true,
	["ö"] = true,
	["ő"] = true,
	u = true,
	["ú"] = true,
	["ü"] = true,
	["ű"] = true
}

function findTheArticle(str)
	if tonumber(str) then
		local num = tonumber(str)

		if num == 1 then
			return "az"
		end

		if tonumber(utf8.sub(str, 1, 1)) == 1 and (utf8.len(str) % 4 == 0 or utf8.len(str) % 4 == 3) then
			return "az"
		end

		return "a"
	end

	str = utf8.lower(str)

	if vowels[utf8.sub(utf8.lower(str), 1, 1)] then
		return "az"
	else
		return "a"
	end
end

function firstToUpper(text)
	return (text:gsub("^%l", string.upper))
end

local unitBlips = {}
local unitTimers = {}

function blipTimer(blipElement)
	if isElement(blipElement) then
		local r, g, b = getBlipColor(blipElement)

		if r == 89 then
			setBlipColor(blipElement, 215, 89, 89, 255)
		else
			setBlipColor(blipElement, 89, 142, 215, 255)
		end
	end
end

local atmRobBlips = {}
local moneyCasetteBlips = {}

function initMDCBlips()
	local objectsTable = getElementsByType("object")

	for i = 1, #objectsTable do
		local objectElement = objectsTable[i]

		if isElement(objectElement) then
			local objectModel = getElementModel(objectElement)

			if objectModel == 2942 or objectModel == 2943 then
				if isElement(atmRobBlips[objectElement]) then
					destroyElement(atmRobBlips[objectElement])
				end

				atmRobBlips[objectElement] = nil

				if getElementData(objectElement, "isRobbed") then
					local x, y, z = getElementPosition(objectElement)

					atmRobBlips[objectElement] = createBlip(x, y, z, 0, 2, 215, 89, 89)

					if isElement(atmRobBlips[objectElement]) then
						setElementData(atmRobBlips[objectElement], "blipTooltipText", "Üzemképtelen ATM")
					end

					outputChatBox("#d75959[StrongMTA - ATM]: #FFFFFFFigyelem! Egy #d75959ATM#ffffff üzemképtelen (#3d7abc" .. getZoneName(x, y, z) .. "#FFFFFF).", 0, 0, 0, true)
				end
			end
		end
	end

	local see_items = getResourceFromName("see_items")

	for k, v in pairs(moneyCasetteBlips) do
		if isElement(v[1]) then
			destroyElement(v[1])
		end
	end

	moneyCasetteBlips = {}

	if see_items then
		if getResourceState(see_items) == "running" then
			local itemsRootElement = getResourceRootElement(see_items)
			local moneyCasettes = getElementData(itemsRootElement, "moneyCasettes") or {}

			for k, v in pairs(moneyCasettes) do
				moneyCasetteBlips[k] = {false, 0, 0}
				moneyCasetteBlips[k][1] = createBlip(0, 0, 0, 0, 2, 191, 255, 0)

				if isElement(moneyCasetteBlips[k][1]) then
					setElementData(moneyCasetteBlips[k][1], "blipTooltipText", "Pénzkazetta")
				end
			end
		end
	end

	local currVeh = getPedOccupiedVehicle(localPlayer)

	if currVeh then
		renderData.unitNumber = getElementData(currVeh, "unitNumber")
	end

	for k, veh in ipairs(getElementsByType("vehicle")) do
		local unitState = getElementData(veh, "unitState")
		local unitNumber = getElementData(veh, "unitNumber")

		if unitState and unitNumber then
			local groupId = getElementData(veh, "vehicle.group") or 0
			local groupPrefix = groupPrefixes[groupId] or "CIVIL"

			if unitState == "off" then
				if isElement(unitBlips[veh]) then
					destroyElement(unitBlips[veh])
				end

				if isTimer(unitTimers[veh]) then
					killTimer(unitTimers[veh])
				end
			elseif unitState == "patrol" then
				local x, y, z = getElementPosition(veh)

				if not isElement(unitBlips[veh]) then
					if getElementDimension(unitBlips[veh]) > 0 then 
						return 
					end
					unitBlips[veh] = createBlip(x, y, z, 0, 2, 89, 142, 215)
					attachElements(unitBlips[veh], veh)
				end

				if isTimer(unitTimers[veh]) then
					killTimer(unitTimers[veh])
				end

				setBlipColor(unitBlips[veh], 89, 142, 215, 255)
				setElementData(unitBlips[veh], "blipTooltipText", groupPrefix .. "-" .. unitNumber .. ". számú egység (járőr)")
			elseif unitState == "chase" then
				local x, y, z = getElementPosition(veh)

				if not isElement(unitBlips[veh]) then
					unitBlips[veh] = createBlip(x, y, z, 0, 2, 89, 142, 215)
					attachElements(unitBlips[veh], veh)
				end

				if isTimer(unitTimers[veh]) then
					killTimer(unitTimers[veh])
				end

				setBlipColor(unitBlips[veh], 89, 142, 215, 255)
				unitTimers[veh] = setTimer(blipTimer, 500, 0, unitBlips[veh])

				setElementData(unitBlips[veh], "blipTooltipText", groupPrefix .. "-" .. unitNumber .. ". számú egység (üldözés)")
			elseif unitState == "action" then
				local x, y, z = getElementPosition(veh)

				if not isElement(unitBlips[veh]) then
					unitBlips[veh] = createBlip(x, y, z, 0, 2, 89, 142, 215)
					attachElements(unitBlips[veh], veh)
				end

				if isTimer(unitTimers[veh]) then
					killTimer(unitTimers[veh])
				end

				setBlipColor(unitBlips[veh], 89, 142, 215, 255)
				unitTimers[veh] = setTimer(blipTimer, 500, 0, unitBlips[veh])

				setElementData(unitBlips[veh], "blipTooltipText", groupPrefix .. "-" .. unitNumber .. ". számú egység (akció)")
			end

			if veh == currVeh then
				renderData.unitState = unitState

				if renderData.unitState == "off" then
					renderData.unitStateStr = "#d75959off"
				elseif renderData.unitState == "patrol" then
					renderData.unitStateStr = "#3d7abcjárőr"
				elseif renderData.unitState == "chase" then
					renderData.unitStateStr = "#3d7abcüldözés"
				elseif renderData.unitState == "action" then
					renderData.unitStateStr = "#3d7abcakció"
				end
			end
		end
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if exports.see_groups:isPlayerOfficer(localPlayer) then
			initMDCBlips()
		end
	end)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if panelState then
			exports.see_hud:showHUD()
		end
	end)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if unitTimers[source] then
			if isTimer(unitTimers[source]) then
				killTimer(unitTimers[source])
			end

			unitTimers[source] = nil
		end

		if unitBlips[source] then
			if isElement(unitBlips[source]) then
				destroyElement(unitBlips[source])
			end

			unitBlips[source] = nil
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if source == localPlayer then
			if dataName == "player.groups" then
				for k, v in pairs(moneyCasetteBlips) do
					if isElement(v[1]) then
						destroyElement(v[1])
					end
				end

				moneyCasetteBlips = {}

				for k, v in pairs(atmRobBlips) do
					if isElement(v) then
						destroyElement(v)
					end
				end

				for k, v in pairs(unitBlips) do
					if isElement(v) then
						destroyElement(v)
					end
				end

				for k, v in pairs(unitTimers) do
					if isTimer(v) then
						killTimer(v)
					end
				end

				if exports.see_groups:isPlayerOfficer(localPlayer) then
					initMDCBlips()
				end
			end
		end

		if dataName == "moneyCasettes" then
			if exports.see_groups:isPlayerOfficer(localPlayer) then
				for k, v in pairs(moneyCasetteBlips) do
					if isElement(v[1]) then
						destroyElement(v[1])
					end
				end

				moneyCasetteBlips = {}

				local itemsRootElement = getResourceRootElement(getResourceFromName("see_items"))
				local moneyCasettes = getElementData(itemsRootElement, "moneyCasettes") or {}

				for k, v in pairs(moneyCasettes) do
					moneyCasetteBlips[k] = {false, 0, 0}
					moneyCasetteBlips[k][1] = createBlip(0, 0, 0, 0, 2, 191, 255, 0)

					if isElement(moneyCasetteBlips[k][1]) then
						setElementData(moneyCasetteBlips[k][1], "blipTooltipText", "Pénzkazetta")
					end
				end
			end
		end

		if dataName == "isRobbed" then
			if exports.see_groups:isPlayerOfficer(localPlayer) then
				if isElement(atmRobBlips[source]) then
					destroyElement(atmRobBlips[source])
				end

				atmRobBlips[source] = nil

				if getElementData(source, "isRobbed") then
					local x, y, z = getElementPosition(source)

					atmRobBlips[source] = createBlip(x, y, z, 0, 2, 215, 89, 89)

					if isElement(atmRobBlips[source]) then
						setElementData(atmRobBlips[source], "blipTooltipText", "Üzemképtelen ATM")
					end

					outputChatBox("#d75959[StrongMTA - ATM]: #FFFFFFFigyelem! Egy #d75959ATM#ffffff üzemképtelen (#3d7abc" .. getZoneName(x, y, z) .. "#FFFFFF).", 0, 0, 0, true)
				end
			end
		end

		if dataName == "unitNumber" or dataName == "unitState" then
			if exports.see_groups:isPlayerOfficer(localPlayer) then
				local dataVal = getElementData(source, dataName)
				local groupId = getElementData(source, "vehicle.group") or 0
				local groupPrefix = groupPrefixes[groupId] or "CIVIL"

				if dataName == "unitNumber" then
					if oldValue and not dataVal then
						policeMessage(firstToUpper(findTheArticle(groupPrefix)) .. " #d75959" .. groupPrefix .. "-" .. oldValue .. ".#ffffff számú egység #3d7abcfelbomlott#ffffff.")
					end

					if dataVal then
						policeMessage(firstToUpper(findTheArticle(groupPrefix)) .. " #d75959" .. groupPrefix .. "-" .. dataVal .. ".#ffffff számú egység #3d7abclétrejött#ffffff.")
					end

					if isElement(unitBlips[source]) then
						destroyElement(unitBlips[source])
					end

					if isTimer(unitTimers[source]) then
						killTimer(unitTimers[source])
					end

					if source == getPedOccupiedVehicle(localPlayer) then
						renderData.unitNumber = dataVal
					end
				end

				if dataName == "unitState" then
					local unitNumber = getElementData(source, "unitNumber")

					if dataVal ~= oldValue and unitNumber then
						if dataVal == "off" or not dataVal then
							policeMessage(firstToUpper(findTheArticle(groupPrefix)) .. " #d75959" .. groupPrefix .. "-" .. unitNumber .. ".#ffffff számú egység #3d7abckiállt a szolgálatból#ffffff.")

							if isElement(unitBlips[source]) then
								destroyElement(unitBlips[source])
							end

							if isTimer(unitTimers[source]) then
								killTimer(unitTimers[source])
							end
						elseif dataVal == "patrol" then
							local x, y, z = getElementPosition(source)

							policeMessage(firstToUpper(findTheArticle(groupPrefix)) .. " #d75959" .. groupPrefix .. "-" .. unitNumber .. ".#ffffff számú egység szolgálati állapota: #3d7abcjárőr#ffffff.")

							if not isElement(unitBlips[source]) then
								unitBlips[source] = createBlip(x, y, z, 0, 2, 89, 142, 215)
								attachElements(unitBlips[source], source)
							end

							if isTimer(unitTimers[source]) then
								killTimer(unitTimers[source])
							end

							setBlipColor(unitBlips[source], 89, 142, 215, 255)
							setElementData(unitBlips[source], "blipTooltipText", groupPrefix .. "-" .. unitNumber .. ". számú egység (járőr)")
						elseif dataVal == "chase" then
							local x, y, z = getElementPosition(source)

							policeMessage(firstToUpper(findTheArticle(groupPrefix)) .. " #d75959" .. groupPrefix .. "-" .. unitNumber .. ".#ffffff számú egység szolgálati állapota: #3d7abcüldözés#ffffff.")

							if not isElement(unitBlips[source]) then
								unitBlips[source] = createBlip(x, y, z, 0, 2, 89, 142, 215)
								attachElements(unitBlips[source], source)
							end

							if isTimer(unitTimers[source]) then
								killTimer(unitTimers[source])
							end

							setBlipColor(unitBlips[source], 89, 142, 215, 255)
							unitTimers[source] = setTimer(blipTimer, 500, 0, unitBlips[source])

							setElementData(unitBlips[source], "blipTooltipText", groupPrefix .. "-" .. unitNumber .. ". számú egység (üldözés)")
						elseif dataVal == "action" then
							local x, y, z = getElementPosition(source)

							policeMessage(firstToUpper(findTheArticle(groupPrefix)) .. " #d75959" .. groupPrefix .. "-" .. unitNumber .. ".#ffffff számú egység szolgálati állapota: #3d7abcakció#ffffff.")

							if not isElement(unitBlips[source]) then
								unitBlips[source] = createBlip(x, y, z, 0, 2, 89, 142, 215)
								attachElements(unitBlips[source], source)
							end

							if isTimer(unitTimers[source]) then
								killTimer(unitTimers[source])
							end

							setBlipColor(unitBlips[source], 89, 142, 215, 255)
							unitTimers[source] = setTimer(blipTimer, 500, 0, unitBlips[source])

							setElementData(unitBlips[source], "blipTooltipText", groupPrefix .. "-" .. unitNumber .. ". számú egység (akció)")
						end

						if source == getPedOccupiedVehicle(localPlayer) then
							renderData.unitState = dataVal

							if renderData.unitState == "off" or not dataVal then
								renderData.unitStateStr = "#d75959off"
							elseif renderData.unitState == "patrol" then
								renderData.unitStateStr = "#3d7abcjárőr"
							elseif renderData.unitState == "chase" then
								renderData.unitStateStr = "#3d7abcüldözés"
							elseif renderData.unitState == "action" then
								renderData.unitStateStr = "#3d7abcakció"
							end
						end
					end
				end
			end
		end
	end)

--[[addEventHandler("onClientVehicleExit", getRootElement(),
	function (leftPlayer)
		if leftPlayer == localPlayer then
			if getElementData(source, "unitState") then
				local occupants = getVehicleOccupants(source)
				local count = 0

				for k in pairs(occupants) do
					count = count + 1
				end

				if count < 1 then
					setElementData(source, "unitState", false)
				end
			end
		end
	end)]]

local vehicleList = {}
renderData.vehicleList = {}
renderData.wantedCarsOffset = 0

local peopleList = {}
renderData.peopleList = {}
renderData.wantedPeopleOffset = 0

local punishmentList = {}
renderData.punishmentList = {}
renderData.punishmentOffset = 0

local btkList = {
	{"#3d7abcPénzbírság orientált", ""},
	{"", ""},
	{"#d75959Szabálysértések", ""},
	{"   Ittas vezetés", "280 $ | Nincs"},
	{"   Gondatlan vezetés", "400 - 800 $\t| Nincs"},
	{"   Forgalom feltartása", "120 $ | Nincs"},
	{"   Oszlopok / Póznák rongálása", "200 $ / db | Nincs"},
	{"   Vandalizmus", "400 - 800 $ | Nincs"},
	{"   Tilosban parkolás", "400 $ | Nincs"},
	{"   Kis mértékben rongált járművel való közlekedés", "200 $ | Nincs"},
	{"   Közepesen rongált járművel való közlekedés", "400 $ | Nincs"},
	{"   Súlyosan rongált járművel való közlekedés", "600 $ | Nincs"},
	{"   Fegyver szabadon viselése közterületen", "200 $ | Nincs"},
	{"   Garázdaság", "600 $ | Nincs"},
	{"   Rendőri munka akadályozása", "400 $ | Nincs"},
	{"   Közszeméremsértés", "120 $ | Nincs"},
	{"   Közrend megzavarása", "200 $ | Nincs"},
	{"   Közúti veszélyeztetés", "1.200 $ - 1.600 $ | Nincs"},
	{"   Tilos jelzésen való áthajtás", "1.000 $ | Nincs"},
	{"   Jogosítvány nélküli vezetés", "300 $ | Nincs"},
	{"   Balra kanyarodási szabály megszegése", "400 $ | Nincs"},
	{"   Rendőrtiszttel szembeni tiszteletlenség", "200 $ esetenként | Nincs"},
	{"   Kresz törvények megsértése", "400 $ | Nincs"},
	{"   Személyi igazolvány hiánya", "400 $ | Nincs"},
	{"", ""},
	{"#d75959Illegális autóalkatrészek gépjárműbe szerelése", ""},
	{"   Neon", "1.600 $ | Nincs"},
	{"   Lámpa színe más", "400 $ | Nincs"},
	{"   Nitró", "2.000 $ | Nincs"},
	{"", ""},
	{"#d75959Alapfokú, Kisebb bűncselekmények", ""},
	{"   Hamis bejelentés / Rendőr félrevezetése", "400 $ - 2.000 $ | 10 perc"},
	{"   Rendőrtiszt előli menekülés", "10.000 $ - 12.000 $ | 40 perc"},
	{"   Rendőrtiszti utasítás megszegése", "1.000 $ | 20 perc"},
	{"   Illegális rendezvény szervezése", "20.000 $ | 50 perc"},
	{"   Illegális rendezvényen való részvétel", "4.000 $ | 20 perc"},
	{"   Életveszélyes fenyegetés", "2.000 $ | 20 perc"},
	{"   Hivatali személy fenyegetése", "4.000 $ | 40 perc"},
	{"   Birtokháborítás", "400 $ | 10 perc"},
	{"", ""},
	{"#d75959Középfokú bűncselekmények", ""},
	{"   Rendőr megvesztegetése", "4.000 $ | 30 perc"},
	{"   Engedély nélküli lőfegyverviselés", "8.000 $\t| 40 perc"},
	{"   Engedély nélküli tölténybirtoklás 35 fölött", "40 $ / Lőszer | 40 perc"},
	{"   Drogbirtoklás", "4.000 + 40 $ / Gramm | 25 perc"},
	{"   Drogkészítési alapanyagok birtoklása", "40 $ / Gramm\t| 15 perc"},
	{"   Drogtermesztés", "200 $ / Termés | 40 perc"},
	{"   Rablás megkísérlése", "2.000 $ | 30 perc"},
	{"   Rablás", "12.000 $ | 60 perc"},
	{"   Könnyű, fokozott, Súlyos Testi sértés", "400 - 2.000 $ | 30 perc"},
	{"   Autólopás", "2.000 $ | 30 perc"},
	{"   Okirathamisítás", "20.000 $ | 50 perc"},
	{"", ""},
	{"#d75959Magas-, Súlyosfokú bűncselekmények", ""},
	{"   Engedély nélküli Behatolás", "6.000 $ | 30 perc"},
	{"   Honvédelmi területre való Behatolás", "12.000 $ | 40 perc"},
	{"   Drog terjesztése", "10.000 $ | 40 perc"},
	{"   Illegális fegyver árusítása", "20.000 $ | 60 perc"},
	{"   Illegális fegyver birtoklása", "16.000 $ | 40 perc"},
	{"   Illegális fegyverhez tartozó lőszerek birtoklása", "40 $ / Lőszer | 20 perc"},
	{"   Illegális fegyvertartozékok birtoklása", "400 $ / Db\t| 20 perc"},
	{"   Civil személy elrablása", "20.000 $ | 60 perc"},
	{"   Hivatali személy elrablása", "40.000 $ | 100 perc"},
	{"   Emberölési kísérlet civillel szemben", "10.000 $ | 50 perc"},
	{"   Emberölési kísérlet hiv. szem. szemben", "40.000 $ | 100 perc"},
	{"   Civil meggyilkolása", "20.000 $ | 70 perc"},
	{"   Hivatali személy meggyilkolása", "40.000 $ | 100 perc"},
	{"   Bankrablás", "40.000 $ | 80 perc"},
	{"   Bandaháború", "8.000 $ | 40 perc"},
	{"   Hivatali személynek való kiadása", "4.000 $ | 30 perc"},
	{"   Pénzszállító eltulajdonítása", "16.000 $ | 40 perc"},
	{"   Illegális határátlépés", "4.000 $ | 30 perc"},
	{"   Boltrablás", "24.000 $ | 60 perc"},
	{"", ""},
	{"#d75959Korrupció", ""},
	{"   Büntetés elmulasztása", "40.000 $ | 100 perc"},
	{"   Fegyver, szolgálati felszerelés árusítása", "40.000 $ | 100 perc"},
	{"   Illegális dolgok forgalmazása, birtoklása", "40.000 $ | 100 perc"},
	{"", ""},
	{"#d75959Adócsalás", ""},
	{"   Cégek: ÁFA-s számla kiállításának elmulasztása", "\t40.000 $ | Nincs"},
	{"   Magánszemély: ÁFA-s számla kiállításának elmulasztása", "20.000 $ | Nincs"},
	{"   Bejegyzetlen cég működtetése", "40.000 $ | 100 perc"},
	{"   C: Adásvételi szerződés kiállításának elmulasztása", "40.000 $ | Nincs"},
	{"   MSZ: Adásvételi szerződés kiállításának elmulasztása", "20.000 $ | Nincs"},
	{"", ""},
	{"#3d7abcBörtönbüntetés orientált", ""},
	{"", ""},
	{"#d75959Szabálysértések", ""},
	{"   Ittas vezetés", "280 $ | Nincs"},
	{"   Gondatlan vezetés", "400 - 800 $\t| Nincs"},
	{"   Forgalom feltartása", "120 $ | Nincs"},
	{"   Oszlopok / Póznák rongálása", "200 $ / db | Nincs"},
	{"   Vandalizmus", "400 - 800 $ | Nincs"},
	{"   Tilosban parkolás", "400 $ | Nincs"},
	{"   Kis mértékben rongált járművel való közlekedés", "200 $ | Nincs"},
	{"   Közepesen rongált járművel való közlekedés", "400 $ | Nincs"},
	{"   Súlyosan rongált járművel való közlekedés", "600 $ | Nincs"},
	{"   Fegyver szabadon viselése közterületen", "200 $ | Nincs"},
	{"   Garázdaság", "600 $ | Nincs"},
	{"   Rendőri munka akadályozása", "400 $ | 10 perc"},
	{"   Közszeméremsértés", "120 $ | Nincs"},
	{"   Közrend megzavarása", "200 $ | Nincs"},
	{"   Közúti veszélyeztetés", "1.200 $ - 1.600 $ | Nincs"},
	{"   Tilos jelzésen való áthajtás", "1.000 $ | Nincs"},
	{"   Jogosítvány nélküli vezetés", "300 $ | Nincs"},
	{"   Balra kanyarodási szabály megszegése", "400 $ | Nincs"},
	{"   Rendőrtiszttel szembeni tiszteletlenség", "200 $ esetenként | 15 perc"},
	{"   Kresz törvények megsértése", "400 $ | Nincs"},
	{"   Személyi igazolvány hiánya", "400 $ | Nincs"},
	{"", ""},
	{"#d75959Illegális autóalkatrészek gépjárműbe szerelése", ""},
	{"   Neon", "1.600 $ | Nincs"},
	{"   Lámpa színe más", "400 $ | Nincs"},
	{"   Nitró", "2.000 $ | Nincs"},
	{"", ""},
	{"#d75959Alapfokú, Kisebb bűncselekmények", ""},
	{"   Hamis bejelentés / Rendőr félrevezetése", "400 $ - 1.000 $ | 20 perc"},
	{"   Rendőrtiszt előli menekülés", "4.000 $ - 6.000 $ | 60 perc"},
	{"   Rendőrtiszti utasítás megszegése", "600 $ | 30 perc"},
	{"   Illegális rendezvény szervezése", "10.000 $ | 65 perc"},
	{"   Illegális rendezvényen való részvétel", "2.000 $ | 30 perc "},
	{"   Életveszélyes fenyegetés", "1.000 $ | 35 perc"},
	{"   Hivatali személy fenyegetése", "2.000 $ | 60 perc"},
	{"   Birtokháborítás", "200 $ | 20 perc"},
	{"", ""},
	{"#d75959Középfokú bűncselekmények", ""},
	{"   Rendőr megvesztegetése", "2.000 $ | 45 perc"},
	{"   Engedély nélküli lőfegyverviselés", "4.000 $ | 60 perc"},
	{"   Engedély nélküli tölténybirtoklás", "35 fölött - 5.000 Ft / Lőszer | 50 perc"},
	{"   Drogbirtoklás", "2.000 + 20 $ / Gramm | 40 perc"},
	{"   Drogkészítési alapanyagok birtoklása", "20 $ / Gramm | 25 perc"},
	{"   Drogtermesztés", "100 $ / Termés | 50-60 perc"},
	{"   Rablás megkísérlése", "1.000 $ | 45 perc"},
	{"   Rablás", "6.000 $ | 75 perc"},
	{"   Könnyű, fokozott, Súlyos Testi sértés", "200 - 1.200 $ | 50 perc"},
	{"   Autólopás", "1.000 $ | 45 perc"},
	{"   Okirathamisítás", "10.000 $ | 65 perc"},
	{"", ""},
	{"#d75959Magasfokú bűncselekmények", ""},
	{"   Engedély nélküli Behatolás", "3.000 $ | 45 perc"},
	{"   Honvédelmi területre való Behatolás", "6.000 $ | 55 perc"},
	{"   Drog terjesztése", "5.000 $ | 55 perc"},
	{"   Illegális fegyver árusítása", "10.000 $ | 75 perc"},
	{"   Illegális fegyver birtoklása", "8.000 $ | 60 perc"},
	{"   Illegális fegyverhez tartozó lőszerek birtoklása", "20 $ / Lőszer | 30 perc"},
	{"   Illegális fegyvertartozékok birtoklása", "240 $ / Darab | 30 perc"},
	{"   Civil személy elrablása", "10.000 $ | 75 perc"},
	{"   Hivatali személy elrablása", "40.000 $ | 100 perc"},
	{"   Emberölési kísérlet civillel szemben", "5.000 $ | 65 perc"},
	{"   Emberölési kísérlet hiv. szem. szemben", "40.000 $ | 100 perc"},
	{"   Civil meggyilkolása", "20.000 $ | 70 perc"},
	{"   Hivatali személy meggyilkolása", "40.000 $ | 100 perc"},
	{"   Bankrablás", "32.000 $ | 100 perc"},
	{"   Bandaháború", "6.000 $ | 60 perc"},
	{"   Hivatali személynek való kiadása", "3.000 $ | 40 perc"},
	{"   Pénzszállító eltulajdonítása", "12.000 $ | 60 perc"},
	{"   Illegális határátlépés", "3.000 $ | 45 perc"},
	{"   Boltrablás", "16.000 $ | 80 perc"},
	{"", ""},
	{"#d75959Korrupció:", ""},
	{"   Büntetés elmulasztása", "40.000 $ | 100 perc"},
	{"   Fegyver, szolgálati felszerelés árusítása", "40.000 $ | 100 perc"},
	{"   Illegális dolgok forgalmazása, birtoklása", "40.000 $ | 100 perc"},
	{"", ""},
	{"#d75959Adócsalás", ""},
	{"   Cégek: ÁFA-s számla kiállításának elmulasztása", "40.000 $ | Nincs"},
	{"   Magánszemély: ÁFA-s számla kiállításának elmulasztása", "20.000 $ | Nincs"},
	{"   Bejegyzetlen cég működtetése", "40.000 $ | 100 perc"},
	{"   C: Adásvételi szerződés kiállításának elmulasztása", "40.000 $ | Nincs"},
	{"   MSZ: Adásvételi szerződés kiállításának elmulasztása", "20.000 $ | Nincs"},
}
renderData.btkList = btkList
renderData.btkOffset = 0

renderData.unitState = "off"
renderData.unitStateStr = "#d75959off"

addCommandHandler("mdc",
	function ()
		if isPedInVehicle(localPlayer) then
			if getPedOccupiedVehicleSeat(localPlayer) == 0 or getPedOccupiedVehicleSeat(localPlayer) == 1 then
				local currVeh = getPedOccupiedVehicle(localPlayer)
				if mdcVehicles[getElementModel(currVeh)] or groupPrefixes[getElementData(currVeh, "vehicle.group")] then
					local groupId = getElementData(currVeh, "vehicle.group") or 0

					if groupId > 0 then
						panelState = not panelState

						if lastVehicle ~= currVeh then
							loggedInMDC = false
							currentPage = "login"
						end

						lastVehicle = currVeh

						activeButton = false
						activeFakeInput = false
						fakeInputValue = {}
						caretIndex = false
						inputError = false
						renderData.whatKindOfGroup = groupPrefixes[groupId] or "CIVIL"

						if panelState then
							renderData.unitNumber = getElementData(currVeh, "unitNumber")
							renderData.unitState = getElementData(currVeh, "unitState")

							if renderData.unitState == "off" then
								renderData.unitStateStr = "#d75959off"
							elseif renderData.unitState == "patrol" then
								renderData.unitStateStr = "#3d7abcjárőr"
							elseif renderData.unitState == "chase" then
								renderData.unitStateStr = "#3d7abcüldözés"
							elseif renderData.unitState == "action" then
								renderData.unitStateStr = "#3d7abcakció"
							end

							createFonts()
							--showCursor(true)
							renderMove = false
							playSound("files/sounds/mdcon.mp3")
						else
							destroyFonts()
							showCursor(false)
							playSound("files/sounds/mdcoff.mp3")
							renderMove = false
						end
					end
				end
			end
		end
	end)

function closeMDC()
	panelState = false
	activeButton = false
	activeFakeInput = false
	fakeInputValue = {}
	caretIndex = false
	inputError = false

	destroyFonts()
	--showCursor(false)
	playSound("files/sounds/mdcoff.mp3")

	renderMove = false
end

local renderMove = false

local loggedPos = {
	x = screenX / 2 - respc(1000) / 2,
	y = screenY / 2 - respc(675) / 2
}

addEventHandler("onClientRender", getRootElement(),
	function ()
		for k in pairs(moneyCasetteBlips) do
			if not (getElementDimension(k) or false) then
				return
			end
			local currentDimension = getElementDimension(k)

			if currentDimension ~= moneyCasetteBlips[k][2] then
				moneyCasetteBlips[k][2] = currentDimension

				if moneyCasetteBlips[k][2] ~= 0 then
					local interiorX, interiorY, interiorZ = exports.see_interiors:getInteriorEntrancePosition(currentDimension)

					setElementPosition(moneyCasetteBlips[k][1], interiorX, interiorY, interiorZ)
				end
			elseif moneyCasetteBlips[k][2] == 0 then
				local currentX, currentY, currentZ = getElementPosition(k)

				setElementPosition(moneyCasetteBlips[k][1], currentX, currentY, currentZ)
			end
		end

		if panelState then
			local currVeh = getPedOccupiedVehicle(localPlayer)

			buttons = {}

			if renderMove then
				local cursorX, cursorY = getCursorPosition()
				local posX, posY = cursorX * screenX - posOffSetX, cursorY * screenY - posOffSetY
				loggedPos = {
					x = posX,
					y = posY
				}
			end
			
			if not currVeh then
				closeMDC()
				return
			end

			local groupType = renderData.whatKindOfGroup
			

			-- ** Panel wardis
			local sx, sy = respc(400), respc(315)

			if currentPage ~= "login" then
				sx, sy = respc(1000), respc(675)
			end
			if currentPage ~= "login" then
				x = loggedPos.x
				y = loggedPos.y
			else
				x = screenX / 2 - sx / 2
				y = screenY / 2 - sy / 2
			end
			local margin = respc(10)

			-- ** Háttér
			dxDrawRectangle(x, y, sx, sy, tocolor(32, 32, 32))
			drawRectangleOutline(x, y, sx, sy, tocolor(81, 81, 81))

			-- ** Cím
			dxDrawRectangle(x, y, sx, respc(40), tocolor(64, 64, 64))
			dxDrawText("StrongMTA - #3d7abcMDC", x + margin, y, 0, y + respc(40), tocolor(255, 255, 255), 0.75, Roboto, "left", "center", false, false, false, true)

			-- Kilépés
			buttons["exit"] = {x + sx - respc(45), y, respc(45), respc(39)}

			if activeButton == "exit" then
				dxDrawRectangle(x + sx - respc(45), y, respc(45), respc(39), tocolor(232, 17, 35))
			end

			dxDrawImage(math.floor(x + sx - respc(45) / 2 - respc(30) / 2), math.floor(y + respc(39) / 2 - respc(30) / 2), respc(30), respc(30), "files/images/icons/close.png")

			y = y + respc(40)

			-- ** Content
			if currentPage == "login" then
				local inputWidth = sx - margin * 4
				local inputHeight = respc(35)

				dxDrawText("Kérjük, jelentkezzen be alább\na számítógép eléréséhez.", x, y, x + sx, y + respc(100), tocolor(255, 255, 255), 1, RobotoL, "center", "center")

				y = y + respc(100)

				drawInput("username|24", "Felhasználónév", x + margin * 2, y, inputWidth - margin * 3, inputHeight, "files/images/icons/user.png")

				y = y + inputHeight + margin

				drawInput("password|24|hash", "Jelszó", x + margin * 2, y, inputWidth - margin * 3, inputHeight, "files/images/icons/key.png")

				y = y + inputHeight + margin * 3

				drawButton("login", "Bejelentkezés", x + sx / 2 - inputWidth / 2, y, inputWidth, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
			else
				local holderSize = sx / #availableTabs
				local contentSize = sx - holderSize

				dxDrawRectangle(x, y, holderSize, sy - respc(40), tocolor(0, 0, 0, 100))
				dxDrawRectangle(x + holderSize - 1, y, 1, sy - respc(40), tocolor(50, 50, 50))
				dxDrawRectangle(x + holderSize, y, contentSize, respc(30), tocolor(0, 0, 0))

				if renderData.unitNumber then
					local startY = y + (sy - respc(40)) / 2 - (respc(40)*7 + margin*6) / 2

					dxDrawText("Egységszám: #3d7abc" .. groupType .. "-" .. renderData.unitNumber, x, startY, x + holderSize, startY + respc(40), tocolor(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)
					startY = startY + respc(40) + margin

					drawButton("delUnit", "Egységcsere", x + margin * 2, startY, holderSize - margin * 4, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
					startY = startY + respc(40) + margin

					dxDrawText("Szolgálat: " .. renderData.unitStateStr, x, startY, x + holderSize, startY + respc(40), tocolor(255, 255, 255), 0.85, Roboto, "center", "center", false, false, false, true)
					startY = startY + respc(40) + margin

					drawButton("setUnitState:off", "OFF", x + margin * 2, startY, holderSize - margin * 4, respc(40), tocolor(180, 45, 45), tocolor(200, 60, 60), tocolor(200, 80, 80))
					startY = startY + respc(40) + margin

					drawButton("setUnitState:patrol", "Járőr", x + margin * 2, startY, holderSize - margin * 4, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
					startY = startY + respc(40) + margin

					drawButton("setUnitState:chase", "Üldözés", x + margin * 2, startY, holderSize - margin * 4, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
					startY = startY + respc(40) + margin

					drawButton("setUnitState:action", "Akció", x + margin * 2, startY, holderSize - margin * 4, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
				else
					local startY = y + (sy - respc(40)) / 2 - (respc(40)*3 + margin*3) / 2

					dxDrawText("Add meg az egységszámot:", x, startY, x + holderSize, startY + respc(40), tocolor(255, 255, 255), 0.75, Roboto, "center", "center")
					startY = startY + respc(40) + margin

					drawInput("unitNum|5|num-only", "Egységszám", x + margin * 2, startY, holderSize - margin * 4, respc(40))
					startY = startY + respc(40) + margin * 2

					drawButton("enterUnit", "Megad", x + margin * 2, startY, holderSize - margin * 4, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
				end

				local oneTabSize = holderSize * 3 / 4

				for i = 1, #availableTabs do
					local tabX = x + holderSize + oneTabSize * (i - 1)
					local tab = availableTabs[i]

					if currentPage == tab.name then
						dxDrawRectangle(tabX, y, oneTabSize, respc(30), tocolor(84, 84, 84))
					else
						if activeButton == "setCurrentPage:" .. tab.name then
							dxDrawRectangle(tabX, y, oneTabSize, respc(30), tocolor(75, 75, 75))
						end

						buttons["setCurrentPage:" .. tab.name] = {tabX, y, oneTabSize, respc(30)}
					end

					dxDrawText(tab.title, tabX, y, tabX + oneTabSize, y + respc(30), tocolor(255, 255, 255), 0.7, Roboto, "center", "center", false, false, false, false, true)
				end

				y = y + respc(30)

				if currentPage == "wantedCars" then
					local startX = x + holderSize
					local startY = y + margin

					-- Oszlopok
					dxDrawRectangle(startX + margin, startY, contentSize - margin * 2, respc(35), tocolor(25, 25, 25))

					dxDrawText("Típus", startX + margin * 2, startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")
					dxDrawRectangle(startX + margin + respc(250), startY, 1, respc(35), tocolor(100, 100, 100))

					dxDrawText("Rendszám", startX + margin * 2 + respc(250), startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")
					dxDrawRectangle(startX + margin + respc(350), startY, 1, respc(35), tocolor(100, 100, 100))

					dxDrawText("Indok", startX + margin * 2 + respc(350), startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")

					-- Tartalom
					local tabNum = 9
					local oneSize = respc(25)

					startY = startY + respc(35)

					for i = 1, tabNum do
						local rowY = startY + oneSize * (i - 1)

						if i % 2 == 0 then
							dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(0, 0, 0, 25))
						else
							dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(255, 255, 255, 10))
						end

						local record = renderData.vehicleList[i + renderData.wantedCarsOffset]

						if record then
							if renderData.editingVehicle == record.id then
								dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(5, 115, 195, 150))
							elseif activeButton == "editVehicle:" .. i + renderData.wantedCarsOffset then
								dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(255, 255, 255, 15))
							end

							buttons["editVehicle:" .. i + renderData.wantedCarsOffset] = {startX + margin, rowY, contentSize - margin * 4 - respc(22), oneSize}

							dxDrawText(record.type, startX + margin * 2, rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")
							dxDrawText(record.plate, startX + margin * 2 + respc(250), rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")
							dxDrawText(record.reason, startX + margin * 2 + respc(350), rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")

							if activeButton == "delReportVehicle:" .. record.id .. ":" .. record.plate then
								dxDrawImage(math.floor(startX + contentSize - margin * 2 - respc(22)), math.floor(rowY + oneSize / 2 - respc(11)), respc(22), respc(22), "files/images/icons/close.png", 0, 0, 0, tocolor(232, 17, 35))
							else
								dxDrawImage(math.floor(startX + contentSize - margin * 2 - respc(22)), math.floor(rowY + oneSize / 2 - respc(11)), respc(22), respc(22), "files/images/icons/close.png")
							end

							buttons["delReportVehicle:" .. record.id .. ":" .. record.plate] = {startX + contentSize - margin * 2 - respc(22), rowY, respc(22), respc(22)}
						end
					end

					local listHeight = tabNum * oneSize

					if #renderData.vehicleList > tabNum then
						local gripSize = listHeight / #renderData.vehicleList

						dxDrawRectangle(startX + contentSize - margin - respc(5), startY, respc(5), listHeight, tocolor(75, 75, 75))
						dxDrawRectangle(startX + contentSize - margin - respc(5), startY + renderData.wantedCarsOffset * gripSize, respc(5), tabNum * gripSize, tocolor(125, 125, 125))
					end

					drawRectangleOutline(startX + margin, y + margin, contentSize - margin * 2, respc(35) + listHeight, tocolor(50, 50, 50))

					startY = startY + listHeight

					-- Kereső mező
					startY = startY + margin

					drawInput("searchByPlate|8", "Keresés rendszám alapján...", startX + margin + 2, startY + 2, contentSize - respc(150) - margin * 2 - 4, respc(40) - 4, false, "files/images/icons/search.png")
					drawButton("searchByPlate", "Keresés", startX + contentSize - respc(150) - margin, startY, respc(150), respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))

					-- Körözés kiadás
					startY = startY + respc(40) + margin

					dxDrawRectangle(startX + margin, startY, contentSize - margin * 2, respc(35), tocolor(25, 25, 25))

					if renderData.editingVehicle then
						dxDrawText("Körözés szerkesztése (" .. renderData.editingVehiclePlate .. ")", startX, startY, startX + contentSize, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "center", "center")
					else
						dxDrawText("Körözés kiadása", startX, startY, startX + contentSize, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "center", "center")
					end

					startY = startY + respc(35) + margin

					drawInput("addReportVehicleType|48", "Jármű típusa", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/car.png")

					startY = startY + respc(40) + margin

					drawInput("addReportVehiclePlate|8", "Jármű rendszáma", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/plate.png")

					startY = startY + respc(40) + margin

					drawInput("addReportReason|60", "Indoklás", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/pencil.png")

					startY = startY + respc(40) + margin * 1.5

					if renderData.editingVehicle then
						local buttonSize = (contentSize - margin * 3) / 2

						drawButton("cancelReportVehicle", "Mégsem", startX + margin, startY, buttonSize, respc(40), tocolor(180, 45, 45), tocolor(200, 60, 60), tocolor(200, 80, 80))

						drawButton("editReportVehicle", "Körözés szerkesztése", startX + margin * 2 + buttonSize, startY, buttonSize, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
					else
						drawButton("addReportVehicle", "Körözés kiadása", startX + margin, startY, contentSize - margin * 2, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
					end
				end

				if currentPage == "wantedPeople" then
					local startX = x + holderSize
					local startY = y + margin

					-- Oszlopok
					dxDrawRectangle(startX + margin, startY, contentSize - margin * 2, respc(35), tocolor(25, 25, 25))

					dxDrawText("Név", startX + margin * 2, startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")
					dxDrawRectangle(startX + margin + respc(250), startY, 1, respc(35), tocolor(100, 100, 100))

					dxDrawText("Indok", startX + margin * 2 + respc(250), startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")

					-- Tartalom
					local tabNum = 9
					local oneSize = respc(25)

					startY = startY + respc(35)

					for i = 1, tabNum do
						local rowY = startY + oneSize * (i - 1)

						if i % 2 == 0 then
							dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(0, 0, 0, 25))
						else
							dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(255, 255, 255, 10))
						end

						local record = renderData.peopleList[i + renderData.wantedPeopleOffset]

						if record then
							if renderData.editingPerson == record.id then
								dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(5, 115, 195, 150))
							elseif activeButton == "editPerson:" .. i + renderData.wantedPeopleOffset then
								dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(255, 255, 255, 15))
							end

							buttons["editPerson:" .. i + renderData.wantedPeopleOffset] = {startX + margin, rowY, contentSize - margin * 4 - respc(22), oneSize}

							dxDrawText(record.name, startX + margin * 2, rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")
							dxDrawText(record.reason, startX + margin * 2 + respc(250), rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")

							if activeButton == "delReportPerson:" .. record.id then
								dxDrawImage(math.floor(startX + contentSize - margin * 2 - respc(22)), math.floor(rowY + oneSize / 2 - respc(11)), respc(22), respc(22), "files/images/icons/close.png", 0, 0, 0, tocolor(232, 17, 35))
							else
								dxDrawImage(math.floor(startX + contentSize - margin * 2 - respc(22)), math.floor(rowY + oneSize / 2 - respc(11)), respc(22), respc(22), "files/images/icons/close.png")
							end

							buttons["delReportPerson:" .. record.id] = {startX + contentSize - margin * 2 - respc(22), rowY, respc(22), respc(22)}
						end
					end

					local listHeight = tabNum * oneSize

					if #renderData.peopleList > tabNum then
						local gripSize = listHeight / #renderData.peopleList

						dxDrawRectangle(startX + contentSize - margin - respc(5), startY, respc(5), listHeight, tocolor(75, 75, 75))
						dxDrawRectangle(startX + contentSize - margin - respc(5), startY + renderData.wantedPeopleOffset * gripSize, respc(5), tabNum * gripSize, tocolor(125, 125, 125))
					end

					drawRectangleOutline(startX + margin, y + margin, contentSize - margin * 2, respc(35) + listHeight, tocolor(50, 50, 50))

					startY = startY + listHeight

					-- Kereső mező
					startY = startY + margin

					drawInput("searchByName|30", "Keresés név alapján...", startX + margin + 2, startY + 2, contentSize - respc(150) - margin * 2 - 4, respc(40) - 4, false, "files/images/icons/search.png")
					drawButton("searchByName", "Keresés", startX + contentSize - respc(150) - margin, startY, respc(150), respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))

					-- Körözés kiadás
					startY = startY + respc(40) + margin

					dxDrawRectangle(startX + margin, startY, contentSize - margin * 2, respc(35), tocolor(25, 25, 25))

					if renderData.editingPerson then
						dxDrawText("Körözés szerkesztése (" .. renderData.editingPersonName .. ")", startX, startY, startX + contentSize, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "center", "center")
					else
						dxDrawText("Körözés kiadása", startX, startY, startX + contentSize, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "center", "center")
					end

					startY = startY + respc(35) + margin

					drawInput("addReportPersonName|30", "Személy neve", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/user.png")

					startY = startY + respc(40) + margin

					drawInput("addReportReason|60", "Indok", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/pencil.png")

					startY = startY + respc(40) + margin

					drawInput("addReportPersonVisual|60", "Személyleírás", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/pencil.png")

					startY = startY + respc(40) + margin * 1.5

					if renderData.editingPerson then
						local buttonSize = (contentSize - margin * 3) / 2

						drawButton("cancelReportPerson", "Mégsem", startX + margin, startY, buttonSize, respc(40), tocolor(180, 45, 45), tocolor(200, 60, 60), tocolor(200, 80, 80))

						drawButton("editReportPerson", "Körözés szerkesztése", startX + margin * 2 + buttonSize, startY, buttonSize, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
					else
						drawButton("addReportPerson", "Körözés kiadása", startX + margin, startY, contentSize - margin * 2, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
					end
				end

				if currentPage == "punishedPeople" then
					local startX = x + holderSize
					local startY = y + margin

					-- Oszlopok
					dxDrawRectangle(startX + margin, startY, contentSize - margin * 2, respc(35), tocolor(25, 25, 25))

					dxDrawText("Név", startX + margin * 2, startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")
					dxDrawRectangle(startX + margin + respc(200), startY, 1, respc(35), tocolor(100, 100, 100))

					dxDrawText("Bírság", startX + margin * 2 + respc(200), startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")
					dxDrawRectangle(startX + margin + respc(275), startY, 1, respc(35), tocolor(100, 100, 100))

					dxDrawText("Börtönbüntetés", startX + margin * 2 + respc(275), startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")
					dxDrawRectangle(startX + margin + respc(400), startY, 1, respc(35), tocolor(100, 100, 100))

					dxDrawText("Indok", startX + margin * 2 + respc(400), startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")

					-- Tartalom
					local tabNum = 7
					local oneSize = respc(25)

					startY = startY + respc(35)

					for i = 1, tabNum do
						local rowY = startY + oneSize * (i - 1)

						if i % 2 == 0 then
							dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(0, 0, 0, 25))
						else
							dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(255, 255, 255, 10))
						end

						local record = renderData.punishmentList[i + renderData.punishmentOffset]

						if record then
							dxDrawText(record.name, startX + margin * 2, rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")
							dxDrawText(record.ticket, startX + margin * 2 + respc(200), rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")
							dxDrawText(record.jail, startX + margin * 2 + respc(275), rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")
							dxDrawText(record.reason, startX + margin * 2 + respc(400), rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")

							if activeButton == "delPunishment:" .. record.id then
								dxDrawImage(math.floor(startX + contentSize - margin * 2 - respc(22)), math.floor(rowY + oneSize / 2 - respc(11)), respc(22), respc(22), "files/images/icons/close.png", 0, 0, 0, tocolor(232, 17, 35))
							else
								dxDrawImage(math.floor(startX + contentSize - margin * 2 - respc(22)), math.floor(rowY + oneSize / 2 - respc(11)), respc(22), respc(22), "files/images/icons/close.png")
							end

							buttons["delPunishment:" .. record.id] = {startX + contentSize - margin * 2 - respc(22), rowY, respc(22), respc(22)}
						end
					end

					local listHeight = tabNum * oneSize

					if #renderData.punishmentList > tabNum then
						local gripSize = listHeight / #renderData.punishmentList

						dxDrawRectangle(startX + contentSize - margin - respc(5), startY, respc(5), listHeight, tocolor(75, 75, 75))
						dxDrawRectangle(startX + contentSize - margin - respc(5), startY + renderData.punishmentOffset * gripSize, respc(5), tabNum * gripSize, tocolor(125, 125, 125))
					end

					drawRectangleOutline(startX + margin, y + margin, contentSize - margin * 2, respc(35) + listHeight, tocolor(50, 50, 50))

					startY = startY + listHeight

					-- Kereső mező
					startY = startY + margin

					drawInput("searchPunishment|30", "Keresés név alapján...", startX + margin + 2, startY + 2, contentSize - respc(150) - margin * 2 - 4, respc(40) - 4, false, "files/images/icons/search.png")
					drawButton("searchPunishment", "Keresés", startX + contentSize - respc(150) - margin, startY, respc(150), respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))

					-- Körözés kiadás
					startY = startY + respc(40) + margin

					dxDrawRectangle(startX + margin, startY, contentSize - margin * 2, respc(35), tocolor(25, 25, 25))
					dxDrawText("Büntetés hozzáadása", startX, startY, startX + contentSize, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "center", "center")

					startY = startY + respc(35) + margin

					drawInput("addPunishmentName|30", "Személy neve", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/user.png")

					startY = startY + respc(40) + margin

					drawInput("addPunishmentTicket|8", "Bírság", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/dollar.png")

					startY = startY + respc(40) + margin

					drawInput("addPunishmentJail|8", "Börtönbüntetés", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/clock.png")

					startY = startY + respc(40) + margin

					drawInput("addPunishmentReason|30", "Indok", startX + margin + 2, startY + 2, contentSize - margin * 2 - respc(32) - 4, respc(40) - 4, "files/images/icons/pencil.png")

					startY = startY + respc(40) + margin * 1.5

					drawButton("addPunishment", "Büntetés hozzáadása", startX + margin, startY, contentSize - margin * 2, respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
				end

				if currentPage == "btk" then
					local startX = x + holderSize
					local startY = y + margin

					-- Oszlopok
					dxDrawRectangle(startX + margin, startY, contentSize - margin * 2, respc(35), tocolor(25, 25, 25))

					dxDrawText("Büntetés", startX + margin * 2, startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")
					dxDrawText("[Pénzbírság | Börtönbüntetés]", startX + margin * 2 + respc(400), startY, 0, startY + respc(35), tocolor(255, 255, 255), 0.75, Roboto, "left", "center")

					-- Tartalom
					local tabNum = 19
					local oneSize = respc(25)

					startY = startY + respc(35)

					for i = 1, tabNum do
						local rowY = startY + oneSize * (i - 1)

						if i % 2 == 0 then
							dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(0, 0, 0, 25))
						else
							dxDrawRectangle(startX + margin, rowY, contentSize - margin * 2, oneSize, tocolor(255, 255, 255, 10))
						end

						local dat = renderData.btkList[i + renderData.btkOffset]

						if dat then
							dxDrawText(dat[1], startX + margin * 2, rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)
							dxDrawText(dat[2], startX + margin * 2 + respc(400), rowY, startX + contentSize, rowY + oneSize, tocolor(255, 255, 255), 0.65, Roboto, "left", "center")
						end
					end

					local listHeight = tabNum * oneSize

					if #renderData.btkList > tabNum then
						local gripSize = listHeight / #renderData.btkList

						dxDrawRectangle(startX + contentSize - margin - respc(5), startY, respc(5), listHeight, tocolor(75, 75, 75))
						dxDrawRectangle(startX + contentSize - margin - respc(5), startY + renderData.btkOffset * gripSize, respc(5), tabNum * gripSize, tocolor(125, 125, 125))
					end

					drawRectangleOutline(startX + margin, y + margin, contentSize - margin * 2, respc(35) + listHeight, tocolor(50, 50, 50))

					startY = startY + listHeight

					-- Kereső mező
					startY = startY + margin

					drawInput("searchBTK|30", "Keresés büntetés alapján...", startX + margin + 2, startY + 2, contentSize - respc(150) - margin * 2 - 4, respc(40) - 4, false, "files/images/icons/search.png")
					drawButton("searchBTK", "Keresés", startX + contentSize - respc(150) - margin, startY, respc(150), respc(40), tocolor(51, 51, 51), tocolor(5, 115, 195), tocolor(105, 160, 200))
				end
			end

			-- ** Gombok
			local cx, cy = getCursorPosition()

			activeButton = false

			if cx and cy then
				cx = cx * screenX
				cy = cy * screenY

				for k, v in pairs(buttons) do
					if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			end
		end
	end, true, "low-999")

local loginClickTick = 0

addEvent("onClientGotMDCData", true)
addEventHandler("onClientGotMDCData", getRootElement(),
	function (data)
		currentPage = "wantedCars"
		loggedInMDC = data
		playSound("files/sounds/login.mp3")
	end)

addEvent("onClientGotMDCVehicles", true)
addEventHandler("onClientGotMDCVehicles", getRootElement(),
	function (data)
		if loggedInMDC then
			vehicleList = data
			renderData.vehicleList = vehicleList
		end
	end)

local backupBlips = {}

addEvent("createBlipForOfficers", true)
addEventHandler("createBlipForOfficers", getRootElement(),
	function (player, reason)
		if exports.see_groups:isPlayerOfficer(localPlayer) or exports.see_groups:isPlayerInGroup(localPlayer, 2) or exports.see_groups:isPlayerInGroup(localPlayer, 18) then
			if reason then
				backupBlips[player] = createBlip(0, 0, 0, 0, 2, 215, 89, 89)
				setElementData(backupBlips[player], "blipTooltipText", "Erősítés ("..reason..")")
				setSoundVolume(volume, 0.5)
				attachElements(backupBlips[player], player)
			else
				if isElement(backupBlips[player]) then
					destroyElement(backupBlips[player])
				end
			end
		end
	end)

addEvent("createBlipForOfficers", true)
addEventHandler("createBlipForOfficers", getRootElement(),
	function (data)
		if loggedInMDC then
			peopleList = data
			renderData.peopleList = peopleList
		end
	end)

	addEvent("onClientGotMDCPeople", true)
addEventHandler("onClientGotMDCPeople", getRootElement(),
	function (data)
		if loggedInMDC then
			peopleList = data
			renderData.peopleList = peopleList
		end
	end)

addEvent("onClientGotMDCPunishment", true)
addEventHandler("onClientGotMDCPunishment", getRootElement(),
	function (data)
		if loggedInMDC then
			punishmentList = data
			renderData.punishmentList = punishmentList
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if panelState then
			if button == "left" and state == "down" then
				if isCursorInPos(loggedPos.x - respc(50), loggedPos.y, respc(1000), respc(40)) then
					local cursorX, cursorY = getCursorPosition()
					posOffSetX, posOffSetY = cursorX * screenX - loggedPos.x, cursorY * screenY - loggedPos.y
					renderMove = true
				end
			elseif button == "left" and state == "up" then
				renderMove = false
			end
			
			if button == "left" then
				if activeButton then
					local selected = split(activeButton, ":")

					if state == "down" then
						if inputError == "searchByPlate|8" then
							renderData.vehicleList = vehicleList
						elseif inputError == "searchByName|30" then
							renderData.peopleList = peopleList
						elseif inputError == "searchPunishment|30" then
							renderData.punishmentList = punishmentList
						elseif inputError == "searchBTK|30" then
							renderData.btkList = btkList
						end

						activeFakeInput = false

						if selected[1] == "setFakeInput" then
							activeFakeInput = selected[2]
							caretIndex = false
							inputError = false
						end

						if selected[1] == "exit" then
							closeMDC()
						end
					else
						if selected[1] == "login" then
							local elapsedTime = getTickCount() - loginClickTick

							if elapsedTime >= 10000 then
								if utf8.len(fakeInputValue["username|24"]) < 1 or utf8.len(fakeInputValue["password|24|hash"]) < 1 then
									exports.see_accounts:showInfo("e", "Minden mező kitöltése kötelező!")
								else
									loginClickTick = getTickCount()
									triggerServerEvent("tryToLoginMDC", localPlayer, fakeInputValue["username|24"], sha256(fakeInputValue["password|24|hash"]))
									fakeInputValue = {}
								end
							else
								exports.see_accounts:showInfo("e", "Várj még " .. 10 - math.floor(elapsedTime / 1000) .. " másodpercet az újrapróbálkozásig!")
							end
						end

						if selected[1] == "setCurrentPage" then
							currentPage = selected[2]
							playSound("files/sounds/mdcnavklikk.mp3")
						end

						if selected[1] == "enterUnit" then
							if string.len(fakeInputValue["unitNum|5|num-only"]) >= 1 then
								setElementData(getPedOccupiedVehicle(localPlayer), "unitNumber", fakeInputValue["unitNum|5|num-only"])
								renderData.unitNumber = fakeInputValue["unitNum|5|num-only"]
								fakeInputValue = {}
								playSound("files/sounds/mdcsetgroup.mp3")
							end
						elseif selected[1] == "delUnit" then
							setElementData(getPedOccupiedVehicle(localPlayer), "unitNumber", false)
							renderData.unitNumber = false
							fakeInputValue = {}
							playSound("files/sounds/mdcnavklikk.mp3")
						elseif selected[1] == "setUnitState" then
							local state = selected[2]

							if state ~= renderData.unitState then

								if state == "off" then
									playSound("files/sounds/mdcnavklikk.mp3")
								elseif state == "patrol" then
									playSound("files/sounds/mdcpatrol.mp3")
								elseif state == "chase" then
									playSound("files/sounds/mdcnavklikk.mp3")
								elseif state == "action" then
									playSound("files/sounds/mdcaction.mp3")
								end

								setElementData(getPedOccupiedVehicle(localPlayer), "unitState", state)
							end
						end

						if selected[1] == "addReportVehicle" then
							local vehtype = fakeInputValue["addReportVehicleType|48"]
							local plate = fakeInputValue["addReportVehiclePlate|8"]
							local reason = fakeInputValue["addReportReason|60"]

							if utf8.len(vehtype) < 1 or utf8.len(plate) < 1 or utf8.len(reason) < 1 then
								exports.see_accounts:showInfo("e", "Minden mező kitöltése kötelező!")
							else
								triggerServerEvent("addReportVehicle", localPlayer, vehtype, plate, reason)

								fakeInputValue = {}
							end
						elseif selected[1] == "delReportVehicle" then
							triggerServerEvent("delReportVehicle", localPlayer, tonumber(selected[2]), selected[3])
						end

						if selected[1] == "editVehicle" then
							local offset = tonumber(selected[2])

							renderData.editingVehicle = renderData.vehicleList[offset].id
							renderData.editingVehiclePlate = renderData.vehicleList[offset].plate

							fakeInputValue["addReportVehicleType|48"] = renderData.vehicleList[offset].type
							fakeInputValue["addReportVehiclePlate|8"] = renderData.vehicleList[offset].plate
							fakeInputValue["addReportReason|60"] = renderData.vehicleList[offset].reason
						elseif selected[1] == "editReportVehicle" then
							local vehtype = fakeInputValue["addReportVehicleType|48"]
							local plate = fakeInputValue["addReportVehiclePlate|8"]
							local reason = fakeInputValue["addReportReason|60"]

							if utf8.len(vehtype) < 1 or utf8.len(plate) < 1 or utf8.len(reason) < 1 then
								exports.see_accounts:showInfo("e", "Minden mező kitöltése kötelező!")
							else
								triggerServerEvent("editReportVehicle", localPlayer, renderData.editingVehicle, vehtype, plate, reason)

								renderData.editingVehicle = false
								renderData.editingVehiclePlate = false
								fakeInputValue = {}
							end
						elseif selected[1] == "cancelReportVehicle" then
							renderData.editingVehicle = false
							renderData.editingVehiclePlate = false
							fakeInputValue = {}
						end

						if selected[1] == "addReportPerson" then
							local name = fakeInputValue["addReportPersonName|30"]
							local reason = fakeInputValue["addReportReason|60"]
							local visual = fakeInputValue["addReportPersonVisual|60"]

							if utf8.len(name) < 1 or utf8.len(reason) < 1 or utf8.len(visual) < 1 then
								exports.see_accounts:showInfo("e", "Minden mező kitöltése kötelező!")
							else
								triggerServerEvent("addReportPerson", localPlayer, name, reason, visual)

								fakeInputValue = {}
							end
						elseif selected[1] == "delReportPerson" then
							local id = tonumber(selected[2])

							if id == renderData.editingPerson then
								renderData.editingPerson = false
								renderData.editingPersonName = false
								fakeInputValue = {}
							end

							triggerServerEvent("delReportPerson", localPlayer, id)
						end

						if selected[1] == "editPerson" then
							local offset = tonumber(selected[2])

							renderData.editingPerson = renderData.peopleList[offset].id
							renderData.editingPersonName = renderData.peopleList[offset].name

							fakeInputValue["addReportPersonName|30"] = renderData.peopleList[offset].name
							fakeInputValue["addReportReason|60"] = renderData.peopleList[offset].reason
							fakeInputValue["addReportPersonVisual|60"] = renderData.peopleList[offset].description
						elseif selected[1] == "editReportPerson" then
							local name = fakeInputValue["addReportPersonName|30"]
							local reason = fakeInputValue["addReportReason|60"]
							local visual = fakeInputValue["addReportPersonVisual|60"]

							if utf8.len(name) < 1 or utf8.len(reason) < 1 or utf8.len(visual) < 1 then
								exports.see_accounts:showInfo("e", "Minden mező kitöltése kötelező!")
							else
								triggerServerEvent("editReportPerson", localPlayer, renderData.editingPerson, name, reason, visual)

								renderData.editingPerson = false
								renderData.editingPersonName = false
								fakeInputValue = {}
							end
						elseif selected[1] == "cancelReportPerson" then
							renderData.editingPerson = false
							renderData.editingPersonName = false
							fakeInputValue = {}
						end

						if selected[1] == "addPunishment" then
							local name = fakeInputValue["addPunishmentName|30"]
							local ticket = fakeInputValue["addPunishmentTicket|8"]
							local jail = fakeInputValue["addPunishmentJail|8"]
							local reason = fakeInputValue["addPunishmentReason|30"]

							if utf8.len(name) < 1 or utf8.len(ticket) < 1 or utf8.len(jail) < 1 or utf8.len(reason) < 1 then
								exports.see_accounts:showInfo("e", "Minden mező kitöltése kötelező!")
							else
								triggerServerEvent("addPunishment", localPlayer, name, ticket, jail, reason)

								fakeInputValue = {}
							end
						elseif selected[1] == "delPunishment" then
							triggerServerEvent("delPunishment", localPlayer, tonumber(selected[2]))
						end

						if selected[1] == "searchByPlate" then
							local searchText = fakeInputValue["searchByPlate|8"]

							if utf8.len(searchText) > 0 then
								local result = {}

								searchText = utf8.gsub(utf8.lower(searchText), "%-", "%%-")

								for i = 1, #vehicleList do
									local record = vehicleList[i]

									if record then
										if utf8.find(utf8.lower(record.plate), searchText) then
											table.insert(result, record)
										end
									end
								end

								renderData.vehicleList = result

								if #result == 0 then
									inputError = "searchByPlate|8"
									inputErrorText = "Nincs találat!"
								end
							else
								renderData.vehicleList = vehicleList
							end
						elseif selected[1] == "searchByName" then
							local searchText = fakeInputValue["searchByName|30"]

							if utf8.len(searchText) > 0 then
								local result = {}

								searchText = utf8.lower(searchText)

								for i = 1, #peopleList do
									local record = peopleList[i]

									if record then
										if utf8.find(utf8.lower(record.name), searchText) then
											table.insert(result, record)
										end
									end
								end

								renderData.peopleList = result

								if #result == 0 then
									inputError = "searchByName|30"
									inputErrorText = "Nincs találat!"
								end
							else
								renderData.peopleList = peopleList
							end
						elseif selected[1] == "searchPunishment" then
							local searchText = fakeInputValue["searchPunishment|30"]

							if utf8.len(searchText) > 0 then
								local result = {}

								searchText = utf8.lower(searchText)

								for i = 1, #punishmentList do
									local record = punishmentList[i]

									if record then
										if utf8.find(utf8.lower(record.name), searchText) then
											table.insert(result, record)
										end
									end
								end

								renderData.punishmentList = result

								if #result == 0 then
									inputError = "searchPunishment|30"
									inputErrorText = "Nincs találat!"
								end
							else
								renderData.punishmentList = punishmentList
							end
						elseif selected[1] == "searchBTK" then
							local searchText = fakeInputValue["searchBTK|30"]

							if utf8.len(searchText) > 0 then
								local result = {}

								searchText = utf8.lower(searchText)

								for i = 1, #btkList do
									local dat = btkList[i]

									if dat then
										if utf8.find(utf8.lower(dat[1]), searchText) then
											table.insert(result, dat)
										end
									end
								end

								renderData.btkList = result

								if #result == 0 then
									inputError = "searchBTK|30"
									inputErrorText = "Nincs találat!"
								end
							else
								renderData.btkList = btkList
							end
						end
					end
				else
					if state == "down" then
						activeFakeInput = false
					end
				end
			end
		end
	end)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if panelState then
			if press then
				if key == "v" and getKeyState("lctrl") or key == "v" and getKeyState("rctrl") or "m" and not activeFakeInput then
					return
				end

				if key ~= "escape" then
					cancelEvent()
				end

				if loggedInMDC then
					local cx, cy = getCursorPosition()

					if cx and cy then
						cx = cx * screenX
						cy = cy * screenY

						if currentPage == "wantedCars" then
							if key == "mouse_wheel_up" then
								if renderData.wantedCarsOffset > 0 then
									renderData.wantedCarsOffset = renderData.wantedCarsOffset - 1
								end
							elseif key == "mouse_wheel_down" then
								if renderData.wantedCarsOffset < #renderData.vehicleList - 9 then
									renderData.wantedCarsOffset = renderData.wantedCarsOffset + 1
								end
							end
						end

						if currentPage == "wantedPeople" then
							if key == "mouse_wheel_up" then
								if renderData.wantedPeopleOffset > 0 then
									renderData.wantedPeopleOffset = renderData.wantedPeopleOffset - 1
								end
							elseif key == "mouse_wheel_down" then
								if renderData.wantedPeopleOffset < #renderData.peopleList - 9 then
									renderData.wantedPeopleOffset = renderData.wantedPeopleOffset + 1
								end
							end
						end

						if currentPage == "punishedPeople" then
							if key == "mouse_wheel_up" then
								if renderData.punishmentOffset > 0 then
									renderData.punishmentOffset = renderData.punishmentOffset - 1
								end
							elseif key == "mouse_wheel_down" then
								if renderData.punishmentOffset < #renderData.punishmentList - 7 then
									renderData.punishmentOffset = renderData.punishmentOffset + 1
								end
							end
						end

						if currentPage == "btk" then
							if key == "mouse_wheel_up" then
								if renderData.btkOffset > 0 then
									renderData.btkOffset = renderData.btkOffset - 1
								end
							elseif key == "mouse_wheel_down" then
								if renderData.btkOffset < #renderData.btkList - 21 then
									renderData.btkOffset = renderData.btkOffset + 1
								end
							end
						end
					end
				end

				if key == "backspace" then
					if activeFakeInput then
						subFakeInputText(activeFakeInput)

						if getKeyState(key) then
							repeatStartTimer = setTimer(subFakeInputText, 500, 1, activeFakeInput, true)
						end
					end
				end

				if key == "arrow_l" then
					if activeFakeInput then
						if utf8.len(fakeInputValue[activeFakeInput]) > 1 then
							if not caretIndex then
								caretIndex = utf8.len(fakeInputValue[activeFakeInput])
							end

							caretIndex = caretIndex - 1

							if caretIndex < 0 then
								caretIndex = 0
							end
						end
					end
				end

				if key == "arrow_r" then
					if activeFakeInput then
						if caretIndex then
							caretIndex = caretIndex + 1

							if caretIndex > utf8.len(fakeInputValue[activeFakeInput]) then
								caretIndex = false
							end
						end
					end
				end

				if key == "c" then
					if activeFakeInput then
						if getKeyState("lctrl") or getKeyState("rctrl") then
							local text = fakeInputValue[activeFakeInput]
							local length = utf8.len(text)

							if string.find(activeFakeInput, "hash") then
								if length > 0 then
									text = string.rep("•", length)
								end
							end

							setClipboard(text)
						end
					end
				end
			end
		end

		if not press then
			if isTimer(repeatStartTimer) then
				killTimer(repeatStartTimer)
			end

			if isTimer(repeatTimer) then
				killTimer(repeatTimer)
			end
		end
	end)

addEventHandler("onClientCharacter", getRootElement(),
	function (character)
		if panelState then
			if activeFakeInput then
				local details = split(activeFakeInput, "|")

				if utf8.len(fakeInputValue[activeFakeInput]) < tonumber(details[2]) then
					if details[3] == "num-only" then
						if not tonumber(character) then
							return
						end
					end

					if caretIndex then
						caretIndex = caretIndex + 1
						fakeInputValue[activeFakeInput] = utf8.insert(fakeInputValue[activeFakeInput], caretIndex, tostring(character))
					else
						fakeInputValue[activeFakeInput] = utf8.insert(fakeInputValue[activeFakeInput], tostring(character))
					end

					playSound("files/sounds/key" .. math.random(1, 3) .. ".mp3")
				end
			end
		end
	end)

addEventHandler("onClientPaste", getRootElement(),
	function (clipboardText)
		if panelState then
			if activeFakeInput then
				local details = split(activeFakeInput, "|")
				local clipLength = utf8.len(clipboardText)
				local currLength = utf8.len(fakeInputValue[activeFakeInput])
				local remainingLength = tonumber(details[2]) - currLength

				if remainingLength > 0 then
					local finalText = clipboardText

					if clipLength > remainingLength then
						finalText = utf8.sub(clipboardText, 1, remainingLength)
					end

					if details[3] == "num-only" then
						if not tonumber(finalText) then
							return
						end
					end

					if caretIndex then
						caretIndex = caretIndex + utf8.len(finalText)
						fakeInputValue[activeFakeInput] = utf8.insert(fakeInputValue[activeFakeInput], caretIndex, tostring(finalText))
					else
						fakeInputValue[activeFakeInput] = utf8.insert(fakeInputValue[activeFakeInput], tostring(finalText))
					end
				end
			end
		end
	end)

function subFakeInputText(inputName, repeatTheTimer)
	if utf8.len(fakeInputValue[inputName]) > 0 then
		if caretIndex then
			if caretIndex > 0 then
				fakeInputValue[inputName] = utf8.sub(fakeInputValue[inputName], 1, caretIndex - 1) .. utf8.sub(fakeInputValue[inputName], caretIndex + 1, utf8.len(fakeInputValue[inputName]))
				caretIndex = caretIndex - 1
			end
		else
			fakeInputValue[inputName] = utf8.sub(fakeInputValue[inputName], 1, -2)
		end

		if repeatTheTimer then
			repeatTimer = setTimer(subFakeInputText, 50, 1, inputName, repeatTheTimer)
		end
	end
end

function getFitFontScale(text, scale, font, maxwidth)
	local scaleex = scale

	while true do
		if dxGetTextWidth(text, scaleex, font) > maxwidth then
			scaleex = scaleex - 0.01
		else
			break
		end
	end

	return scaleex
end

function drawInput(id, placeholder, x, y, sx, sy, icon, innericon)
	if not fakeInputValue[id] then
		fakeInputValue[id] = ""
	end

	local hash = false
	local length = utf8.len(fakeInputValue[id])

	if string.find(id, "hash") then
		if length > 0 then
			hash = string.rep("•", length)
		end
	end

	local text = hash

	if not hash then
		text = fakeInputValue[id]
	end

	if icon then
		buttons["setFakeInput:" .. id] = {x + respc(32), y, sx, sy}
	else
		buttons["setFakeInput:" .. id] = {x, y, sx, sy}
	end

	local scale = 0.75

	if length == 0 and placeholder then
		scale = getFitFontScale(placeholder, 0.75, Roboto, sx - respc(10))
	else
		scale = getFitFontScale(text, 0.75, Roboto, sx - respc(10))
	end

	if activeFakeInput == id then
		if icon then
			dxDrawRectangle(x, y - 2, respc(32), sy + 4, tocolor(7, 112, 196))
			dxDrawImage(x, y + sy / 2 - respc(32) / 2, respc(32), respc(32), icon)

			x = x + respc(32)
		end

		dxDrawRectangle(x, y, sx, sy, tocolor(255, 255, 255))
		drawRectangleOutline(x, y, sx, sy, tocolor(7, 112, 196), 2)

		if innericon then
			if length == 0 and placeholder then
				dxDrawImage(x + sx - respc(32), y + sy / 2 - respc(32) / 2, respc(32), respc(32), innericon, 0, 0, 0, tocolor(167, 167, 167))
			else
				dxDrawImage(x + sx - respc(32), y + sy / 2 - respc(32) / 2, respc(32), respc(32), innericon, 0, 0, 0, tocolor(0, 0, 0))
			end

			sx = sx - respc(32)
		end

		if length == 0 and placeholder then
			dxDrawText(placeholder, x + respc(10), y, x + sx - respc(10), y + sy, tocolor(167, 167, 167), scale, 0.75, Roboto, "left", "center", true)
		else
			dxDrawText(text, x + respc(10), y, x + sx - respc(10), y + sy, tocolor(0, 0, 0), scale, 0.75, Roboto, "left", "center", true)
		end

		local progress = math.abs(getTickCount() % 750 - 375) / 375

		if progress > 0.5 then
			local textWidth = 0

			if caretIndex then
				textWidth = dxGetTextWidth(utf8.sub(text, 1, caretIndex), scale, Roboto)
			else
				textWidth = dxGetTextWidth(text, scale, Roboto)
			end

			local caretX = x + respc(10) + textWidth

			if caretX > x + sx - respc(10) then
				caretX = x + sx - respc(10)
			end

			dxDrawRectangle(caretX, y + respc(5), 1, sy - respc(10), tocolor(0, 0, 0))
		end
	else
		local color = tocolor(75, 75, 75)
		local bgcolor = tocolor(0, 0, 0, 100)

		if inputError == id then
			color = tocolor(232, 17, 35)
			bgcolor = tocolor(255, 255, 255)
		elseif activeButton == "setFakeInput:" .. id then
			color = tocolor(100, 100, 100)
		end

		if icon then
			dxDrawRectangle(x, y - 2, respc(32), sy + 4, color)
			dxDrawImage(x, y + sy / 2 - respc(32) / 2, respc(32), respc(32), icon)

			x = x + respc(32)
		end

		dxDrawRectangle(x, y, sx, sy, bgcolor)
		drawRectangleOutline(x, y, sx, sy, color, 2)

		if innericon then
			if inputError == id then
				dxDrawImage(x + sx - respc(32), y + sy / 2 - respc(32) / 2, respc(32), respc(32), innericon, 0, 0, 0, tocolor(232, 17, 35))
			elseif length == 0 and placeholder then
				dxDrawImage(x + sx - respc(32), y + sy / 2 - respc(32) / 2, respc(32), respc(32), innericon, 0, 0, 0, tocolor(75, 75, 75))
			else
				dxDrawImage(x + sx - respc(32), y + sy / 2 - respc(32) / 2, respc(32), respc(32), innericon, 0, 0, 0, tocolor(255, 255, 255))
			end

			sx = sx - respc(32)
		end

		if inputError == id and inputErrorText then
			dxDrawText(inputErrorText, x + respc(10), y, x + sx - respc(10), y + sy, tocolor(232, 17, 35), scale, 0.75, Roboto, "left", "center", true)
		elseif length == 0 and placeholder then
			dxDrawText(placeholder, x + respc(10), y, x + sx - respc(10), y + sy, tocolor(75, 75, 75), scale, 0.75, Roboto, "left", "center", true)
		else
			dxDrawText(text, x + respc(10), y, x + sx - respc(10), y + sy, tocolor(255, 255, 255), scale, 0.75, Roboto, "left", "center", true)
		end
	end
end

function drawButton(id, text, x, y, sx, sy, bgcolor, bordercolor, presscolor, scale)
	if activeButton == id then
		bgcolor = bordercolor
	end

	dxDrawRectangle(x, y, sx, sy, bgcolor)

	if activeButton == id then
		if getKeyState("mouse1") then
			drawRectangleOutline(x + 2, y + 2, sx - 4, sy - 4, presscolor, 2)
		end
	end

	dxDrawText(text, x, y, x + sx, y + sy, tocolor(255, 255, 255), scale or 0.85, Roboto, "center", "center")

	buttons[id] = {x, y, sx, sy}

	return x + sx
end

function drawRectangleOutline(x, y, sx, sy, color, thickness)
	thickness = thickness or 1
	dxDrawRectangle(x, y - thickness, sx, thickness, color) -- felső
	dxDrawRectangle(x, y + sy, sx, thickness, color) -- alsó
	dxDrawRectangle(x - thickness, y - thickness, thickness, sy + thickness * 2, color) -- bal
	dxDrawRectangle(x + sx, y - thickness, thickness, sy + thickness * 2, color) -- jobb
end

function drawRectangleOutlineEx(x, y, sx, sy, color, thickness)
	thickness = thickness or 1
	dxDrawRectangle(x, y - thickness, sx, thickness, color) -- felső
	dxDrawRectangle(x, y + sy, sx, thickness, color) -- alsó
	dxDrawRectangle(x - thickness, y, thickness, sy, color) -- bal
	dxDrawRectangle(x + sx, y, thickness, sy, color) -- jobb
end

function isCursorInPos(posX, posY, width, height)
	if isCursorShowing() then
		local mouseX, mouseY = getCursorPosition()
		local clientW, clientH = guiGetScreenSize()
		local mouseX, mouseY = mouseX * clientW, mouseY * clientH;
		if (mouseX > posX and mouseX < (posX+width) and mouseY > posY and mouseY < (posY+height)) then
			return true;
		end
	end
	return false
end


local MdcStates = {
    [0] = "off",
    [1] = "patrol",
    [2] = "chase",
    [3] = "action"
}

local MdcFactions = {
    [1] = true,
    [12] = true,
    [13] = true,
    [26] = true
}

addCommandHandler("mdcstate", 
    function(Command, State)
        local Vehicle = getPedOccupiedVehicle(localPlayer)

        if Vehicle and getPedOccupiedVehicleSeat(localPlayer) == 0 or getPedOccupiedVehicleSeat(localPlayer) == 1 then
            local VehicleModel = getElementModel(Vehicle)
            local GroupId = getElementData(Vehicle, "vehicle.group") or 0
            if mdcVehicles[VehicleModel] and MdcFactions[GroupId] and loggedInMDC then
                if tonumber(State) and tonumber(State) >= 0 and tonumber(State) < 4 then
                    setElementData(Vehicle, "unitState", MdcStates[tonumber(State)])
                else
                    outputChatBox("#7cc576[Használat]: #ffffff/" .. Command .. ": [0-3]", 255, 255, 255, true)
                end
            end
        end
    end
)

addEvent("clearBlips", true)
addEventHandler("clearBlips", getRootElement(),
	function ()
		source = localPlayer
		for k, v in pairs(atmRobBlips) do
			destroyElement(v)
		end
	end 
)

local Robot = dxCreateFont("files/fonts/Roboto.ttf", respc(12), false, "antialiased")

local blackColor = tocolor(0, 0, 0)

function dxDrawBorderedText(text, x, y, w, h, color, ...)
	local textWithoutHEX = string.gsub(text, "#%x%x%x%x%x%x", "")
	dxDrawText(textWithoutHEX, x - 1, y - 1, w - 1, h - 1, blackColor, ...)
	dxDrawText(textWithoutHEX, x - 1, y + 1, w - 1, h + 1, blackColor, ...)
	dxDrawText(textWithoutHEX, x + 1, y - 1, w + 1, h - 1, blackColor, ...)
	dxDrawText(textWithoutHEX, x + 1, y + 1, w + 1, h + 1, blackColor, ...)
	dxDrawText(text, x, y, w, h, color, ...)
end

local signableVehicles = {
	[416] = true, 
	[427] = true, 
	[490] = true,
	[497] = true,
	[528] = true, 
	[596] = true,
	[597] = true,
	[598] = true,
	[599] = true,
	[601] = true,
}

local canSetSign = false

addCommandHandler("setsign",
	function (commandName, text)

		local pedVehicle = getPedOccupiedVehicle(localPlayer)
		local groupVehicle = getElementData(pedVehicle, "vehicle.group") or 0

		if signableVehicles[getElementModel(pedVehicle)] or groupVehicle > 0 then 
			canSetSign = true 
		else
			if pedVehicle and not signableVehicles[getElementModel(pedVehicle)] then
				outputChatBox("#d75959[StrongMTA]: #ffffffEbben a járműben ez a funkció nem használható.", 255, 255, 255, true)
			end
			--outputChatBox("#d75959[StrongMTA]: #ffffffNem ülsz járműben.", 255, 255, 255, true)
		end

		if not exports.see_groups:isPlayerOfficer(localPlayer) then 
			canSetSign = false 
		end

		if not canSetSign then 
			return 
		end

		print(canSetSign)

		if pedVehicle then 
			if not getElementData(pedVehicle, "set") then
				if not text then
					if getElementData(pedVehicle, "set") then 
						text = "a"
					else
						text = false
					end
					outputChatBox("#7cc576[Használat]: #ffffff/" .. commandName .. " [Név]", 255, 255, 255, true)
				else
					if utfLen(text) > 12 then
						return outputChatBox("#d75959[StrongMTA]: #ffffffAz azonosító nem lehet nagyobb mint 12 karakter.", 255, 255, 255, true)
					end
					setElementData(pedVehicle, "policeCarSign", tostring(text))
					outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen átállítottad a járműved egységazonosítóját. #32b3ef(" .. tostring(text) .. ")", 255, 255, 255, true)
					outputChatBox("#3d7abc[StrongMTA]: #ffffffA parancs újboli beírásával leveheted az azonosoítót.", 255, 255, 255, true)
					setElementData(pedVehicle, "set", true)
					triggerServerEvent("reportChangeSign", localPlayer, text)
				end
			else
				setElementData(pedVehicle, "policeCarSign", false)
				setElementData(pedVehicle, "set", false)
				outputChatBox("#3d7abc[StrongMTA]: #ffffffA járművedről lekerült az azonosító.", 255, 255, 255, true)
			end
		else
			outputChatBox("#d75959[StrongMTA]: #ffffffNem ülsz járműben.", 255, 255, 255, true)
		end
	end 
)

addEventHandler("onClientRender", root, function()
	--if getElementData(localPlayer, "groupDuty") then
		local pX, pY, pZ = getElementPosition(localPlayer)
		for k, v in pairs(getElementsByType("vehicle")) do
			if v then
				if getElementData(v, "policeCarSign") then
					if isElement(v) then
						local vX, vY, vZ = getElementPosition(v)
						if getDistanceBetweenPoints3D(vX, vY, vZ, pX, pY, pZ) <= 10 then
							local cX, cY, cZ = getVehicleComponentPosition(v, "wheel_rb_dummy", "world")
							local worldX, worldY = getScreenFromWorldPosition(cX, cY, cZ + 0.5, 10)
							if worldX then
								local cameraX, cameraY, cameraZ = getCameraMatrix()
								if isLineOfSightClear(cameraX, cameraY, cameraZ, cX, cY, cZ, true, false, false, true, false, true, false) then
									dxDrawBorderedText(getElementData(v, "policeCarSign"):gsub("_", " ") or "", worldX, worldY, worldX, worldY, tocolor(255, 255, 255), 1, Robot, "center", "center", false, false, false, true)
								end
							end
						end
					end
				end
			end
		end
	--end
end)
