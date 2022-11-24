function rotateAround(angle, x, y, x2, y2)
	local theta = math.rad(angle)
	local rotatedX = x * math.cos(theta) - y * math.sin(theta) + (x2 or 0)
	local rotatedY = x * math.sin(theta) + y * math.cos(theta) + (y2 or 0)
	return rotatedX, rotatedY
end

pedPositions = {
	{0.5, 1.85, 0.7},
	{-0.9, 2.75, 0.7},
	{-0.9, -2.2, 1},
	{-0.9, -5.1, 1},
	{-0.5, -5.1, 1},
	{-0.5, 1.85, 0.7},
	{0.5, -3.1, 1},
	{-0.5, -3.1, 1},
	{-0.9, -4.2, 1},
	{0.85, 1.85, 0.7},
	{-0.5, 0.95, 0.7},
	{-0.9, 1.85, 0.7},
	{-0.9, -3.1, 1},
	{0.5, 3.65, 0.7},
	{-0.9, 0.95, 0.7},
	{0.5, 2.75, 0.7},
	{0.85, 0.95, 0.7},
	{0.5, 0.95, 0.7},
	{0.5, -5.1, 1},
	{-0.5, -2.2, 1},
	{0.85, -2.2, 1},
	{0.85, -5.1, 1},
	{-0.5, 2.75, 0.7},
	{0.85, -3.1, 1},
	{0.5, -2.2, 1},
	{0.85, -4.2, 1},
	{-0.5, 3.65, 0.7},
	{-0.9, 3.65, 0.7},
	{0.85, 3.65, 0.7},
	{-0.5, -4.2, 1},
	{0.85, 2.75, 0.7},
	{0.5, -4.2, 1}
}

pedBasePositions = {
	{-1.5, -2},
	{-1.5, -1},
	{-1.5, 0},
	{-1.5, 1},
	{-1.5, 2}
}

busStops = {}

markerPoints = {
	normal = {},
	country = {}
}

pedPoints = {
	normal = {},
	country = {}
}

function initBusStop(lineType, baseX, baseY, baseZ, rotation)
	local markerX, markerY = rotateAround(rotation, -4, 0)

	table.insert(markerPoints[lineType], {baseX + markerX, baseY + markerY, baseZ})

	if setObjectBreakable then
		local objectElement = createObject(1257, baseX, baseY, baseZ + 0.15, 0, 0, rotation)

		if isElement(objectElement) then
			setObjectBreakable(objectElement, false)
			busStops[objectElement] = true
		end
	end

	local markerId = #markerPoints[lineType]

	pedPoints[lineType][markerId] = {}

	for i = 1, #pedBasePositions do
		local pedX, pedY = rotateAround(rotation, pedBasePositions[i][1], pedBasePositions[i][2])

		table.insert(pedPoints[lineType][markerId], {baseX + pedX, baseY + pedY, baseZ, rotation + 90})
	end
end

initBusStop("normal", 2534.25, 1348.8, 11.1, 0)
initBusStop("normal", 2172.7, 1379.6, 11.1, 90)
initBusStop("normal", 2079.7002, 1683.5, 11.1, 0)
initBusStop("normal", 2317.6001, 1886.9, 11.1, 270)
initBusStop("normal", 2447.8999, 1967.1, 11.1, 270)
initBusStop("normal", 2853.8, 2064.1001, 11.1, 0)
initBusStop("normal", 2533.7, 2318.8999, 11.1, 0)
initBusStop("normal", 2373.7, 2461, 11.1, 0)
initBusStop("normal", 2175.8, 2779.6001, 11.1, 90)
initBusStop("normal", 2021.1, 2430.8999, 11.1, 180)
initBusStop("normal", 1921, 2309.3, 11.1, 180)
initBusStop("normal", 1651.1, 2279.6001, 11, 90)
initBusStop("normal", 1365, 2059.7, 11.1, 90)
initBusStop("normal", 1001.1, 1916.8, 11.1, 180)
initBusStop("normal", 1001.2, 1298.9, 11.1, 180)
initBusStop("normal", 1540.1, 1127.2, 11.1, 270)
initBusStop("normal", 2009.9, 1086.8, 11.1, 270)
initBusStop("normal", 2113.6001, 967.20001, 11.1, 270)
initBusStop("normal", 2354.5, 1042.9541015625, 10.8203125, 0)
initBusStop("normal", 2485.8999, 1067, 11.1, 270)

initBusStop("country", 2588.7, 1479.8, 11.1, 90)
initBusStop("country", 2036.6572265625, 1330.28515625, 10.8203125, 180)
initBusStop("country", 2036.2, 923.79999, 9.2, 180)
initBusStop("country", 918.7998, 749.40039, 11, 109.99)
initBusStop("country", 253.896484375, 928.2041015625, 25.6575756073, 22)
initBusStop("country", -75.2, 855.59998, 18.5, 119.994)
initBusStop("country", -836.1591796875, 1525.5869140625, 21, 350)
initBusStop("country", -1379.3, 1861.3, 37.3, 95.995)
initBusStop("country", -1986.5, 2395.8, 33.6, 20.743)
initBusStop("country", -1363.322265625, 2652.5, 51.7, 220)
initBusStop("country", -836.2998, 2719.2998, 46, 273.746)
initBusStop("country", -446.310546875, 2710.609375, 62.761515808105, 274)
initBusStop("country", 849.7998, 2473.6006, 30.2, 193.744)
initBusStop("country", 1036.5, 2505.7, 11, 237.746)
initBusStop("country", 2265.5, 2594.8, 7.1, 279.744)
initBusStop("country", 2697.2, 1913.2, 7.1, 180)