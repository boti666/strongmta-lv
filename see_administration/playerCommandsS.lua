local connection = exports.see_database:getConnection()

addCommandHandler("resetplayer",
	function(sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			if not (targetPlayer) then
				outputChatBox("[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 255, 150, 0, true)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					triggerClientEvent("addKickbox", root, "kick", getElementData(sourcePlayer, "acc.adminNick"), getElementData(targetPlayer, "visibleName"), "vagyontörlés")
					local charId = getElementData(targetPlayer, "char.ID")
					kickPlayer(targetPlayer, sourcePlayer, "vagyontörlés")

					dbExec(connection, "DELETE FROM items WHERE ownerType = 'player' AND ownerId = ?", charId)
					dbExec(connection, "DELETE FROM vehicles WHERE ownerId = ?", charId)
					dbExec(connection, "UPDATE interiors SET deleted = 'Y' WHERE ownerId = ?", charId)
					dbExec(connection, "UPDATE characters SET money = 1000000, slotCoins = 0, playedMinutes = 0, bankMoney = 0, maxVehicles = 2, interiorLimit = 5 WHERE accountId = ?", charId)

					outputChatBox("[SeeMTA]: #ffffffSikeresen lenulláztad a kiválasztott játékost.", sourcePlayer, 215, 59, 59, true)
				end
			end
		end
	end
)

--[[addCommandHandler("givepp",
	function (source)
		--if isElement(source) then 
			if getElementData(source, "acc.adminLevel") >= 9 then 
				for k, v in pairs(getElementsByType("player")) do
					if getElementData(v, "loggedIn") then  
						local premiumPoints = getElementData(v, "acc.premiumPoints") 
						local givedPremiumPoints = 30000
						setElementData(v, "acc.premiumPoints", premiumPoints + givedPremiumPoints) 
					end
				end
			end
		--end
	end 
)]]

addCommandHandler("korhaz",
	function (source)
		if getElementData(source, "acc.adminLevel") >= 6 then 
			setElementPosition(source, 1607.1197509766, 1820.5279541016, 10.828001022339)
		end
	end 
)

addCommandHandler("vá",
	function (sourcePlayer, commandName, partialNick, ...)
		local myAdminLevel = getElementData(sourcePlayer, "acc.adminLevel") or 0
		local myHelperLevel = getElementData(sourcePlayer, "acc.helperLevel") or 0

		if myAdminLevel > 0 or myHelperLevel > 0 then
			if not partialNick or not (...) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Név / ID] [Üzenet]", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, partialNick)

				if isElement(targetPlayer) then
					local message = table.concat({...}, " "):gsub("#%x%x%x%x%x%x", "")

					if message then
						local myName = getElementData(sourcePlayer, "visibleName"):gsub("_", " ")
						local myPlayerID = getElementData(sourcePlayer, "playerID") or "N/A"
						local targetPlayerID = getElementData(targetPlayer, "playerID") or "N/A"

						if myHelperLevel > 0 then
							triggerClientEvent(sourcePlayer, "onClientPM", sourcePlayer, targetPlayer,  message, true)
							outputChatBox(string.format("#ff9000[Válasz]: #ffffff%s (%d): #ff9000%s", targetName, targetPlayerID, message), sourcePlayer, 0, 0, 0, true)
							outputChatBox(string.format("#ff9000[Segítség]: #ffffff%s (%d): #ff9000%s", myName, myPlayerID, message), targetPlayer, 0, 0, 0, true)

							triggerClientEvent("onAdminMSGVa", resourceRoot, string.format("Adminsegéd %s válaszolt neki: %s", myName, targetName))
							triggerClientEvent("onAdminMSGVa", resourceRoot, string.format("Üzenet: %s", message))

							setElementData(sourcePlayer, "acc.reply", (getElementData(sourcePlayer, "acc.reply") or 0)+1)
							dbExec(connection, "UPDATE accounts SET statReply = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.reply"), getElementData(sourcePlayer, "char.accID"))
						elseif myAdminLevel > 0 then
							local adminName = getElementData(sourcePlayer, "acc.adminNick")
							local adminRank = getPlayerAdminTitle(sourcePlayer)

							outputChatBox(string.format("#ff9000[Válasz]: #ffffff%s (%d): #ff9000%s", targetName, targetPlayerID, message), sourcePlayer, 0, 0, 0, true)
							outputChatBox(string.format("#ff9000[Segítség]: #ffffff%s %s (%d): #ff9000%s", adminRank, adminName, myPlayerID, message), targetPlayer, 0, 0, 0, true)

							triggerClientEvent("onAdminMSGVa", resourceRoot, string.format("%s %s válaszolt neki: %s", adminRank, adminName, targetName))
							triggerClientEvent("onAdminMSGVa", resourceRoot, string.format("Üzenet: %s", message))
							setElementData(sourcePlayer, "acc.reply", (getElementData(sourcePlayer, "acc.reply") or 0)+1)
							dbExec(connection, "UPDATE accounts SET statReply = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.reply"), getElementData(sourcePlayer, "char.accID"))
						end
					end
				end
			end
		end
	end)

addCommandHandler("pm",
	function (sourcePlayer, commandName, partialNick, ...)
		if getElementData(sourcePlayer, "loggedIn") then
			if not partialNick or not (...) then
				outputChatBox("#7cc576[Használat]: #ffffff/" .. commandName .. " [Név / ID] [Üzenet]", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, partialNick)

				if isElement(targetPlayer) then
					local message = table.concat({...}, " "):gsub("#%x%x%x%x%x%x", "")

					if message then
						local myName = getElementData(sourcePlayer, "visibleName"):gsub("_", " ")
						local myAdminLevel = getElementData(sourcePlayer, "acc.adminLevel") or 0
						local myPlayerID = getElementData(sourcePlayer, "playerID") or "N/A"

						if myAdminLevel == 0 or myAdminLevel >= 6 then
							local targetHelperLevel = getElementData(targetPlayer, "acc.helperLevel") or 0
							local targetPlayerID = getElementData(targetPlayer, "playerID") or "N/A"
							local targetInDuty = getElementData(targetPlayer, "adminDuty") or 0

							if targetInDuty == 1 or targetHelperLevel > 0 then
								outputChatBox(string.format("#ff9000[Küldött PM]: #ffffff%s (%d): #ff9000%s", targetName, targetPlayerID, message), sourcePlayer, 0, 0, 0, true)
								outputChatBox(string.format("#ff9000[Fogadott PM]: #ffffff%s (%d): #ff9000%s", myName, myPlayerID, message), targetPlayer, 0, 0, 0, true)
								
								triggerClientEvent(targetPlayer, "onClientPM", sourcePlayer, sourcePlayer,  message)
								triggerClientEvent(targetPlayer, "scrollDown", targetPlayer)
								

								setElementData(sourcePlayer, "acc.receivedMessages", (getElementData(sourcePlayer, "acc.receivedMessages") or 0)+1)
								dbExec(connection, "UPDATE accounts SET statReceivedMessages = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.receivedMessages"), getElementData(sourcePlayer, "char.accID"))
							else
								outputChatBox("#d75959[StrongMTA]: #ffffffCsak szolgálatban lévő adminnak/adminsegédnek tudsz privát üzenetet írni!", sourcePlayer, 0, 0, 0, true)
							end
						else
							outputChatBox("#d75959[StrongMTA]: #ffffffNincs jogosultságod privát üzenetet írni. Használd a #7cc576/vá #ffffffparancsot.", sourcePlayer, 0, 0, 0, true)
						end
					end
				end
			end
		end
	end)

