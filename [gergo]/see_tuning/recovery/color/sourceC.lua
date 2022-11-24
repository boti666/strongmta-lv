local panelWidth = respc(400)
local panelHeight = respc(240)

local panelPosX = menuPosX
local panelPosY = menuPosY + menuHeight

local hue = 0.5
local saturation = 0.5
local lightness = 0.5

local activeColorId = false

colorPicker = false
colorX = false
colorY = false

isColorPicking = false
isLuminancePicking = false

activeColorInput = false
colorInputs = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local r, g, b = convertHSLToRGB(hue, saturation, lightness)
		colorInputs.r = math.floor(r)
		colorInputs.g = math.floor(g)
		colorInputs.b = math.floor(b)
		colorInputs.hex = convertRGBToHEX(colorInputs.r, colorInputs.g, colorInputs.b)
	end)

function processColorPicker()
	if activeColorId == 1 then
		setVehicleColor(vehicleElement,
			colorInputs.r, colorInputs.g, colorInputs.b,
			vehicleColor[4], vehicleColor[5], vehicleColor[6],
			vehicleColor[7], vehicleColor[8], vehicleColor[9],
			vehicleColor[10], vehicleColor[11], vehicleColor[12]
		)
	elseif activeColorId == 2 then
		setVehicleColor(vehicleElement,
			vehicleColor[1], vehicleColor[2], vehicleColor[3],
			colorInputs.r, colorInputs.g, colorInputs.b,
			vehicleColor[7], vehicleColor[8], vehicleColor[9],
			vehicleColor[10], vehicleColor[11], vehicleColor[12]
		)
	elseif activeColorId == 3 then
		setVehicleColor(vehicleElement,
			vehicleColor[1], vehicleColor[2], vehicleColor[3],
			vehicleColor[4], vehicleColor[5], vehicleColor[6],
			colorInputs.r, colorInputs.g, colorInputs.b,
			vehicleColor[10], vehicleColor[11], vehicleColor[12]
		)
	elseif activeColorId == 4 then
		setVehicleColor(vehicleElement,
			vehicleColor[1], vehicleColor[2], vehicleColor[3],
			vehicleColor[4], vehicleColor[5], vehicleColor[6],
			vehicleColor[7], vehicleColor[8], vehicleColor[9],
			colorInputs.r, colorInputs.g, colorInputs.b
		)
	elseif activeColorId == 5 then
		setVehicleHeadLightColor(vehicleElement, colorInputs.r, colorInputs.g, colorInputs.b)
	elseif activeColorId == 6 then
		exports.see_spinner:setPreviewColor(vehicleElement, colorInputs.r, colorInputs.g, colorInputs.b)
	end
