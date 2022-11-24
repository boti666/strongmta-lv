local components = {
	[443] = "hook",
	[400] = "front_glass",
	[585] = "roof_ok",
	[579] = "right_skirt",
	[529] = "glass",
	[409] = "chassis",
	[598] = "chassis",
	[587] = "display",
	[603] = "challenger70_gauges",
	[600] = "CAMINO_box",
	[596] = "siren",
	[589] = "R32_Engine",
	[566] = "chassis",
	[562] = "RB20DET",
	[547] = "galant87_engine",
	[527] = "SHELBY_blinker",
	[526] = "chassis",
	[491] = "chassis",
	[506] = "lamps",
	[502] = "v12engine",
	[492] = "chassis",
	[477] = "F4087_transmission",
	[475] = "gto69_engine",
	[470] = "front_glass",
	[466] = "lights",
	[458] = "plastic",
	[451] = "LP700_engine",
	[438] = "gauges",
	[436] = "vr6block",
	[429] = "v12",
	[420] = "frontlights",
	[418] = "engine",
	[412] = "misc_f",
	[410] = "gremlin73_taillights",
	[402] = "fastback67_chassis",
	[401] = "track",
	[480] = "turbo89_engine",
	[431] = "Bus_posters"
}

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			local model = getElementModel(source)

			if components[model] then
				setVehicleComponentVisible(source, components[model], false)
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if utf8.find(dataName, "visibility") then
			local model = getElementModel(source)

			if components[model] then
				setVehicleComponentVisible(source, components[model], false)
			end
		end
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function()
		local vehicles = getElementsByType("vehicle", getRootElement(), true)

		for i = 1, #vehicles do
			local veh = vehicles[i]

			if isElement(veh) then
				local model = getElementModel(veh)

				if components[model] then
					setVehicleComponentVisible(veh, components[model], false)
				end
			end
		end
	end)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function()
		local vehicles = getElementsByType("vehicle")

		for i = 1, #vehicles do
			local veh = vehicles[i]

			if isElement(veh) then
				local model = getElementModel(veh)

				if components[model] then
					setVehicleComponentVisible(veh, components[model], true)
				end
			end
		end
	end)

function hideComponent(vehicle)
	local model = getElementModel(vehicle)

	if components[model] then
		setVehicleComponentVisible(vehicle, components[model], false)
	end
end

addCommandHandler("gvc",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local pedveh = getPedOccupiedVehicle(localPlayer)

			if pedveh then
				for k in pairs(getVehicleComponents(pedveh)) do
					outputConsole(k)
				end
			end
		end
	end)

local gvc = false

addCommandHandler("gvc2",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			gvc = not gvc

			if gvc then
				addEventHandler("onClientRender", getRootElement(), renderComponents)
			else
				removeEventHandler("onClientRender", getRootElement(), renderComponents)
			end
		end
	end)

function renderComponents()
	local vehicles = getElementsByType("vehicle", getRootElement(), true)

	for i = 1, #vehicles do
		local veh = vehicles[i]

		if isElement(veh) and isElementOnScreen(veh) then
			for k in pairs(getVehicleComponents(veh)) do
				local x, y, z = getVehicleComponentPosition(veh, k, "world")

				if x and y and z then
					local wx, wy, wz = getScreenFromWorldPosition(x, y, z)

					if wx and wy then
						for y = -2, 2, 2 do
							for x = -2, 2, 2 do
								dxDrawText(k, wx + x, wy + y, x, y, tocolor(0, 0, 0))
							end
						end

						dxDrawText(k, wx, wy, 0, 0, tocolor(61, 122, 188))
					end
				end
			end
		end
	end
end

function getStreamedOutElementMatrix(element)
	local rx, ry, rz = getElementRotation(element, "ZXY")
	rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)

	local matrix = {}
	
	matrix[1] = {}
	matrix[1][1] = math.cos(rz) * math.cos(ry) - math.sin(rz) * math.sin(rx) * math.sin(ry)
	matrix[1][2] = math.cos(ry) * math.sin(rz) + math.cos(rz) * math.sin(rx) * math.sin(ry)
	matrix[1][3] = -math.cos(rx) * math.sin(ry)
	matrix[1][4] = 1
 
	matrix[2] = {}
	matrix[2][1] = -math.cos(rx) * math.sin(rz)
	matrix[2][2] = math.cos(rz) * math.cos(rx)
	matrix[2][3] = math.sin(rx)
	matrix[2][4] = 1
 
	matrix[3] = {}
	matrix[3][1] = math.cos(rz) * math.sin(ry) + math.cos(ry) * math.sin(rz) * math.sin(rx)
	matrix[3][2] = math.sin(rz) * math.sin(ry) - math.cos(rz) * math.cos(ry) * math.sin(rx)
	matrix[3][3] = math.cos(rx) * math.cos(ry)
	matrix[3][4] = 1
 
	matrix[4] = {}
	matrix[4][1], matrix[4][2], matrix[4][3] = getElementPosition(element)
	matrix[4][4] = 1
 
	return matrix
end

function getPositionFromElementOffset(element, x, y, z)
	local m = false

	if not isElementStreamedIn(element) then
		m = getStreamedOutElementMatrix(element)
	else
		m = getElementMatrix(element)
	end

	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		   x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		   x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end