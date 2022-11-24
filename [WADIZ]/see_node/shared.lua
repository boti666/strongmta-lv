frequencyOfNodes = 5
skipUnderWaterNodes = true

generationAreaBBox =
{
	minX = -3000,
	maxX =  3000,
	minY =  3000,
	maxY = -3000,
}

mapSizeX = 16000
mapSizeY = 16000
zoneSize = 125

function getZoneIndex(coordX, coordY)
	local xIndex = math.floor((coordX + mapSizeX) / zoneSize)
	local yIndex = math.floor((coordY + mapSizeY) / zoneSize)
	return xIndex * (mapSizeX / zoneSize) + yIndex
end

allowedSurfaceMaterials =
{
	--> https://wiki.multitheftauto.com/wiki/Material_IDs

	--// Grass
	9, --> Short Lush
	10, --> Medium Lush
	11, --> Long Lush
	12, --> Short Dry
	13, --> Medium Dry
	14, --> Long Dry
	-- 15, --> Rough Golf Grass
	-- 16, --> Smooth Golf Grass
	17, --> Steep Slidy Grass
	20, --> Meadow
	80, --> Short Grass
	81, --> Meadow Grass
	82, --> Dry Grass
	115, --> Wee Flowers
	116, --> Dry Tall
	117, --> Lush Tall
	118, --> Green Mix
	119, --> Brown Mix
	120, --> Low Grass
	121, --> Rocky Grass
	122, --> Small Trees Grass
	125, --> Weeds Grass
	146, --> Light Grass
	147, --> Lighter Grass
	148, --> Lighter Grass 2
	149, --> Mid Grass
	150, --> Mid Grass 2
	151, --> Dark Grass
	152, --> Dark Grass 2
	153, --> Dirt Mix
	160, --> Park Grass

	--// Dirt
	-- 19, --> Flower Bed
	-- 21, --> Waste Ground
	22, --> Woodland Ground
	24, --> Wet Mud
	25, --> Dry Mud
	-- 26, --> Dirt
	-- 27, --> Dirt Track
	-- 40, --> Corn Field
	83, --> Woodland
	84, --> Wood Dense
	-- 87, --> Flower Bed
	-- 88, --> Waste Ground
	-- 100, --> Riverbed
	-- 110, --> Marsh
	123, --> Rocky Dirt
	124, --> Weeds Dirt
	-- 126, --> River Edge
	128, --> Stumps Forest
	129, --> Sticks Forest
	130, --> Leaves Forest
	132, --> Dry Forest
	133, --> Sparse Flowers
	-- 141, --> Junkyard Ground
	-- 142, --> Dump
	-- 145, --> Corn Field
	-- 155, --> Shallow Riverbed
	-- 156, --> Weeds Riverbed

	--// Sand
	28, --> Deep
	29, --> Medium
	30, --> Compact
	31, --> Arid
	32, --> More
	33, --> Beach
	74, --> Sand
	75, --> Dense
	76, --> Arid
	77, --> Compact
	78, --> Rocky
	79, --> Beach
	86, --> Roadside Desert
	-- 96, --> Underwater Lush
	-- 97, --> Underwater Barren
	-- 98, --> Underwater Coral
	-- 99, --> Underwater Deep
	-- 131, --> Desert Rocks
	-- 143, --> Cactus Dense
	-- 157, --> Seaweed

	--// Vegetation
	23, --> Vegetation
	41, --> Hedge
	111, --> Bushy
	112, --> Mix Bushy
	113, --> Dry Bushy
	114, --> Mid Bushy
}

local timeUnits = {
	{seconds = 60*60*24*7*4*12, label = "year"},
	{seconds = 60*60*24*7*4, label = "month"},
	{seconds = 60*60*24*7, label = "week"},
	{seconds = 60*60*24, label = "day"},
	{seconds = 60*60, label = "hour"},
	{seconds = 60, label = "minute"},
	{seconds = 1, label = "second"},
}

function formatSeconds(seconds)
	seconds = tonumber(seconds) or 0
	seconds = math.abs(seconds)
	seconds = math.round(seconds)

	local firstUnit = false
	local secondUnit = false
	local timeString = {}

	for i = 1, #timeUnits do
		local v = timeUnits[i]

		if v then
			local quotient = math.round(seconds / v.seconds)
			local remainder = seconds - quotient * v.seconds

			seconds = remainder

			if quotient > 0 then
				if math.abs(quotient) < math.huge then
					if not firstUnit then
						firstUnit = i
						timeString[1] = quotient .. " " .. v.label .. (quotient > 1 and "s" or "")
					elseif not secondUnit then
						if i - firstUnit == 1 then
							secondUnit = i
							timeString[2] = quotient .. " " .. v.label .. (quotient > 1 and "s" or "")
							break
						end
					end
				else
					timeString = {"∞"}
					break
				end
			end
		end
	end

	if #timeString == 0 then
		return "0 second"
	else
		return table.concat(timeString, " ")
	end
end

function math.round(inputNumber, numDecimalPlaces)
	local multiplier = 10 ^ (numDecimalPlaces or 0)
	return math.floor(inputNumber * multiplier + 0.5) / multiplier
end