addCommandHandler("a",
	function (sourcePlayer, commandName, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not (...) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Üzenet]", 255, 150, 0)
			else
				local msg = string.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")

				if #msg > 0 and utf8.len(msg) > 0 then
					if utf8.len((utf8.gsub(msg, " ", "") or 0)) > 0 then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						local adminRank = getPlayerAdminTitle(sourcePlayer)

						showMessageForAdmins("[AdminChat]: #3d7abc" .. adminRank .. " " .. adminName .. ": #ffffff" .. msg, 89, 142, 215)
					end
				end
			end
		end
	end)

addCommandHandler("v",
	function (sourcePlayer, commandName, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			if not (...) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Üzenet]", 255, 150, 0)
			else
				local msg = string.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")

				if #msg > 0 and utf8.len(msg) > 0 then
					if utf8.len((utf8.gsub(msg, " ", "") or 0)) > 0 then
						local adminName = getElementData(sourcePlayer, "acc.adminNick")
						local adminRank = getPlayerAdminTitle(sourcePlayer)

						showStaffChat(adminRank .. " " .. adminName .. ": #ffffff" .. msg, 6)
					end
				end
			end
		end
	end)

addCommandHandler("as",
	function (sourcePlayer, commandName, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 or getElementData(sourcePlayer, "acc.helperLevel") > 0  then
			if not (...) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Üzenet]", 255, 150, 0)
			else
				local msg = string.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")

				if #msg > 0 and utf8.len(msg) > 0 then
					if utf8.len((utf8.gsub(msg, " ", "") or 0)) > 0 then
						local adminName = getElementData(sourcePlayer, "visibleName"):gsub("_", " ")
						local adminRank = getPlayerAdminTitle(sourcePlayer)

						if not adminRank then
							if getElementData(sourcePlayer, "acc.helperLevel") == 1 then
								adminRank = "AdminSegéd"
							elseif getElementData(sourcePlayer, "acc.helperLevel") == 2 then
								adminRank = "S.G.H."
							end
						end

						for k, v in pairs(getElementsByType("player")) do
							if (getElementData(v, "acc.adminLevel") or 0)>= 1 or (getElementData(v, "acc.helperLevel") or 0) >= 1 then
								outputChatBox("[HelperChat]: #3d7abc" .. adminRank .. " " .. adminName .. ": #ffffff" .. msg, v, 215, 89, 89, true)
							end
						end
					end
				end
			end
		end
	end)


addCommandHandler("jailed", 
	function (sourcePlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 6 then 
			print("a")
			for k, v in pairs(getElementsByType("player")) do 
				print("a")
				if (getElementData(v, "acc.adminJailTime") or -1) > 0 then
					print("a")
					local characterName = getElementData(v, "visibleName") or "false" 
					local adminJailTime = getElementData(v, "acc.adminJailTime") or 0
					local adminJailedBy = getElementData(v, "acc.adminJailBy") or "Admin"
					local adminJailReason = getElementData(v, "acc.adminJailReason") or "false"
					local allJailedPlayers = #v
					outputChatBox("#3d7abc[StrongMTA - Jailed]: #ffffffÖsszesen #32b3ef" .. allJailedPlayers .. " db #ffffffjátékos van börtönben.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)


local unbanNotifySerials = {
    ["FD424DF6D41AB8322C89E1B3E7AC6BF4"] = true,
    ["3964A9A5103CDA070946DED861649B52"] = true
}

addCommandHandler("unban",
    function (sourcePlayer, commandName, targetData, reason)
        if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
            if not (targetData and reason) then
                showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Account ID / Serial] [Indok]", 255, 150, 0)
            else
                local unbanType = "playerAccountId"

                if tonumber(targetData) then
                    targetData = tonumber(targetData)
                elseif string.len(targetData) == 32 then
                    unbanType = "serial"
                else
                    return false
                end

                local currTimestamp = getRealTime().timestamp

                dbQuery(
                    function (qh, adminPlayer)
                        local result, rows = dbPoll(qh, 0)

                        if rows > 0 and result then
                            local accountId = false
							local adminNick = getElementData(adminPlayer, "acc.adminNick")

                            for k, v in ipairs(result) do
                                if not accountId then
                                    accountId = v.playerAccountId
                                end

                                dbExec(connection, "UPDATE bans SET deactivated = 'Yes', deactivatedBy = ?, deactivateTimestamp = ?, deactivateReason = ? WHERE banId = ?", getElementData(sourcePlayer, "acc.adminNick"), currTimestamp, reason, v.banId)
                            end

                            dbExec(connection, "UPDATE accounts SET suspended = 0 WHERE accountId = ?", accountId)
                            exports.see_logs:logCommand(adminPlayer, commandName, {targetData})

                            if isElement(adminPlayer) then
                                showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen feloldottad a kiválasztott játékos tiltását.", 61, 122, 188)

                                for k, v in ipairs(getElementsByType("player")) do
                                    if unbanNotifySerials[getPlayerSerial(v)] then
                                        showAdminMessageFor(v, "[StrongMTA]: #ffffff" .. getElementData(sourcePlayer, "acc.adminNick") .. " Sikeresen feloldotta #32bef" .. targetData .. " #ffffffkitiltását.", 61, 122, 188)
                                    end
                                end
                            end
                        else
                            showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos nincs kitiltva.", 215, 89, 89)
                        end
                    end,
                {sourcePlayer}, connection, "SELECT * FROM bans WHERE ?? = ? AND deactivated = 'No'", unbanType, targetData)
            end
        end
    end
)

function offBanFunction(datas)
	local adminNick = datas.adminNick
	local adminAccountId = datas.adminAccountId

	if isElement(datas.sourcePlayer) then
		adminNick = getElementData(datas.sourcePlayer, "acc.adminNick")
		adminAccountId = getElementData(datas.sourcePlayer, "char.accID")
	end

	local qh = dbQuery(connection, "SELECT * FROM characters WHERE name = ?", datas.characterName)
	local result = dbPoll(qh, -1)
	result = result[1]

	if not result then
		exports.see_accounts:showInfo(datas.sourcePlayer, "e", "Nincs ilyen nevű karakter regisztrálva a szerveren!")
		return
	end

	local qh2 = dbQuery(connection, "SELECT * FROM accounts WHERE accountId = ?", result.accountId)
	local result2 = dbPoll(qh2, -1)
	result2 = result2[1]

	local targetName = result.name:gsub("_", " ")
	local accountName, playerAccountId = result2.username, result2.accountId
	local duration = datas.duration

	local currentTime = getRealTime().timestamp
	local expireTime = currentTime

	if duration == 0 then
		expireTime = currentTime + 31536000 * 100
	else
		expireTime = currentTime + duration * 3600
	end

	if targetName then
		triggerClientEvent("addKickbox", root, "ban", adminNick, targetName, datas.reason, tostring(duration))
	end

	dbExec(connection, [[
		INSERT INTO bans
		(serial, playerName, playerAccountId, adminName, adminAccountId, banReason, banTimestamp, expireTimestamp)
		VALUES (?,?,?,?,?,?,?,?)
	]], result2.serial, accountName, playerAccountId, adminNick, adminAccountId, (datas.reason or "N/A"), currentTime, expireTime)

	dbExec(connection, "UPDATE accounts SET suspended = 1 WHERE accountId = ?", playerAccountId)

	return "ok"
end

addCommandHandler("offban",
	function (sourcePlayer, commandName, characterName, duration, ...)
		duration = tonumber(duration)

		if getElementData(sourcePlayer, "acc.adminLevel") >= 2 or getElementData(sourcePlayer, "acc.adminNick") == "muffsheen" then
			if not (duration and characterName and (...)) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Karakternév (alsóvonallal)] [Óra < 0 = örök >] [Indok]", 255, 150, 0)
			else
				if characterName then
					offBanFunction({
						sourcePlayer = sourcePlayer,
						characterName = characterName,
						reason = table.concat({...}, " "),
						duration = math.floor(math.abs(duration)),
					})
				end
			end
		end
	end)

function banFunction(datas)
	local adminNick = datas.adminNick
	local adminAccountId = datas.adminAccountId

	if isElement(datas.sourcePlayer) then
		adminNick = getElementData(datas.sourcePlayer, "acc.adminNick")
		adminAccountId = getElementData(datas.sourcePlayer, "char.accID")
	end

	local targetName = datas.targetName
	local accountName, playerAccountId = datas.accountName, datas.playerAccountId
	local duration = datas.duration

	if isElement(datas.targetPlayer) then
		targetName = getElementData(datas.targetPlayer, "visibleName"):gsub("_", " ")
		accountName = getElementData(datas.targetPlayer, "acc.Name")
		playerAccountId = getElementData(datas.targetPlayer, "char.accID")
	end

	local currentTime = getRealTime().timestamp
	local expireTime = currentTime

	if duration == 0 then
		expireTime = 1924988399
	else
		expireTime = currentTime + duration * 3600
	end

	if isElement(datas.targetPlayer) then
		kickPlayer(datas.targetPlayer, adminNick, "Ki lettél tiltva a szerverről!")
	end

	if targetName then
		triggerClientEvent(root, "addKickbox", root, "ban", adminNick, targetName, datas.reason, tostring(duration))
	end

	dbExec(connection, [[
		INSERT INTO bans
		(serial, playerName, playerAccountId, adminName, adminAccountId, banReason, banTimestamp, expireTimestamp)
		VALUES (?,?,?,?,?,?,?,?)
	]], datas.serial, accountName, playerAccountId, adminNick, adminAccountId, datas.reason, currentTime, expireTime)

	dbExec(connection, "UPDATE accounts SET suspended = 1 WHERE accountId = ?", playerAccountId)

	setElementData(datas.sourcePlayer, "acc.ban", (getElementData(datas.sourcePlayer, "acc.ban") or 0)+1)
	dbExec(connection, "UPDATE accounts SET statBan = ? WHERE accountId = ?", getElementData(datas.sourcePlayer,"acc.ban"), getElementData(datas.sourcePlayer, "char.accID"))

	return "ok"
end

addCommandHandler("ban",
	function (sourcePlayer, commandName, targetPlayer, duration, ...)
		duration = tonumber(duration)

		if getElementData(sourcePlayer, "acc.adminLevel") >= 2 then
			if not (targetPlayer and duration and (...)) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Óra < 0 = örök >] [Indok]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				banFunction({
					sourcePlayer = sourcePlayer,
					targetPlayer = targetPlayer,
					reason = table.concat({...}, " "),
					duration = math.floor(math.abs(duration)),
					serial = getPlayerSerial(targetPlayer)
				})
			end
		end
	end
)

