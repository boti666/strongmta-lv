local wheelComponents = {"wheel_rf_dummy", "wheel_lf_dummy", "wheel_rb_dummy", "wheel_lb_dummy"}
local availableSpinners = {4812, 4813, 4814, 4815, 4816, 4817, 4818, 4819}

local spinnerObjects = {}
local spinnerShaders = {}

local myLastDimension = 0

local previewSize = {false, false, false}
local previewColor = {false, false, false}
local originalSpinner = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local spinnerTXD = engineLoadTXD("spinners/spinner.txd")

		if spinnerTXD then
			for i = 1, #availableSpinners do
				local spinnerDFF = engineLoadDFF("spinners/" .. i .. ".dff")

				if spinnerDFF then
					engineImportTXD(spinnerTXD, availableSpinners[i])
					engineReplaceModel(spinnerDFF, availableSpinners[i])
				end
			end
		end

		for k, v in pairs(getElementsByType("vehicle", getRootElement(), true)) do
			applySpinner(v, true)
		end

		myLastDimension = getElementDimension(localPlayer)
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			applySpinner(source, true)
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "tuningSpinners" then
			applySpinner(source, true)
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			applySpinner(source, false)
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			applySpinner(source, false)
		end
	end
)

function applySpinner(vehicle, state)
	if spinnerObjects[vehicle] then
		for i = 1, #spinnerObjects[vehicle] do
			if isElement(spinnerObjects[vehicle][i]) then
				destroyElement(spinnerObjects[vehicle][i])
			end
		end

		spinnerObjects[vehicle] = nil
	end

	if isElement(spinnerShaders[vehicle]) then
		destroyElement(spinnerShaders[vehicle])
	end

	spinnerShaders[vehicle] = nil

	if state then
		local spinnerData = getElementData(vehicle, "tuningSpinners")

		if spinnerData then
			if isElementStreamedIn(vehicle) then
				local currentInterior = getElementInterior(vehicle)
				local currentDimension = getElementDimension(vehicle)

				spinnerObjects[vehicle] = {
					createObject(spinnerData[1], 0, 0, 0),
					createObject(spinnerData[1], 0, 0, 0),
					createObject(spinnerData[1], 0, 0, 0),
					createObject(spinnerData[1], 0, 0, 0)
				}

				if spinnerData[5] then
					spinnerShaders[vehicle] = dxCreateShader("tint.fx")

					if isElement(spinnerShaders[vehicle]) then
						dxSetShaderValue(spinnerShaders[vehicle], "red", spinnerData[5] / 255)
						dxSetShaderValue(spinnerShaders[vehicle], "green", spinnerData[6] / 255)
						dxSetShaderValue(spinnerShaders[vehicle], "blue", spinnerData[7] / 255)
					end
				end

				for i = 1, 4 do
					local spinnerObject = spinnerObjects[vehicle][i]

					if isElement(spinnerObject) then
						if spinnerData[5] then
							if isElement(spinnerShaders[vehicle]) then
								engineApplyShaderToWorldTexture(spinnerShaders[vehicle], "*", spinnerObject)
							end
						end

						setElementCollisionsEnabled(spinnerObject, false)
						setObjectScale(spinnerObject, spinnerData[2], spinnerData[3], spinnerData[4])

						setElementInterior(spinnerObject, currentInterior)
						setElementDimension(spinnerObject, currentDimension)
					end
				end

				setTimer(
					function ()
						if isElement(vehicle) then
							local x, y, z = getElementPosition(vehicle)
							setElementPosition(vehicle, x, y, z + 0.01)
							setElementPosition(vehicle, x, y, z)
						end
					end,
				200, 1)

				spinnerObjects[vehicle][5] = 0
			end
		end
	end
end

addEventHandler("onClientPreRender", getRootElement(),
	function (timeStep)
		local currentDimension = getElementDimension(localPlayer)

		if myLastDimension ~= currentDimension then
			myLastDimension = currentDimension

			for k in pairs(spinnerObjects) do
				triggerEvent("onClientElementStreamIn", k)
			end
		end

		timeStep = timeStep / 1000

		for k, v in pairs(spinnerObjects) do
			local velocityX, velocityY, velocityZ = getElementVelocity(k)
			local currentSpeed = math.sqrt(velocityX*velocityX + velocityY*velocityY + velocityZ*velocityZ) * 180
			local spinnerSpeed = 1 + currentSpeed / 10

			v[5] = v[5] + spinnerSpeed * timeStep * 100

			for i = 1, 4 do
				local posX, posY, posZ = getVehicleComponentPosition(k, wheelComponents[i])
				local rotX, rotY, rotZ = getVehicleComponentRotation(k, wheelComponents[i])

				if i % 2 == 1 then
					attachElements(v[i], k, posX, posY, posZ, v[5], rotY, rotZ)
				else
					attachElements(v[i], k, posX, posY, posZ, -v[5], rotY, rotZ)
				end
			end
		end
	end
)

addEvent("buySpinner", true)
addEventHandler("buySpinner", getRootElement(),
	function (state, value)
		originalSpinner = value
	end
)

function getOriginalSpinner()
	if originalSpinner then
		if originalSpinner ~= 0 then
			return tonumber(originalSpinner[1])
		end
	end
	return false
