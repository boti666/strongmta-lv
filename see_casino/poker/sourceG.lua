tablePositions = {}

cardRanks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
cardSuits = {"S", "H", "D", "C"}

--secondaryValues = {1, 4, 13, 40, 121, 364, 1093, 3280, 9841, 29524, 88573, 265720, 797161}

handRankings = {
	ROYAL_FLUSH = 1,
	STRAIGHT_FLUSH = 2,
	FOUR_OF_A_KIND = 3,
	FULL_HOUSE = 4,
	FLUSH = 5,
	STRAIGHT = 6,
	THREE_OF_A_KIND = 7,
	TWO_PAIRS = 8,
	ONE_PAIR = 9,
	HIGH_HAND = 10
}

secondaryValues = {
    [handRankings.HIGH_HAND] = 0,
    [handRankings.ONE_PAIR] = 1000000,
    [handRankings.TWO_PAIRS] = 2000000,
    [handRankings.THREE_OF_A_KIND] = 3000000,
    [handRankings.STRAIGHT] = 4000000,
    [handRankings.FLUSH] = 5000000,
    [handRankings.FULL_HOUSE] = 6000000,
    [handRankings.FOUR_OF_A_KIND] = 7000000,
    [handRankings.STRAIGHT_FLUSH] = 8000000,
    [handRankings.ROYAL_FLUSH] = 8000000
}

evaluationNames = {
	ROYAL_FLUSH = "Royal Flush", -- Egy ászt, egy királyt, egy dámát, egy bubit és egy tízest tartalmaz ugyanabból a színből
	STRAIGHT_FLUSH = "Színsor",  -- Öt egymást követő értékű lap, mind azonos színben
	FOUR_OF_A_KIND = "Póker",    -- Négy azonos értékű lap és egy plusz lap, a kísérő
	FULL_HOUSE = "Full House",   -- Három azonos értékű lap és két másik, egymással azonos értékű lap
	FLUSH = "Flöss",             -- Öt azonos színű lap
	STRAIGHT = "Sor",            -- Öt egymást követő lap
	THREE_OF_A_KIND = "Drill",   -- Három azonos értékű lap, két, egymástól független kísérőlappal kiegészülve
	TWO_PAIRS = "Két pár",       -- Két azonos értékű lap és két másik, egymással azonos értékű kártya, plusz egy kísérő
	ONE_PAIR = "Pár",            -- Két azonos értékű lap és három különböző kártya
	HIGH_HAND = "Magas Lap"      -- Mindazok a kezek, amelyek a fenti kategóriák egyikébe sem tartoznak
}

interactionTime = 1000 * 30

minimumPlayers = 2
maximumPlayers = 9

function rotateAround(angle, offsetX, offsetY, originX, originY)
	angle = math.rad(angle)

	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)

	local rotatedX = offsetX * cosAngle - offsetY * sinAngle
	local rotatedY = offsetX * sinAngle + offsetY * cosAngle

	originX = originX or 0
	originY = originY or 0

	return originX + rotatedX, originY + rotatedY
end

function thousandsStepper(amount)
	local formatted = tostring(amount)
	local counter = 0

	while true do
		formatted, counter = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1 %2")

		if counter == 0 then
			break
		end
	end

	return formatted
end

cardLinePositionsExample = {0, 0.1, 0.4}
cardLinePositions = {}

guiPositions = {
	{-1.29, -0.95},
	{-2.35, -0.5},
	{-2.35, 0.5},
	{-1.29, 0.95},
	{0, 0.95},
	{1.29, 0.95},
	{2.35, 0.5},
	{2.35, -0.5},
	{1.29, -0.95}
}
realGuiPositions = {}

pedPositionZ = 0.9
pedPositions = {
	{-1.3, -1.5, 0},
	{-2.8, -0.7, -60},
	{-2.8, 0.7, -120},
	{-1.3, 1.5, 180},
	{0, 1.5, 180},
	{1.3, 1.5, 180},
	{2.8, 0.7, 120},
	{2.8, -0.7, 60},
	{1.3, -1.5, 0}
}
realPedPositions = {}