addCommandHandler("kick",
	function (sourcePlayer, commandName, targetPlayer, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not (targetPlayer and (...)) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Indok]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				local adminName = getElementData(sourcePlayer, "acc.adminNick")
				local reason = table.concat({...}, " ")

				triggerClientEvent(root, "addKickbox", root, "kick", adminName, targetName, reason)
				kickPlayer(targetPlayer, adminName, reason)

				exports.see_logs:logCommand(adminName, commandName, {targetName, reason})

				setElementData(sourcePlayer, "acc.kick", (getElementData(sourcePlayer, "acc.kick") or 0)+1)
				dbExec(connection, "UPDATE accounts SET statKick = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.kick"), getElementData(sourcePlayer, "char.accID"))
			end
		end
	end)

addCommandHandler("takemoney",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 8 then
			value = tonumber(value)

			if not (targetPlayer and value and value > 0) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Összeg]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					value = math.floor(value)
					exports.see_core:takeMoney(targetPlayer, value, "admintake")

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffelvett tőled #d75959" .. formatNumber(value) .. " #ffffffdollárt.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffElvettél #32b3ef" .. targetName .. " #ffffffjátékostól #d75959" .. formatNumber(value) .. " #ffffffdollárt.", 61, 122, 188)
				end
			end
		end
	end)

addCommandHandler("givemoney",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 8 then
			value = tonumber(value)

			if not (targetPlayer and value and value > 0) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Összeg]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					value = math.floor(value)
					exports.see_core:giveMoney(targetPlayer, value, "admingive")

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffadott neked #3d7abc" .. formatNumber(value) .. " #ffffffdollárt.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffAdtál #32b3ef" .. targetName .. " #ffffffjátékosnak #3d7abc" .. formatNumber(value) .. " #ffffffdollárt.", 61, 122, 188)
				end
			end
		end
	end
)

addCommandHandler("setmoney",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 8 then
			value = tonumber(value)

			if not (targetPlayer and value and value > 0) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Összeg]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					value = math.floor(value)
					exports.see_core:setMoney(targetPlayer, value, "admingive")

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffbeálltotta a pénzed a következőre: #3d7abc" .. formatNumber(value) .. " #ffffffdollár.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffBeállítottad #32b3ef" .. targetName .. " #ffffffjátékosnak a pénzét a következőre: #3d7abc" .. formatNumber(value) .. " #ffffffdollár.", 61, 122, 188)
				end
			end
		end
	end
)

addCommandHandler("forceaduty",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then

			if not (targetPlayer) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local targetAdminNick = getElementData(targetPlayer, "acc.adminNick")
					local adminRank = getPlayerAdminTitle(sourcePlayer)

					executeCommandHandler("aduty", targetPlayer)

					--showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminRank .. " ".. adminName .. " #ffffffadminszolgálatba léptetett.", 61, 122, 188)
					if getElementData(targetPlayer, "adminDuty") == 0 then 
						showMessageForAdmins("#3d7abc[StrongMTA - #32b3efAdminNapló#3d7abc]: #ffffff" .. adminRank .. " ".. adminName .. " #ffffffkiléptette az adminszolgálatból #32b3ef" .. targetAdminNick .. " #ffffff-t.", 61, 122, 188)
					elseif getElementData(targetPlayer, "adminDuty") == 1 then
						showMessageForAdmins("#3d7abc[StrongMTA - #32b3efAdminNapló#3d7abc]: #ffffff" .. adminRank .. " ".. adminName .. " #ffffffadminszolgálatba léptette #32b3ef" .. targetAdminNick .. " #ffffff-t.", 61, 122, 188)
					end
				end
			end
		end
	end
)