end

function resetSpinner(vehicle)
	if originalSpinner == 0 then
		originalSpinner = false
	end

	setElementData(vehicle, "tuningSpinners", originalSpinner)

	originalSpinner = false
end

function previewSpinner(vehicle, spinnerId, tinted)
	if not originalSpinner then
		originalSpinner = getElementData(vehicle, "tuningSpinners") or 0
	end

	if spinnerId then
		if tinted then
			setElementData(vehicle, "tuningSpinners", {spinnerId, previewSize[1], previewSize[2], previewSize[3], previewColor[1], previewColor[2], previewColor[3]}, false)
		else
			setElementData(vehicle, "tuningSpinners", {spinnerId, previewSize[1], previewSize[2], previewSize[3]}, false)
		end
	else
		setElementData(vehicle, "tuningSpinners", false, false)
	end
end

function getPreviewColor()
	return previewColor[1], previewColor[2], previewColor[3], previewSize[1], previewSize[2], previewSize[3]
end

function setPreviewColor(vehicle, r, g, b)
	previewColor = {r, g, b}

	if spinnerShaders[vehicle] then
		dxSetShaderValue(spinnerShaders[vehicle], "red", r / 255)
		dxSetShaderValue(spinnerShaders[vehicle], "green", g / 255)
		dxSetShaderValue(spinnerShaders[vehicle], "blue", b / 255)
	end
end

function getSizeForPreview(vehicle)
	previewSize = {getSpinnerSize(vehicle)}
	previewColor = {false, false, false}
end

function getSpinnerSize(vehicle)
	local vehicleRotX, vehicleRotY, vehicleRotZ = getElementRotation(vehicle)
	local dummyPosX, dummyPosY, dummyPosZ = getVehicleComponentPosition(vehicle, "wheel_lb_dummy")

	if not dummyPosX then
		return 0.7, 0.7, 0.7
	end

	local isWheelVisible = getVehicleComponentVisible(vehicle, "wheel_lb_dummy")
	local tempWheels = {
		createObject(1218, 0, 0, 0),
		createObject(1218, 0, 0, 0),
		createObject(1218, 0, 0, 0),
		createObject(1218, 0, 0, 0)
	}

	for i = 1, 4 do
		if isElement(tempWheels[i]) then
			setElementAlpha(tempWheels[i], 0)
			setElementCollisionsEnabled(tempWheels[i], false)
		end
	end

	local sizeX, sizeY = 0, 0
	local minSizeY, maxSizeY = false, 0
	local minSizeX, maxSizeX = false, 200

	setVehicleComponentVisible(vehicle, "wheel_lb_dummy", true)
	setElementRotation(vehicle, 0, 0, 0)

	for i = 0, 200 do
		attachElements(tempWheels[1], vehicle, dummyPosX + 1, dummyPosY - 1 + i / 100, dummyPosZ)
		attachElements(tempWheels[2], vehicle, dummyPosX - 1, dummyPosY - 1 + i / 100, dummyPosZ)
		attachElements(tempWheels[3], vehicle, dummyPosX - 1 + i / 150, dummyPosY + 1, dummyPosZ)
		attachElements(tempWheels[4], vehicle, dummyPosX - 1 + i / 150, dummyPosY - 1, dummyPosZ)

		local wheelX1, wheelY1, wheelZ1 = getElementPosition(tempWheels[1])
		local wheelX2, wheelY2, wheelZ2 = getElementPosition(tempWheels[2])
		local wheelX3, wheelY3, wheelZ3 = getElementPosition(tempWheels[3])
		local wheelX4, wheelY4, wheelZ4 = getElementPosition(tempWheels[4])

		local wheelPart1 = select(11, processLineOfSight(wheelX2, wheelY2, wheelZ2, wheelX1, wheelY1, wheelZ1, true, true, true, true, true, false, false, false, nil, false, true))
		local wheelPart2 = select(11, processLineOfSight(wheelX4, wheelY4, wheelZ4, wheelX3, wheelY3, wheelZ3, true, true, true, true, true, false, false, false, nil, false, true))

		if wheelPart1 then
			if wheelPart1 >= 13 then
				if not minSizeY then
					minSizeY = i
				end

				maxSizeY = i
			end
		end

		if wheelPart2 then
			if wheelPart2 == 15 then
				if not minSizeX then
					minSizeX = i
				end
			end
		end
	end

	if minSizeX then
		sizeX = maxSizeX - minSizeX
	end

	if minSizeY then
		sizeY = maxSizeY - minSizeY
	end

	for i = 1, 4 do
		if isElement(tempWheels[i]) then
			destroyElement(tempWheels[i])
		end
	end

	local vehicleModel = getElementModel(vehicle)

	setElementVelocity(vehicle, 0, 0, 0)
	setElementRotation(vehicle, vehicleRotX, vehicleRotY, vehicleRotZ)
	setVehicleComponentVisible(vehicle, "wheel_lb_dummy", isWheelVisible)

	if vehicleModel == 567 then
		return sizeX / 140, sizeY / 75, sizeY / 75
	elseif vehicleModel == 585 then
		return sizeX / 120, sizeY / 75, sizeY / 75
	else
		return sizeX / 150, sizeY / 75, sizeY / 75
	end
end
