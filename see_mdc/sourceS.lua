local connection = false

local groups = {
	PD = 1,
	SWAT = 26,
	SD = 13,
	FBI = 12,
	USSOF = 18,
	NONE = 21
}

local accounts = {}
local wantedcars = {}
local wantedpeople = {}
local punishedpeople = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		
		connection = exports.see_database:getConnection()
		
		dbQuery(
				function (qh)
					local result = dbPoll(qh, 0, true)

					for k, v in ipairs(result[1][1]) do
						table.insert(accounts, v)
					end
					
				end, 
		connection, "SELECT * FROM mdc_accounts")

		dbQuery(
				function (qh)
					local result = dbPoll(qh, 0, true)

					for k, v in ipairs(result[1][1]) do
						table.insert(wantedcars, v)
					end

				end, 
		connection, "SELECT * FROM mdc_wantedcars ORDER BY id DESC")

		dbQuery(
				function (qh)
					local result = dbPoll(qh, 0, true)

					for k, v in ipairs(result[1][1]) do
						table.insert(wantedpeople, v)
					end

				end, 
		connection, "SELECT * FROM mdc_wantedpeople ORDER BY id DESC")
		
		dbQuery(
				function (qh)
					local result = dbPoll(qh, 0, true)

					for k, v in ipairs(result[1][1]) do
						table.insert(punishedpeople, v)
					end

				end, 
		connection, "SELECT * FROM mdc_punishedpeople ORDER BY id DESC")
		
		
	end)


function ServerResponse()
	outputChatBox("info from php")
end

addEvent("reportChangeSign", true)
addEventHandler("reportChangeSign", getRootElement(),
	function (changedText)
		if isElement(source) and client and client == source then 
			exports.see_administration:showAdminLog("#32b3ef" .. getElementData(source, "visibleName"):gsub("_", " ") .. " #ffffffmegváltoztatta a járműve azonosítóját. #32b3ef(" .. changedText .. ")", 6)
			exports.see_webhook:sendDiscordMessage("```"..getElementData(source, "visibleName"):gsub("_", " ") .. " megváltoztatta a járműve azonosítóját. ("..changedText..")```", "callsign")
		end
	end 
)

addEvent("reportKill", true)
addEventHandler("reportKill", getRootElement(),
	function (vehicle, zoneName)
		if source == client and zoneName then
			local suspectName = "ismeretlen"
			local wantedReason = false

			if isElement(vehicle) then
				local plateText = getVehiclePlateText(vehicle)
				local reasons = {}

				if plateText then
					plateText = fixPlateText(plateText)

					for i = 1, #wantedcars do
						local dat = wantedcars[i]

						if dat and dat.plate == plateText then
							table.insert(reasons, dat.reason)
						end
					end
				end

				if #reasons > 0 then
					wantedReason = table.concat(reasons, "; ")
				end

				triggerClientEvent(getElementsByType("player"), "killAlertFromServer", source, suspectName, vehicle, false, wantedReason, zoneName)
			else
				local visibleName = getElementData(source, "visibleName"):gsub("_", " ")
				local reasons = {}

				for i = 1, #wantedpeople do
					local dat = wantedpeople[i]

					if dat and dat.name == visibleName then
						suspectName = dat.name
						table.insert(reasons, dat.reason)
					end
				end

				if #reasons > 0 then
					wantedReason = table.concat(reasons, "; ")
				end

				triggerClientEvent(getElementsByType("player"), "killAlertFromServer", source, suspectName, vehicle, wantedReason, false, zoneName)
			end
		end
	end
)

function policeMessage(text)
	for k, v in pairs(getElementsByType("player")) do
		if exports.see_groups:isPlayerOfficer(v) or exports.see_groups:isPlayerInGroup(v, 2) or exports.see_groups:isPlayerInGroup(v, 18) then
			outputChatBox("[StrongMTA - Rendőrség]:#FFFFFF " .. text, v, 215, 89, 89, true)
		end
	end
end

local backupBlips = {}