end

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if colorPicker then
			if key == "mouse1" then
				if press then
					local cursorX, cursorY = getCursorPosition()

					if cursorX >= panelPosX + 2 and cursorY >= panelPosY + 2 and cursorX <= panelPosX + 2 + panelWidth - 4 and cursorY <= panelPosY + 2 + panelHeight - respc(44) then
						isColorPicking = true
					end

					if cursorX >= panelPosX + respc(10) and cursorY >= panelPosY + panelHeight - respc(30) and cursorX <= panelPosX + respc(10) + respc(344) and cursorY <= panelPosY + panelHeight - respc(30) + respc(20) then
						isLuminancePicking = true
					end
				else
					isColorPicking = false
					isLuminancePicking = false
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if colorPicker then
			local cursorX, cursorY = getCursorPosition()

			panelWidth = respc(400)
			panelHeight = respc(240)

			panelPosX = menuPosX
			panelPosY = menuPosY + menuHeight

			-- ** Háttér
			dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight + respc(40), tocolor(0, 0, 0, 125))

			-- ** Keret
			dxDrawRectangle(panelPosX, panelPosY, panelWidth, 2, tocolor(0, 0, 0, 200))
			dxDrawRectangle(panelPosX, panelPosY + panelHeight + respc(40) - 2, panelWidth, 2, tocolor(0, 0, 0, 200))
			dxDrawRectangle(panelPosX, panelPosY + 2, 2, panelHeight + respc(40) - 4, tocolor(0, 0, 0, 200))
			dxDrawRectangle(panelPosX + panelWidth - 2, panelPosY + 2, 2, panelHeight + respc(40) - 4, tocolor(0, 0, 0, 200))

			-- ** Content
			dxDrawImage(panelPosX + 2, panelPosY + 2, panelWidth - 4, panelHeight - respc(44), "files/colorpicker.png")

			if isColorPicking then
				local moveX = cursorX
				local moveY = cursorY

				if moveX < panelPosX + 2 then
					moveX = panelPosX + 2
				else
					if moveX > panelPosX + 2 + panelWidth - 4 then
						moveX = panelPosX + 2 + panelWidth - 4
					end
				end

				if moveY < panelPosY + 2 then
					moveY = panelPosY + 2
				else
					if moveY > panelPosY + 2 + panelHeight - respc(44) then
						moveY = panelPosY + 2 + panelHeight - respc(44)
					end
				end

				hue = reMap(moveX - (panelPosX + 2), 0, panelWidth - 4, 0, 1)
				saturation = reMap(moveY - (panelPosY + 2), 0, panelHeight - respc(44), 1, 0)
				colorX, colorY = moveX, moveY

				updateColorPicker(true)
				processColorPicker()
			end

			dxDrawImage(panelPosX + panelWidth - respc(36), panelPosY + panelHeight - respc(36), respc(32), respc(32), "files/light.png")
			dxDrawRectangle(panelPosX + respc(10), panelPosY + panelHeight - respc(30), respc(344), respc(20), tocolor(255, 255, 255))
			
			for i = 0, respc(344) do
				local r, g, b = convertHSLToRGB(hue, saturation, i / respc(344))

				dxDrawRectangle(panelPosX + respc(10) + i, panelPosY + panelHeight - respc(30), 1, respc(20), tocolor(r, g, b))
			end

			dxDrawImage(panelPosX + respc(10), panelPosY + panelHeight - respc(30), respc(172), respc(20), "files/luminance.png", 0, 0, 0, tocolor(r, g, b))
			dxDrawImage(panelPosX + respc(10) + respc(172), panelPosY + panelHeight - respc(30), respc(172), respc(20), "files/luminance2.png", 0, 0, 0, tocolor(r, g, b))
			
			local r, g, b = convertHSLToRGB(hue, saturation, 0.5)

			if not colorX then
				colorX = reMap(hue, 0, 1, panelPosX + 2, panelPosX + 2 + panelWidth - 4)
				colorY = reMap(saturation, 0, 1, panelPosY + 2 + panelHeight - respc(44), panelPosY + 2)
			end

			dxDrawRectangle(colorX - respc(5), colorY - respc(5), respc(10), respc(10), tocolor(0, 0, 0))
			dxDrawRectangle(colorX - respc(4), colorY - respc(4), respc(8), respc(8), tocolor(r, g, b))

			local luminanceX = reMap(lightness, 0, 1, 0, respc(344))
			local r, g, b = convertHSLToRGB(hue, saturation, lightness)

			dxDrawRectangle(panelPosX + respc(10) + luminanceX - respc(3), panelPosY + panelHeight - respc(30) - respc(1), respc(6), respc(22), tocolor(0, 0, 0))
			dxDrawRectangle(panelPosX + respc(10) + luminanceX - respc(2), panelPosY + panelHeight - respc(30), respc(4), respc(20), tocolor(r, g, b))
		
			if not colorInputs then
				colorInputs = {}
				colorInputs.r = math.floor(r)
				colorInputs.g = math.floor(g)
				colorInputs.b = math.floor(b)
				colorInputs.hex = convertRGBToHEX(colorInputs.r, colorInputs.g, colorInputs.b)
			end

			if isLuminancePicking then
				local moveX = cursorX

				if moveX < panelPosX + respc(10) then
					moveX = panelPosX + respc(10)
				else
					if moveX > panelPosX + respc(10) + respc(344) then
						moveX = panelPosX + respc(10) + respc(344)
					end
				end

				lightness = reMap(moveX - (panelPosX + respc(10)), 0, respc(344), 0, 1)

				updateColorPicker(true)
				processColorPicker()
			end

			local colorId = tuningContainer[selectedMenu].subMenu[selectionLevel].colorId or tuningContainer[selectedMenu].subMenu[selectedSubMenu].subMenu[selectionLevel].colorId

			if colorId >= 7 then
				--triggerEvent("renderSpeedoForTest", vehicleElement, {r, g, b}, colorId)
				exports.see_hud:renderSpeedoForTest(vehicleElement, {r, g, b}, colorId)
			end

			if colorId ~= activeColorId then
				activeColorId = colorId

				triggerEvent("resetSpeedoColor", vehicleElement)
				
				if not buyingInProgress then
					processColorPicker()
				end
			end

			local hexWidth = dxGetTextWidth(" #FFFFFF ", 1, Roboto)
			local rgbWidth = dxGetTextWidth(" 255 ", 1, Roboto)

			local startX = panelPosX + respc(10)
			local endX = panelPosX + respc(10) + hexWidth

			local startY = panelPosY + panelHeight
			local endY = panelPosY + panelHeight + respc(30)

			-- ** HEX
			if activeColorInput == "hex" then
				dxDrawRectangle(startX - respc(3), startY - respc(3), hexWidth + respc(11), respc(36), tocolor(61, 122, 188, 100))
				
				if getKeyState("mouse1") and (not (cursorX >= startX and cursorY >= startY and cursorX <= endX and cursorY <= endY)) then
					activeColorInput = false
				end
			elseif getKeyState("mouse1") and cursorX >= startX and cursorY >= startY and cursorX <= endX and cursorY <= endY then
				activeColorInput = "hex"
				isLuminancePicking = false
				isColorPicking = false
			end

			dxDrawRectangle(startX, startY, hexWidth + respc(5), respc(30), tocolor(0, 0, 0, 200))
			dxDrawText(colorInputs.hex, startX, startY, endX + respc(5), endY, tocolor(255, 255, 255), 1, Roboto, "center", "center")
			
			-- ** BLUE
			startX = panelPosX + panelWidth - rgbWidth - respc(15)
			endX = panelPosX + panelWidth - respc(10)

			if activeColorInput == "b" then
				dxDrawRectangle(startX - respc(3), startY - respc(3), rgbWidth + respc(11), respc(36), tocolor(61, 122, 188, 100))
				
				if getKeyState("mouse1") and (not (cursorX >= startX and cursorY >= startY and cursorX <= endX and cursorY <= endY)) then
					activeColorInput = false
				end
			elseif getKeyState("mouse1") and cursorX >= startX and cursorY >= startY and cursorX <= endX and cursorY <= endY then
				activeColorInput = "b"
				isLuminancePicking = false
				isColorPicking = false
			end

			dxDrawRectangle(startX, startY, rgbWidth + respc(5), respc(30), tocolor(0, 0, 0, 200))
			dxDrawText(colorInputs.b, startX, startY, endX, endY, tocolor(255, 255, 255), 1, Roboto, "center", "center")
			
			-- ** GREEN
			startX = startX - rgbWidth - respc(10)
			endX = endX - rgbWidth - respc(10)

			if activeColorInput == "g" then
				dxDrawRectangle(startX - respc(3), startY - respc(3), rgbWidth + respc(11), respc(36), tocolor(61, 122, 188, 100))
				
				if getKeyState("mouse1") and (not (cursorX >= startX and cursorY >= startY and cursorX <= endX and cursorY <= endY)) then
					activeColorInput = false
				end
			elseif getKeyState("mouse1") and cursorX >= startX and cursorY >= startY and cursorX <= endX and cursorY <= endY then
				activeColorInput = "g"
				isLuminancePicking = false
				isColorPicking = false
			end

			dxDrawRectangle(startX, startY, rgbWidth + respc(5), respc(30), tocolor(0, 0, 0, 200))
			dxDrawText(colorInputs.g, startX, startY, endX, endY, tocolor(255, 255, 255), 1, Roboto, "center", "center")
			
			-- ** RED
			startX = startX - rgbWidth - respc(10)
			endX = endX - rgbWidth - respc(10)

			if activeColorInput == "r" then
				dxDrawRectangle(startX - respc(3), startY - respc(3), rgbWidth + respc(11), respc(36), tocolor(61, 122, 188, 100))
				
				if getKeyState("mouse1") and (not (cursorX >= startX and cursorY >= startY and cursorX <= endX and cursorY <= endY)) then
					activeColorInput = false
				end
			elseif getKeyState("mouse1") and cursorX >= startX and cursorY >= startY and cursorX <= endX and cursorY <= endY then
				activeColorInput = "r"
				isLuminancePicking = false
				isColorPicking = false
			end

			dxDrawRectangle(startX, startY, rgbWidth + respc(5), respc(30), tocolor(0, 0, 0, 200))
			dxDrawText(colorInputs.r, startX, startY, endX, endY, tocolor(255, 255, 255), 1, Roboto, "center", "center")
			
			-- Title
			endX = endX - rgbWidth - respc(10)

			dxDrawText("RGB: ", 0, startY, endX, endY, tocolor(61, 122, 188), 1, Roboto, "right", "center")
		else
			activeColorId = false
			activeColorInput = false
		end
	end)

