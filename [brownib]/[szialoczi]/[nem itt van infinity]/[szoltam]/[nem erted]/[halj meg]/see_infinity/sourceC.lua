local latestRow = 1
local currentRow = 1
local maxRow = 8
local lockCode = "lociGergelyLoricAlexBotoKotond"
local lockString = 655

local vehiclePath = "files/vehicles/" 

local vehicleCustomID = {}
local loadedVeh = {}
local modelTable = {}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		setTimer(function()
			for k, v in pairs(vehicleDatas) do
				local id = engineRequestModel("vehicle", v[1])
				vehicleCustomID[id] = {v[1], v[2]}
				vehDataToId[k] = id
	
				loadVehicleMod(id, v[2])
			end
	
			loadLockedDemon()
		end, 2500, 1)
	end
)

function loadVehicleMod(id, model)
	if tonumber(id) and model then
		if fileExists(vehiclePath .. model .. ".txd") then
			local txd = engineLoadTXD(vehiclePath .. model .. ".txd", true)

			if txd then
				engineImportTXD(txd, id)
			end
		end

		if fileExists(vehiclePath .. model .. ".strong") then
			local dff = engineLoadDFF(loadLockedFiles(vehiclePath .. model .. ".strong", lockCode), id)

			if dff then
				engineReplaceModel(dff, id)
			end
		elseif fileExists(vehiclePath .. model .. ".dff") then
			local dff = engineLoadDFF(vehiclePath .. model .. ".dff", id)

			if dff then
				engineReplaceModel(dff, id)
			end
		end
	end

	setTimer(function()
		for k, v in ipairs(getElementsByType("vehicle"), getRootElement(), true) do
			local vehID = getElementData(v, "vehicleSpecialMod")
	
			if vehID then
				local modelID = getElementModel(v)
	
				if vehID and not loadedVeh[modelID] then
					setSpecialVehicleMod(v)
				end
			end
		end
	end, 7000, 1)
end

addCommandHandler("buggedcars", 
	function ()
		if fileExists("files/vehicles/911turbo.strong") then 
			fileDelete("files/vehicles/911turbo.strong", true)
			fileDelete("files/vehicles/senna.strong", true)
			fileDelete("files/vehicles/modelx.strong", true)
			fileDelete("files/vehicles/models.strong", true)
			fileDelete("files/vehicles/roadster.strong", true)
			fileDelete("files/vehicles/wvid6.strong", true)
			fileDelete("files/vehicles/demon.strong", true)
			fileDelete("files/vehicles/charger.strong", true)
			fileDelete("files/vehicles/amgone.strong", true)
			fileDelete("files/vehicles/chiron.strong", true)

		end
	end 
)

function loadLockedFiles(path, key)
	local file = fileOpen(path)
	local size = fileGetSize(file)
	local FirstPart = fileRead(file, lockString+6)
	fileSetPos(file, lockString+6)
	local SecondPart = fileRead(file, size-(lockString+6))
	fileClose(file)
	return decodeString("tea", FirstPart, { key = key })..SecondPart
end

function setSpecialVehicleMod(element)
	local vehID = getElementData(element, "vehicleSpecialMod")

	if vehID and isElement(element) and vehDataToId[vehID] then
		setElementModel(element, vehDataToId[vehID])
		--triggerServerEvent("makeTuning", getRootElement(), element)
	end
end

addEventHandler("onClientVehicleEnter", getRootElement(),
	function(Player)
		if Player == localPlayer then
			triggerServerEvent("makeTuning", getRootElement(), source)
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function(dataName)

		if dataName == "vehicleSpecialMod" and getElementType(source) == "vehicle" and not loadedVeh[modelID] then
			local modelID = getElementModel(source)

			local vehID = getElementData(source, "vehicleSpecialMod")

			if vehID then
				setSpecialVehicleMod(source)
			end

			--loadedVeh[modelID] = true
		end
	end
)	

