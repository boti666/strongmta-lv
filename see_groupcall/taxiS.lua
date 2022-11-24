local callerPlayers = {}
local callTimers = {}

addCommandHandler("calltaxi",
	function (sourcePlayer)
		triggerEvent("calltaxi", sourcePlayer, 123456789)
	end
)

addEvent("calltaxi", true)
addEventHandler("calltaxi", getRootElement(),
	function (phoneNumber)
		if isElement(source) then
			if not getElementData(source, "isCalledTaxi") then 
				local x, y, z = getElementPosition(source)
				local callID = 1

				for i = 1, #callerPlayers + 1 do
					if not callerPlayers[i] then
						callID = i
						break
					end
				end

				callerPlayers[callID] = source
				callTimers[source] = setTimer(cancelAuto, 1000 * 60 * 15, 1, source, callID)
				setElementData(source, "isCalledTaxi", true)

				triggerClientEvent("taxiMessageFromServer", resourceRoot, "Hívás érkezett! (" .. getZoneName(x, y, z) .. ")")
				triggerClientEvent("taxiMessageFromServer", resourceRoot, "Elfogadáshoz: /accepttaxi " .. callID .. " vagy /accepttaxi auto")
			else
				outputChatBox("#d75959[StrongMTA]: #FFFFFFMár hívtál egy taxit.", source, 255, 255, 255, true)
			end
		end
	end
)

function cancelAuto(playerElement, callID, disconnected)
	if not disconnected then
		triggerClientEvent("taxiMessageFromServer", resourceRoot, "Mivel az " .. callID .. ". számú hívásra nem válaszolt senki 15 percig, ezért törlődött.")
	end

	if callerPlayers[callID] then
		if callerPlayers[callID] == playerElement then
			callerPlayers[callID] = nil
		end
	end

	if isTimer(callTimers[playerElement]) then
		killTimer(callTimers[playerElement])
	end

	callTimers[playerElement] = nil
end

addEvent("endThetaxi", true)
addEventHandler("endThetaxi", getRootElement(),
	function (callerId)
		if callerId then
			callerPlayers[callerId] = nil
		end
	end
)

addCommandHandler("accepttaxi",
	function (sourcePlayer, commandName, callerId)
		if exports.see_groups:isPlayerHavePermission(sourcePlayer, "canAcceptTaxi") then
			if callerId == "auto" then
				local lastId = false

				for k, v in pairs(callerPlayers) do
					if v ~= "accepted" then
						lastId = k
					end
				end

				if lastId then
					accepttaxi(sourcePlayer, lastId)
				else
					taxiMessage("Nincs fogadatlan hívás.", sourcePlayer)
				end
			else
				callerId = tonumber(callerId)

				if callerId then
					accepttaxi(sourcePlayer, callerId)
				else
					taxiMessage("/" .. commandName .. " [< szám | auto >]", sourcePlayer)
				end
			end
		end
	end
)

function accepttaxi(playerElement, callerId)
	if callerPlayers[callerId] then
		local targetPlayer = callerPlayers[callerId]

		if isElement(targetPlayer) then
			if isTimer(callTimers[targetPlayer]) then
				killTimer(callTimers[targetPlayer])
			end

			callTimers[targetPlayer] = nil
		
			local visibleName = getElementData(playerElement, "visibleName"):gsub("_", " ")

			triggerClientEvent(playerElement, "handletaxiBlip", playerElement, targetPlayer, callerId)
			triggerClientEvent("taxiMessageFromServer", resourceRoot, visibleName .. " elfogadta az " .. callerId .. ". számú hívást.")
			triggerClientEvent("radioSoundForMech", resourceRoot)

			exports.see_hud:showInfobox(targetPlayer, "s", "Elfogadták a hívásod! Maradj a helyszínen.")
			setElementData(targetPlayer, "isCalledTaxi", false)
		else
			if targetPlayer == "accepted" then
				taxiMessage("Már elfogadta egy kollegád.", playerElement)
			end
		end

		callerPlayers[callerId] = "accepted"
	else
		taxiMessage("Nincs hívás ezzel az azonosítóval.", playerElement)
	end
end

function taxiMessage(message, playerElement)
	outputChatBox("#fece01[StrongMTA - Taxi]:#FFFFFF " .. message, playerElement, 255, 255, 255, true)
end