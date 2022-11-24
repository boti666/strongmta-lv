local blipElement = false
local markerElement = false
local currentCallerID = false
setElementData(localPlayer, "isCalledMedic", false)


addEvent("handleMedicBlip", true)
addEventHandler("handleMedicBlip", getRootElement(),
	function (sourceElement, callerId)
		if isElement(blipElement) then
			destroyElement(blipElement)
		end

		if isElement(markerElement) then
			destroyElement(markerElement)
		end

		if isElement(sourceElement) then
			blipElement = createBlip(0, 0, 0, 0, 2, 50, 179, 239)

			if isElement(blipElement) then
				attachElements(blipElement, sourceElement)
				setElementData(blipElement, "blipTooltipText", "Ügyfél")
			end

			markerElement = createMarker(0, 0, 0, "checkpoint", 4, 50, 179, 239)

			if isElement(markerElement) then
				attachElements(markerElement, sourceElement)
			end

			currentCallerID = callerId
		end
	end
)

addEventHandler("onClientMarkerHit", getRootElement(),
	function (hitElement)
		if hitElement == localPlayer then
			if source == markerElement then
				if isElement(blipElement) then
					destroyElement(blipElement)
				end

				if isElement(markerElement) then
					destroyElement(markerElement)
				end

				triggerServerEvent("endTheMedic", localPlayer, currentCallerID)
			end
		end
	end
)

addEvent("radioSoundForMedic", true)
addEventHandler("radioSoundForMedic", getRootElement(),
	function ()
		if exports.see_groups:isPlayerInGroup(localPlayer, {2}) then
			playSoundFrontEnd(47)
			setTimer(playSoundFrontEnd, 700, 1, 48)
			setTimer(playSoundFrontEnd, 800, 1, 48)
		end
	end
)

addEvent("medicMessageFromServer", true)
addEventHandler("medicMessageFromServer", getRootElement(),
	function (message)
		if exports.see_groups:isPlayerInGroup(localPlayer, {2}) then
			medicMessage(message)
		end
	end
)

function medicMessage(message)
	outputChatBox("#32b3ef[StrongMTA - Mentő]:#FFFFFF " .. message, 255, 255, 255, true)
end