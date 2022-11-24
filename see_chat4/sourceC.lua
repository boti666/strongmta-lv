local oocColorState = false

function onOOCChat(commandName, ...)
	local msg = string.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")
	
	if utf8.len(msg) > 0 and utf8.len(msg) <= 128 then
		local visibleName = getElementData(localPlayer, "visibleName"):gsub("_", " ")
		local px, py, pz = getElementPosition(localPlayer)
		local affected = {}
		local count = 0

		for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
			if v ~= localPlayer then
				local tx, ty, tz = getElementPosition(v)

				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 12 then
					table.insert(affected, v)
					count = count + 1
				end
			end
		end

		local adminDuty = getElementData(localPlayer, "adminDuty") or 0

		if adminDuty == 1 then
			local adminLevel = getElementData(localPlayer, "acc.adminLevel") or 0
			local adminTitle = exports.see_administration:getPlayerAdminTitle(localPlayer)
			local levelColor = exports.see_administration:getAdminLevelColor(adminLevel)

			visibleName = levelColor .. adminTitle .. " " .. visibleName
		elseif getElementData(localPlayer, "acc.adminLevel") >= 6 and oocColorState then
			local adminLevel = getElementData(localPlayer, "acc.adminLevel") or 0
			local adminTitle = exports.see_administration:getPlayerAdminTitle(localPlayer)
			local levelColor = exports.see_administration:getAdminLevelColor(adminLevel)
			visibleName = levelColor .. adminTitle .. " " .. visibleName
		else
			visibleName = "#FFFFFF" .. visibleName
		end
		
		triggerEvent("onClientRecieveOOCMessage", localPlayer, msg, visibleName)

		local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")

		if spectatingPlayers then
			for k, v in pairs(spectatingPlayers) do
				if isElement(k) then
					count = count + 1
				end
			end
		end
		
		if count > 0 then
			triggerServerEvent("onOOCMessage", localPlayer, affected, visibleName, msg)
		end
	end
end
addCommandHandler("b", onOOCChat)
addCommandHandler("LocalOOC", onOOCChat)
bindKey("b", "down", "chatbox", "LocalOOC")

function togColorFA()
	if getElementData(localPlayer, "acc.adminLevel") >= 6 then
		oocColorState = not oocColorState

		if oocColorState then
			outputChatBox("#3d7abc[StrongMTA]: #ffffffOOC Chat szín #3d7abcbekapcsolva", 255, 255, 255, true)
		else
			outputChatBox("#3d7abc[StrongMTA]: #ffffffOOC Chat szín #d75959kikapcsolva", 255, 255, 255, true)
		end
	end
end
addCommandHandler("togcolorooc", togColorFA)

function localActionC(ped, msg)
	localAction(ped, msg)
end

function sendLocalDoC(ped, msg)
	localDo(ped, msg)
end

function sendLocalSay(ped, msg)
	sendSay(ped, msg)
end

addCommandHandler("say",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			sendSay(localPlayer, table.concat({...}, " "):gsub("#%x%x%x%x%x%x", ""))
		end
	end)

function literalize(msd)
	return msd:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function (character)
		return "%" .. character
	end)
end

local smileyTable = {
	[":D"] = "nevet",
	["xD"] = "szakad a röhögéstől",
	[":$"] = "elpirul",
	[":P"] = "nyelvet ölt",
	[":p"] = "nyelvet ölt",
	[":("] = "szomorú",
	[":-("] = "szomorú",
	["):"] = "szomorú",
	[":)"] = "mosolyog",
	["(:"] = "mosolyog",
	[";-)"] = "kacsint",
	["(-;"] = "kacsint",
	[":@"] = "mérges",
	[";D"] = "nagyot kacsint",
	[";-D"] = "nagyot kacsint",
	["xd"] = "szakad a röhögéstől",
	["XD"] = "szakad a röhögéstől",
	["Xd"] = "szakad a röhögéstől",
	["^^"] = "vihog",
	[":'("] = "sír",
	["-.-"] = "sóhajt",
	[":O"] = "meglepődik",
	[":o"] = "meglepődik",
	["o.O"] = "meglepődik",
	["O.o"] = "meglepődik"
}