blindPositions = {
	{-1.29, -0.42, 0},
	{-1.935, -0.24, -60},
	{-1.935, 0.24, -120},
	{-1.29, 0.42, 180},
	{0, 0.42, 180},
	{1.29, 0.42, 180},
	{1.935, 0.24, 120},
	{1.935, -0.24, 60},
	{1.29, -0.42, 0}
}
realBlindPositions = {}

playerCardPositions = {
	-- Játékosok lapjainak pozíciói
	{-1.29, -0.7, 0},
	{-2.15, -0.4, -60},
	{-2.15, 0.4, -120},
	{-1.29, 0.7, 180},
	{0, 0.7, 180},
	{1.29, 0.7, 180},
	{2.15, 0.4, 120},
	{2.15, -0.4, 60},
	{1.29, -0.7, 0},
	-- Osztó lapjainak pozíciói
	{0, -1.5, 0},
	{0, -1.5, -60},
	{0, -1.5, -120},
	{0, -1.5, 180},
	{0, -1.5, 180},
	{0, -1.5, 180},
	{0, -1.5, 120},
	{0, -1.5, 60},
	{0, -1.5, 0}
}
realPlayerCardPositions = {}

coinPositions = {
	-- A játékosok zsetonjainak pozíciói
	{-1.29, -0.7, 0},
	{-2.1, -0.4, -60},
	{-2.15, 0.4, -120},
	{-1.29, 0.7, 180},
	{0, 0.7, 180},
	{1.29, 0.7, 180},
	{2.15, 0.4, 120},
	{2.1, -0.4, 60},
	{1.29, -0.7, 0},
	-- A licitkörre felrakott zsetonok pozíciói
	{ -1.29, -0.28, 0},
	{-1.8275, -0.16, -60},
	{-1.8275, 0.16, -120},
	{-1.29, 0.28, 180},
	{0, 0.28, 180},
	{1.29, 0.28, 180},
	{1.8275, 0.16, 120},
	{1.8275, -0.16, 60},
	{1.29, -0.28, 0},
	-- A kassza zseton pozíciója
	pot = {0, -0.3, 0}
}
realCoinPositions = {}

dealerPosition = {0, -1.5, 0}
realDealerPositions = {}

