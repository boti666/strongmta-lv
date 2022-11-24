local connection = false
local credentials = {
	dbname = "seemta",
	host = "localhost",
	port = "3306",
	charset = "utf8",
	username = "root",
	password = "nMTHn5DZMy*)[Z/q",
	tag = "seemta",
	multi_statements = "1"
}

addEvent("}Đää{äđÄ&}}Ä&ÄĐ~", true)
addEvent("\€Ä>ÄäĐ>", true)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = dbConnect("mysql", "dbname=" .. credentials.dbname .. ";host=" .. credentials.host .. ";port=" .. credentials.port .. ";charset=" .. credentials.charset, credentials.username, credentials.password, "tag=" .. credentials.tag .. ";multi_statements=" .. credentials.multi_statements)

		if not connection then
			cancelEvent()
		else
			dbExec(connection, "SET NAMES utf8")
		end

		if isElement(connection) then
			triggerEvent("}Đää{äđÄ&}}Ä&ÄĐ~", root, connection)
		end
	end
)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		local playersTable = getElementsByType("player")

		for i = 1, #playersTable do
			local playerElement = playersTable[i]

			if playerElement then
				savePlayer(playerElement, true)
			end
		end

		local vehiclesTable = getElementsByType("vehicle")

		for i = 1, #vehiclesTable do
			local vehicleElement = vehiclesTable[i]

			if vehicleElement then
				saveVehicle(vehicleElement)
			end
		end

		outputDebugString("Database disconnected.")
	end
)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		savePlayer(source, true, true)
	end,
true, "high+999")