addCommandHandler("setpp",
	function (sourcePlayer, commandName, targetPlayer, state, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			state = tonumber(state)
			value = tonumber(value)

			if not (targetPlayer and state and state >= 0 and state <= 1 and value and value > 0) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [0 = levonás | 1 = hozzáadás] [Összeg]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local currentPP = getElementData(targetPlayer, "acc.premiumPoints") or 0
					local newPP = currentPP

					value = math.floor(value)

					if state == 0 then
						newPP = currentPP - value

						if newPP < 0 then
							newPP = 0
						end
					elseif state == 1 then
						newPP = currentPP + value
					end

					setElementData(targetPlayer, "acc.premiumPoints", newPP)

					dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", newPP, getElementData(targetPlayer, "char.accID"))

					if state == 0 then
						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #fffffflevont tőled #d75959" .. formatNumber(value) .. " #ffffffPP-t.", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffLevontál #32b3ef" .. targetName .. " #ffffffjátékostól #d75959" .. formatNumber(value) .. " #ffffffPP-t.", 61, 122, 188)
					elseif state == 1 then
						showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffadott neked #3d7abc" .. formatNumber(value) .. " #ffffffPP-t.", 61, 122, 188)
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffAdtál #32b3ef" .. targetName .. " #ffffffjátékosnak #3d7abc" .. formatNumber(value) .. " #ffffffPP-t.", 61, 122, 188)
					end
				end
			end
		end
	end)

addCommandHandler("setskin",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			value = tonumber(value)

			if not targetPlayer or not value or value < 0 then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Skin ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					setElementModel(targetPlayer, value)
					setElementData(targetPlayer, "char.Skin", value)

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta a kinézeted. #3d7abc(" .. value .. ")", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen megváltoztattad #32b3ef" .. targetName .. " #ffffffkinézetét. #3d7abc(" .. value .. ")", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, value})
				end
			end
		end
	end)

addCommandHandler("unfreeze",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					if pedveh then
						setElementFrozen(pedveh, false)
					end

					setElementFrozen(targetPlayer, false)
					exports.see_controls:toggleControl(targetPlayer, "all", true)

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffkiolvasztott téged.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffKiolvasztottad #32b3ef" .. targetName .. " #ffffffjátékost.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
				end
			end
		end
	end)

addCommandHandler("freeze",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local pedveh = getPedOccupiedVehicle(targetPlayer)

					if pedveh then
						setElementFrozen(pedveh, true)
					end

					setElementFrozen(targetPlayer, true)
					exports.see_controls:toggleControl(targetPlayer, "all", false)

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #fffffflefagyasztott téged.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffLefagyasztottad #32b3ef" .. targetName .. " #ffffffjátékost.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
				end
			end
		end
	end)

addCommandHandler("setthirst",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			value = tonumber(value)

			if not targetPlayer or not value or value < 0 or value > 100 then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Szomjúság < 0 - 100 >]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					setElementData(targetPlayer, "char.Thirst", value)

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta a szomjúságszinted. #3d7abc(" .. value .. ")", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffMegváltoztattad #32b3ef" .. targetName .. " #ffffffjátékos szomjúságszintjét. #3d7abc(" .. value .. ")", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, value})
				end
			end
		end
	end)

addCommandHandler("sethunger",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			value = tonumber(value)

			if not targetPlayer or not value or value < 0 or value > 100 then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Éhség < 0 - 100 >]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					setElementData(targetPlayer, "char.Hunger", value)

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta az éhségszinted. #3d7abc(" .. value .. ")", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffMegváltoztattad #32b3ef" .. targetName .. " #ffffffjátékos éhségszintjét. #3d7abc(" .. value .. ")", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, value})
				end
			end
		end
	end)

addCommandHandler("setarmor",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			value = tonumber(value)

			if not targetPlayer or not value or value < 0 or value > 100 then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Páncélzat < 0 - 100 >]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local adminRank = getPlayerAdminTitle(sourcePlayer)

					setPedArmor(targetPlayer, value)

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta a páncélzatodat. #3d7abc(" .. value .. ")", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffMegváltoztattad #32b3ef" .. targetName .. " #ffffffjátékos páncélzatát. #3d7abc(" .. value .. ")", 61, 122, 188)
					showAdminLog(adminRank .. " " .. adminName .. " átállította #32b3ef" .. targetName .. " #ffffffpáncélzatát. #32b3ef(" .. value .. ")")

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, value})

					setElementData(sourcePlayer, "acc.armor", (getElementData(sourcePlayer, "acc.armor") or 0)+1)
					dbExec(connection, "UPDATE accounts SET statArmor = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.armor"), getElementData(sourcePlayer, "char.accID"))
				end
			end
		end
	end)

addCommandHandler("sethp",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			value = tonumber(value)

			if not targetPlayer or not value or value < 0 or value > 100 then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Életerő < 0 - 100 >]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local adminRank = getPlayerAdminTitle(sourcePlayer)

					setElementHealth(targetPlayer, value)

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta az életerődet. #3d7abc(" .. value .. ")", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffMegváltoztattad #32b3ef" .. targetName .. " #ffffffjátékos életerejét. #3d7abc(" .. value .. ")", 61, 122, 188)
					showAdminLog(adminRank .. " " .. adminName .. " átállította #32b3ef" .. targetName .. " #fffffféleterejét. #32b3ef(" .. value .. ")")

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, value})

					setElementData(sourcePlayer, "acc.sethp", (getElementData(sourcePlayer, "acc.sethp") or 0)+1)
					dbExec(connection, "UPDATE accounts SET statSetHP = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.sethp"), getElementData(sourcePlayer, "char.accID"))
				end
			end
		end
	end)

addCommandHandler("vhspawn",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						removePedFromVehicle(targetPlayer)
					end

					setElementPosition(targetPlayer, 1042.7795410156, 1010.8475952148, 11)
					setElementInterior(targetPlayer, 0)
					setElementDimension(targetPlayer, 0)

					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffelteleportált téged a városházára.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen elteleportáltad a kiválasztott játékost a városházára. #32b3ef(" .. targetName .. ")", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
				end
			end
		end
	end)
addCommandHandler("tuningspawn",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 5 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						removePedFromVehicle(targetPlayer)
					end

					setElementPosition(targetPlayer, 404.50494384766, 2471.8176269531, 16.298713684082)
					setElementInterior(targetPlayer, 0)
					setElementDimension(targetPlayer, 0)

					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffelteleportált téged a tuningolóhoz.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen elteleportáltad a kiválasztott játékost a tuningolóhoz. #32b3ef(" .. targetName .. ")", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
				end
			end
		end
	end)

addCommandHandler("akspawn",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if isPedInVehicle(targetPlayer) then
						removePedFromVehicle(targetPlayer)
					end

					setElementPosition(targetPlayer, 1669.2921142578, 1804.6446533203, 10.8203125)
					setElementInterior(targetPlayer, 0)
					setElementDimension(targetPlayer, 0)

					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffelteleportált téged az autókereskedéshez.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffSikeresen elteleportáltad a kiválasztott játékost az autókereskedéshez. #32b3ef(" .. targetName .. ")", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
				end
			end
		end
	end)

