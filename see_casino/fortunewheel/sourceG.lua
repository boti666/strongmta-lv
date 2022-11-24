nums = {1, 2, 1, 5, 1, 2, 1, 5, 1, 2, 1, 10, 1, 20, 1, 5, 1, 2, 1, 5, 2, 1, 2, 1, 2, 40, 1, 2, 1, 5, 1, 2, 1, 10, 5, 2, 1, 20, 1, 2, 5, 1, 2, 1, 10, 2, 1, 5, 1, 2, 1, 10, 2, 40}

nums_weights = {}

for i = 1, #nums do
    local num = nums[i]

    if not nums_weights[num] then
        nums_weights[num] = 1
    else
        nums_weights[num] = nums_weights[num] + 1
    end
end

function rotateAround(angle, x, y, x2, y2)
	x2 = x2 or 0
	y2 = y2 or 0

	local theta = math.rad(angle)
	local rotatedX = x * math.cos(theta) - y * math.sin(theta) + x2
	local rotatedY = x * math.sin(theta) + y * math.cos(theta) + y2

	return rotatedX, rotatedY
end

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end