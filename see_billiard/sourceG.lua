ballSetup = {
	radius = 0.038,
	mass = 10,
	restitution = 0.9,
	friction = 0.075,
	airResistance = 0.025
}

ballNames = {
	[1] = "1-es (#f2b012sárga#ffffff)",
	[2] = "2-es (#0a27a3kék#ffffff)",
	[3] = "3-as (#b70c0apiros#ffffff)",
	[4] = "4-es (#160e41lila#ffffff)",
	[5] = "5-ös (#ca4414narancs#ffffff)",
	[6] = "6-os (#085d21zöld#ffffff)",
	[7] = "7-es (#6c1608bordó#ffffff)",
	[8] = "8-as (#000000fekete#ffffff)",
	[9] = "9-es (csíkos-#f2b012sárga#ffffff)",
	[10] = "10-es (csíkos-#0a27a3kék#ffffff)",
	[11] = "11-es (csíkos-#b70c0apiros#ffffff)",
	[12] = "12-es (csíkos-#160e41lila#ffffff)",
	[13] = "13-as (csíkos-#ca4414narancs#ffffff)",
	[14] = "14-es (csíkos-#085d21zöld#ffffff)",
	[15] = "15-ös (csíkos-#6c1608bordó#ffffff)",
	[16] = "fehér"
}

numModels = {
	[1] = 3002,
	[2] = 3100,
	[3] = 3101,
	[4] = 3102,
	[5] = 3103,
	[6] = 3104,
	[7] = 3105,
	[8] = 3106,
	[9] = 2995,
	[10] = 2996,
	[11] = 2997,
	[12] = 2998,
	[13] = 2999,
	[14] = 3000,
	[15] = 3001,
	[16] = 3003
}

modelNums = {
	[3002] = 1,
	[3100] = 2,
	[3101] = 3,
	[3102] = 4,
	[3103] = 5,
	[3104] = 6,
	[3105] = 7,
	[3106] = 8,
	[2995] = 9,
	[2996] = 10,
	[2997] = 11,
	[2998] = 12,
	[2999] = 13,
	[3000] = 14,
	[3001] = 15,
	[3003] = 16
}

ballOffsets = {
	[16] = {-0.35, 0}
}

local rackSetup = {1, 2, 9, 3, 8, 10, 4, 14, 7, 11, 12, 6, 15, 13, 5}
local lastCurrNum = 1

for i = 0, 4 do
	for j = 0, i do
		local num = rackSetup[lastCurrNum]

		ballOffsets[num] = {
			0.35 + i * math.sqrt(3 * ballSetup.radius * ballSetup.radius),
			ballSetup.radius - ballSetup.radius * (i + 1) + (ballSetup.radius * 2) * j
		}

		lastCurrNum = lastCurrNum + 1
	end
end

pocketPoses = {
	-- radius, x, y
	{0.09, -0.957, -0.505},
	{0.09, -0.957, 0.525},
	{0.09, 0.97, 0.525},
	{0.09, 0.97, -0.505},
	{0.075, 0.01, 0.57},
	{0.075, 0.01, -0.55}
}

boundaryPoses = {
	-- start x, start y, stop x, stop y
	{-0.957, -0.42, -0.957, 0.44},
	{0.97, -0.42, 0.97, 0.44},
	{-0.865, -0.505, -0.054, -0.505},
	{0.070, -0.505, 0.888, -0.505},
	{-0.865, 0.525, -0.054, 0.525},
	{0.070, 0.525, 0.888, 0.525}
}

function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end