function loadLockedDemon()
	local model = "demon"
	local id = 426

	if fileExists(vehiclePath .. model .. ".txd") then
		local txd = engineLoadTXD(vehiclePath .. model .. ".txd", true)

		if txd then
			engineImportTXD(txd, id)
		end
	end

	if fileExists(vehiclePath .. model .. ".strong") then
		local dff = engineLoadDFF(loadLockedFiles(vehiclePath .. model .. ".strong", lockCode), id)

		if dff then
			engineReplaceModel(dff, id)
		end
	end
end

--[[addEventHandler("onClientElementStreamIn", getRootElement(),
	function()
		local modelID = getElementModel(source)

		if getElementType(source) == "vehicle" and not loadedVeh[modelID] then
			local vehID = getElementData(source, "vehicleSpecialMod")

			if vehID then
				setSpecialVehicleMod(source)
			end
			--loadedVeh[modelID] = true
		end
	end
)]]

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		for k, v in pairs(vehicleCustomID) do
			engineFreeModel(k)

			--print(k)
		end
	end
)

local screenX, screenY = guiGetScreenSize()
local sizeX, sizeY = 400, 600
local posX, posY = screenX / 2 - sizeX / 2, screenY / 2 - sizeY / 2

local font = dxCreateFont("files/Ubuntu-M.ttf", 12)

addCommandHandler("showcars",
	function()
		showCustomVehicles = not showCustomVehicles
	end
)

addEventHandler("onClientRender", getRootElement(),
	function()
		if showCustomVehicles then
			dxDrawRectangle(posX, posY, sizeX, sizeY, tocolor(25, 25, 25))
			dxDrawRectangle(posX, posY, sizeX, 30, tocolor(45, 45, 45, 190))

			latestRow = currentRow + maxRow - 1
			numValue = 0

		    for k, v in pairs(vehicleDatas) do
		  		numValue = numValue + 1

		        if numValue >= currentRow and numValue <= latestRow then
		        	--print(numValue)
		            numValue = numValue - currentRow + 1

		            if numValue % 2 == 0 then
		           	 	dxDrawRectangle(posX + 4, posY + 44 * numValue, sizeX - 8, 40, tocolor(45, 45, 45, 190))
		           	else
		           	 	dxDrawRectangle(posX + 4, posY + 44 * numValue, sizeX - 8, 40, tocolor(30, 30, 30, 190))
		           	end
		            dxDrawText(v[3] .. ": " .. k, posX + 4 + 5, posY + 44 * numValue + 40 / 2, nil, nil, tocolor(200, 200, 200, 200), 1, font, "left", "center")
		        end
		    end
		end
	end
)

addEventHandler("onClientKey", getRootElement(),
	function(key,state)
	    if showCustomVehicles then
	        if key == "mouse_wheel_up" then
	            if currentRow > 1 then
	                currentRow = currentRow - 1
	            end
	        elseif key == "mouse_wheel_down" then
	            if currentRow < #vehicleDatas - (maxRow - 1) then
	                currentRow = currentRow + 1
	            end
	        end

	        if key == "backspace" and state then
	            showCustomVehicles = false
	        end
	    end
	end
)

function loadModel(name, model, key)
	local file = fileOpen(name)
	local size = fileGetSize(file)
	local bytes = fileRead(file, size)

	fileClose(file)

	local sections = splitEx(bytes, ";")

	for k, v in pairs(sections) do
		processData = sections[k]

		local isTXD = string.find(processData, "isTxd")
		local isDFF = string.find(processData, "isDff")

		processData = string.gsub(processData, "isTxd", "")
		processData = string.gsub(processData, "isDff", "")

		processData = teaDecode(processData, key)
		processData = base64Decode(processData)

		if isTXD then
			engineImportTXD(engineLoadTXD(processData), model)
		elseif isDFF then
			engineReplaceModel(engineLoadDFF(processData), model)
		end
	end
end