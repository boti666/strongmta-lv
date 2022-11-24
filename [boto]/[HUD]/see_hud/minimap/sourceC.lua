local getZoneNameEx = getZoneName

function getZoneName(x, y, z, cities)
	local zone = getZoneNameEx(x, y, z, cities)

	if zone == "Greenglass College" then
		return "Las Venturas City Hall"
	end

	return zone
end

local screenSource = dxCreateScreenSource(screenX, screenY)
local radarTexture = dxCreateTexture("minimap/radar.jpg", "dxt3")
local radarTexture2 = dxCreateTexture("minimap/radar.png", "dxt3")

dxSetTextureEdge(radarTexture, "border", tocolor(110, 158, 204))
dxSetTextureEdge(radarTexture2, "border", tocolor(110, 158, 204))

local radarTextureSize = 3072
local mapScaleFactor = 6000 / radarTextureSize
local mapUnit = radarTextureSize / 6000

local minimapWidth = respc(320)
local minimapHeight = respc(225)
local minimapX = 0
local minimapY = 0

local rtsize = math.ceil((minimapWidth + minimapHeight) * 0.85)
local renderTarget = dxCreateRenderTarget(rtsize, rtsize)

local zoomval = 0.5
local zoom = zoomval

local defaultBlips = {
	{1655.353515625, 1733.31640625, 10.82811164856, "minimap/newblips/binco.png"},
	{2807.494140625, 1981.3134765625, 10.8203125, "minimap/newblips/shop_h.png"},
	{-145.84765625, 1177.509765625, 19.7421875, "minimap/newblips/shop_h.png"},
	{-1530.974609375, 2592.26953125, 55.8359375, "minimap/newblips/shop_h.png"},
	{-271.583984375, 2692.0361328125, 62.6875, "minimap/newblips/shop_h.png"},
	{1889.3505859375, 2072.1767578125, 11.0625, "minimap/newblips/burger.png"},
	{2486.0390625, 2038.3525390625, 19.420318603516, "minimap/newblips/burger.png"},
	{1134.873046875, 2071.9794921875, 14.744215965271, "minimap/newblips/burger.png"},
	{2115.4638671875, 919.7763671875, 10.820312, "minimap/newblips/fuel.png"},
	{2640.33984375, 1105.9560546875, 10.8203125, "minimap/newblips/fuel.png"},
	{2203.072265625, 2474.5146484375, 10.820325, "minimap/newblips/fuel.png"},
	{612.5185546875, 1691.505859375, 12.464294433594, "minimap/newblips/fuel.png"},
	{2147.6455078125, 2747.4794921875, 10.8203125, "minimap/newblips/fuel.png"},
	{1596.33984375, 2199.55859375, 10.8203125, "minimap/newblips/fuel.png"},
	{-1328.3515625, 2677.6474609375, 50.0625, "minimap/newblips/fuel.png"},
	{-1471.361328125, 1864.9228515625, 32.6328125, "minimap/newblips/fuel.png"},
	{302.00833129883, 2544.7514648438, 16.819074630737, "minimap/newblips/fuel.png"},
	{385.5224609375, 2599.2919921875, 16.484375, "minimap/newblips/junkyard.png"},
	{2290.111328125, 2426.25, 14.771887779236, "minimap/newblips/pd.png"},
	{1606.96875, 1833.5576171875, 13.671875, "minimap/newblips/korhaz.png"},
	{-316.119140625, 1061.9130859375, 24.484375, "minimap/newblips/korhaz.png"},
	{1043.0751953125, 1011.4326171875, 11, "minimap/newblips/vh.png"},
	{-828.1181640625, 1501.02734375, 19.394908905029, "minimap/newblips/bank.png"},
	{2474.234375, 1018.3564453125, 22.484375, "minimap/newblips/bank.png"},
	{-177.3310546875, 1132.3046875, 25.333562850952, "minimap/newblips/bank.png"},
	{-2227.7705078125, 2326.6669921875, 7.546875, "minimap/newblips/szerelo_heli.png"},
	{-2419.419921875, 2292.8623046875, -0.55000001192093, "minimap/newblips/crab.png"},
	{2325.8681640625, 520.96875, -0.55000001192093, "minimap/newblips/crab.png"},
	{1685.380859375, 1447.8037109375, 27.449996948242, "minimap/newblips/repter.png"},
	{-606.5869140625, 641.9921875, 27.063598632813, "minimap/newblips/hatar.png"},
	{-476.82421875, 1054.9736328125, 13.263624191284, "minimap/newblips/hatar.png"},
	{-864.7978515625, 1903.2265625, 60.153533935547, "minimap/newblips/hatar.png"},
	{-1022.7890625, 2708.72265625, 56.638889312744, "minimap/newblips/hatar.png"},
	{801.6865234375, 1690.412109375, 5.28125, "minimap/newblips/loter.png"},
	{968.400390625, 2160.552734375, 10.8203125, "minimap/newblips/gyar.png"},
	{-1210.375, 1828.5146484375, 41.71875, "minimap/newblips/cb.png"},
	{170.9140625, 1174.6494140625, 14.7578125, "minimap/newblips/cb.png"},
	{404.8173828125, 2454.6396484375, 16.5, "minimap/newblips/tuning.png"},
	{1703.7724609375, 1825.9912109375, 21.089450836182, "minimap/newblips/carshop.png"},
	--{-511.599609375, 2592.744140625, 53.4140625, "minimap/newblips/carrent.png"},
	--{1701.71875, 1316.6025390625, 10.8203125, "minimap/newblips/carrent.png"},
	{-473.8720703125, 855.27947998047, 1.5984375476837, "minimap/newblips/kikoto.png"},
	{-289.69921875, 872.25994873047, 10.10781288147, "minimap/newblips/fisherman.png"},
	{261.771484375, 2894.7880859375, 10.658462524414, "minimap/newblips/fisherman.png"},
	{2918.8134765625, 2119.84375, 10.9365158081, "minimap/newblips/fisherman.png"},
	{598.2431640625, 861.87109375, 0.36845397949219, "minimap/newblips/fisherman.png"},
	{-2052.0029296875, 2339.392578125, 1.3684539794922, "minimap/newblips/fisherman.png"},
	{-423.1318359375, 1163.7470703125, 1.1664280891418, "minimap/newblips/boat.png"},
	{-1457.998046875, 2592.8076171875, 55.391719818115, "minimap/newblips/kocsma.png"},
	{-857.1708984375, 1536.51953125, 22.587043762207, "minimap/newblips/kocsma.png"},
	{-89.1689453125, 1378.1650390625, 10.469839096069, "minimap/newblips/kocsma.png"},
	{665.646484375, 1717.802734375, 12.276634216309, "minimap/newblips/lottoblip.png"},
	{1067.20703125, 1323.7861328125, 15.3125, "minimap/newblips/szerelo.png"},
	{-249.6103515625, 1219.42578125, 19.7421875, "minimap/newblips/szerelo.png"},
	{886.154296875, 2016.4853515625, 27.224990844727, "minimap/newblips/autosiskola.png"},
	{1924.7568359375, 703.208984375, 16.012411117554, "minimap/newblips/motel.png"},
	{2435.3427734375, 1662.87109375, 15.641407012939, "minimap/newblips/motel.png"},
	{2083.7314453125, 2172.0927734375, 10.8203125, "minimap/newblips/motel.png"},
	{-770.8349609375, 2754.3115234375, 45.745559692383, "minimap/newblips/szerelo.png"},
	{-55.0146484375, 1216.6279296875, 19.359375, "minimap/newblips/motel.png"},
	{-801.1025390625, 1436.0302734375, 93.929473876953, "minimap/newblips/motel.png"},
	{1766.947265625, 2821.7939453125, 11.497863769531, "minimap/newblips/motel.png"},
	{2617.7880859375, 2190.876953125, 60.797866821289, "minimap/newblips/motel.png"},
	{2635.330078125, 2021.73046875, 113.4293670654, "minimap/newblips/motel.png"},
	{1292.720703125, 1540.1052246094, 15.492664337158, "minimap/newblips/szerelo_heli.png"},
	{1628.271484375, 575.71875, 3.2853827476501, "minimap/newblips/szerelo_boat.png"},
	{-217.6494140625, 979.1669921875, 19.50302696228, "minimap/newblips/sheriffblip.png"},
	{1097.7802734375, 1531.09765625, 96.746452331543, "minimap/newblips/versenypalya.png"},
	{1643.81640625, 2203.431640625, 10.8203125, "minimap/newblips/kosar.png"},
	{2019.9814453125, 1007.73828125, 10.8203125, "minimap/newblips/cblip.png"},
	{2196.5966796875, 1677.3017578125, 12.3671875, "minimap/newblips/cblip.png"},
	{2492.3349609375, 2522.408203125, 10.8203125, "minimap/newblips/impound.png"},
	{115.1590423584, 2959.9367675781, 72.15119934082, "minimap/newblips/north.png", 16.5, true, 99999},
	{2874.0703125, 2438.8688964844, 10.16895198822, "minimap/newblips/pawn.png"},
	{2180.9028320312, 2294.6069335938, 10.8203125, "minimap/newblips/club.png"},
	{-552.35626220703, 2593.8464355469, 53.93478012085, "minimap/newblips/usedcars.png"},
	{2050.3156738281, 2066.66015625, 10.8203125, "minimap/newblips/szerelo.png"},
	{1660.5107421875, 1315.9400634766, 10, "minimap/newblips/carrent.png"},
}

