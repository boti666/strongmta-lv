local placedDoLabels = {}
local placeDoTimer = false

addEvent("getTickSync", true)
addEventHandler("getTickSync", getResourceRootElement(),
	function ()
		if isElement(client) then
			triggerClientEvent(client, "getTickSync", client, getRealTime().timestamp)
		end
	end
)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue, newValue)
		if dataName == "afk" then
			if newValue then
				setElementData(source, "startAfk", getRealTime().timestamp)
			else
				removeElementData(source, "startAfk")
			end
		elseif dataName == "startedAnim" then
			local newValue = getElementData(source, "startedAnim")

			if newValue then
				setElementData(source, "startAnim", getRealTime().timestamp)
			else
				removeElementData(source, "startAnim")
			end
		elseif dataName == "paintOnPlayerFace" then
			local newValue = getElementData(source, "paintOnPlayerFace")

			if newValue then
				local playedMinutes = getElementData(source, "char.playedMinutes") or 0

				setElementData(source, "paintOnPlayerTime", playedMinutes)
				setElementData(source, "paintVisibleOnPlayer", true)
				removeElementData(source, "paintOnPlayerFace")

				setPedAnimation(source, false)
			end
		end
	end
)

addCommandHandler("placedo",
	function (sourcePlayer, commandName, ...)
		if getElementData(sourcePlayer, "loggedIn") then
			if not (...) then
				outputChatBox("#bc873d[WeakMTA - Chat]: #ffffff/" .. commandName .. " [szöveg]", sourcePlayer, 255, 194, 14, true)
			else
				local message = utf8.gsub(table.concat({...}, " "), "#%x%x%x%x%x%x", "")

				if utf8.len(message) > 0 then
					local characterId = getElementData(sourcePlayer, "char.ID")
					local numOfLabels = 0

					for k, v in pairs(placedDoLabels) do
						if characterId == v.characterId then
							numOfLabels = numOfLabels + 1
						end
					end

					if numOfLabels < 5 then
						local labelIndex = 1

						for i = 1, #placedDoLabels + 1 do
							if not placedDoLabels[i] then
								labelIndex = i
								break
							end
						end

						placedDoLabels[labelIndex] = {
							messageText = message .. " ((" .. getElementData(sourcePlayer, "visibleName"):gsub("_", " ") .. "))",
							characterId = characterId,
							position = {getElementPosition(sourcePlayer)},
							interior = getElementInterior(sourcePlayer),
							dimension = getElementDimension(sourcePlayer),
							currentTime = getTickCount(),
							visibleTime = 1000 * 60 * 60 * 3
						}

						triggerClientEvent("addPlaceDo", resourceRoot, labelIndex, placedDoLabels[labelIndex])

						if not isTimer(placeDoTimer) then
							placeDoTimer = setTimer(removeExpiredPlaceDos, 1000 * 60 * 10, 0)
						end
					else
						exports.wm_hud:showInfobox(sourcePlayer, "e", "Maximum 5 placedo engedélyezett!")
					end
				end
			end
		end
	end
)

addEvent("requestPlaceDos", true)
addEventHandler("requestPlaceDos", getResourceRootElement(),
	function ()
		if isElement(client) then
			triggerClientEvent(client, "gotRequestPlaceDos", client, placedDoLabels)
		end
	end
)
iprint("asd")
addEvent("deletePlaceDo", true)
addEventHandler("deletePlaceDo", getRootElement(),
	function (labelIndex)
		if isElement(client) and client and client == source then
			if labelIndex then
				local numOfLabels = 0

				placedDoLabels[labelIndex] = nil

				for k, v in pairs(placedDoLabels) do
					numOfLabels = numOfLabels + 1
				end

				if numOfLabels == 0 then
					if isTimer(placeDoTimer) then
						killTimer(placeDoTimer)
					end
				end

				triggerClientEvent("deletePlaceDo", resourceRoot, labelIndex)
			end
		end
	end
)

function removeExpiredPlaceDos()
	local currentTickCount = getTickCount()
	local numOfLabels = 0

	for k, v in pairs(placedDoLabels) do
		if currentTickCount >= v.currentTime + v.visibleTime then
			placedDoLabels[k] = nil
			triggerClientEvent("deletePlaceDo", resourceRoot, k)
		else
			numOfLabels = numOfLabels + 1
		end
	end

	if numOfLabels == 0 then
		if isTimer(placeDoTimer) then
			killTimer(placeDoTimer)
		end
	end
end