function sendSay(ped, msg)
	if string.len(msg) == 0 then
		return
	end

	local adminDuty = getElementData(ped, "adminDuty") or 0

	if adminDuty ~= 1 then
		local laugh = false

		for k, v in pairs(smileyTable) do
			if utf8.find(msg, k, 1, true) then
				laugh = v
				localActionC(ped, v)
				msg = utf8.gsub(msg, literalize(k), "")
			end
		end

		if laugh == "szakad a röhögéstől" or laugh == "nevet" then
			triggerServerEvent("laughAnim", ped)
		end
	end

	if utf8.len((utf8.gsub(msg, " ", "") or 0)) == 0 then
		return
	end

	local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
	local affected = {}
	local count = 0
	local pedveh = getPedOccupiedVehicle(ped)
	local str = ""

	if isElement(pedveh) and getElementData(pedveh, "vehicle.windowState") then
		str = str .. " (járműben)"

		for k, v in pairs(getVehicleOccupants(pedveh)) do
			if v ~= ped then
				table.insert(affected, {v, "#FFFFFF"})
				count = count + 1
			end
		end
	else
		local px, py, pz = getElementPosition(ped)

		for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
			if v ~= localPlayer then
				local maxdist = 12
				local pedveh = getPedOccupiedVehicle(v)

				if pedveh then
					if getElementData(pedveh, "vehicle.windowState") then
						maxdist = 8
					end
				end

				local tx, ty, tz = getElementPosition(v)
				local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

				if dist <= maxdist then
					table.insert(affected, {v, RGBToHex(interpolateBetween(255, 255, 255, 50, 50, 50, dist / maxdist, "Linear"))})
					count = count + 1
				end
			end
		end
	end

	local adminLevel = getElementData(ped, "acc.adminLevel") or 0
	local adminTitle = exports.see_administration:getPlayerAdminTitle(ped)
	local levelColor = exports.see_administration:getAdminLevelColor(adminLevel)

	msg = firstToUpper(msg)

	if adminDuty ~= 1 or ped ~= localPlayer then
		outputChatBox("#FFFFFF" .. visibleName .. " mondja" .. str .. ": " .. msg, 231, 217, 176, true)
	else
		outputChatBox(levelColor .. "[ADMIN] " .. adminTitle .. " " .. visibleName .. " mondja" .. str .. ": " .. msg, 231, 217, 176, true)
	end

	local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers") or {}
	
	if spectatingPlayers then
		for k, v in pairs(spectatingPlayers) do
			if isElement(v) then
				count = count + 1
			end
		end
	end

	if count > 0 then
		triggerServerEvent("onLocalMessage", localPlayer, affected, visibleName, msg, str, adminDuty, adminTitle, levelColor, ped)
	else
		local talkingAnim = getElementData(localPlayer, "talkingAnim") or "false"

		if talkingAnim ~= "false" then
			triggerServerEvent("sayAnimServer", getRootElement(), ped, msg, talkingAnim)
		end
	end
end

