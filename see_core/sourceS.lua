local maxPlayers = tonumber(getServerConfigSetting("maxplayers"))
local slots = {}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		setGameType("StrongMTA")
		setMapName("Las Venturas")

		setMaxPlayers(maxPlayers)
		setElementData(resourceRoot, "server.maxPlayers", maxPlayers)

		for k, v in ipairs(getElementsByType("player")) do
			slots[k] = v
			setElementData(v, "playerID", k)
			setPlayerNametagShowing(v, false)
		end
	end)

addEventHandler("onPlayerJoin", getRootElement(),
	function ()
		local freeId = false

		for i = 1, maxPlayers do
			if not slots[i] then
				freeId = i
				break
			end
		end

		if freeId and isElement(source) then
			slots[freeId] = source
			setElementData(source, "playerID", freeId)
			setPlayerNametagShowing(source, false)
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		local playerId = getElementData(source, "playerID")

		if playerId then
			slots[playerId] = nil
		end
	end)

addCommandHandler("id",
	function (sourcePlayer, commandName, targetPlayer)
		if not targetPlayer then
			outputChatBox("#ff9900[Használat]: #ffffff/" .. commandName .. " [Név / ID]", sourcePlayer, 0, 0, 0, true)
		else
			targetPlayer, targetName = findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				outputChatBox("#3d7abc[StrongMTA]: #32b3ef" .. targetName .. " #ffffffjátékos azonosítója #3d7abc" .. getElementData(targetPlayer, "playerID") .. ".", sourcePlayer, 0, 0, 0, true)
			end
		end
	end)

addCommandHandler("lvl",
	function (sourcePlayer, commandName, targetPlayer)
		if not targetPlayer then
			outputChatBox("#ff9900[Használat]: #ffffff/" .. commandName .. " [Név / ID]", sourcePlayer, 0, 0, 0, true)
		else
			targetPlayer, targetName = findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				outputChatBox("#3d7abc[StrongMTA - Szint]: #ffffff" .. targetName .. " szintje: " .. getLevel(targetPlayer) .. ".", sourcePlayer, 0, 0, 0, true)
			end
		end
	end)

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
				outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem található.", sourcePlayer, 255, 255, 255, true)
			else
				outputChatBox("#3d7abc[StrongMTA]: #ffffffEzzel a névrészlettel #32b3ef" .. #candidates .. " db #ffffffjátékos található:", sourcePlayer, 255, 255, 255, true)
			
				for i = 1, #candidates do
					local player = candidates[i]

					if isElement(player) then
						local playerId = getElementData(player, "playerID")
						local playerName = string.gsub(getPlayerName(player), "_", " ")

						outputChatBox("#3d7abc    (" .. tostring(playerId) .. ") #ffffff" .. playerName, sourcePlayer, 255, 255, 255, true)
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
			outputChatBox("#d75959[StrongMTA]:  #ffffffA kiválasztott játékos nincs bejelentkezve.", sourcePlayer, 255, 255, 255, true)
			return false
		end
	end
end