local blipTextures = {}

for k, v in ipairs(defaultBlips) do
	blipTextures[v[4]] = dxCreateTexture(v[4], "dxt3")
end

local blipNames = {
	["minimap/newblips/pawn.png"] = "Zacis",
	["minimap/newblips/usedcars.png"] = "StrongCity Used Car Dealership",
	["minimap/newblips/versenypalya.png"] = "Versenypálya",
	["minimap/newblips/club.png"] = "Disco",
	["minimap/newblips/shop_h.png"] = "Hobby bolt",
	["minimap/newblips/carshop.png"] = "Autókereskedés",
	["minimap/newblips/bank.png"] = "Bank",
	["minimap/newblips/autosiskola.png"] = "Autósiskola",
	["minimap/newblips/tuning.png"] = "Tuning",
	["minimap/newblips/korhaz.png"] = "Kórház",
	["minimap/newblips/pd.png"] = "Rendőrség",
	["minimap/newblips/cb.png"] = "Cluckin' Bell",
	["minimap/newblips/vh.png"] = "Városháza",
	["minimap/newblips/szerelo.png"] = "Szerelőtelep",
	["minimap/newblips/banya.png"] = "Bánya",
	["minimap/newblips/gyar.png"] = "Gyár",
	["minimap/newblips/repter.png"] = "Reptér",
	["minimap/newblips/plaza.png"] = "See-City Mall",
	["minimap/newblips/fuel.png"] = "Benzinkút",
	["minimap/newblips/hatar.png"] = "Határátkelőhely",
	["minimap/newblips/templom.png"] = "Templom",
	["minimap/newblips/loter.png"] = "Lőtér",
	["minimap/newblips/hunting.png"] = "Vadászat",
	["minimap/newblips/favago.png"] = "Fatelep",
	["minimap/newblips/kikoto.png"] = "Kikötő",
	["minimap/newblips/kocsma.png"] = "Kocsma",
	["minimap/newblips/burger.png"] = "Burger Shot",
	["minimap/newblips/binco.png"] = "Ruhabolt",
	["minimap/newblips/fisherman.png"] = "Horgászbolt",
	["minimap/newblips/hunting2.png"] = "Vadász",
	["minimap/newblips/change.png"] = "Pénzváltó",
	["minimap/newblips/junkyard.png"] = "Roncstelep",
	["minimap/newblips/lottoblip.png"] = "Lottózó",
	["minimap/newblips/boat.png"] = "Hajóbolt",
	["minimap/newblips/cblip.png"] = "Kaszinó",
	["minimap/newblips/crab.png"] = "Rákászat",
	["minimap/newblips/carrent.png"] = "Autóbérlő",
	["minimap/newblips/szerelo_boat.png"] = "Szerelőtelep (hajó)",
	["minimap/newblips/szerelo_heli.png"] = "Szerelőtelep (helikopter)",
	["minimap/newblips/motel.png"] = "Motel",
	["minimap/newblips/sheriffblip.png"] = "Sheriff",
	["minimap/newblips/kosar.png"] = "Streetball pálya",
	["minimap/newblips/markblip.png"] = "Kijelölt pont (Kattints a törléshez)",
	["minimap/newblips/north.png"] = "Észak",
	["minimap/newblips/impound.png"] = "Lefoglalt járművek"
}

createdBlips = {}
local blipTooltipText = {}
local farBlips = {}
local jobBlips = {}

state3DBlip = true
stateMarksBlip = true

function delJobBlips()
	for k = 1, #jobBlips do
		local v = jobBlips[k]

		if v then
			createdBlips[v] = nil
		end
	end

	local temp = {}

	for k = 1, #createdBlips do
		local v = createdBlips[k]

		if v then
			table.insert(temp, v)
		end
	end

	createdBlips = temp
	jobBlips = {}
	temp = nil
end

