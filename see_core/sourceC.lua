local screenX, screenY = guiGetScreenSize()
local isWatermarkEnabled = true
local watermarkLabel = false

addCommandHandler("togwatermark",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			isWatermarkEnabled = not isWatermarkEnabled

			if isWatermarkEnabled then
				createWatermark()
			else
				destroyWatermark()
			end
		end
	end)

addCommandHandler("togglecursor",
	function ()
		showCursor(not isCursorShowing())
	end)
bindKey("m", "down", "togglecursor")

local sX, sY = guiGetScreenSize()

function createMisi()
	if getElementData(localPlayer, "acc.adminLevel") >= 6 then 
		if isMisi then
			isMisi = false
			removeEventHandler("onClientRender", root, onMisi)
		else
			isMisi = true
			addEventHandler("onClientRender", root, onMisi)
		end
	end
end
addCommandHandler("misi", createMisi)

function onMisi()
	dxDrawImage(sX - 515, sY - 515, 512, 512, "files/misi.png", 0, 0, 0, tocolor(200, 200, 200, 200))
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setHeatHaze(0)
		setBlurLevel(0)
		setCloudsEnabled(false)

		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)

		setWorldSpecialPropertyEnabled("randomfoliage", false)
		setWorldSpecialPropertyEnabled("extraairresistance", false)

		setAmbientSoundEnabled("general", true)
		setAmbientSoundEnabled("gunfire", false)

		for k, v in ipairs(getElementsByType("player")) do
			setPedVoice(v, "PED_TYPE_DISABLED")
			setPlayerNametagShowing(v, false)
		end

		for k, v in ipairs(getElementsByType("ped")) do
			setPedVoice(v, "PED_TYPE_DISABLED")
		end

		setTimer(
			function ()
				toggleControl("next_weapon", false)
				toggleControl("previous_weapon", false)
			end,
		1000, 0)

		--setWorldSoundEnabled(0, 0, false, true)
		--setWorldSoundEnabled(0, 29, false, true)
		--setWorldSoundEnabled(0, 30, false, true)
		--setWorldSoundEnabled(41, false, true) -- footsteps

		if isWatermarkEnabled then
			createWatermark()
		end
	end)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "ped" or getElementType(source) == "player" then
			setPedVoice(source, "PED_TYPE_DISABLED")
		end
	end)

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "loggedIn" then
			if isWatermarkEnabled then
				updateWatermark()
			end
		end
	end)

function destroyWatermark()
	if isElement(watermarkLabel) then
		destroyElement(watermarkLabel)
	end
	watermarkLabel = nil
end

function createWatermark()
	destroyWatermark()

	watermarkLabel = guiCreateLabel(0, screenY - 25, screenX - 80, 24, "", false)

	if isElement(watermarkLabel) then
		guiLabelSetVerticalAlign(watermarkLabel, "bottom")
		guiLabelSetHorizontalAlign(watermarkLabel, "right")
		guiSetAlpha(watermarkLabel, 0.5)
		updateWatermark()
	end
end

function updateWatermark()
	if isElement(watermarkLabel) then
		local time = getRealTime()
		local date = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 1, time.monthday)
		local str = "StrongMTA"

		if getElementData(localPlayer, "loggedIn") then
			str = str .. " # Account ID:" .. getElementData(localPlayer, "char.accID")
		end

		str = str .. " # " .. date

		guiSetText(watermarkLabel, str)
	end
end

addEventHandler("onClientPlayerJoin", getRootElement(),
	function ()
		setPlayerNametagShowing(source, false)
	end)

addEventHandler("onClientGUIBlur", getRootElement(),
	function ()
		guiSetInputMode("no_binds_when_editing")
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
		if #candidates == 0 then
			outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem található.", 255, 255, 255, true)
		else
			outputChatBox("#3d7abc[StrongMTA]: #ffffffEzzel a névrészlettel #32b3ef" .. #candidates .. " db #ffffffjátékos található:", 255, 255, 255, true)

			for i = 1, #candidates do
				local player = candidates[i]

				if isElement(player) then
					local playerId = getElementData(player, "playerID")
					local playerName = string.gsub(getPlayerName(player), "_", " ")

					outputChatBox("#3d7abc    (" .. tostring(playerId) .. ") #ffffff" .. playerName, 255, 255, 255, true)
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
			outputChatBox("#d75959[StrongMTA]:  #ffffffA kiválasztott játékos nincs bejelentkezve.", 255, 255, 255, true)
			return false
		end
	end
end
