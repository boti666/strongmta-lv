local createdGates = {}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(availableGates) do
			local objectElement = createObject(v[15], v[7], v[8], v[9], v[10], v[11], v[12])

			if isElement(objectElement) then
				setElementInterior(objectElement, v[13])
				setElementDimension(objectElement, v[14])

				createdGates[k] = {}
				createdGates[k].objectElement = objectElement
				createdGates[k].state = false
				createdGates[k].startTime = 0
			end
		end
	end
)

addEvent("toggleGate", true)
addEventHandler("toggleGate", getRootElement(),
	function (gateID)
		if isElement(source) and client and client == source then
			local gateParameters = availableGates[gateID]

			if gateParameters then
				local selectedGate = createdGates[gateID]

				if selectedGate then
					local adminDutyState = getElementData(source, "adminDuty") or 0

					if adminDutyState > 0 or exports.see_items:hasItemWithData(source, 3, gateID) then
						local elapsedTime = getTickCount() - selectedGate.startTime
						local movementTime = gateParameters[16]

						if elapsedTime >= movementTime then
							selectedGate.startTime = getTickCount()

							local rotX = angleDiff(gateParameters[10], gateParameters[4])
							local rotY = angleDiff(gateParameters[11], gateParameters[5])
							local rotZ = angleDiff(gateParameters[12], gateParameters[6])

							if not selectedGate.state then
								moveObject(selectedGate.objectElement, movementTime, gateParameters[1], gateParameters[2], gateParameters[3], rotX, rotY, rotZ)
							else
								moveObject(selectedGate.objectElement, movementTime, gateParameters[7], gateParameters[8], gateParameters[9], -rotX, -rotY, -rotZ)
							end

							selectedGate.state = not selectedGate.state

							if selectedGate.state then
								exports.see_chat:localAction(source, "kinyit egy közelben lévő kaput.")
							else
								exports.see_chat:localAction(source, "bezár egy közelben lévő kaput.")
							end
						end
					end
				end
			end
		end
	end
)

function angleDiff(firstAngle, secondAngle)
	local difference = secondAngle - firstAngle

	while difference < -180 do
		difference = difference + 360
	end

	while difference > 180 do
		difference = difference - 360
	end

	return difference
end