addCommandHandler("gethere",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local x, y, z = getElementPosition(sourcePlayer)
					local int = getElementInterior(sourcePlayer)
					local dim = getElementDimension(sourcePlayer)
					local rot = getPedRotation(sourcePlayer)

					x = x + math.cos(math.rad(rot)) * 2
					y = y + math.sin(math.rad(rot)) * 2

					local customInterior = getElementData(sourcePlayer, "currentCustomInterior") or 0
					if customInterior > 0 then
						exports.see_interioredit:loadInterior(targetPlayer, customInterior)
					end

					if isPedInVehicle(targetPlayer) then
						local pedveh = getPedOccupiedVehicle(targetPlayer)

						setElementAngularVelocity(pedveh, 0, 0, 0)
						setElementInterior(pedveh, int)
						setElementDimension(pedveh, dim)
						setElementPosition(pedveh, x, y, z + 1)

						setTimer(setElementAngularVelocity, 50, 20, pedveh, 0, 0, 0)
					else
						setElementPosition(targetPlayer, x, y, z)
						setElementInterior(targetPlayer, int)
						setElementDimension(targetPlayer, dim)
					end

					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmagához teleportált.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffMagadhoz teleportáltad #32b3ef" .. targetName .. " #ffffffjátékost.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
				end
			end
		end
	end)

addCommandHandler("goto",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			if not targetPlayer then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local x, y, z = getElementPosition(targetPlayer)
					local int = getElementInterior(targetPlayer)
					local dim = getElementDimension(targetPlayer)
					local rot = getPedRotation(targetPlayer)

					x = x + math.cos(math.rad(rot)) * 2
					y = y + math.sin(math.rad(rot)) * 2

					local customInterior = getElementData(targetPlayer, "currentCustomInterior") or 0
					if customInterior > 0 then
						local editingInterior = getElementData(targetPlayer, "editingInterior") or 0
						if editingInterior == 0 then
							exports.see_interioredit:loadInterior(sourcePlayer, customInterior)
						else
							showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos interior szerkesztő módban van.", 215, 89, 89)
							return
						end
					end

					if isPedInVehicle(sourcePlayer) then
						local pedveh = getPedOccupiedVehicle(sourcePlayer)

						setElementAngularVelocity(pedveh, 0, 0, 0)
						setElementInterior(pedveh, int)
						setElementDimension(pedveh, dim)
						setElementPosition(pedveh, x, y, z + 1)

						setElementInterior(sourcePlayer, int)
						setElementDimension(sourcePlayer, dim)
						setCameraInterior(sourcePlayer, int)

						--warpPedIntoVehicle(sourcePlayer, pedveh)
						setTimer(setElementAngularVelocity, 50, 20, pedveh, 0, 0, 0)
					else
						setElementPosition(sourcePlayer, x, y, z)
						setElementInterior(sourcePlayer, int)
						setElementDimension(sourcePlayer, dim)
						setCameraInterior(sourcePlayer, int)
					end

					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffhozzád teleportált.", 61, 122, 188)
					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffElteleportáltál #32b3ef" .. targetName .. " #ffffffjátékoshoz.", 61, 122, 188)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
				end
			end
		end
	end)

addCommandHandler("vanish",
	function (sourcePlayer, commandName)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			local vanished = getElementData(sourcePlayer, "player.Vanished")
			local newState = not vanished

			setElementData(sourcePlayer, "player.Vanished", newState)
			setElementAlpha(sourcePlayer, newState and 0 or 255)

			if newState then
				showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffLáthatatlanná tetted magad.", 61, 122, 188)
			else
				showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffLáthatóvá tetted magad.", 61, 122, 188)
			end
		end
	end)

addCommandHandler("aduty",
	function (sourcePlayer, commandName)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			local adminDutyState = getElementData(sourcePlayer, "adminDuty") or 0
			local adminName = getElementData(sourcePlayer, "acc.adminNick")

			if adminDutyState == 0 then
				setPlayerName(sourcePlayer, adminName)
				setElementData(sourcePlayer, "visibleName", adminName)
				setElementData(sourcePlayer, "adminDuty", 1)
				setElementData(sourcePlayer, "invulnerable", true)

				exports.see_hud:showInfobox(root, "i", adminName .. " adminszolgálatba lépett.")
				showMessageForAdmins("[AdminDuty]: #32b3ef" .. adminName .. " #ffffffadminszolgálatba lépett.", 89, 142, 215)
			else
				local adutyCounter = 0
				if getElementData(sourcePlayer, "acc.adminLevel") <= 5 then
					for k, v in pairs(getElementsByType("player")) do
						if getElementData(v, "adminDuty") == 1 then
							adutyCounter = adutyCounter + 1
						end
					end
					if adutyCounter*25 < #getElementsByType("player") then
						showMessageForAdmins("[AdminDuty]: #32b3ef" .. adminName .. " megpróbált kilépni adminszolgálatból, de nincs arány", 89, 142, 215)
						exports.see_hud:showInfobox(sourcePlayer, "e", "Nincs arány!")
						return
					end
				end

				local characterName = getElementData(sourcePlayer, "char.Name")

				setPlayerName(sourcePlayer, characterName)
				setElementData(sourcePlayer, "visibleName", characterName)
				setElementData(sourcePlayer, "adminDuty", 0)
				setElementData(sourcePlayer, "invulnerable", false)

				exports.see_hud:showInfobox(root, "i", adminName .. " kilépett az adminszolgálatból.")
				showMessageForAdmins("[AdminDuty]: #3d7abc" .. adminName .. " #ffffffkilépett az adminszolgálatból.", 89, 142, 215)
			end
		end
	end
)