addCommandHandler("backup",
	function(sourcePlayer, commandName, ...)
		local reason = table.concat({...}, " ")
		if exports.see_groups:isPlayerOfficer(sourcePlayer) or exports.see_groups:isPlayerInGroup(sourcePlayer, 2) or exports.see_groups:isPlayerInGroup(sourcePlayer, 18) then
			if backupBlips[sourcePlayer] then
				triggerClientEvent(root, "createBlipForOfficers", sourcePlayer, sourcePlayer)
				backupBlips[sourcePlayer] = nil
				policeMessage(getPlayerName(sourcePlayer):gsub("_", " ").." lemondta az erősítést.")
			else
				if reason then
					local x, y, z = getElementPosition(sourcePlayer)
					backupBlips[sourcePlayer] = true
					triggerClientEvent(root, "createBlipForOfficers", sourcePlayer, sourcePlayer, reason)
					--[[attachElements(backupBlips[sourcePlayer], sourcePlayer)
					setElementData(backupBlips[sourcePlayer], "blipTooltipText", "Erősítés: " .. reason)]]
					policeMessage(getPlayerName(sourcePlayer):gsub("_", " ").." erősítést hívott. ("..reason..")")
				end
			end
		end
	end
)

addEvent("reportGunShot", true)
addEventHandler("reportGunShot", getRootElement(),
	function (vehicle, zoneName)
		if source == client and zoneName then
			local suspectName = "ismeretlen"
			local wantedReason = false

			if isElement(vehicle) then
				local plateText = getVehiclePlateText(vehicle)
				local reasons = {}

				if plateText then
					plateText = fixPlateText(plateText)

					for i = 1, #wantedcars do
						local dat = wantedcars[i]

						if dat and dat.plate == plateText then
							table.insert(reasons, dat.reason)
						end
					end
				end

				if #reasons > 0 then
					wantedReason = table.concat(reasons, "; ")
				end

				triggerClientEvent(getElementsByType("player"), "shootAlertFromServer", source, suspectName, vehicle, false, wantedReason, zoneName)
			else
				local visibleName = getElementData(source, "visibleName"):gsub("_", " ")
				local reasons = {}

				for i = 1, #wantedpeople do
					local dat = wantedpeople[i]

					if dat and dat.name == visibleName then
						suspectName = dat.name
						table.insert(reasons, dat.reason)
					end
				end

				if #reasons > 0 then
					wantedReason = table.concat(reasons, "; ")
				end

				triggerClientEvent(getElementsByType("player"), "shootAlertFromServer", source, suspectName, vehicle, wantedReason, false, zoneName)
			end
		end
	end)

function fixPlateText(plate)
	local plateSection = {}
	local plateTextTable = split(plate:upper(), "-")

	for i = 1, #plateTextTable do
		if utf8.len(plateTextTable[i]) > 0 then
			table.insert(plateSection, plateTextTable[i])
		end
	end

	return table.concat(plateSection, "-")
end

addEvent("checkMDC", true)
addEventHandler("checkMDC", getRootElement(),
	function (vehicle, cctv)
		if source == client and isElement(vehicle) then
			local plateText = getVehiclePlateText(vehicle)

			if plateText then
				plateText = fixPlateText(plateText)

				for i = 1, #wantedcars do
					local dat = wantedcars[i]

					if dat and dat.plate == plateText then
						triggerClientEvent(getElementsByType("player"), "mdcAlertFromServer", vehicle, plateText, cctv, dat.reason)
						break
					end
				end
			end
		end
	end)

function punishedPeopleCallback(qh, thePlayer)
	dbFree(qh)

	if isElement(thePlayer) then
		dbQuery(
			function (qh)
				local result, rows = dbPoll(qh, 0)

				punishedpeople = {}

				if result then
					for k, v in ipairs(result) do
						table.insert(punishedpeople, v)
					end

					triggerClientEvent(getElementsByType("player"), "onClientGotMDCPunishment", thePlayer, punishedpeople)
				end
			end,
		connection, "SELECT * FROM mdc_punishedpeople ORDER BY id DESC")
	end
end

addEvent("addPunishment", true)
addEventHandler("addPunishment", getRootElement(),
	function (name, ticket, jail, reason)
		if source == client and ticket and jail and reason then
			dbQuery(punishedPeopleCallback, {client}, connection, "INSERT INTO mdc_punishedpeople (name, ticket, jail, reason) VALUES (?,?,?,?)", name:gsub("_", " "), ticket, jail, reason)
		end
	end)

addEvent("delPunishment", true)
addEventHandler("delPunishment", getRootElement(),
	function (id)
		if source == client and id then
			dbQuery(punishedPeopleCallback, {client}, connection, "DELETE FROM mdc_punishedpeople WHERE id = ?", id)
		end
	end)

