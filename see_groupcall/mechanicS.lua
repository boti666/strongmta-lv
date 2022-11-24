local callerPlayers = {}
local callTimers = {}

addCommandHandler("callmechanic",
	function (sourcePlayer)
		triggerEvent("callMechanic", sourcePlayer, 123456789)
	end
)

addEvent("callMechanic", true)
addEventHandler("callMechanic", getRootElement(),
	function (phoneNumber)
		if isElement(source) then
			if not getElementData(source, "isCalledTowtruck") then 
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
				setElementData(source, "isCalledTowtruck", true)

				triggerClientEvent("mechanicMessageFromServer", resourceRoot, "Hívás érkezett! (" .. getZoneName(x, y, z) .. ")")
				triggerClientEvent("mechanicMessageFromServer", resourceRoot, "Elfogadáshoz: /acceptmechanic " .. callID .. " vagy /acceptmechanic auto")
			else
				outputChatBox("#d75959[StrongMTA]: #FFFFFFMár hívtál egy vontatót.", source, 255, 255, 255, true)
			end
		end
	end
)

function cancelAuto(playerElement, callID, disconnected)
	if not disconnected then
		triggerClientEvent("mechanicMessageFromServer", resourceRoot, "Mivel az " .. callID .. ". számú hívásra nem válaszolt senki 15 percig, ezért törlődött.")
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

addEvent("endTheMechanic", true)
addEventHandler("endTheMechanic", getRootElement(),
	function (callerId)
		if callerId then
			callerPlayers[callerId] = nil
		end
	end
)

addCommandHandler("acceptmechanic",
	function (sourcePlayer, commandName, callerId)
		if exports.see_groups:isPlayerHavePermission(sourcePlayer, "repair") then
			if callerId == "auto" then
				local lastId = false

				for k, v in pairs(callerPlayers) do
					if v ~= "accepted" then
						lastId = k
					end
				end

				if lastId then
					acceptMechanic(sourcePlayer, lastId)
				else
					mechanicMessage("Nincs fogadatlan hívás.", sourcePlayer)
				end
			else
				callerId = tonumber(callerId)

				if callerId then
					acceptMechanic(sourcePlayer, callerId)
				else
					mechanicMessage("/" .. commandName .. " [< szám | auto >]", sourcePlayer)
				end
			end
		end
	end
)

function acceptMechanic(playerElement, callerId)
	if callerPlayers[callerId] then
		local targetPlayer = callerPlayers[callerId]

		if isElement(targetPlayer) then
			if isTimer(callTimers[targetPlayer]) then
				killTimer(callTimers[targetPlayer])
			end

			callTimers[targetPlayer] = nil
		
			local visibleName = getElementData(playerElement, "visibleName"):gsub("_", " ")

			triggerClientEvent(playerElement, "handleMechanicBlip", playerElement, targetPlayer, callerId)
			triggerClientEvent("mechanicMessageFromServer", resourceRoot, visibleName .. " elfogadta az " .. callerId .. ". számú hívást.")
			triggerClientEvent("radioSoundForMech", resourceRoot)

			exports.see_hud:showInfobox(targetPlayer, "s", "Elfogadták a hívásod! Maradj a helyszínen.")
			setElementData(targetPlayer, "isCalledTowtruck", false)
		else
			if targetPlayer == "accepted" then
				mechanicMessage("Már elfogadta egy kollegád.", playerElement)
			end
		end

		callerPlayers[callerId] = "accepted"
	else
		mechanicMessage("Nincs hívás ezzel az azonosítóval.", playerElement)
	end
end

function mechanicMessage(message, playerElement)
	outputChatBox("#32b3ef[SeeMTA - Autómentő]:#FFFFFF " .. message, playerElement, 255, 255, 255, true)
end