addCommandHandler("aduty2",
	function (sourcePlayer, commandName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			local adminDutyState = getElementData(sourcePlayer, "adminDuty") or 0
			local adminName = getElementData(sourcePlayer, "acc.adminNick")

			if adminDutyState ~= 2 then
				local characterName = getElementData(sourcePlayer, "char.Name")

				setPlayerName(sourcePlayer, characterName)
				setElementData(sourcePlayer, "visibleName", characterName)
				setElementData(sourcePlayer, "adminDuty", 2)
				setElementData(sourcePlayer, "invulnerable", true)

				showAdminMessageFor(sourcePlayer, "[AdminDuty - Hidden]: #ffffffRejtett adminszolgálatba léptél.", 89, 142, 215)
			else
				local characterName = getElementData(sourcePlayer, "char.Name")

				setPlayerName(sourcePlayer, characterName)
				setElementData(sourcePlayer, "visibleName", characterName)
				setElementData(sourcePlayer, "adminDuty", 0)
				setElementData(sourcePlayer, "invulnerable", false)

				showAdminMessageFor(sourcePlayer, "[AdminDuty - Hidden]: #ffffffKiléptél az adminszolgálatból..", 89, 142, 215)
			end
		end
	end
)


addCommandHandler("changename",
	function (sourcePlayer, commandName, partialNick, newName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not (partialNick and newName) then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Név / ID] [Új név]", 255, 150, 0)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, partialNick)

				if isElement(targetPlayer) then
					local accountId = getElementData(targetPlayer, "char.ID")
					local fixedName = utf8.gsub(newName, " ", "_")
					local currentName = getElementData(targetPlayer, "char.Name"):gsub("_", " ")
					local adminRank = getPlayerAdminTitle(sourcePlayer)

					dbQuery(
						function (queryHandle)
							local result, numRows = dbPoll(queryHandle, 0)

							if numRows == 0 then
								dbExec(connection, "UPDATE characters SET name = ? WHERE characterId = ?", fixedName, accountId)

								if isElement(targetPlayer) then
									local adminName = getElementData(sourcePlayer, "acc.adminNick")

									setPlayerName(targetPlayer, fixedName)
									setElementData(targetPlayer, "char.Name", fixedName)

									if getElementData(targetPlayer, "adminDuty") ~= 1 then
										setElementData(targetPlayer, "visibleName", fixedName)
									end

									showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffátállította a karakterneved. #32b3ef(" .. fixedName:gsub("_", " ") .. ")", 61, 122, 188)
									showAdminLog(adminRank .. " " .. adminName .. " megváltoztatta #32b3ef" .. targetName .. " #ffffffnevét. #7cc576(" .. fixedName:gsub("_", " ") .. ")")

									setElementData(sourcePlayer, "acc.changename", (getElementData(sourcePlayer, "acc.changename") or 0)+1)
									dbExec(connection, "UPDATE accounts SET statChangeName = ? WHERE accountId = ?", getElementData(sourcePlayer,"acc.changename"), getElementData(sourcePlayer, "char.accID"))
								end

								if isElement(sourcePlayer) then
									showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffÁtállítottad #32b3ef" .. currentName .. " #ffffffjátékos karakternevét. #32b3ef(" .. fixedName:gsub("_", " ") .. ")", 61, 122, 188)
								end
							else
								showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott karakternév foglalt!", 215, 89, 89)
							end
						end,
					connection, "SELECT name FROM characters WHERE name = ? LIMIT 1", fixedName)
				end
			end
		end
	end
)

addCommandHandler("setadminnick",
	function (sourcePlayer, commandName, targetPlayer, newName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			if not targetPlayer or not newName then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Új név]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")

					setElementData(targetPlayer, "acc.adminNick", newName)

					if getElementData(targetPlayer, "adminDuty") == 1 then
						setElementData(targetPlayer, "visibleName", newName)
					end

					dbExec(connection, "UPDATE accounts SET adminNick = ? WHERE accountId = ?", newName, getElementData(targetPlayer, "char.accID"))

					showAdminMessage("[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta #32b3ef" .. targetName .. " #ffffffadminisztrátori nevét. #32b3ef(" .. newName .. ")", 127, 197, 118)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, newName})
				end
			end
		end
	end
)

addCommandHandler("stats",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then 
			if not targetPlayer then 
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)
				local moneyInHand = getElementData(targetPlayer, "char.Money") or 0
				local bankMoney = getElementData(targetPlayer, "char.bankMoney") or 0
				local playerSkin = getElementData(targetPlayer, "char.Skin") or 0
				local slotCoins = getElementData(targetPlayer, "char.slotCoins") or 0
				local playerGroups = inspect(exports.see_groups:getPlayerGroups(targetPlayer))
				local adminLevel = getElementData(targetPlayer, "acc.adminLevel") or 0
				local premiumPoints = getElementData(targetPlayer, "acc.premiumPoints") or 0
				local adminName = getElementData(targetPlayer, "acc.adminNick") or "Admin"

				if getElementData(targetPlayer, adminName) == "Admin" then 
					adminName = "Nincs"
				end

				outputChatBox("#7cc576[StrongMTA]: #32b3ef" .. targetName .. " #FFFFFFstatisztikái: ", sourcePlayer, 255, 255, 255, true)
				outputChatBox("	  #FFFFFFSkin ID: #32b3ef" .. playerSkin, sourcePlayer, 255, 255, 255, true)
				outputChatBox("   #FFFFFFAdmin név: #32b3ef" .. adminName, sourcePlayer, 255, 255, 255, true)
				outputChatBox("   #FFFFFFAdmin: #32b3ef" .. adminLevel, sourcePlayer, 255, 255, 255, true)
				--outputChatBox("	  #FFFFFFFrakció(i): #32b3ef" .. playerGroups .. "$", sourcePlayer, 255, 255, 255, true)
				outputChatBox("	  #FFFFFFKészpénz: #7cc576" .. formatNumber(moneyInHand) .. "$", sourcePlayer, 255, 255, 255, true)
				outputChatBox("	  #FFFFFFBanki egyenleg: #7cc576" .. formatNumber(bankMoney) .. "$", sourcePlayer, 255, 255, 255, true)
				outputChatBox("	  #FFFFFFKaszinó zseton egyenleg: #7cc576" .. formatNumber(slotCoins) .. "$", sourcePlayer, 255, 255, 255, true)
				outputChatBox("	  #FFFFFFPrémium egyenleg: #32b3ef" .. formatNumber(premiumPoints) .. "PP", sourcePlayer, 255, 255, 255, true)

			end
		end
		
	end 
)

addCommandHandler("setadminlevel",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			value = tonumber(value)

			if not targetPlayer or not value or value < 0 or value > 11 then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Szint < 0 - 11 >]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local currentAdminLevel = getElementData(targetPlayer, "acc.adminLevel") or 0

					if value == currentAdminLevel then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos már a megadott szinten van.", 215, 89, 89)
						return
					end

					if value == 0 then
						--outputChatBox("GECIS FASZ VISIBLENAMEE NAME OK")
						setElementData(targetPlayer, "adminDuty", false)
						print(getElementData(targetPlayer, "char.Name"):gsub("_", " "))
						--setElementData(targetPlayer, "visibleName", nil)
						iprint(getElementData(targetPlayer, "visibleName"))
						setElementData(targetPlayer, "visibleName", tostring(getElementData(targetPlayer, "char.Name")))
					end

					local targetAdminNick = getElementData(targetPlayer, "acc.adminNick")

					setElementData(targetPlayer, "acc.adminLevel", value)

					dbExec(connection, "UPDATE accounts SET adminLevel = ? WHERE accountId = ?", value, getElementData(targetPlayer, "char.accID"))

					if getElementData(targetPlayer, "acc.adminNick") == "Admin" then 
						showAdminMessage("[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta #32b3ef" .. targetName .. " #ffffffadminisztrátori szintjét. #7cc576(" .. currentAdminLevel .. " -> " .. value .. ")", 127, 197, 118)
					else
						showAdminMessage("[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta #32b3ef" .. targetAdminNick .. " #ffffffadminisztrátori szintjét. #7cc576(" .. currentAdminLevel .. " -> " .. value .. ")", 127, 197, 118)
					end
					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, value})
				end
			end
		end
	end
)

addCommandHandler("sethelperlevel",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 3 then
			value = tonumber(value)

			if not targetPlayer or not value or value < 0 or value > 2 then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Szint < 0 - 2 >]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local currentAdminLevel = getElementData(targetPlayer, "acc.helperLevel") or 0

					if value == currentAdminLevel then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos már a megadott szinten van.", 215, 89, 89)
						return
					end

					if value == 0 then
						--outputChatBox("GECIS FASZ VISIBLENAMEE NAME OK")
						setElementData(targetPlayer, "adminDuty", false)
						print(getElementData(targetPlayer, "char.Name"):gsub("_", " "))
						--setElementData(targetPlayer, "visibleName", nil)
						iprint(getElementData(targetPlayer, "visibleName"))
						setElementData(targetPlayer, "visibleName", tostring(getElementData(targetPlayer, "char.Name")))
					end

					setElementData(targetPlayer, "acc.helperLevel", value)

					if value > 1 or value == 0 then
						dbExec(connection, "UPDATE accounts SET helperLevel = ? WHERE accountId = ?", value, getElementData(targetPlayer, "char.accID"))
					end

					showAdminMessage("[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta #32b3ef" .. targetName .. " #ffffffadminsegéd szintjét. #7cc576(" .. currentAdminLevel .. " -> " .. value .. ")", 127, 197, 118)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, value})
				end
			end
		end
	end
)