function wWantedPeopleCallback(qh, thePlayer)
	dbFree(qh)

	if isElement(thePlayer) then
		dbQuery(
			function (qh)
				local result, rows = dbPoll(qh, 0)

				wantedpeople = {}

				if result then
					for k, v in ipairs(result) do
						table.insert(wantedpeople, v)
					end

					triggerClientEvent(getElementsByType("player"), "onClientGotMDCPeople", thePlayer, wantedpeople)
				end
			end,
		connection, "SELECT * FROM mdc_wantedpeople ORDER BY id DESC")
	end
end

addEvent("addReportPerson", true)
addEventHandler("addReportPerson", getRootElement(),
	function (name, reason, visual)
		if source == client and name and reason and visual then
			dbQuery(wWantedPeopleCallback, {client}, connection, "INSERT INTO mdc_wantedpeople (name, reason, description) VALUES (?,?,?)", name:gsub("_", " "), reason, visual)
			exports.see_logs:logCommand(client, "addmdcperson", {name, reason, visual})
		end
	end)

addEvent("delReportPerson", true)
addEventHandler("delReportPerson", getRootElement(),
	function (id)
		if source == client and id then
			local personName = false

			for i = 1, #wantedpeople do
				local dat = wantedpeople[i]
				
				if dat.id == id then
					personName = dat.name
					break
				end
			end

			if personName then
				exports.see_logs:logCommand(client, "delmdcperson", {personName, id, "csoport" .. tostring(exports.see_groups:isPlayerOfficer(client))})
				dbQuery(wWantedPeopleCallback, {client}, connection, "DELETE FROM mdc_wantedpeople WHERE id = ?", id)
			end
		end
	end)

addEvent("editReportPerson", true)
addEventHandler("editReportPerson", getRootElement(),
	function (id, name, reason, visual)
		if source == client and id and name and reason and visual then
			dbQuery(wWantedPeopleCallback, {client}, connection, "UPDATE mdc_wantedpeople SET name = ?, reason = ?, description = ? WHERE id = ?", name:gsub("_", " "), reason, visual, id)
			exports.see_logs:logCommand(client, "editmdcperson", {id, name, reason, visual})
		end
	end)

function wantedCarsCallback(qh, thePlayer)
	dbFree(qh)

	if isElement(thePlayer) then
		dbQuery(
			function (qh)
				local result, rows = dbPoll(qh, 0)

				wantedcars = {}

				if result then
					for k, v in ipairs(result) do
						table.insert(wantedcars, v)
					end

					triggerClientEvent(getElementsByType("player"), "onClientGotMDCVehicles", thePlayer, wantedcars)
				end
			end,
		connection, "SELECT * FROM mdc_wantedcars ORDER BY id DESC")
	end
end

addEvent("addReportVehicle", true)
addEventHandler("addReportVehicle", getRootElement(),
	function (vehtype, plate, reason)
		if source == client and vehtype and plate and reason then
			dbQuery(wantedCarsCallback, {client}, connection, "INSERT INTO mdc_wantedcars (type, plate, reason) VALUES (?,?,?)", vehtype, fixPlateText(plate), reason)
			exports.see_logs:logCommand(client, "addmdcvehicle", {fixPlateText(plate), reason})
		end
	end)

addEvent("delReportVehicle", true)
addEventHandler("delReportVehicle", getRootElement(),
	function (id, plate)
		if source == client and id and plate then
			local plateText = false

			for i = 1, #wantedcars do
				local dat = wantedcars[i]

				if dat.id == id then
					plateText = dat.plate
					break
				end
			end

			if plateText then
				exports.see_logs:logCommand(client, "delmdcvehicle", {plateText, id, "csoport" .. tostring(exports.see_groups:isPlayerOfficer(client))})
				dbQuery(wantedCarsCallback, {client}, connection, "DELETE FROM mdc_wantedcars WHERE id = ?", id)
			end
		end
	end)

addEvent("editReportVehicle", true)
addEventHandler("editReportVehicle", getRootElement(),
	function (id, vehtype, plate, reason)
		if source == client and id and vehtype and plate and reason then
			dbQuery(wantedCarsCallback, {client}, connection, "UPDATE mdc_wantedcars SET type = ?, plate = ?, reason = ? WHERE id = ?", vehtype, fixPlateText(plate), reason, id)
			exports.see_logs:logCommand(client, "editmdcvehicle", {id, fixPlateText(plate), reason})
		end
	end)

