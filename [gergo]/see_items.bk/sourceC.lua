local screenX, screenY = guiGetScreenSize()

myriadpro = dxCreateFont("files/fonts/myriadpro.ttf", 18, false, "antialiased")

function showTooltip(x, y, text, subText, showItem)
	text = tostring(text)
	subText = subText and tostring(subText)

	if text == subText then
		subText = nil
	end

	local sx = dxGetTextWidth(text, 1, "clear", true) + 20
	
	if subText then
		sx = math.max(sx, dxGetTextWidth(subText, 1, "clear", true) + 20)
		text = "#3d7abc" .. text .. "\n#ffffff" .. subText
	end

	local sy = 30

	if subText then
		local _, lines = string.gsub(subText, "\n", "")
		
		sy = sy + 12 * (lines + 1)
	end

	local drawnOnTop = true

	if showItem then
		x = math.floor(x - sx / 2)
		drawnOnTop = false
	else
		x = math.max(0, math.min(screenX - sx, x))
		y = math.max(0, math.min(screenY - sy, y))
	end

	dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 190), drawnOnTop)
	dxDrawText(text, x, y, x + sx, y + sy, tocolor(255, 255, 255), 0.5, myriadpro, "center", "center", false, false, drawnOnTop, true)
end