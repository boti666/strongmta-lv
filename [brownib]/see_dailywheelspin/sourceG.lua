fortuneWheels = {
    {1989.3884277344, 1017.8950195312, 994.890625, -90, 10, 347},
}

function getPositionFromElementOffset(element, x, y, z)
    if element then
        m = getElementMatrix(element)
        return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1], x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2], x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
    end
end

nums = {1, 2, 1, 5, 1, 2, 1, 5, 1, 2, 1, 10, 1, 20, 1, 5, 1, 2, 1, 5, 2, 1, 2, 1, 2, 40, 1, 2, 1, 5, 1, 2, 1, 10, 5, 2, 1, 20, 1, 2, 5, 1, 2, 1, 10, 2, 1, 5, 1, 2, 1, 10, 2, 40}
nums_weights = {}
degPerNum = 360 / #nums

for i = 1, #nums do
    local num = nums[i]

    if not nums_weights[num] then
        nums_weights[num] = 1
    else
        nums_weights[num] = nums_weights[num] + 1
    end
end

function chooseRandomNumber()
    local totalWeight = 0

    for number, weight in pairs(nums_weights) do
        totalWeight = totalWeight + weight
    end

    local randomWeight = math.random(1, totalWeight)
    local currentWeight = 0

    for number, weight in pairs(nums_weights) do
        currentWeight = currentWeight + weight

        if randomWeight <= currentWeight then
            return number
        end
    end

    return false
end	

function rotateAround(angle, x, y, x2, y2)
	x2 = x2 or 0
	y2 = y2 or 0

	local theta = math.rad(angle)
	local rotatedX = x * math.cos(theta) - y * math.sin(theta) + x2
	local rotatedY = x * math.sin(theta) + y * math.cos(theta) + y2

	return rotatedX, rotatedY
end