addEvent("tryToLoginMDC", true)
addEventHandler("tryToLoginMDC", getRootElement(),
	function (username, password)
		if source == client and username and password then
			local account = false

			for k, v in pairs(accounts) do
				if v.username == username and v.password == password then
					account = v
					break
				end
			end

			if account then
				triggerClientEvent(client, "onClientGotMDCData", client, account.leader)
				triggerClientEvent(client, "onClientGotMDCVehicles", client, wantedcars)
				triggerClientEvent(client, "onClientGotMDCPeople", client, wantedpeople)
				triggerClientEvent(client, "onClientGotMDCPunishment", client, punishedpeople)
			else
				exports.see_accounts:showInfo(client, "e", "Nincs ilyen felhasználónév/jelszó kombináció!")
			end
		end
	end)

addCommandHandler("addmdcacc",
	function (sourcePlayer, commandName, groupId, username, password, leader)
		if not groups[groupId] then
			groupId = false
		end

		leader = tonumber(leader) or 0

		if not (groupId and username and password) then
			if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
				outputChatBox("#ea7212[Használat]: #ffffff/" .. commandName .. " [Csoport Azonosító] [Felhasználónév] [Jelszó] [Leader fiók (0 = nem | 1 = igen)]", sourcePlayer, 0, 0, 0, true)
			else
				outputChatBox("#ea7212[Használat]: #ffffff/" .. commandName .. " [Csoport Azonosító] [Felhasználónév] [Jelszó]", sourcePlayer, 0, 0, 0, true)
			end
			outputChatBox("#ea7212[Elérhető csoportok]: #ffffffPD -> LVMPD | SWAT -> SWAT | SD -> Sheriff | FBI -> Nemzeti Nyomozó Iroda", sourcePlayer, 0, 0, 0, true)
		else
			if exports.see_groups:isPlayerLeaderInGroup(sourcePlayer, groups[groupId]) or getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
				local found = false

				for k, v in pairs(accounts) do
					if v.username == username then
						found = true
						break
					end
				end

				if not found then
					if leader < 0 or leader > 1 then
						leader = 0
					end

					outputChatBox("#3d7abc[StrongMTA - MDC]: #ffffffSikeresen létrehoztad az MDC fiókot. #32b3ef(" .. username .. ")", sourcePlayer, 0, 0, 0, true)

					dbExec(connection, "INSERT INTO mdc_accounts (username, password, leader) VALUES (?,?,?)", username, sha256(password), leader)
				else
					outputChatBox("#d75959[StrongMTA - MDC]: #ffffffA kiválasztott felhasználónév foglalt!", sourcePlayer, 0, 0, 0, true)
				end
			else
				outputChatBox("#d75959[StrongMTA - MDC]: #ffffffNincs jogosultságod ilyen fiókot létrehozni!", sourcePlayer, 0, 0, 0, true)
			end
		end
	end)

addCommandHandler("delmdcacc",
	function (sourcePlayer, commandName, username)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			if not username then
				outputChatBox("#ea7212[Használat]: #ffffff/" .. commandName .. " [Felhasználónév]", sourcePlayer, 0, 0, 0, true)
			else
				local accountId = false

				for k, v in pairs(accounts) do
					if v.username == username then
						accountId = k
						break
					end
				end

				if accountId then
					accounts[accountId] = nil

					outputChatBox("#3d7abc[StrongMTA - MDC]: #ffffffSikeresen törölted az MDC fiókot. #32b3ef(" .. username .. ")", sourcePlayer, 0, 0, 0, true)

					dbExec(connection, "DELETE FROM mdc_accounts WHERE accountId = ?", accountId)
				else
					outputChatBox("#d75959[StrongMTA - MDC]: #ffffffA kiválasztott felhasználó nem létezik!", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end)

addCommandHandler("setmdcpass",
	function (sourcePlayer, commandName, username, password)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			if not (username and password) then
				outputChatBox("#ea7212[Használat]: #ffffff/" .. commandName .. " [Felhasználónév] [Új jelszó]", sourcePlayer, 0, 0, 0, true)
			else
				local accountId = false

				for k, v in pairs(accounts) do
					if v.username == username then
						accountId = k
						break
					end
				end

				if accountId then
					password = sha256(password)
					accounts[accountId].password = password

					outputChatBox("#3d7abc[StrongMTA - MDC]: #ffffffSikeresen módosítottad az MDC fiók jelszavát. #32b3ef(" .. username .. ")", sourcePlayer, 0, 0, 0, true)

					dbExec(connection, "UPDATE mdc_accounts SET password = ? WHERE accountId = ?", password, accountId)
				else
					outputChatBox("#d75959[StrongMTA - MDC]: #ffffffA kiválasztott felhasználó nem létezik!", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end
)
