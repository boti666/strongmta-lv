local blipElement = false
local markerElement = false
local currentCallerID = false
setElementData(localPlayer, "isCalledTaxi", false)


addEvent("handletaxiBlip", true)
addEventHandler("handletaxiBlip", getRootElement(),
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

				triggerServerEvent("endThetaxi", localPlayer, currentCallerID)
			end
		end
	end
)

addEvent("radioSoundForMech", true)
addEventHandler("radioSoundForMech", getRootElement(),
	function ()
		if exports.see_groups:isPlayerInGroup(localPlayer, 24) then
			playSoundFrontEnd(47)
			setTimer(playSoundFrontEnd, 700, 1, 48)
			setTimer(playSoundFrontEnd, 800, 1, 48)
		end
	end
)

addEvent("taxiMessageFromServer", true)
addEventHandler("taxiMessageFromServer", getRootElement(),
	function (message)
		if exports.see_groups:isPlayerInGroup(localPlayer, 24) then
			taxiMessage(message)
		end
	end
)

function taxiMessage(message)
	outputChatBox("#32b3ef[StrongMTA - Taxi]:#FFFFFF " .. message, 255, 255, 255, true)
end