addEventHandler("onClientCharacter", getRootElement(),
	function (character)
		if colorPicker then
			character = utf8.upper(character)

			if activeColorInput == "r" or activeColorInput == "g" or activeColorInput == "b" then
				if tonumber(character) then
					if utf8.len(colorInputs[activeColorInput]) < 3 then
						colorInputs[activeColorInput] = tonumber(colorInputs[activeColorInput] .. character)
					end

					colorInputs.hex = convertRGBToHEX(colorInputs.r, colorInputs.g, colorInputs.b)
					hue, saturation, lightness = convertRGBToHSL(colorInputs.r, colorInputs.g, colorInputs.b)
					colorX = false

					processColorPicker()
				end
			elseif activeColorInput == "hex" then
				if utf8.len(colorInputs[activeColorInput]) < 7 then
					if utf8.find("0123456789ABCDEF", character) then
						colorInputs[activeColorInput] = colorInputs[activeColorInput] .. character

						if utf8.len(colorInputs[activeColorInput]) >= 7 then
							local r, g, b = convertHEXToRGB(colorInputs[activeColorInput])

							hue, saturation, lightness = convertRGBToHSL(r, g, b)
							colorX = false

							colorInputs.r = math.floor(r)
							colorInputs.g = math.floor(g)
							colorInputs.b = math.floor(b)

							processColorPicker()
						end
					end
				end
			end
		end
	end)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if colorPicker then
			if activeColorInput and key == "enter" and press then
				activeColorInput = false
			end

			if key == "backspace" and press then
				if activeColorInput == "r" or activeColorInput == "g" or activeColorInput == "b" then
					if utf8.len(colorInputs[activeColorInput]) > 0 then
						colorInputs[activeColorInput] = tonumber(utf8.sub(colorInputs[activeColorInput], 1, -2)) or 0
						colorInputs.hex = convertRGBToHEX(colorInputs.r, colorInputs.g, colorInputs.b)
						hue, saturation, lightness = convertRGBToHSL(colorInputs.r, colorInputs.g, colorInputs.b)
						colorX = false

						processColorPicker()
					end
				elseif activeColorInput == "hex" then
					if utf8.len(colorInputs[activeColorInput]) > 1 then
						colorInputs[activeColorInput] = utf8.sub(colorInputs[activeColorInput], 1, -2)
					end
				end
			end
		end
	end)

