local onlineAdmins = {}
connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		for k, v in pairs(getElementsByType("player")) do
			local adminLevel = getElementData(v, "acc.adminLevel") or 0
			if adminLevel > 0 then
				onlineAdmins[v] = adminLevel
			end
		end
	end)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "acc.adminLevel" or dataName == "adminDuty" then
			local adminLevel = getElementData(source, "acc.adminLevel") or 0
			if adminLevel > 0 then
				onlineAdmins[source] = adminLevel
			else
				onlineAdmins[source] = nil
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if onlineAdmins[source] then
			onlineAdmins[source] = nil
		end
	end)

addEventHandler("onPlayerChangeNick", getRootElement(),
	function (oldNick, newNick, changedByUser)
		if changedByUser then
			cancelEvent()
		end
	end)

addEvent("warpToGameInterior", true)
addEventHandler("warpToGameInterior", getRootElement(),
	function (interiorId, gameInterior)
		if isElement(source) and client and client == source then
			if getElementData(source, "acc.adminLevel") >= 6 then
				if gameInterior then
					--outputChatBox(inspect(interiorId, gameInterior))
					setElementPosition(source, gameInterior.position[1], gameInterior.position[2], gameInterior.position[3])
					setElementRotation(source, gameInterior.rotation[1], gameInterior.rotation[2], gameInterior.rotation[3])
					setElementInterior(source, gameInterior.interior)
					setElementDimension(source, 0)
					setCameraInterior(source, gameInterior.interior)
					outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen elteleportáltál a kiválasztott interior belsőbe. #32b3ef([" .. interiorId .. "] " .. gameInterior.name .. ")", source, 255, 255, 255, true)
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

function showAdminMessageFor(player, message, r, g, b)
	if r and g and b then
		return outputChatBox(string.format("#%.2X%.2X%.2X", r, g, b) .. message, player, r, g, b, true)
	else
		return outputChatBox(message, player, 255, 255, 255, true)
	end
end

function showAdminMessage(message, r, g, b)
	if r and g and b then
		return outputChatBox(string.format("#%.2X%.2X%.2X", r, g, b) .. message, root, r, g, b, true)
	else
		return outputChatBox(message, root, 255, 255, 255, true)
	end
end

function showMessageForAdmins(message, r, g, b)
	for playerElement, adminLevel in pairs(onlineAdmins) do
		if isElement(playerElement) then
			if r and g and b then
				outputChatBox(string.format("#%.2X%.2X%.2X", r, g, b) .. message, playerElement, r, g, b, true)
			else
				outputChatBox(message, playerElement, 255, 255, 255, true)
			end
		end
	end
end

function showAdminLog(message, level)
	level = level or 1

	for playerElement, adminLevel in pairs(onlineAdmins) do
		if isElement(playerElement) then
			if adminLevel >= level then
				outputChatBox("#3d7abc[StrongMTA - #32b3efAdminNapló#3d7abc]: #ffffff" .. message, playerElement, 255, 255, 255, true)
			end
		end
	end
end

function showStaffChat(message, level)
	level = level or 1

	for playerElement, adminLevel in pairs(onlineAdmins) do
		if isElement(playerElement) then
			if adminLevel >= level then
				outputChatBox("[StaffChat]: #ffffff" .. message, playerElement, 215, 59, 59, true)
			end
		end
	end
end

addCommandHandler("startres",
	function (sourcePlayer, commandName, resourceName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 8 then
			if not resourceName then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Resource Név]", 255, 150, 0)
			else
				local res = getResourceFromName(resourceName)

				if res then
					local state = getResourceState(res)

					if state == "loaded" then
						if startResource(res) then
							showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffResource sikeresen elindítva. #32b3ef(" .. resourceName .. ")", 61, 122, 188)
						else
							showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource elindítása sikertelen.", 215, 89, 89)
						end
					elseif state == "running" then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource már el van indítva.", 215, 89, 89)
					elseif state == "failed to load" then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resourcet nem sikerült betölteni.", 215, 89, 89)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffIndok: #d75959" .. getResourceLoadFailureReason(res), 215, 89, 89)
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource éppen elindul vagy leáll.", 215, 89, 89)
					end
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource nem található.", 215, 89, 89)
				end
			end
		end
	end)

addCommandHandler("stopres",
	function (sourcePlayer, commandName, resourceName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 8 then
			if not resourceName then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Resource Név]", 255, 150, 0)
			else
				local res = getResourceFromName(resourceName)

				if res then
					local state = getResourceState(res)

					if state == "loaded" then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource nincs elindítva.", 215, 89, 89)
					elseif state == "running" then
						if stopResource(res) then
							showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffResource sikeresen leállítva. #32b3ef(" .. resourceName .. ")", 61, 122, 188)
						else
							showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource leállítása sikertelen.", 215, 89, 89)
						end
					elseif state == "failed to load" then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resourcet nem sikerült betölteni.", 215, 89, 89)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffIndok: #d75959" .. getResourceLoadFailureReason(res), 215, 89, 89)
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource éppen elindul vagy leáll.", 215, 89, 89)
					end
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource nem található.", 215, 89, 89)
				end
			end
		end
	end)

addCommandHandler("restartres",
	function (sourcePlayer, commandName, resourceName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 8 then
			if not resourceName then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Resource Név]", 255, 150, 0)
			else
				local res = getResourceFromName(resourceName)

				if res then
					local state = getResourceState(res)

					if state == "loaded" then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource nincs elindítva.", 215, 89, 89)
					elseif state == "running" then
						if restartResource(res) then
							showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffResource sikeresen újraindítva. #32b3ef(" .. resourceName .. ")", 61, 122, 188)
						else
							showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource újraindítása sikertelen.", 215, 89, 89)
						end
					elseif state == "failed to load" then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resourcet nem sikerült betölteni.", 215, 89, 89)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffIndok: #d75959" .. getResourceLoadFailureReason(res), 215, 89, 89)
					else
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource éppen elindul vagy leáll.", 215, 89, 89)
					end
				else
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott resource nem található.", 215, 89, 89)
				end
			end
		end
	end)