addCommandHandler("saveme",
	function (sourcePlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") == 11 then
			if savePlayer(sourcePlayer) then
				outputDebugString("Character saved.")
			else
				outputDebugString("Character saving failed.")
			end
		end
	end
)

function getConnection()
	return connection
end

function dbInsert(tableName, insertValues)
	if tableName and insertValues and type(insertValues) == "table" then
		local columns = {}
		local values = {}

		for column, value in pairs(insertValues) do
			table.insert(columns, column)
			table.insert(values, value)
		end

		local paramString = ("?,"):rep(#columns):sub(1, -2)
		local queryString = dbPrepareString(connection, "INSERT INTO ?? (" .. table.concat(columns, ",") .. ") VALUES (" .. paramString .. ");", tableName, unpack(values))

		return dbExec(connection, queryString)
	end

	return false
end

function dbUpdate(tableName, setFields, whereFields)
	if tableName and setFields and type(setFields) == "table" and whereFields and type(whereFields) == "table" then
		local columns = {}
		local values = {}
		local wheres = {}

		for column, value in pairs(setFields) do
			if string.sub(value, 0, 1) == "%" and string.sub(value, string.len(value)) == "%" then -- speciális esetek, pl. %NULL% vagy %CURRENT_TIMESTAMP%
				table.insert(columns, string.format("`%s`=%s", column, string.gsub(value, "%%", "")))
			else
				table.insert(columns, string.format("`%s`=?", column))
				table.insert(values, value)
			end
		end

		for column, value in pairs(whereFields) do
			table.insert(wheres, string.format("`%s`=?", column))
			table.insert(values, value)
		end

		local queryString = dbPrepareString(connection, "UPDATE ?? SET " .. table.concat(columns, ", ") .. " WHERE " .. table.concat(wheres, " AND ") .. ";", tableName, unpack(values))

		return dbExec(connection, queryString)
	end

	return false
end

function dbSelect(queryIdentifier, tableName, selectFields, whereFields)
	if not (queryIdentifier and tableName) then
		return
	end

	selectFields = selectFields or "*"

	if type(selectFields) == "table" then
		selectFields = table.concat(selectFields, ", ")
	end

	local queryString = "SELECT " .. selectFields .. " FROM ??"
	local queryValues = {}

	if type(whereFields) == "table" then
		local wheres = {}

		for column, value in pairs(whereFields) do
			table.insert(wheres, string.format("`%s`=?", column))
			table.insert(queryValues, value)
		end

		queryString = queryString .. " WHERE " .. table.concat(wheres, " AND ")
	end

	dbQuery(connection,
		function (qHandle)
			triggerEvent("\€Ä>ÄäĐ>", root, queryIdentifier, dbPoll(qHandle, 0))
		end,
	queryString, tableName, unpack(queryValues))
end

function savePlayer(sourcePlayer, loggedOut, containsVehicles)
	if not sourcePlayer then
		sourcePlayer = source
	end

	if getElementData(sourcePlayer, "loggedIn") then
		local accountId = getElementData(sourcePlayer, "char.accID")
		local characterId = getElementData(sourcePlayer, "char.ID")

		if accountId and characterId then
			-- ** Alap adatok
			local playerX, playerY, playerZ = getElementPosition(sourcePlayer)
			local datas = {
				["posX"] = playerX,
				["posY"] = playerY,
				["posZ"] = playerZ,
				["rotZ"] = getPedRotation(sourcePlayer),
				["interior"] = getElementInterior(sourcePlayer),
				["dimension"] = getElementDimension(sourcePlayer),
				["skin"] = getElementModel(sourcePlayer),
				["health"] = getElementHealth(sourcePlayer),
				["armor"] = getPedArmor(sourcePlayer),
				["hunger"] = getElementData(sourcePlayer, "char.Hunger") or 100,
				["thirst"] = getElementData(sourcePlayer, "char.Thirst") or 100,
				["money"] = getElementData(sourcePlayer, "char.Money") or 0,
				["bankMoney"] = getElementData(sourcePlayer, "char.bankMoney") or 0,
				["playTimeForPayday"] = getElementData(sourcePlayer, "char.playTimeForPayday") or 60,
				["slotCoins"] = getElementData(sourcePlayer, "char.slotCoins") or 0,
				["playedMinutes"] = getElementData(sourcePlayer, "char.playedMinutes") or 0,
				["isPlayerDeath"] = getElementData(sourcePlayer, "isPlayerDeath") and 1 or 0,
				["job"] = getElementData(sourcePlayer, "char.Job") or 0,
				["radio"] = getElementData(sourcePlayer, "char.Radio") or 0,
				["radio2"] = getElementData(sourcePlayer, "char.Radio2") or 0,
				["currentClothes"] = getElementData(sourcePlayer, "currentClothes") or "",
				["boughtClothes"] = getElementData(sourcePlayer, "boughtClothes") or "",
				["paintOnPlayerTime"] = getElementData(sourcePlayer, "paintOnPlayerTime") or 0
			}

			if loggedOut then
				datas["lastOnline"] = "%CURRENT_TIMESTAMP%"
			end

			-- ** Frakciók
			local playerGroups = getElementData(sourcePlayer, "player.groups") or {}
			local groupsTable = {}

			for k, v in pairs(playerGroups) do
				table.insert(groupsTable, {
					["groupId"] = k,
					["data"] = v
				})
			end

			datas["groups"] = toJSON(groupsTable, true)
			datas["inDuty"] = getElementData(sourcePlayer, "inDuty") or 0

			if datas["inDuty"] ~= 0 then
				datas["skin"] = getElementData(sourcePlayer, "char.Skin") or 0
			end

			-- ** Actionbar itemek
			local actionBarItemsTable = getElementData(sourcePlayer, "actionBarItems") or {}
			datas["actionBarItems"] = {}

			for i = 1, 6 do
				if actionBarItemsTable[i] then
					table.insert(datas["actionBarItems"], tostring(actionBarItemsTable[i]))
				else
					table.insert(datas["actionBarItems"], "-")
				end
			end

			datas["actionBarItems"] = table.concat(datas["actionBarItems"], ";")

			-- ** Karakter mentése
			dbUpdate("characters", datas, {characterId = characterId})

			if not loggedOut then
				dbExec(connection, "UPDATE accounts SET online = 1 WHERE accountId = ?", accountId)
			else
				dbExec(connection, "UPDATE accounts SET online = 0 WHERE accountId = ?", accountId)
			end

			-- ** Járművek mentése
			if loggedOut and containsVehicles then
				local vehiclesTable = getElementsByType("vehicle")

				for i = 1, #vehiclesTable do
					local vehicleElement = vehiclesTable[i]

					if isElement(vehicleElement) then
						if getElementData(vehicleElement, "vehicle.owner") == characterId then
							local groupId = getElementData(vehicleElement, "vehicle.group") or 0
							local isProtected = getElementData(vehicleElement, "vehicle.protect") or 0

							if saveVehicle(vehicleElement) then
								if groupId == 0 and isProtected == 0 then
									destroyElement(vehicleElement)
								end
							end
						end
					end
				end
			end

			return true
		else
			return false
		end
	else
		return false
	end
end
addEvent("autoSavePlayer", true)
addEventHandler("autoSavePlayer", getRootElement(), savePlayer)

function saveVehicle(sourceVehicle)
	local vehicleId = getElementData(sourceVehicle, "vehicle.dbID")

	if vehicleId then
		-- ** Adatok összegyűjtése
		local model = getElementModel(sourceVehicle)
		local datas = {
			["last_position"] = table.concat({getElementPosition(sourceVehicle)}, ","),
			["last_rotation"] = table.concat({getElementRotation(sourceVehicle)}, ","),
			["last_interior"] = getElementInterior(sourceVehicle),
			["last_dimension"] = getElementDimension(sourceVehicle),
			["health"] = getElementHealth(sourceVehicle),
			["fuel"] = getElementData(sourceVehicle, "vehicle.fuel") or exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(model),
			["engine"] = getElementData(sourceVehicle, "vehicle.engine") or 0,
			["lights"] = getElementData(sourceVehicle, "vehicle.lights") or 0,
			["locked"] = getElementData(sourceVehicle, "vehicle.locked") or 0,
			["handBrake"] = getElementData(sourceVehicle, "vehicle.handBrake") and 1 or 0,
			["distance"] = getElementData(sourceVehicle, "vehicle.distance") or 0,
			["tuningNitroLevel"] = getElementData(sourceVehicle, "vehicle.nitroLevel") or 0,
			["gpsNavigation"] = getElementData(sourceVehicle, "vehicle.GPS") or 0,
			["activeDriveType"] = getElementData(sourceVehicle, "activeDriveType") or "",
			["wheelStates"] = table.concat({getVehicleWheelStates(sourceVehicle)}, "/"),
			["protected"] = (getElementData(sourceVehicle, "vehicle.protect")) or 0,
		}

		local panelStatesTable = {}
		local doorStatesTable = {}

		for i = 0, 6 do
			table.insert(panelStatesTable, getVehiclePanelState(sourceVehicle, i))

			if i < 6 then
				table.insert(doorStatesTable, getVehicleDoorState(sourceVehicle, i))
			end
		end

		datas["panelStates"] = table.concat(panelStatesTable, "/")
		datas["doorStates"] = table.concat(doorStatesTable, "/")

		local speedoColor = getElementData(sourceVehicle, "vehicle.speedoColor") or {255, 255, 255}
		local speedoColor2 = getElementData(sourceVehicle, "vehicle.speedoColor2") or {255, 255, 255}

		datas["speedoColor"] = table.concat({rgbToHex(unpack(speedoColor)), rgbToHex(unpack(speedoColor2))}, ";")

		local airRideMemory1 = getElementData(sourceVehicle, "airRideMemory1") or 8
		local airRideMemory2 = getElementData(sourceVehicle, "airRideMemory2") or 8

		datas["airRideMemory"] = table.concat({airRideMemory1, airRideMemory2}, ",")

		-- ** Elmentés
		dbUpdate("vehicles", datas, {vehicleId = vehicleId})

		return true
	else
		return false
	end
end

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

function hexToRgb(color)
	if color and string.len(color) > 0 then
		color = color:gsub("#", "")
		return tonumber("0x" .. color:sub(1, 2)), tonumber("0x" .. color:sub(3, 4)), tonumber("0x" .. color:sub(5, 6))
	else
		return 255, 255, 255
	end
end

function validHexColor(color)
	return color:match("^%x%x%x%x%x%x$")
end