addCommandHandler("c",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			if not (...) then
				outputChatBox("#3d7abc[StrongMTA - Chat]: #ffffff/" .. commandName .. " [szöveg]", 255, 194, 14, true)
			else
				local msg = string.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")

				if #msg > 0 and utf8.len(msg) > 0 then
					local laugh = false

					for k, v in pairs(smileyTable) do
						if utf8.find(msg, k, 1, true) then
							laugh = v
							localActionC(localPlayer, v)
							msg = utf8.gsub(msg, literalize(k), "")
						end
					end

					if laugh == "szakad a röhögéstől" or laugh == "nevet" then
						triggerServerEvent("laughAnim", localPlayer)
					end

					if utf8.len((utf8.gsub(msg, " ", "") or 0)) > 0 then
						local visibleName = getElementData(localPlayer, "visibleName"):gsub("_", " ")
						local affected = {}
						local count = 0
						local pedveh = getPedOccupiedVehicle(localPlayer)
						local str = " (suttogva)"

						if isElement(pedveh) and getElementData(pedveh, "vehicle.windowState") then
							str = str .. "(járműben)"
							
							for k, v in pairs(getVehicleOccupants(pedveh)) do
								if v ~= localPlayer then
									table.insert(affected, {v, "#FFFFFF"})
									count = count + 1
								end
							end
						else
							local px, py, pz = getElementPosition(localPlayer)

							for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
								if v ~= localPlayer then
									local maxdist = 4
									local pedveh = getPedOccupiedVehicle(v)

									if pedveh then
										if getElementData(pedveh, "vehicle.windowState") then
											return
										end
									end

									local tx, ty, tz = getElementPosition(v)
									local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

									if dist <= maxdist then
										table.insert(affected, {v, RGBToHex(interpolateBetween(255, 255, 255, 70, 70, 70, dist / maxdist, "Linear"))})
										count = count + 1
									end
								end
							end
						end

						msg = firstToUpper(msg)
						
						outputChatBox("#FFFFFF" .. visibleName .. " mondja" .. str .. ": " .. msg, 231, 217, 176, true)
						
						local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")

						if spectatingPlayers then
							for k, v in pairs(spectatingPlayers) do
								if isElement(k) then
									count = count + 1
								end
							end
						end

						if count > 0 then
							triggerServerEvent("onLocalMessage", localPlayer, affected, visibleName, msg, str, 0)
						end
					end
				end
			end
		end
	end)

function localActionLow(ped, msg)
	if string.len(msg) == 0 then
		return
	end

	local px, py, pz = getElementPosition(ped)
	local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
	local affected = {}
	local count = 0
	local syncer = false

	if getElementType(ped) == "ped" then
		syncer = localPlayer
	else
		syncer = ped
	end

	for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
		if v ~= syncer then
			local tx, ty, tz = getElementPosition(v)

			if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 6 then
				table.insert(affected, v)
				count = count + 1
			end
		end
	end

	outputChatBox("#DBC5EB*** [LOW] " .. visibleName .. " #DBC5EB" .. msg, 219, 197, 235, true)

	local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")

	if spectatingPlayers then
		for k, v in pairs(spectatingPlayers) do
			if isElement(k) then
				count = count + 1
			end
		end
	end

	if count > 0 then
		triggerServerEvent("onActionMessageLow", syncer, affected, visibleName, msg)
	end
end

function localActionA(ped, msg)
	if string.len(msg) == 0 then
		return
	end

	local px, py, pz = getElementPosition(ped)
	local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
	local affected = {}
	local count = 0
	local syncer = false

	if getElementType(ped) == "ped" then
		syncer = localPlayer
	else
		syncer = ped
	end

	for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
		if v ~= syncer then
			local tx, ty, tz = getElementPosition(v)

			if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 12 then
				table.insert(affected, v)
				count = count + 1
			end
		end
	end

	outputChatBox("#956CB4>> " .. visibleName .. " #956CB4" .. msg, 194, 162, 218, true)

	local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")

	if spectatingPlayers then
		for k, v in pairs(spectatingPlayers) do
			if isElement(k) then
				count = count + 1
			end
		end
	end

	if count > 0 then
		triggerServerEvent("onActionMessageA", syncer, affected, visibleName, msg)
	end
end

function localAction(ped, msg)
	if string.len(msg) == 0 then
		return
	end

	local px, py, pz = getElementPosition(ped)
	local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
	local affected = {}
	local count = 0
	local syncer = false

	if getElementType(ped) == "ped" then
		syncer = localPlayer
	else
		syncer = ped
	end

	for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
		if v ~= syncer then
			local tx, ty, tz = getElementPosition(v)

			if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 12 then
				table.insert(affected, v)
				count = count + 1
			end
		end
	end

	outputChatBox("#C2A2DA*** " .. visibleName .. " #C2A2DA" .. msg, 194, 162, 218, true)

	local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")

	if spectatingPlayers then
		for k, v in pairs(spectatingPlayers) do
			if isElement(k) then
				count = count + 1
			end
		end
	end

	if count > 0 then
		triggerServerEvent("onActionMessage", syncer, affected, visibleName, msg)
	end
