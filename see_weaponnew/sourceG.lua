replacementModels = {
	cage = 4858,
	buoy = 4861,
	crab = 4859,
	bait = 4860
}

cagePrice = 50
crabPrice = 6.5

function getPositionFromElementOffset(element, x, y, z)
	local m = getElementMatrix(element)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		    x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		    x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end