function addJobBlips(data)
	for k = 1, #data do
		if data[k] then
			table.insert(createdBlips, {
				blipPosX = data[1],
				blipPosY = data[2],
				blipPosZ = data[3],
				blipId = data[4],
				farShow = data[6],
				renderDistance = 9999,
				iconSize = data[5] or 48,
				blipColor = data[7] or tocolor(255, 255, 255)
			})
			table.insert(jobBlips, #createdBlips)
		end
	end
end

carCanGPSVal = false
gpsHello = false

local gpsLines = {}
local gpsRenderTarget = false
local gpsBoundingBox = {}
local gpsColor = tocolor(220, 163, 30)

function carCanGPS()
	carCanGPSVal = false

	local currVehicle = getPedOccupiedVehicle(localPlayer)

	if currVehicle then
		local gpsVal = tonumber(getElementData(currVehicle, "vehicle.GPS"))

		if gpsVal == 1 then
			carCanGPSVal = ""
		elseif gpsVal == 2 then
			carCanGPSVal = "2"
		elseif gpsVal == 3 then
			carCanGPSVal = "off"
		else
			carCanGPSVal = false

			if getElementData(currVehicle, "gpsDestination") then
				setElementData(currVehicle, "gpsDestination", false)
			end
		end
	end

	return carCanGPSVal
end

function addGPSLine(x, y)
	table.insert(gpsLines, {remapTheFirstWay(x), remapTheFirstWay(y)})
end

function clearGPSRoute()
	gpsLines = {}
	gpsBoundingBox = false

	if isElement(gpsRenderTarget) then
		destroyElement(gpsRenderTarget)
	end

	gpsRenderTarget = nil
end

function processGPSLines()
	local minX, minY = 99999, 99999
	local maxX, maxY = -99999, -99999

	for i = 1, #gpsLines do
		local v = gpsLines[i]

		if v[1] < minX then
			minX = v[1]
		end

		if v[1] > maxX then
			maxX = v[1]
		end

		if v[2] < minY then
			minY = v[2]
		end

		if v[2] > maxY then
			maxY = v[2]
		end
	end

	local sx = maxX - minX + 16
	local sy = maxY - minY + 16

	if isElement(gpsRenderTarget) then
		destroyElement(gpsRenderTarget)
	end

	gpsRenderTarget = dxCreateRenderTarget(sx, sy, true)
	gpsBoundingBox = {minX - 8, minY - 8, sx, sy}

	dxSetRenderTarget(gpsRenderTarget)
	dxSetBlendMode("modulate_add")

	dxDrawImage(gpsLines[1][1] - minX + 4, gpsLines[1][2] - minY + 4, 8, 8, "minimap/gps/dot.png")
	dxDrawImage(gpsLines[#gpsLines][1] - minX, gpsLines[#gpsLines][2] - minY, 16, 16, "minimap/gps/dot.png")

	for i = 2, #gpsLines do
		local j = i - 1

		if gpsLines[j] then
			dxDrawImage(gpsLines[i][1] - minX + 4, gpsLines[i][2] - minY + 4, 8, 8, "minimap/gps/dot.png")
			dxDrawLine(gpsLines[i][1] - minX + 8, gpsLines[i][2] - minY + 8, gpsLines[j][1] - minX + 8, gpsLines[j][2] - minY + 8, tocolor(255, 255, 255), 9)
		end
	end

	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

addEventHandler("onClientRestore", getRootElement(),
	function ()
		if gpsRoute then
			processGPSLines()
		end
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("blip")) do
			blipTooltipText[v] = getElementData(v, "blipTooltipText")
		end

		for k, v in ipairs(defaultBlips) do
			v[5] = v[5] or 22
			v[6] = v[6] or false
			v[7] = v[7] or 9999
			v[8] = v[8] or tocolor(255, 255, 255)

			table.insert(createdBlips, {
				blipPosX = v[1],
				blipPosY = v[2],
				blipPosZ = v[3],
				blipId = v[4],
				iconSize = v[5],
				farShow = v[6],
				renderDistance = v[7],
				blipColor = v[8]
			})
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if getElementType(source) == "blip" then
			if dataName == "blipTooltipText" then
				blipTooltipText[source] = getElementData(source, "blipTooltipText")
			end
		end

		if source == getPedOccupiedVehicle(localPlayer) then
			if dataName == "vehicle.GPS" then
				carCanGPS()
			end

			if dataName == "gpsDestination" then
				local dataVal = getElementData(source, dataName)

				if dataVal then
					gpsThread = coroutine.create(makeRoute)
					gpsColor = dataVal[3] or tocolor(220, 163, 30)

					coroutine.resume(gpsThread, unpack(dataVal))

					waypointInterpolation = false
				else
					endRoute()
				end
			end
		end
	end)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if getElementType(source) == "blip" then
			blipTooltipText[source] = nil
		end
	end)

local damageStart = false

addEventHandler("onClientPlayerDamage", localPlayer,
	function ()
		damageStart = getTickCount()
	end)

function renderBlip(icon, x1, y1, x2, y2, sx, sy, color, farshow, cameraRot, blipNum)
	if icon == "minimap/newblips/markblip.png" and not stateMarksBlip then
		return
	end

	local x = 0 + rtsize / 2 + (remapTheFirstWay(x2) - remapTheFirstWay(x1)) * zoom
	local y = 0 + rtsize / 2 - (remapTheFirstWay(y2) - remapTheFirstWay(y1)) * zoom

	if not farshow and (x > rtsize or x < 0 or y > rtsize or y < 0) then
		return
	end

	local rendering = true

	if farshow then
		if icon == 0 then
			sx = sx / 1.5
			sy = sy / 1.5
		end

		if x > rtsize then
			x = rtsize
		elseif x < 0 then
			x = 0
		end

		if y > rtsize then
			y = rtsize
		elseif y < 0 then
			y = 0
		end

		local middleSize = rtsize / 2
		local angle = math.rad(cameraRot)
		local x2 = middleSize + (x - middleSize) * math.cos(angle) - (y - middleSize) * math.sin(angle)
		local y2 = middleSize + (x - middleSize) * math.sin(angle) + (y - middleSize) * math.cos(angle)

		x2 = x2 + minimapX - rtsize / 2 + (minimapWidth - sx) / 2
		y2 = y2 + minimapY - rtsize / 2 + (minimapHeight - sy) / 2

		farBlips[blipNum] = nil

		if x2 < minimapX then
			rendering = false
			x2 = minimapX
		elseif x2 > minimapX + minimapWidth - sx then
			rendering = false
			x2 = minimapX + minimapWidth - sx
		end

		if y2 < minimapY then
			rendering = false
			y2 = minimapY
		elseif y2 > minimapY + minimapHeight - resp(30) - sy then
			rendering = false
			y2 = minimapY + minimapHeight - resp(30) - sy
		end

		if not rendering then
			farBlips[blipNum] = {x2, y2, sx, sy, icon, color}
		end
	end

	if rendering then
		if blipTextures[icon] then
			dxDrawImage(x - sx / 2, y - sy / 2, sx, sy, blipTextures[icon], 360 - cameraRot, 0, 0, color)
		else
			dxDrawImage(x - sx / 2, y - sy / 2, sx, sy, icon, 360 - cameraRot, 0, 0, color)
		end
	end
end

function remapTheFirstWay(x)
	return (-x + 3000) / mapScaleFactor
end

function remapTheSecondWay(x)
	return (x + 3000) / mapScaleFactor
end

local lostSignalStart = false
local lostSignalDirection = false

render.minimap = function (x, y)
	minimapWidth, minimapHeight = tonumber(renderData.size.minimapX), tonumber(renderData.size.minimapY)

	local newRTsize = math.ceil((minimapWidth + minimapHeight) * 0.85)

	if math.abs(newRTsize - rtsize) > 10 then
		rtsize = newRTsize

		if isElement(renderTarget) then
			destroyElement(renderTarget)
		end

		renderTarget = dxCreateRenderTarget(rtsize, rtsize)
	end

	minimapX, minimapY = tonumber(x), tonumber(y)

	-- ** Zoom
	if getKeyState("num_add") and zoomval < 1.2 then
		zoomval = zoomval + 0.01
	elseif getKeyState("num_sub") and zoomval > 0.31 then
		zoomval = zoomval - 0.01
	end

	zoom = zoomval

	local pedveh = getPedOccupiedVehicle(localPlayer)

	if isElement(pedveh) then
		local velx, vely, velz = getElementVelocity(pedveh)
		local actualspeed = math.sqrt(velx * velx + vely * vely + velz * velz) * 180 / 1300

		if actualspeed >= 0.4 then
			actualspeed = 0.4
		end

		zoom = zoom - actualspeed
	end

	-- ** Map
	local px, py, pz = getElementPosition(localPlayer)
	local _, _, prz = getElementRotation(localPlayer)
	local dim = getElementDimension(localPlayer)

	if dim == 0 or dim == 987 then
		local crx, cry, crz = getElementRotation(getCamera())

		farBlips = {}

		dxUpdateScreenSource(screenSource, true)

		dxSetRenderTarget(renderTarget)
		dxSetBlendMode("modulate_add")

		dxDrawRectangle(0, 0, rtsize, rtsize, tocolor(110, 158, 204))
		dxDrawImageSection(0, 0, rtsize, rtsize, remapTheSecondWay(px) - rtsize / zoom / 2, remapTheFirstWay(py) - rtsize / zoom / 2, rtsize / zoom, rtsize / zoom, radarTexture)

		-- ** GPS Útvonal
		if gpsRenderTarget then
			dxDrawImage(
				rtsize / 2 + (remapTheFirstWay(px) - (gpsBoundingBox[1] + gpsBoundingBox[3] / 2)) * zoom - gpsBoundingBox[3] * zoom / 2,
				rtsize / 2 - (remapTheFirstWay(py) - (gpsBoundingBox[2] + gpsBoundingBox[4] / 2)) * zoom + gpsBoundingBox[4] * zoom / 2,
				gpsBoundingBox[3] * zoom,
				-(gpsBoundingBox[4] * zoom),
				gpsRenderTarget,
				180, 0, 0,
				gpsColor
			)
		end

		-- ** Blipek
		local blipCount = 0

		for k = 1, #createdBlips do
			local v = createdBlips[k]

			if v then
				blipCount = blipCount + 1

				renderBlip(v.blipId, v.blipPosX, v.blipPosY, px, py, v.iconSize, v.iconSize, v.blipColor, v.farShow, crz, blipCount)
			end
		end

		local blips = getElementsByType("blip")

		for k = 1, #blips do
			local v = blips[k]

			if v then
				local bx, by = getElementPosition(v)
				local color = tocolor(getBlipColor(v))

				blipCount = blipCount + 1

				if getBlipIcon(v) == 1 then
					renderBlip("minimap/newblips/munkajarmu.png", bx, by, px, py, 18, 15, tocolor(255, 255, 255), true, crz, blipCount)
				elseif getBlipIcon(v) == 2 then
					renderBlip("minimap/newblips/kukamunka.png", bx, by, px, py, 14.5, 14.5, tocolor(255, 255, 255), true, crz, blipCount)
				else
					renderBlip("minimap/newblips/target.png", bx, by, px, py, 14.5, 14.5, color, true, crz, blipCount)
				end
			end
		end

		dxSetBlendMode("blend")
		dxSetRenderTarget()

		-- ** Térkép
		dxDrawImage(x - rtsize / 2 + minimapWidth / 2, y - rtsize / 2 + minimapHeight / 2, rtsize, rtsize, renderTarget, crz)
		dxDrawImage(x, y, minimapWidth, minimapHeight, "files/images/vin.png")

		-- ** Távoli blipek
		for k, v in pairs(farBlips) do
			dxDrawImage(v[1], v[2], v[3], v[4], v[5], 0, 0, 0, v[6])
		end

		-- ** Pozíciónk
		local arrowsize = 60 / (4 - zoom) + 3
		dxDrawImage(x + (minimapWidth - arrowsize) / 2, y + (minimapHeight - arrowsize) / 2, arrowsize, arrowsize, "minimap/files/arrow.png", crz + math.abs(360 - prz))

		-- ** Rendertarget kitakarása a képernyőforrással
		local margin = respc(rtsize * 0.75)
		dxDrawImageSection(x - margin, y - margin, minimapWidth + margin * 2, margin, x - margin, y - margin, minimapWidth + margin * 2, margin, screenSource) -- felsó
		dxDrawImageSection(x - margin, y + minimapHeight, minimapWidth + margin * 2, margin, x - margin, y + minimapHeight, minimapWidth + margin * 2, margin, screenSource) -- alsó
		dxDrawImageSection(x - margin, y, margin, minimapHeight, x - margin, y, margin, minimapHeight, screenSource) -- bal
		dxDrawImageSection(x + minimapWidth, y, margin, minimapHeight, x + minimapWidth, y, margin, minimapHeight, screenSource) -- jobb

		-- ** Keret
		dxDrawRectangle(x - 2, y - 2, minimapWidth + 4, 2, tocolor(0, 0, 0, 200)) -- felső
		dxDrawRectangle(x - 2, y + minimapHeight, minimapWidth + 4, 2, tocolor(0, 0, 0, 200)) -- alsó
		dxDrawRectangle(x - 2, y, 2, minimapHeight, tocolor(0, 0, 0, 200)) -- bal
		dxDrawRectangle(x + minimapWidth, y, 2, minimapHeight, tocolor(0, 0, 0, 200)) -- jobb

		-- ** GPS Location
		dxDrawRectangle(x, y + minimapHeight - resp(30), minimapWidth, resp(30), tocolor(0, 0, 0, 200))
		dxDrawText(getZoneName(px, py, pz), x, y + minimapHeight - resp(30), x + minimapWidth - resp(10), y + minimapHeight, tocolor(200, 200, 200, 200), 0.5, Raleway, "center", "center",false,false,false,true)

		-- ** GPS Navigáció
		if gpsRoute or waypointEndInterpolation then
			local offsetY = (minimapHeight - respc(30)) / 2
			local iconX = x + minimapWidth - respc(50)
			local iconY = y + offsetY

			if waypointEndInterpolation then
				local progress = (getTickCount() - waypointEndInterpolation) / 500
				local alpha = interpolateBetween(
					1, 0, 0,
					0, 0, 0,
					progress, "Linear"
				)

				dxDrawRectangle(x + minimapWidth - respc(60), y, respc(60), minimapHeight - respc(30), tocolor(0, 0, 0, 150 * alpha))
				dxDrawImage(iconX, iconY - respc(20), respc(40), respc(40), "minimap/gps/end.png", 0, 0, 0, tocolor(61, 122, 188, 255 * alpha))
				dxDrawText("0 m", iconX, iconY + respc(20), x + minimapWidth - respc(10), iconY + respc(36), tocolor(61, 122, 188, 255 * alpha), 0.9, Roboto, "center", "center")

				if progress > 1 then
					waypointEndInterpolation = false
				end
			elseif nextWp then
				dxDrawRectangle(x + minimapWidth - respc(60), y, respc(60), minimapHeight - respc(30), tocolor(0, 0, 0, 150))

				if currentWaypoint ~= nextWp and not tonumber(reRouting) then
					if nextWp > 1 then
						waypointInterpolation = {getTickCount(), currentWaypoint}
					end

					currentWaypoint = nextWp
				end

				if tonumber(reRouting) then
					local progress = (getTickCount() - reRouting) / 1250
					local rot, count = interpolateBetween(
						360, 0, 0,
						0, 3, 0,
						progress, "Linear"
					)

					currentWaypoint = nextWp
					dxDrawImage(iconX, iconY - respc(20), respc(40), respc(40), "minimap/gps/refresh.png", rot, 0, 0, tocolor(61, 122, 188))

					if count > 2 then
						dxDrawText("•••", iconX, iconY + respc(20), x + minimapWidth - respc(10), iconY + respc(36), tocolor(61, 122, 188), 0.9, Roboto, "center", "center")
					elseif count > 1 then
						dxDrawText("••", iconX, iconY + respc(20), x + minimapWidth - respc(10), iconY + respc(36), tocolor(61, 122, 188), 0.9, Roboto, "center", "center")
					elseif count > 0 then
						dxDrawText("•", iconX, iconY + respc(20), x + minimapWidth - respc(10), iconY + respc(36), tocolor(61, 122, 188), 0.9, Roboto, "center", "center")
					end

					if progress > 1 then
						reRouting = getTickCount()
					end
				elseif turnAround then
					currentWaypoint = nextWp
					dxDrawImage(iconX, iconY - respc(20) - respc(8), respc(40), respc(40), "minimap/gps/around.png", 0, 0, 0, tocolor(61, 122, 188))
					dxDrawText("Fordulj\nvissza!", iconX, iconY + respc(20) + respc(8), x + minimapWidth - respc(10), iconY + respc(36) + respc(8), tocolor(61, 122, 188), 0.9, Roboto, "center", "center")
				elseif not waypointInterpolation then
					local distance = 0

					if gpsWaypoints[nextWp] then
						distance = math.floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10
					end

					dxDrawImage(iconX, iconY - respc(20), respc(40), respc(40), "minimap/gps/" .. gpsWaypoints[nextWp][2] .. ".png", 0, 0, 0, tocolor(61, 122, 188))

					if gpsWaypoints[nextWp + 1] then
						dxDrawImage(iconX, iconY + respc(44), respc(40), respc(40), "minimap/gps/" .. gpsWaypoints[nextWp + 1][2] .. ".png", 0, 0, 0, tocolor(220, 163, 30))
					end

					dxDrawText(distance .. " m", iconX, iconY + respc(20), x + minimapWidth - respc(10), iconY + respc(36), tocolor(61, 122, 188), 0.9, Roboto, "center", "center")
				else
					local waypointId = waypointInterpolation[2]
					local currDist = 0
					local nextDist = 0

					if gpsWaypoints[waypointId] then
						currDist = math.floor((gpsWaypoints[waypointId][3] or 0) / 10) * 10
					end

					if gpsWaypoints[waypointId+1] then
						nextDist = math.floor((gpsWaypoints[waypointId+1][3] or 0) / 10) * 10
					end

					local elapsedTime = getTickCount() - waypointInterpolation[1]
					local progress = elapsedTime / 750

					if progress > 1 then
						progress = 1
					end

					local alpha, currentY, nextY = interpolateBetween(
						255, offsetY - respc(20), offsetY + respc(44),
						0, 0, offsetY - respc(20),
						progress, "Linear"
					)

					dxDrawImage(iconX, y + currentY, respc(40), respc(40), "minimap/gps/" .. gpsWaypoints[waypointId][2] .. ".png", 0, 0, 0, tocolor(61, 122, 188, alpha))
					dxDrawText(currDist .. " m", iconX, y + currentY + respc(40), x + minimapWidth - respc(10), y + currentY + respc(40) + respc(16), tocolor(61, 122, 188, alpha), 0.9, Roboto, "center", "center")

					if gpsWaypoints[waypointId+1] then
						local r, g, b = interpolateBetween(
							220, 163, 30,
							61, 122, 188,
							progress, "Linear"
						)

						dxDrawImage(iconX, y + nextY, respc(40), respc(40), "minimap/gps/" .. gpsWaypoints[waypointId+1][2] .. ".png", 0, 0, 0, tocolor(r, g, b))
						dxDrawText(nextDist .. " m", iconX, y + nextY + respc(40), x + minimapWidth - respc(10), y + nextY + respc(40) + respc(16), tocolor(r, g, b, 255 - alpha), 0.9, Roboto, "center", "center")
					end

					if progress >= 1 then
						local progress = (elapsedTime - 750) / 500

						if gpsWaypoints[waypointId+2] then
							if progress > 1 then
								progress = 1
							end

							dxDrawImage(iconX, iconY + respc(44), respc(40), respc(40), "minimap/gps/" .. gpsWaypoints[waypointId+2][2] .. ".png", 0, 0, 0, tocolor(220, 163, 30, 255 * progress))
						end

						if progress >= 1 then
							waypointInterpolation = false
						end
					end
				end
			end
		end

		-- ** Sérülés detect
		if damageStart then
			local now = getTickCount()
			local elapsedTime = now - damageStart

			if tonumber(damageStart) then
				if elapsedTime >= 1000 then
					damageStart = false
					return
				end
			else
				damageStart = false
				return
			end

			local progress = elapsedTime / 500

			if progress > 1 then
				damageStart = false
				return
			end

			local alpha = interpolateBetween(150, 0, 0, 0, 0, 0, progress, "Linear")

			dxDrawRectangle(minimapX, minimapY, minimapWidth, minimapHeight, tocolor(255, 0, 0, alpha))
		end
	else
		local now = getTickCount()

		dxDrawRectangle(x, y, minimapWidth, minimapHeight, tocolor(0, 0, 0))

		if not lostSignalStart then
			lostSignalStart = now
		end

		local alpha = 255

		if not lostSignalDirection then
			alpha = 255
		else
			alpha = 0
		end

		local progress = (now - lostSignalStart) / 1500

		if progress > 1 then
			lostSignalStart = now
			lostSignalDirection = not lostSignalDirection
		end

		alpha = interpolateBetween(alpha, 0, 0, 255 - alpha, 0, 0, progress, "Linear")

		dxDrawImage(x + minimapWidth / 2 - 32, y + minimapHeight / 2 - 32 - 16, 64, 64, "minimap/files/gpslosticon.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawImage(x + minimapWidth / 2 - 128, y + minimapHeight / 2 + 16 + 8, 256, 16, "minimap/files/gpslostszoveg.png")

		dxDrawImage(x + minimapWidth - 64, y, 64, 16, "minimap/files/nosignalszoveg.png")
	end
end

local bigRadarState = false

local bigmapWidth = screenX - 60
local bigmapHeight = screenY - 60
local bigmapX = 30
local bigmapY = 30

local zoom = 0.5

local cursorX, cursorY = -1, -1
local lastCursorPos = false
local cursorMoveDiff = false

local mapMoveDiff = false
local lastMapMovePos = false
local mapIsMoving = false

local lastMapPosX, lastMapPosY = 0, 0
local mapMovedX, mapMovedY = 0, 0

local hoverBlip = false
local hoverMarkBlip = false
local hoverMarksButton = false
local hoverMarksRemove = false
local hover3DBlip = false

function render3DBlips()
	if getElementDimension(localPlayer) == 0 then
		local px, py, pz = getElementPosition(localPlayer)

		if pz < 10000 then
			local blips = getElementsByType("blip")

			for i = 1, #blips do
				local v = blips[i]

				if v then
					if getElementAttachedTo(v) ~= localPlayer then
						local bx, by, bz = getElementPosition(v)
						local sx, sy = getScreenFromWorldPosition(bx, by, bz)

						if sx and sy then
							local dist = getDistanceBetweenPoints3D(px, py, pz, bx, by, bz)
							local tooltip = ""

							if blipTooltipText[v] then
								tooltip = blipTooltipText[v]
							end

							dxDrawText(math.floor(dist) .. " m\n" .. tooltip, sx + 1, sy + 1 + 7.5 + respc(4), sx, 0, tocolor(0, 0, 0, 255), 0.75, Roboto, "center", "top")
							dxDrawText(math.floor(dist) .. " m#e0e0e0\n" .. tooltip, sx, sy + 7.5 + respc(4), sx, 0, tocolor(255, 255, 255), 0.75, Roboto, "center", "top", false, false, false, true)

							local icon = "target"
							local color = tocolor(getBlipColor(v))

							if getBlipIcon(v) == 1 then
								icon = "munkajarmu"
								color = tocolor(255, 255, 255)
							elseif getBlipIcon(v) == 2 then
								icon = "kukamunka"
								color = tocolor(255, 255, 255)
							end

							dxDrawImage(sx - 9, sy - 7.5, 18, 15, "minimap/newblips/" .. icon .. ".png", 0, 0, 0, color)
						end
					end
				end
			end

			for i = 1, #createdBlips do
				local v = createdBlips[i]

				if v then
					if v.blipId == "minimap/newblips/markblip.png" and stateMarksBlip then
						local z = getGroundPosition(v.blipPosX, v.blipPosY, 400) + 3
						local sx, sy = getScreenFromWorldPosition(v.blipPosX, v.blipPosY, z)

						if sx and sy then
							local dist = getDistanceBetweenPoints3D(px, py, pz, v.blipPosX, v.blipPosY, z)
							local size = v.iconSize / 2

							dxDrawText(math.floor(dist) .. " m\nKijelölt pont", sx + 1, sy + 1 + size + respc(4), sx, 0, tocolor(0, 0, 0, 255), 0.75, Roboto, "center", "top")
							dxDrawText(math.floor(dist) .. " m#e0e0e0\nKijelölt pont", sx, sy + size + respc(4), sx, 0, tocolor(255, 255, 255), 0.75, Roboto, "center", "top", false, false, false, true)

							dxDrawImage(sx - size, sy - size, v.iconSize, v.iconSize, "minimap/newblips/markblip2.png", 0, 0, 0, tocolor(255, 255, 255, 200))
						end
					end

					if string.find(v.blipId, "jobblips") then
						local z = getGroundPosition(v.blipPosX, v.blipPosY, 400) + 3
						local sx, sy = getScreenFromWorldPosition(v.blipPosX, v.blipPosY, z)

						if sx and sy then
							local dist = getDistanceBetweenPoints3D(px, py, pz, v.blipPosX, v.blipPosY, z)
							local size = v.iconSize / 2

							dxDrawText(math.floor(dist) .. " m", sx + 1, sy + 1 + size + respc(4), sx, 0, tocolor(0, 0, 0, 255), 0.75, Roboto, "center", "top")
							dxDrawText(math.floor(dist) .. " m", sx, sy + size + respc(4), sx, 0, tocolor(255, 255, 255), 0.75, Roboto, "center", "top")

							dxDrawImage(sx - size, sy - size, v.iconSize, v.iconSize, v.blipId, 0, 0, 0, tocolor(255, 255, 255, 200))
						end
					end
				end
			end
		end
	end
end

function renderBigBlip(icon, x1, y1, x2, y2, sx, sy, color, maxdist, tooltip, id, element)
	if icon == "minimap/newblips/markblip.png" and not stateMarksBlip then
		return
	end

	if maxdist and getDistanceBetweenPoints2D(x2, y2, x1, y1) > maxdist then
		return
	end

	local x = bigmapX + bigmapWidth / 2 + (remapTheFirstWay(x2) - remapTheFirstWay(x1)) * zoom
	local y = bigmapY + bigmapHeight / 2 - (remapTheFirstWay(y2) - remapTheFirstWay(y1)) * zoom

	sx = (sx / (4 - zoom) + 3) * 2.25
	sy = (sy / (4 - zoom) + 3) * 2.25

	if x < bigmapX + sx / 2 then
		x = bigmapX + sx / 2
	elseif x > bigmapX + bigmapWidth - sx / 2 then
		x = bigmapX + bigmapWidth - sx / 2
	end

	if y < bigmapY + sy / 2 then
		y = bigmapY + sy / 2
	elseif y > bigmapY + bigmapHeight - respc(30) - sy / 2 then
		y = bigmapY + bigmapHeight - respc(30) - sy / 2
	end

	if cursorX and cursorY then
		if not hoverBlip then
			if cursorX >= x - sx / 2 and cursorY >= y - sy / 2 and cursorX <= x + sx / 2 and cursorY <= y + sy / 2 then
				if isElement(element) and getElementType(element) == "player" then
					hoverBlip = element
				elseif tooltip then
					hoverBlip = tooltip
				elseif blipNames[icon] then
					hoverBlip = blipNames[icon]
				end

				if icon == "minimap/newblips/markblip.png" then
					hoverMarkBlip = id
				end
			end
		end
	end

	if icon == "minimap/files/arrow.png" then
		local _, _, prz = getElementRotation(localPlayer)

		dxDrawImage(x - sx / 2, y - sy / 2, sx, sy, icon, math.abs(360 - prz))
	else
		dxDrawImage(x - sx / 2, y - sy / 2, sx, sy, icon, 0, 0, 0, color)
	end
end

function renderTheBigmap()
	local px, py, pz = getElementPosition(localPlayer)
	local _, _, prz = getElementRotation(localPlayer)
	local dim = getElementDimension(localPlayer)

	hover3DBlip = false
	hoverMarkBlip = false
	hoverMarksButton = false
	hoverMarksRemove = false

	if dim == 0 or dim == 987 then
		-- ** Térkép mozgatása
		cursorX, cursorY = getCursorPosition()

		if cursorX and cursorY then
			cursorX, cursorY = cursorX * screenX, cursorY * screenY

			if getKeyState("mouse1") then
				if not lastCursorPos then
					lastCursorPos = {cursorX, cursorY}
				end

				if not cursorMoveDiff then
					cursorMoveDiff = {0, 0}
				end

				cursorMoveDiff = {
					cursorMoveDiff[1] + cursorX - lastCursorPos[1],
					cursorMoveDiff[2] + cursorY - lastCursorPos[2]
				}

				if not lastMapMovePos then
					if not mapMoveDiff then
						lastMapMovePos = {0, 0}
					else
						lastMapMovePos = {mapMoveDiff[1], mapMoveDiff[2]}
					end
				end

				if not mapMoveDiff then
					if math.abs(cursorMoveDiff[1]) >= 3 or math.abs(cursorMoveDiff[2]) >= 3 then
						mapMoveDiff = {
							lastMapMovePos[1] - cursorMoveDiff[1] / zoom / mapUnit,
							lastMapMovePos[2] + cursorMoveDiff[2] / zoom / mapUnit
						}
						mapIsMoving = true
					end
				elseif cursorMoveDiff[1] ~= 0 or cursorMoveDiff[2] ~= 0 then
					mapMoveDiff = {
						lastMapMovePos[1] - cursorMoveDiff[1] / zoom / mapUnit,
						lastMapMovePos[2] + cursorMoveDiff[2] / zoom / mapUnit
					}
					mapIsMoving = true
				end

				lastCursorPos = {cursorX, cursorY}
			else
				if mapMoveDiff then
					lastMapMovePos = {mapMoveDiff[1], mapMoveDiff[2]}
				end

				lastCursorPos = false
				cursorMoveDiff = false
			end
		end

		mapMovedX, mapMovedY = lastMapPosX, lastMapPosY

		if mapMoveDiff then
			mapMovedX = mapMovedX + mapMoveDiff[1]
			mapMovedY = mapMovedY + mapMoveDiff[2]
		else
			mapMovedX, mapMovedY = px, py
			lastMapPosX, lastMapPosY = mapMovedX, mapMovedY
		end

		-- ** Render
		dxDrawRectangle(bigmapX - 5, bigmapY - 5, bigmapWidth + 10, bigmapHeight + 10, tocolor(0, 0, 0, 125))
		dxDrawRectangle(bigmapX, bigmapY, bigmapWidth, bigmapHeight, tocolor(110, 158, 204))

		local mapPlayerPosX = remapTheSecondWay(mapMovedX) - bigmapWidth / zoom / 2
		local mapPlayerPosY = remapTheFirstWay(mapMovedY) - bigmapHeight / zoom / 2

		dxDrawImageSection(bigmapX, bigmapY, bigmapWidth, bigmapHeight, mapPlayerPosX, mapPlayerPosY, bigmapWidth / zoom, bigmapHeight / zoom, radarTexture2, 0, 0, 0, tocolor(255, 255, 255))
		
		-- ** GPS Útvonal
		if gpsRenderTarget then
			dxUpdateScreenSource(screenSource, true)

			dxDrawImage(
				bigmapX + bigmapWidth / 2 + (remapTheFirstWay(mapMovedX) - (gpsBoundingBox[1] + gpsBoundingBox[3] / 2)) * zoom - gpsBoundingBox[3] * zoom / 2,
				bigmapY + bigmapHeight / 2 - (remapTheFirstWay(mapMovedY) - (gpsBoundingBox[2] + gpsBoundingBox[4] / 2)) * zoom + gpsBoundingBox[4] * zoom / 2,
				gpsBoundingBox[3] * zoom,
				-(gpsBoundingBox[4] * zoom),
				gpsRenderTarget,
				180, 0, 0,
				gpsColor
			)

			dxDrawImageSection(0, 0, bigmapX, screenY, 0, 0, bigmapX, screenY, screenSource)
			dxDrawImageSection(screenX - bigmapX, 0, bigmapX, screenY, screenX - bigmapX, 0, bigmapX, screenY, screenSource)
			dxDrawImageSection(bigmapX, 0, screenX - 2 * bigmapX, bigmapY, bigmapX, 0, screenX - 2 * bigmapX, bigmapY, screenSource)
			dxDrawImageSection(bigmapX, screenY - bigmapY, screenX - 2 * bigmapX, bigmapY, bigmapX, screenY - bigmapY, screenX - 2 * bigmapX, bigmapY, screenSource)
		end

		-- ** Blipek
		local blipCount = 0

		for k = 1, #createdBlips do
			local v = createdBlips[k]

			if v then
				blipCount = blipCount + 1

				renderBigBlip(v.blipId, v.blipPosX, v.blipPosY, mapMovedX, mapMovedY, v.iconSize, v.iconSize, v.blipColor, v.renderDistance or 9999, v.tooltip, blipCount)
			end
		end

		local blips = getElementsByType("blip")

		for k = 1, #blips do
			local v = blips[k]

			if v then
				local bx, by = getElementPosition(v)
				local renderDistance = getBlipVisibleDistance(v)
				local color = tocolor(getBlipColor(v))

				blipCount = blipCount + 1

				if getBlipIcon(v) == 1 then
					renderBigBlip("minimap/newblips/munkajarmu.png", bx, by, mapMovedX, mapMovedY, 18, 15, tocolor(255, 255, 255), renderDistance, blipTooltipText[v], blipCount, v)
				elseif getBlipIcon(v) == 2 then
					renderBigBlip("minimap/newblips/kukamunka.png", bx, by, mapMovedX, mapMovedY, 14.5, 14.5, tocolor(255, 255, 255), renderDistance, blipTooltipText[v], blipCount, v)
				else
					renderBigBlip("minimap/newblips/target.png", bx, by, mapMovedX, mapMovedY, 14.5, 14.5, color, renderDistance, blipTooltipText[v], blipCount, v)
				end
			end
		end

		-- ** Pozíciónk
		dxDrawImage(bigmapX, bigmapY, bigmapWidth, bigmapHeight, "files/images/vin.png")

		renderBigBlip("minimap/files/arrow.png", px, py, mapMovedX, mapMovedY, 20, 20)

		if mapMoveDiff then
			renderBigBlip("minimap/newblips/cross.png", mapMovedX, mapMovedY, mapMovedX, mapMovedY, 128, 128)
		end

		dxDrawRectangle(bigmapX, bigmapY + bigmapHeight - respc(30), bigmapWidth, respc(30), tocolor(0, 0, 0, 200))

		if tonumber(cursorX) then
			local zx = reMap((cursorX - bigmapX) / zoom + mapPlayerPosX, 0, radarTextureSize, -3000, 3000)
			local zy = reMap((cursorY - bigmapY) / zoom + mapPlayerPosY, 0, radarTextureSize, 3000, -3000)

			dxDrawText(getZoneName(zx, zy, 0), bigmapX + respc(10), bigmapY + bigmapHeight - respc(30), bigmapX + bigmapWidth, bigmapY + bigmapHeight, tocolor(255, 255, 255), 0.5, BrushScriptStd, "left", "center")

			if hoverBlip then -- kijelölt blip
				local tooltipWidth = dxGetTextWidth(hoverBlip, 0.75, Roboto) + respc(10)

				dxDrawRectangle(cursorX + respc(12.5), cursorY, tooltipWidth, respc(25), tocolor(0, 0, 0, 150))

				dxDrawText(hoverBlip, cursorX + respc(12.5), cursorY, cursorX + tooltipWidth + respc(12.5), cursorY + respc(25), tocolor(255, 255, 255), 0.75, Roboto, "center", "center")
			end
		else
			dxDrawText(getZoneName(px, py, pz), bigmapX + respc(10), bigmapY + bigmapHeight - respc(30), bigmapX + bigmapWidth, bigmapY + bigmapHeight, tocolor(255, 255, 255), 0.5, BrushScriptStd, "left", "center")
		end

		if hoverBlip then
			hoverBlip = false
		end

		-- ** GPS be -és kikapcs
		if isPedInVehicle(localPlayer) and carCanGPSVal then
			dxDrawImage(bigmapX + bigmapWidth - respc(144), bigmapY + bigmapHeight - respc(174), respc(128), respc(128), "minimap/gps/sgo.png", 0, 0, 0, tocolor(255, 255, 255, 200))

			if carCanGPSVal == "" then
				dxDrawText("Női hang", bigmapX + bigmapWidth - respc(85), bigmapY + bigmapHeight - respc(46), bigmapX + bigmapWidth - respc(144) + respc(128), 0, tocolor(255, 255, 255), 0.75, Roboto, "center", "top")
			elseif carCanGPSVal == "2" then
				dxDrawText("Férfi hang", bigmapX + bigmapWidth - respc(85), bigmapY + bigmapHeight - respc(46), bigmapX + bigmapWidth - respc(144) + respc(128), 0, tocolor(255, 255, 255), 0.75, Roboto, "center", "top")
			else
				dxDrawText("Nincs hang", bigmapX + bigmapWidth - respc(85), bigmapY + bigmapHeight - respc(46), bigmapX + bigmapWidth - respc(144) + respc(128), 0, tocolor(255, 255, 255), 0.75, Roboto, "center", "top")
			end
		end

		-- ** 3D blipek
		dxDrawText("3D blipek  ", bigmapX, bigmapY + bigmapHeight - respc(30), bigmapX + bigmapWidth - respc(30), bigmapY + bigmapHeight, tocolor(255, 255, 255), 0.75, Roboto, "right", "center")

		if state3DBlip then
			dxDrawImage(bigmapX + bigmapWidth - respc(30), bigmapY + bigmapHeight - respc(30), respc(30), respc(30), "files/images/tick_on.png")
		else
			dxDrawImage(bigmapX + bigmapWidth - respc(30), bigmapY + bigmapHeight - respc(30), respc(30), respc(30), "files/images/tick.png")
		end

		if tonumber(cursorX) and cursorX >= bigmapX + bigmapWidth - respc(30) - dxGetTextWidth("  3D blipek  ", 0.75, Roboto) and cursorX <= bigmapX + bigmapWidth and cursorY >= bigmapY + bigmapHeight - respc(30) and cursorY <= bigmapY + bigmapHeight then
			hover3DBlip = true
		end

		-- ** Jelölések be/ki
		local totalWidth = respc(30) * 2 + dxGetTextWidth("3D blipek", 0.75, Roboto)

		dxDrawText("Jelölések  ", bigmapX, bigmapY + bigmapHeight - respc(30), bigmapX + bigmapWidth - totalWidth, bigmapY + bigmapHeight, tocolor(255, 255, 255), 0.75, Roboto, "right", "center")

		if stateMarksBlip then
			dxDrawImage(bigmapX + bigmapWidth - totalWidth, bigmapY + bigmapHeight - respc(30), respc(30), respc(30), "files/images/tick_on.png")
		else
			dxDrawImage(bigmapX + bigmapWidth - totalWidth, bigmapY + bigmapHeight - respc(30), respc(30), respc(30), "files/images/tick.png")
		end

		if tonumber(cursorX) and cursorX >= bigmapX + bigmapWidth - totalWidth - dxGetTextWidth("  Jelölések  ", 0.75, Roboto) and cursorX <= bigmapX + bigmapWidth - totalWidth and cursorY >= bigmapY + bigmapHeight - respc(30) and cursorY <= bigmapY + bigmapHeight then
			hoverMarksButton = true
		end

		-- ** Jelölések törlése
		local buttonWidth = dxGetTextWidth("  Jelölések törlése  ", 0.75, Roboto)

		totalWidth = totalWidth + respc(60) + buttonWidth

		if tonumber(cursorX) and cursorX >= bigmapX + bigmapWidth - totalWidth and cursorX <= bigmapX + bigmapWidth - totalWidth + buttonWidth and cursorY >= bigmapY + bigmapHeight - respc(30) and cursorY <= bigmapY + bigmapHeight then
			dxDrawRectangle(bigmapX + bigmapWidth - totalWidth, bigmapY + bigmapHeight - respc(30) / 2 - respc(22.5) / 2, buttonWidth, respc(22.5), tocolor(0, 0, 0, 175))
			hoverMarksRemove = true
		else
			dxDrawRectangle(bigmapX + bigmapWidth - totalWidth, bigmapY + bigmapHeight - respc(30) / 2 - respc(22.5) / 2, buttonWidth, respc(22.5), tocolor(0, 0, 0, 125))
		end

		dxDrawText("Jelölések törlése", bigmapX + bigmapWidth - totalWidth, bigmapY + bigmapHeight - respc(30), bigmapX + bigmapWidth - totalWidth + buttonWidth, bigmapY + bigmapHeight, tocolor(255, 255, 255), 0.75, Roboto, "center", "center")

		-- ** Térkép visszaállítása
		if mapMoveDiff then
			dxDrawText("A nézet visszaállításához nyomd meg a 'SPACE' gombot.", bigmapX, bigmapY + bigmapHeight - respc(30), bigmapX + bigmapWidth, bigmapY + bigmapHeight, tocolor(255, 255, 255), 1, Roboto, "center", "center")

			if getKeyState("space") then
				mapMoveDiff = false
				lastMapMovePos = false
			end
		end
	else
		dxDrawRectangle(bigmapX, bigmapY, bigmapWidth, bigmapHeight, tocolor(0, 0, 0))
		dxDrawImage(bigmapX + bigmapWidth / 2 - 32, bigmapY + bigmapHeight / 2 - 32 - 16, 64, 64, "minimap/files/gpslosticon.png")
		dxDrawImage(bigmapX + bigmapWidth / 2 - 128, bigmapY + bigmapHeight / 2 + 16 + 8, 256, 16, "minimap/files/gpslostszoveg.png")
	end
end

function bigmapClickHandler(button, state, absX, absY)
	if not bigRadarState then
		return
	end

	if hoverMarksButton then
		if state == "up" then
			stateMarksBlip = not stateMarksBlip
			playSound(":see_accounts/files/bubble.mp3")
		end

		return
	end

	if hoverMarksRemove then
		if state == "up" then
			for i = #createdBlips, 1, -1 do
				if createdBlips[i].blipId == "minimap/newblips/markblip.png" then
					table.remove(createdBlips, i)
				end
			end
		end

		return
	end

	if hover3DBlip then
		if state == "up" then
			state3DBlip = not state3DBlip

			if state3DBlip then
				addEventHandler("onClientHUDRender", getRootElement(), render3DBlips, true, "low-99999999")
			else
				removeEventHandler("onClientHUDRender", getRootElement(), render3DBlips)
			end

			playSound(":see_accounts/files/bubble.mp3")
		end

		return
	end

	if state == "up" and mapIsMoving then
		mapIsMoving = false
		return
	end

	local currVeh = getPedOccupiedVehicle(localPlayer)

	if currVeh and carCanGPS() then
		if absX >= bigmapX + bigmapWidth - respc(85) and absY >= bigmapY + bigmapHeight - respc(174) and absX <= bigmapX + bigmapWidth - respc(144) + respc(128) and absY <= bigmapY + bigmapHeight - respc(30) then
			if state == "down" then
				local newVal = carCanGPSVal

				if newVal == "" then
					newVal = 2
				elseif newVal == "2" then
					newVal = 3
				elseif newVal == "off" then
					newVal = 1
				end

				setElementData(currVeh, "vehicle.GPS", newVal)
			end

			return
		end

		if button == "left" and state == "up" then
			local tx = reMap((absX - bigmapX) / zoom + (remapTheSecondWay(mapMovedX) - bigmapWidth / zoom / 2), 0, radarTextureSize, -3000, 3000)
			local ty = reMap((absY - bigmapY) / zoom + (remapTheFirstWay(mapMovedY) - bigmapHeight / zoom / 2), 0, radarTextureSize, 3000, -3000)

			if getElementData(currVeh, "gpsDestination") then
				setElementData(currVeh, "gpsDestination", false)
			else
				setElementData(currVeh, "gpsDestination", {tx, ty})
			end

			return
		end
	end

	if state == "up" and stateMarksBlip then
		if absX >= bigmapX and absY >= bigmapY and absX <= bigmapX + bigmapWidth and absY <= bigmapY + bigmapHeight then
			if hoverMarkBlip then
				table.remove(createdBlips, hoverMarkBlip)
			else
				local tx = reMap((absX - bigmapX) / zoom + (remapTheSecondWay(mapMovedX) - bigmapWidth / zoom / 2), 0, radarTextureSize, -3000, 3000)
				local ty = reMap((absY - bigmapY) / zoom + (remapTheFirstWay(mapMovedY) - bigmapHeight / zoom / 2), 0, radarTextureSize, 3000, -3000)
				local tz = getGroundPosition(tx, ty, 400) + 3

				table.insert(createdBlips, {
					blipPosX = tx,
					blipPosY = ty,
					blipPosZ = tz,
					blipId = "minimap/newblips/markblip.png",
					farShow = true,
					renderDistance = 9999,
					iconSize = 18,
					blipColor = tocolor(255, 255, 255)
				})
			end
		end
	end
end

addEventHandler("onClientKey", getRootElement(),
	function (key, state)
		if key == "F11" then
			if state and renderData.loggedIn then
				bigRadarState = not bigRadarState

				if bigRadarState then
					hideHUD()

					addEventHandler("onClientHUDRender", getRootElement(), renderTheBigmap)
					addEventHandler("onClientClick", getRootElement(), bigmapClickHandler)

					playSound("minimap/files/f11radaropen.mp3")

					if isPedInVehicle(localPlayer) and carCanGPS() and carCanGPSVal ~= "off" then
						gpsHello = playSound("minimap/gps/sound" .. carCanGPSVal .. "/hello.mp3")
					end
				else
					playSound("minimap/files/f11radarclose.mp3")

					removeEventHandler("onClientHUDRender", getRootElement(), renderTheBigmap)
					removeEventHandler("onClientClick", getRootElement(), bigmapClickHandler)

					showHUD()

					if isElement(gpsHello) then
						destroyElement(gpsHello)
					end

					gpsHello = nil
				end

				setElementData(localPlayer, "bigRadarState", bigRadarState, false)
			end

			cancelEvent()
		elseif key == "mouse_wheel_up" and bigRadarState then
			if zoom + 0.1 <= 2.1 then
				zoom = zoom + 0.1
			end
		elseif key == "mouse_wheel_down" and bigRadarState then
			if zoom - 0.1 >= 0.1 then
				zoom = zoom - 0.1
			end
		end
	end)
