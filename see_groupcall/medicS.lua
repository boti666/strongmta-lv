local callerPlayers = {}
local callTimers = {}

addCommandHandler("callmedic",
	function (sourcePlayer)
		triggerEvent("callMedic", sourcePlayer, 123456789)
	end
)

addEvent("callMedic", true)
addEventHandler("callMedic", getRootElement(),
	function (phoneNumber)
		if isElement(source) then
			if not getElementData(source, "isCalledMedic") then 
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
				setElementData(source, "isCalledMedic", true)

				triggerClientEvent("medicMessageFromServer", resourceRoot, "Hívás érkezett! (" .. getZoneName(x, y, z) .. ")")
				triggerClientEvent("medicMessageFromServer", resourceRoot, "Elfogadáshoz: /acceptmedic " .. callID .. " vagy /acceptmedic auto")
			else
				outputChatBox("#d75959[StrongMTA]: #FFFFFFMár hívtál egy mentőt.", source, 255, 255, 255, true)
			end
		end
	end
)

function cancelAuto(playerElement, callID, disconnected)
	if not disconnected then
		triggerClientEvent("medicMessageFromServer", resourceRoot, "Mivel az " .. callID .. ". számú hívásra nem válaszolt senki 15 percig, ezért törlődött.")
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

addEvent("endTheMedic", true)
addEventHandler("endTheMedic", getRootElement(),
	function (callerId)
		if callerId then
			callerPlayers[callerId] = nil
		end
	end
)

addCommandHandler("acceptmedic",
	function (sourcePlayer, commandName, callerId)
		if exports.see_groups:isPlayerHavePermission(sourcePlayer, "heal") then
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
					medicMessage("Nincs fogadatlan hívás.", sourcePlayer)
				end
			else
				callerId = tonumber(callerId)

				if callerId then
					acceptMedic(sourcePlayer, callerId)
				else
					medicMessage("/" .. commandName .. " [< szám | auto >]", sourcePlayer)
				end
			end
		end
	end
)

function acceptMedic(playerElement, callerId)
	if callerPlayers[callerId] then
		local targetPlayer = callerPlayers[callerId]

		if isElement(targetPlayer) then
			if isTimer(callTimers[targetPlayer]) then
				killTimer(callTimers[targetPlayer])
			end

			callTimers[targetPlayer] = nil
		
			local visibleName = getElementData(playerElement, "visibleName"):gsub("_", " ")

			triggerClientEvent(playerElement, "handleMedicBlip", playerElement, targetPlayer, callerId)
			triggerClientEvent("medicMessageFromServer", resourceRoot, visibleName .. " elfogadta az " .. callerId .. ". számú hívást.")
			triggerClientEvent("radioSoundForMedic", resourceRoot)

			exports.see_hud:showInfobox(targetPlayer, "s", "Elfogadták a hívásod! Maradj a helyszínen.")
			setElementData(targetPlayer, "isCalledMedic", false)
		else
			if targetPlayer == "accepted" then
				medicMessage("Már elfogadta egy kollegád.", playerElement)
			end
		end

		callerPlayers[callerId] = "accepted"
	else
		medicMessage("Nincs hívás ezzel az azonosítóval.", playerElement)
	end
end

function medicMessage(message, playerElement)
	outputChatBox("#32b3ef[SeeMTA - Mentő]:#FFFFFF " .. message, playerElement, 255, 255, 255, true)
end