function banPlayerCommand ( theClient, commandName, bannedName, reason )

	-- Give the player a nice error if he doesn't have rights
	if ( hasObjectPermissionTo ( theClient, "function.banPlayer" ) ) then
		--Get player element from the name
		local bannedPlayer = getPlayerFromName ( bannedName )

		--Ban the player
		banPlayer ( bannedPlayer, theClient, reason )
		outputChatBox ( "ban: " .. bannedName .. " successfully banned", theClient )

	else
		outputChatBox ( "ban: You don't have enough permissions", theClient )
	end

end
addCommandHandler ( "kutyaban", banPlayerCommand )

addCommandHandler("ancik",
	function (source)
		setElementData(source, "acc.adminNick", "marco")
	end 
)

addCommandHandler("ancik2",
	function (source)
		setElementData(source, "acc.adminNick", "boti")
	end 
)

addCommandHandler("setguardlevel",
	function (sourcePlayer, commandName, targetPlayer, value)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			value = tonumber(value)

			if not targetPlayer or not value or value < 0 or value > 3 then
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Szint < 0 - 2 >]", 255, 150, 0)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminName = getElementData(sourcePlayer, "acc.adminNick")
					local currentAdminLevel = getElementData(targetPlayer, "acc.rpGuard") or 0

					if value == currentAdminLevel then
						showAdminMessageFor(sourcePlayer, "[StrongMTA]: #ffffffA kiválasztott játékos már a megadott szinten van.", 215, 89, 89)
						return
					end

					if value == 0 then
						--outputChatBox("GECIS FASZ VISIBLENAMEE NAME OK")
						setElementData(targetPlayer, "adminDuty", false)
						print(getElementData(targetPlayer, "char.Name"):gsub("_", " "))
						--setElementData(targetPlayer, "visibleName", nil)
						iprint(getElementData(targetPlayer, "visibleName"))
						setElementData(targetPlayer, "visibleName", tostring(getElementData(targetPlayer, "char.Name")))
					end

					setElementData(targetPlayer, "acc.rpGuard", value)

					dbExec(connection, "UPDATE accounts SET guardLevel = ? WHERE accountId = ?", value, getElementData(targetPlayer, "char.accID"))

					showAdminMessageFor(sourcePlayer, "[StrongMTA]: #FFFFFFSikeresen megváltoztattad #32b3ef" .. targetName .. " #ffffffguard szintjét. #7cc576(" .. currentAdminLevel .. " -> " .. value .. ")", 127, 197, 118)
					showAdminMessageFor(targetPlayer, "[StrongMTA]: #32b3ef" .. adminName .. " #ffffffmegváltoztatta guard szinted. #7cc576(" .. currentAdminLevel .. " -> " .. value .. ")", 127, 197, 118)

					exports.see_logs:logCommand(sourcePlayer, commandName, {targetName, value})
				end
			end
		end
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}

		for k, v in pairs(spectatingPlayers) do
			if isElement(k) then
				local playerLastPos = getElementData(k, "playerLastPos")
				local currentTarget = getElementData(k, "spectateTarget") -- nézett játékos lekérése

				spectatingPlayers[k] = nil -- kivesszük a parancs használóját a nézett játékos nézelődői közül

				setElementAlpha(k, 255)
				setElementInterior(k, playerLastPos[4])
				setElementDimension(k, playerLastPos[5])
				setCameraInterior(k, playerLastPos[4])
				setCameraTarget(k, k)
				setElementFrozen(k, false)
				setElementCollisionsEnabled(k, true)
				setElementPosition(k, playerLastPos[1], playerLastPos[2], playerLastPos[3])
				setElementRotation(k, 0, 0, playerLastPos[6])

				removeElementData(k, "spectateTarget")
				removeElementData(k, "playerLastPos")
			end
		end
	end
)

addEvent("updateSpectatePosition", true)
addEventHandler("updateSpectatePosition", getRootElement(),
	function (interior, dimension, customInterior)
		if isElement(source) then
			setElementInterior(source, interior)
			setElementDimension(source, dimension)
			setCameraInterior(source, interior)

			if customInterior and customInterior > 0 then
				triggerClientEvent(source, "loadCustomInterior", source, customInterior)
			end
		end
	end
)
	