end

addCommandHandler("me",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			if not (...) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [üzenet]", 255, 255, 255, true)
			else
				localAction(localPlayer, table.concat({...}, " "):gsub("#%x%x%x%x%x%x", ""))
			end
		end
	end)

addCommandHandler("melow",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			if not (...) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [üzenet]", 255, 255, 255, true)
			else
				localActionLow(localPlayer, table.concat({...}, " "):gsub("#%x%x%x%x%x%x", ""))
			end
		end
	end)

addCommandHandler("ame",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			if not (...) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [üzenet]", 255, 255, 255, true)
			else
				localActionA(localPlayer, table.concat({...}, " "):gsub("#%x%x%x%x%x%x", ""))
			end
		end
	end)

function localDo(ped, msg)
	if string.len(msg) == 0 then
		return
	end

	local px, py, pz = getElementPosition(ped)
	local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
	local affected = {}
	local count = 0
	local syncer = false

	if getElementType(ped) == "ped" then
		syncer = localPlayer
	else
		syncer = ped
	end

	for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
		if v ~= syncer then
			local tx, ty, tz = getElementPosition(v)

			if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 12 then
				table.insert(affected, v)
				count = count + 1
			end
		end
	end

	msg = firstToUpper(msg)

	outputChatBox(" *" .. msg .. " ((#FF2850" .. visibleName .. "))", 255, 40, 80, true)

	local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")

	if spectatingPlayers then
		for k, v in pairs(spectatingPlayers) do
			if isElement(k) then
				count = count + 1
			end
		end
	end

	if count > 0 then
		triggerServerEvent("onDoMessage", syncer, affected, visibleName, msg)
	end
end

function localDoLow(ped, msg)
	if string.len(msg) == 0 then
		return
	end

	local px, py, pz = getElementPosition(ped)
	local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
	local affected = {}
	local count = 0
	local syncer = false

	if getElementType(ped) == "ped" then
		syncer = localPlayer
	else
		syncer = ped
	end

	for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
		if v ~= syncer then
			local tx, ty, tz = getElementPosition(v)

			if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 6 then
				table.insert(affected, v)
				count = count + 1
			end
		end
	end

	msg = firstToUpper(msg)

	outputChatBox("[LOW] *" .. msg .. " ((#ff6682" .. visibleName .. "))", 255, 102, 130, true)

	local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")

	if spectatingPlayers then
		for k, v in pairs(spectatingPlayers) do
			if isElement(k) then
				count = count + 1
			end
		end
	end

	if count > 0 then
		triggerServerEvent("onDoMessageLow", syncer, affected, visibleName, msg)
	end
end

addCommandHandler("dolow",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			if not (...) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [üzenet]", 255, 255, 255, true)
			else
				localDoLow(localPlayer, table.concat({...}, " "):gsub("#%x%x%x%x%x%x", ""))
			end
		end
	end)


addCommandHandler("do",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			if not (...) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [üzenet]", 255, 255, 255, true)
			else
				localDo(localPlayer, table.concat({...}, " "):gsub("#%x%x%x%x%x%x", ""))
			end
		end
	end)

addCommandHandler("m",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			if exports.see_groups:isPlayerHavePermission(localPlayer, "megaPhone") then
				if not (...) then
					outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [üzenet]", 255, 255, 255, true)
				else
					local msg = string.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")

					if #msg > 0 and utf8.len(msg) > 0 then
						local msg2 = utf8.gsub(msg, " ", "") or 0

						if utf8.len(msg2) > 0 then
							local visibleName = getElementData(localPlayer, "visibleName"):gsub("_", " ")
							local px, py, pz = getElementPosition(localPlayer)
							local affected = {}
							local count = 0

							for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
								if v ~= localPlayer then
									local tx, ty, tz = getElementPosition(v)
									local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

									if dist <= 60 then
										table.insert(affected, {v, 1 - dist / 60})
										count = count + 1
									end
								end
							end

							msg = firstToUpper(msg)

							outputChatBox("((" .. visibleName .. ")) Megaphone <O: " .. msg, 255, 255, 0, true)

							local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")

							if spectatingPlayers then
								for k, v in pairs(spectatingPlayers) do
									if isElement(k) then
										count = count + 1
									end
								end
							end

							if count > 0 then
								triggerServerEvent("onMegaPhoneMessage", localPlayer, affected, visibleName, msg)
							end
						end
					end
				end
			end
		end
	end)

