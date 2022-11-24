presets = {
	[596] = { -- Police LS
		duration = 500,
		lights = {
			{x = -0.55, y = -0.4, z = 1, rz = 90,   color = {255, 60, 60}, start = 0,   stop = 125, size = 0.5},
			{x = 0.55, y = -0.4, z = 1, rz = -90,   color = {10, 50, 255}, start = 0,   stop = 125, size = 0.5},

			{x = -0.4, y = -0.35, z = 1, rz = 67.5,   color = {255, 255, 255}, start = 125,   stop = 250, size = 0.5},
			{x = 0.4, y = -0.35, z = 1, rz = -67.5,   color = {255, 255, 255}, start = 125,   stop = 250, size = 0.5},

			{x = -0.2, y = -0.25, z = 1, rz = 45,   color = {255, 60, 60}, start = 250,   stop = 375, size = 0.5},
			{x = 0.2, y = -0.25, z = 1, rz = -45,   color = {10, 50, 255}, start = 250,   stop = 375, size = 0.5},

			{x = 0, y = -0.15, z = 1, rz = 0,   color = {255, 255, 255}, start = 375,   stop = 500, size = 0.5},
		}
	},
	[597] = { -- Police SF
		duration = 500,
		lights = {
			{x = -0.2, y = -0.475, z = 1, rz = 90,   color = {255, 60, 60}, start = 0,   stop = 125, size = 0.5},
			{x = 0.2, y = -0.475, z = 1, rz = -90,   color = {10, 50, 255}, start = 0,   stop = 125, size = 0.5},

			{x = -0.4, y = -0.475, z = 1, rz = 90,   color = {255, 60, 60}, start = 125,   stop = 250, size = 0.5},
			{x = 0.4, y = -0.475, z = 1, rz = -90,   color = {10, 50, 255}, start = 125,   stop = 250, size = 0.5},

			{x = -0.2, y = 2.55, z = -0.05, rz = 5,   color = {255, 60, 60}, start = 250,   stop = 375, size = 0.5},
			{x = 0.2, y = 2.55, z = -0.05, rz = -5,   color = {10, 50, 255}, start = 250,   stop = 375, size = 0.5},

			{x = -0.75, y = -2.65, z = 0.2, rz = 185,   color = {255, 255, 255}, start = 375,   stop = 500, size = 0.5},
			{x = 0.75, y = -2.65, z = 0.2, rz = -185,   color = {255, 255, 255}, start = 375,   stop = 500, size = 0.5},
		}
	},
	[86] = { -- Ford Explorer Slicktop
		duration = 500,
		lights = {
			{x = -0.2, y = -0.475, z = 1, rz = 90,   color = {255, 60, 60}, start = 0,   stop = 125, size = 0.5},
			{x = 0.2, y = -0.475, z = 1, rz = -90,   color = {10, 50, 255}, start = 0,   stop = 125, size = 0.5},

			{x = -0.4, y = -0.475, z = 1, rz = 90,   color = {255, 60, 60}, start = 125,   stop = 250, size = 0.5},
			{x = 0.4, y = -0.475, z = 1, rz = -90,   color = {10, 50, 255}, start = 125,   stop = 250, size = 0.5},

			{x = -0.2, y = 2.55, z = -0.05, rz = 5,   color = {255, 60, 60}, start = 250,   stop = 375, size = 0.5},
			{x = 0.2, y = 2.55, z = -0.05, rz = -5,   color = {10, 50, 255}, start = 250,   stop = 375, size = 0.5},

			{x = -0.75, y = -2.65, z = 0.2, rz = 185,   color = {255, 255, 255}, start = 375,   stop = 500, size = 0.5},
			{x = 0.75, y = -2.65, z = 0.2, rz = -185,   color = {255, 255, 255}, start = 375,   stop = 500, size = 0.5},
		}
	},
}

function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix ( element )  -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z                               -- Return the transformed point
end