addCommandHandler("spec", 
	function(sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") > 0 then
			if not targetPlayer then
				--outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminNick = getPlayerAdminNick(sourcePlayer)

					if targetPlayer == sourcePlayer then -- ha a célszemély saját maga, kapcsolja ki a nézelődést
						local playerLastPos = getElementData(sourcePlayer, "playerLastPos")

						if playerLastPos then -- ha tényleg nézelődött
							local currentTarget = getElementData(sourcePlayer, "spectateTarget") -- nézett játékos lekérése
							local spectatingPlayers = getElementData(currentTarget, "spectatingPlayers") or {} -- nézett játékos nézelődőinek lekérése

							spectatingPlayers[sourcePlayer] = nil -- kivesszük a parancs használóját a nézett játékos nézelődői közül
							setElementData(currentTarget, "spectatingPlayers", spectatingPlayers) -- elmentjük az úrnak

							setElementAlpha(sourcePlayer, 255)
							setElementInterior(sourcePlayer, playerLastPos[4])
							setElementDimension(sourcePlayer, playerLastPos[5])
							setCameraInterior(sourcePlayer, playerLastPos[4])
							setCameraTarget(sourcePlayer, sourcePlayer)
							setElementFrozen(sourcePlayer, false)
							setElementCollisionsEnabled(sourcePlayer, true)
							setElementPosition(sourcePlayer, playerLastPos[1], playerLastPos[2], playerLastPos[3])
							setElementRotation(sourcePlayer, 0, 0, playerLastPos[6])

							removeElementData(sourcePlayer, "spectateTarget")
							removeElementData(sourcePlayer, "playerLastPos")

							local targetName = getElementData(sourcePlayer, "visibleName")
							local adminRank = getPlayerAdminTitle(sourcePlayer)

							--outputInfoText("Kikapcsoltad #32b3ef" .. targetName .. " #ffffffjátékos nézését.", sourcePlayer)
							--outputChatBox("stop spec")
							--exports.sarp_core:sendMessageToAdmins("#32b3ef" .. adminNick .. " #ffffffbefejezte #32b3ef" .. targetName .. " #ffffffjátékos nézését.")
							showMessageForAdmins("#c8c8c8[TV] " .. adminRank .. "#2B73BC " .. adminNick .. "#c8c8c8 kikapcsolta a TV-zést.")
						end
					else
						local targetInterior = getElementInterior(targetPlayer)
						local targetDimension = getElementDimension(targetPlayer)
						local currentTarget = getElementData(sourcePlayer, "spectateTarget")
						local playerLastPos = getElementData(sourcePlayer, "playerLastPos")

						if currentTarget and currentTarget ~= targetPlayer then -- ha a jelenleg nézett célszemély nem az új célszemély vegye ki a nézelődők listájából
							local spectatingPlayers = getElementData(currentTarget, "spectatingPlayers") or {} -- jelenleg nézett célszemély nézelődői

							spectatingPlayers[sourcePlayer] = nil -- eltávolítjuk az eddig nézett játékos nézelődői közül
							setElementData(currentTarget, "spectatingPlayers", spectatingPlayers) -- elmentjük a változásokat
						end

						if not playerLastPos then -- ha eddig nem volt nézelődő módban, mentse el a jelenlegi pozícióját
							local localX, localY, localZ = getElementPosition(sourcePlayer)
							local localRotX, localRotY, localRotZ = getElementPosition(sourcePlayer)
							local localInterior = getElementInterior(sourcePlayer)
							local localDimension = getElementDimension(sourcePlayer)

							setElementData(sourcePlayer, "playerLastPos", {localX, localY, localZ, localInterior, localDimension, localRotZ}, false)
						end

						setElementAlpha(sourcePlayer, 0)
						setPedWeaponSlot(sourcePlayer, 0)
						setElementInterior(sourcePlayer, targetInterior)
						setElementDimension(sourcePlayer, targetDimension)
						setCameraInterior(sourcePlayer, targetInterior)
						setCameraTarget(sourcePlayer, targetPlayer)
						setElementFrozen(sourcePlayer, true)
						setElementCollisionsEnabled(sourcePlayer, false)

						local spectatingPlayers = getElementData(targetPlayer, "spectatingPlayers") or {} -- lekérjük az új úrfi jelenlegi nézelődőit

						spectatingPlayers[sourcePlayer] = true -- hozzáadjuk az úrfi nézelődőihez a parancs használóját
						setElementData(targetPlayer, "spectatingPlayers", spectatingPlayers) -- elmentjük az úrfinak a változásokat

						setElementData(sourcePlayer, "spectateTarget", targetPlayer)

						local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")
						local adminRank = getPlayerAdminTitle(sourcePlayer)

						--outputInfoText("Elkezdted nézni #32b3ef" .. targetName .. " #ffffffjátékost.", sourcePlayer)
						--outputChatBox("start spec")
						showMessageForAdmins("#c8c8c8[TV] " .. adminRank .. "#2B73BC " .. adminNick .. " #c8c8c8elkezdte TV-zni #2B73BC" .. targetName .. " #c8c8c8-et.")
					end
				end
			end
		end
	end
)


addCommandHandler("baszospec", 
	function(sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			if not targetPlayer then
				--outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
				showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", 255, 150, 0)
			else
				targetPlayer = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local adminNick = getPlayerAdminNick(sourcePlayer)

					if targetPlayer == sourcePlayer then -- ha a célszemély saját maga, kapcsolja ki a nézelődést
						local playerLastPos = getElementData(sourcePlayer, "playerLastPos")

						if playerLastPos then -- ha tényleg nézelődött
							local currentTarget = getElementData(sourcePlayer, "spectateTarget") -- nézett játékos lekérése
							local spectatingPlayers = getElementData(currentTarget, "spectatingPlayers") or {} -- nézett játékos nézelődőinek lekérése

							spectatingPlayers[sourcePlayer] = nil -- kivesszük a parancs használóját a nézett játékos nézelődői közül
							setElementData(currentTarget, "spectatingPlayers", spectatingPlayers) -- elmentjük az úrnak

							setElementAlpha(sourcePlayer, 255)
							setElementInterior(sourcePlayer, playerLastPos[4])
							setElementDimension(sourcePlayer, playerLastPos[5])
							setCameraInterior(sourcePlayer, playerLastPos[4])
							setCameraTarget(sourcePlayer, sourcePlayer)
							setElementFrozen(sourcePlayer, false)
							setElementCollisionsEnabled(sourcePlayer, true)
							setElementPosition(sourcePlayer, playerLastPos[1], playerLastPos[2], playerLastPos[3])
							setElementRotation(sourcePlayer, 0, 0, playerLastPos[6])

							removeElementData(sourcePlayer, "spectateTarget")
							removeElementData(sourcePlayer, "playerLastPos")

							local targetName = getElementData(sourcePlayer, "visibleName")
							local adminRank = getPlayerAdminTitle(sourcePlayer)

							--outputInfoText("Kikapcsoltad #32b3ef" .. targetName .. " #ffffffjátékos nézését.", sourcePlayer)
							--outputChatBox("stop spec")
							--exports.sarp_core:sendMessageToAdmins("#32b3ef" .. adminNick .. " #ffffffbefejezte #32b3ef" .. targetName .. " #ffffffjátékos nézését.")
							--showMessageForAdmins("#c8c8c8[TV] " .. adminRank .. "#2B73BC " .. adminNick .. "#c8c8c8 kikapcsolta a TV-zést.")
						end
					else
						local targetInterior = getElementInterior(targetPlayer)
						local targetDimension = getElementDimension(targetPlayer)
						local currentTarget = getElementData(sourcePlayer, "spectateTarget")
						local playerLastPos = getElementData(sourcePlayer, "playerLastPos")

						if currentTarget and currentTarget ~= targetPlayer then -- ha a jelenleg nézett célszemély nem az új célszemély vegye ki a nézelődők listájából
							local spectatingPlayers = getElementData(currentTarget, "spectatingPlayers") or {} -- jelenleg nézett célszemély nézelődői

							spectatingPlayers[sourcePlayer] = nil -- eltávolítjuk az eddig nézett játékos nézelődői közül
							setElementData(currentTarget, "spectatingPlayers", spectatingPlayers) -- elmentjük a változásokat
						end

						if not playerLastPos then -- ha eddig nem volt nézelődő módban, mentse el a jelenlegi pozícióját
							local localX, localY, localZ = getElementPosition(sourcePlayer)
							local localRotX, localRotY, localRotZ = getElementPosition(sourcePlayer)
							local localInterior = getElementInterior(sourcePlayer)
							local localDimension = getElementDimension(sourcePlayer)

							setElementData(sourcePlayer, "playerLastPos", {localX, localY, localZ, localInterior, localDimension, localRotZ}, false)
						end

						setElementAlpha(sourcePlayer, 0)
						setPedWeaponSlot(sourcePlayer, 0)
						setElementInterior(sourcePlayer, targetInterior)
						setElementDimension(sourcePlayer, targetDimension)
						setCameraInterior(sourcePlayer, targetInterior)
						setCameraTarget(sourcePlayer, targetPlayer)
						setElementFrozen(sourcePlayer, true)
						setElementCollisionsEnabled(sourcePlayer, false)

						local spectatingPlayers = getElementData(targetPlayer, "spectatingPlayers") or {} -- lekérjük az új úrfi jelenlegi nézelődőit

						spectatingPlayers[sourcePlayer] = true -- hozzáadjuk az úrfi nézelődőihez a parancs használóját
						setElementData(targetPlayer, "spectatingPlayers", spectatingPlayers) -- elmentjük az úrfinak a változásokat

						setElementData(sourcePlayer, "spectateTarget", targetPlayer)

						local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")
						local adminRank = getPlayerAdminTitle(sourcePlayer)

						--outputInfoText("Elkezdted nézni #32b3ef" .. targetName .. " #ffffffjátékost.", sourcePlayer)
						--outputChatBox("start spec")
						--showMessageForAdmins("#c8c8c8[TV] " .. adminRank .. "#2B73BC " .. adminNick .. " #c8c8c8elkezdte TV-zni #2B73BC" .. targetName .. " #c8c8c8-et.")
					end
				end
			end
		end
	end
)