function generateTables(tableId)
	if not tableId then
		for k, v in pairs(tablePositions) do
			generateTables(k)
		end
	else
		local theTablePosition = tablePositions[tableId]

		-- GUI (Leülő gomb) pozíciók
		realGuiPositions[tableId] = {}

		for i, v in ipairs(guiPositions) do
			local guiPositionX, guiPositionY = rotateAround(theTablePosition[4], v[1], v[2])

			realGuiPositions[tableId][i] = {
				theTablePosition[1] + guiPositionX,
				theTablePosition[2] + guiPositionY,
				theTablePosition[3] + 0.5
			}
		end

		-- Vak jelző objekt pozíciók
		realBlindPositions[tableId] = {}

		for i, v in ipairs(blindPositions) do
			local blindPositionX, blindPositionY = rotateAround(theTablePosition[4], v[1], v[2])

			realBlindPositions[tableId][i] = {
				theTablePosition[1] + blindPositionX,
				theTablePosition[2] + blindPositionY,
				theTablePosition[3] + 0.4
			}
		end

		-- Kártya material3d pozíciók
		realPlayerCardPositions[tableId] = {}

		for i, v in ipairs(playerCardPositions) do
			local upperOffsetX, upperOffsetY = rotateAround(v[3], 0, 0.125)
			local lowerOffsetX, lowerOffsetY = rotateAround(v[3], 0, -0.075)

			local upperPositionX, upperPositionY = rotateAround(theTablePosition[4], v[1] + upperOffsetX, v[2] + upperOffsetY)
			local lowerPositionX, lowerPositionY = rotateAround(theTablePosition[4], v[1] + lowerOffsetX, v[2] + lowerOffsetY)

			realPlayerCardPositions[tableId][i] = {
				theTablePosition[1] + upperPositionX,
				theTablePosition[2] + upperPositionY,
				theTablePosition[1] + lowerPositionX,
				theTablePosition[2] + lowerPositionY,
				theTablePosition[3] + 0.4
			}
		end

		-- Zseton pozíciók
		realCoinPositions[tableId] = {}

		for k, v in pairs(coinPositions) do
			local baseOffsetX = 0
			local baseOffsetY = 0

			if tonumber(k) then
				if k <= 9 then
					baseOffsetX, baseOffsetY = rotateAround(v[3], -0.3, 0.05)
				end
			end

			local coinRotation = math.random(180, 360) + v[3]
			local coinOffsetX1, coinOffsetY1 = rotateAround(coinRotation, 0, -0.1)
			local coinOffsetX2, coinOffsetY2 = rotateAround(coinRotation, -0.1, 0)

			local coinPositionX1, coinPositionY1 = rotateAround(theTablePosition[4], v[1] + baseOffsetX, v[2] + baseOffsetY)
			local coinPositionX2, coinPositionY2 = rotateAround(theTablePosition[4], v[1] + baseOffsetX + coinOffsetX1, v[2] + baseOffsetY + coinOffsetY1)
			local coinPositionX3, coinPositionY3 = rotateAround(theTablePosition[4], v[1] + baseOffsetX + coinOffsetX2, v[2] + baseOffsetY + coinOffsetY2)

			realCoinPositions[tableId][k] = {
				theTablePosition[1] + coinPositionX1,
				theTablePosition[2] + coinPositionY1,
				theTablePosition[1] + coinPositionX2,
				theTablePosition[2] + coinPositionY2,
				theTablePosition[1] + coinPositionX3,
				theTablePosition[2] + coinPositionY3,
				theTablePosition[3] + 0.5
			}
		end

		-- Ülőhely pozíciók
		realPedPositions[tableId] = {}

		for i, v in ipairs(pedPositions) do
			local pedPositionX, pedPositionY = rotateAround(theTablePosition[4], v[1], v[2])

			realPedPositions[tableId][i] = {
				theTablePosition[1] + pedPositionX,
				theTablePosition[2] + pedPositionY,
				theTablePosition[3] + pedPositionZ,
				theTablePosition[4] + v[3]
			}
		end

		-- Osztó pozíció
		local dealerPositionX, dealerPositionY = rotateAround(theTablePosition[4], dealerPosition[1], dealerPosition[2])

		realDealerPositions[tableId] = {
			theTablePosition[1] + dealerPositionX,
			theTablePosition[2] + dealerPositionY,
			theTablePosition[3],
			theTablePosition[4] + dealerPosition[3]
		}

		-- Közöslapok pozíció
		local upperPositionX, upperPositionY = rotateAround(theTablePosition[4], cardLinePositionsExample[1], cardLinePositionsExample[2])
		local lowerPositionX, lowerPositionY = rotateAround(theTablePosition[4], -cardLinePositionsExample[1], -cardLinePositionsExample[2])

		cardLinePositions[tableId] = {
			theTablePosition[1] + upperPositionX,
			theTablePosition[2] + upperPositionY,
			theTablePosition[3] + cardLinePositionsExample[3],
			theTablePosition[1] + lowerPositionX,
			theTablePosition[2] + lowerPositionY,
			theTablePosition[1],
			theTablePosition[2]
		}
	end
end

if not localPlayer then
	function setPokerBoardData(id, key, value, ...)
		return setElementData(resourceRoot, "pokerBoard." .. tostring(id) .. "." .. tostring(key), value, ...)
	end

	function setPokerSeatData(id, seat, key, value, ...)
		return setElementData(resourceRoot, "pokerBoard." .. tostring(id) .. ".seat." .. tostring(seat) .. "." .. tostring(key), value, ...)
	end

	function removePokerBoardData(id, key)
		return removeElementData(resourceRoot, "pokerBoard." .. tostring(id) .. "." .. tostring(key))
	end

	function removePokerSeatData(id, seat, key)
		return removeElementData(resourceRoot, "pokerBoard." .. tostring(id) .. ".seat." .. tostring(seat) .. "." .. tostring(key))
	end
end

function getPokerBoardData(id, key, ...)
	return getElementData(resourceRoot, "pokerBoard." .. tostring(id) .. "." .. tostring(key), ...)
end

function getPokerSeatData(id, seat, key, ...)
	return getElementData(resourceRoot, "pokerBoard." .. tostring(id) .. ".seat." .. tostring(seat) .. "." .. tostring(key), ...)
end
