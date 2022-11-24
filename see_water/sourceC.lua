local createdWaters = {}
local waterPositions = {
	{2800, -3000, 0, 3000, -3000, 0, 2800, 3000, 0, 3000, 3000, 0},
	{-3000, 2900, 0, 2900, 2900, 0, -3000, 3000, 0, 2900, 3000, 0},
	{-3000, -3000, 0, -1300, -3000, 0, -3000, 2900, 0, -1300, 2900, 0},
	{-1300, -3000, 0, 0, -3000, 0, -1300, 2030, 0, 0, 2030, 0},
	{0, -3000, 0, 2800, -3000, 0, 0, 700, 0, 2800, 700, 0},
	{-1400, 2030, 0 + 40, -832, 2030, 0 + 40, -1400, 2900, 0 + 40, -832, 2900, 0 + 40},
	{-832, 2060, 0 + 40, -600, 2060, 0 + 40, -832, 2350, 0 + 40, -600, 2350, 0 + 40},
	{-600, 2060, 0 + 40, -400, 2060, 0 + 40, -600, 2250, 0 + 40, -400, 2250, 0 + 40},
	{-600, 2250, 0 + 40, -500, 2250, 0 + 40, -600, 2350, 0 + 40, -500, 2350, 0 + 40},
	{-550, 2000, 0 + 40, -500, 2000, 0 + 40, -550, 2060, 0 + 40, -500, 2060, 0 + 40},
	{-600, 2030, 0 + 40, -550, 2030, 0 + 40, -600, 2060, 0 + 40, -550, 2060, 0 + 40},
	{2050, 1870, 9.6, 2107, 1870, 9.6, 2050, 1962, 9.6, 2107, 1962, 9.6},
	{1850, 1470, 9, 2032, 1470, 9, 1850, 1570, 9, 2032, 1570, 9},
	{1890, 1570, 9, 2032, 1570, 9, 1890, 1700, 9, 2032, 1700, 9},
	{2105, 1220, 9, 2200, 1220, 9, 2105, 1333, 9, 2200, 1333, 9},
	{2105, 1100, 8.5, 2200, 1100, 8.5, 2105, 1175, 8.5, 2200, 1175, 8.5},
	{2120, 1050, 8.5, 2150, 1050, 8.5, 2120, 1100, 8.5, 2150, 1100, 8.5},
	{542, 2800, 0, 793, 2800, 0, 542, 2900, 0, 793, 2900, 0},
	{1750, 2770, 9, 1800, 2770, 9, 1750, 2850, 9, 1800, 2850, 9},
	{2510, 1550, 9.25, 2550, 1550, 9.25, 2510, 1600, 9.25, 2550, 1600, 9.25},
	{333, 699, 0, 826, 699, 0, 333, 1033, 0, 826, 1033, 0}
}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local pedDimension = getElementDimension(localPlayer)

		setWaterLevel(-3000, true, false)
		setWaveHeight(0.15)
		setWaterColor(45, 105, 115, 235)

		for i = 1, #waterPositions do
			table.insert(createdWaters, createWater(unpack(waterPositions[i])))
		end

		for i = 1, #createdWaters do
			setElementDimension(createdWaters[i], pedDimension)
		end
	end
)

function changeWaterDimension(dimension)
	if not tonumber(dimension) then
		dimension = getElementDimension(localPlayer)
	end

	for i = 1, #createdWaters do
		setElementDimension(createdWaters[i], dimension)
	end
end
addEventHandler("onClientElementStreamIn", localPlayer, changeWaterDimension)
addEvent("waterDimensionChange", true)
addEventHandler("waterDimensionChange", getRootElement(), changeWaterDimension)