function updateColorPicker(renderupdate)
	if renderupdate then
		local r, g, b = convertHSLToRGB(hue, saturation, lightness)

		colorInputs.r = math.floor(r)
		colorInputs.g = math.floor(g)
		colorInputs.b = math.floor(b)
		colorInputs.hex = convertRGBToHEX(colorInputs.r, colorInputs.g, colorInputs.b)
	end
end

function convertHEXToRGB(hex)
	hex = hex:gsub("#", "")
	return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

function convertRGBToHEX(r, g, b, a)
	if (r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255) or (a and (a < 0 or a > 255)) then
		return nil
	end
	
	if a then
		return string.format("#%.2X%.2X%.2X%.2X", r, g, b, a)
	else
		return string.format("#%.2X%.2X%.2X", r, g, b)
	end
end

function convertHSLToRGB(h, s, l)
	local lightnessValue
	
	if l < 0.5 then
		lightnessValue = l * (s + 1)
	else
		lightnessValue = (l + s) - (l * s)
	end
	
	local lightnessValue2 = l * 2 - lightnessValue
	local r = convertHUEtoRGB(lightnessValue2, lightnessValue, h + 1 / 3)
	local g = convertHUEtoRGB(lightnessValue2, lightnessValue, h)
	local b = convertHUEtoRGB(lightnessValue2, lightnessValue, h - 1 / 3)
	
	return r * 255, g * 255, b * 255
end

function convertHUEtoRGB(l, l2, h)
	if h < 0 then
		h = h + 1
	elseif h > 1 then
		h = h - 1
	end

	if h * 6 < 1 then
		return l + (l2 - l) * h * 6
	elseif h * 2 < 1 then
		return l2
	elseif h * 3 < 2 then
		return l + (l2 - l) * (2 / 3 - h) * 6
	else
		return l
	end
end

function convertRGBToHSL(r, g, b)
	r = r / 255
	g = g / 255
	b = b / 255

	local maxValue = math.max(r, g, b)
	local minValue = math.min(r, g, b)
	local h, s, l = 0, 0, (minValue + maxValue) / 2

	if maxValue == minValue then
		h, s = 0, 0
	else
		local different = maxValue - minValue

		if l < 0.5 then
			s = different / (maxValue + minValue)
		else
			s = different / (2 - maxValue - minValue)
		end

		if maxValue == r then
			h = (g - b) / different
			
			if g < b then
				h = h + 6
			end
		elseif maxValue == g then
			h = (b - r) / different + 2
		else
			h = (r - g) / different + 4
		end

		h = h / 6
	end

	return h, s, l
end