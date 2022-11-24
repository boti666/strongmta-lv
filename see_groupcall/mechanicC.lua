local blipElement = false
local markerElement = false
local currentCallerID = false
setElementData(localPlayer, "isCalledTowtruck", false)


addEvent("handleMechanicBlip", true)
addEventHandler("handleMechanicBlip", getRootElement(),
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

				triggerServerEvent("endTheMechanic", localPlayer, currentCallerID)
			end
		end
	end
)

addEvent("radioSoundForMech", true)
addEventHandler("radioSoundForMech", getRootElement(),
	function ()
		if exports.see_groups:isPlayerInGroup(localPlayer, {15, 39, 19}) then
			playSoundFrontEnd(47)
			setTimer(playSoundFrontEnd, 700, 1, 48)
			setTimer(playSoundFrontEnd, 800, 1, 48)
		end
	end
)

addEvent("mechanicMessageFromServer", true)
addEventHandler("mechanicMessageFromServer", getRootElement(),
	function (message)
		if exports.see_groups:isPlayerInGroup(localPlayer, {15, 39, 19}) then
			mechanicMessage(message)
		end
	end
)

function mechanicMessage(message)
	outputChatBox("#32b3ef[StrongMTA - Autómentő]:#FFFFFF " .. message, 255, 255, 255, true)
end