function tryCommand(commandName, ...)
	if getElementData(localPlayer, "loggedIn") then
		if not (...) then
			outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [üzenet]", 255, 255, 255, true)
		else
			local msg = string.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")

			if #msg > 0 and utf8.len(msg) > 0 then
				local visibleName = getElementData(localPlayer, "visibleName"):gsub("_", " ")
				local px, py, pz = getElementPosition(localPlayer)
				local affected = {}
				local count = 0

				for k, v in ipairs(getElementsByType("player", getRootElement(), true)) do
					if v ~= localPlayer then
						local tx, ty, tz = getElementPosition(v)
						local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

						if dist <= 12 then
							table.insert(affected, v)
							count = count + 1
						end
					end
				end
				
				local rnd = math.random(1, 2)
				
				if commandName == "megprobal" or commandName == "megpróbál" then
					if rnd == 1 then
						outputChatBox(" *** " .. visibleName .. " megpróbál " .. msg .. " és sikerül neki.", 173, 211, 115, true)
					elseif rnd == 2 then
						outputChatBox(" *** " .. visibleName .. " megpróbál " .. msg .. " de sajnos nem sikerül neki.", 220, 20, 60, true)
					end
				elseif commandName == "megprobalja" or commandName == "megpróbálja" then
					if rnd == 1 then
						outputChatBox(" *** " .. visibleName .. " megpróbálja " .. msg .. " és sikerül neki.", 173, 211, 115, true)
					elseif rnd == 2 then
						outputChatBox(" *** " .. visibleName .. " megpróbálja " .. msg .. " de sajnos nem sikerül neki.", 220, 20, 60, true)
					end
				end

				local spectatingPlayers = getElementData(localPlayer, "spectatingPlayers")
				
				if spectatingPlayers then
					for k, v in pairs(spectatingPlayers) do
						if isElement(k) then
							count = count + 1
						end
					end
				end
				
				if count > 0 then
					triggerServerEvent("onTryMessage", localPlayer, affected, visibleName, msg, rnd, commandName)
				end
			end
		end
	end
end
addCommandHandler("megprobal", tryCommand)
addCommandHandler("megpróbál", tryCommand)
addCommandHandler("megprobalja", tryCommand)
addCommandHandler("megpróbálja", tryCommand)

function firstToUpper(text)
	return (text:gsub("^%l", string.upper))
end

function RGBToHex(r, g, b)
	return string.format("#%.2X%.2X%.2X", r, g, b)
end

addCommandHandler("s",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			if not (...) then
				outputChatBox("#3d7abc[StrongMTA - Chat]: #ffffff/" .. commandName .. " [szöveg]", 255, 194, 14, true)
			else
				local msg = string.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")

				if #msg > 0 and utf8.len(msg) > 0 then
					local msg2 = utf8.gsub(msg, " ", "") or 0

					if utf8.len(msg2) > 0 then
						local currentStandingInterior = exports.see_interiors:getCurrentStandingInterior()

						if currentStandingInterior then
							local x, y, z = 0, 0, 0

							if currentStandingInterior[2] == "entrance" then
								x, y, z = exports.see_interiors:getInteriorExitPosition(currentStandingInterior[1])
							else
								x, y, z = exports.see_interiors:getInteriorEntrancePosition(currentStandingInterior[1])
							end

							triggerServerEvent("shoutInterior", localPlayer, currentStandingInterior, msg, x, y, z)
						else
							triggerServerEvent("shoutNormal", localPlayer, msg)
						end
					end
				end
			end
		end
	end)