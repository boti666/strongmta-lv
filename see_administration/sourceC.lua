local spectateTarget = false
local lastSpectateUpdate = 0

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		
		if dataName == "spectateTarget" and source == localPlayer then
			spectateTarget = getElementData(localPlayer, "spectateTarget")

			if spectateTarget then
				local targetInterior = getElementInterior(spectateTarget)
				local targetDimension = getElementDimension(spectateTarget)

				triggerServerEvent("updateSpectatePosition", localPlayer, targetInterior, targetDimension, tonumber(getElementData(spectateTarget, "currentCustomInterior") or 0))
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if spectateTarget and isElement(spectateTarget) then
			local updatePosition = false
			local currentInterior = getElementInterior(localPlayer)
			local currentDimension = getElementDimension(localPlayer)
			local targetInterior = getElementInterior(spectateTarget)
			local targetDimension = getElementDimension(spectateTarget)

			if currentInterior ~= targetInterior then
				updatePosition = true
			end

			if currentDimension ~= targetDimension then
				updatePosition = true
			end

			if updatePosition and lastSpectateUpdate + 1000 <= getTickCount() then
				local customInterior = tonumber(getElementData(spectateTarget, "currentCustomInterior") or 0)

				triggerServerEvent("updateSpectatePosition", localPlayer, targetInterior, targetDimension, customInterior)

				lastSpectateUpdate = getTickCount()
			end
		end
	end
)
