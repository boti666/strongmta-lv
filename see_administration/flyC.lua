local flyingState = false

addCommandHandler("fly",
	function()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if not isPedInVehicle(localPlayer) then
				toggleFly()
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function(dataName)
		if dataName == "flyMode" then
			if getElementData(source, dataName) then
				setElementCollisionsEnabled(source, false)
			else
				setElementCollisionsEnabled(source, true)
			end
		elseif dataName == "acc.adminLevel" and source == localPlayer then
			if getElementData(localPlayer, dataName) == 0 then
				if flyingState then
					toggleFly()
				end
			end
		end
	end)

function toggleFly()
	flyingState = not flyingState

	if flyingState then
		addEventHandler("onClientRender", getRootElement(), flyingRender)
		setElementCollisionsEnabled(localPlayer, false)
		setElementData(localPlayer, "flyMode", true)
	else
		removeEventHandler("onClientRender", getRootElement(), flyingRender)
		setElementCollisionsEnabled(localPlayer, true)
		setElementData(localPlayer, "flyMode", false)
	end
end

function flyingRender()
	if isMTAWindowActive() then
		return
	end

	local x, y, z = getElementPosition(localPlayer)
	local lx, ly = x, y
	local speed = 10

	if getKeyState("lalt") or getKeyState("ralt") then
		speed = 3
	elseif getKeyState("lshift") or getKeyState("rshift") then
		speed = 50
	elseif getKeyState("mouse1") then
		speed = 200
	end

	if getAnalogControlState("forwards") == 1 then
		x, y = rotatePoint(getRotationFromCamera(0), x, y, speed)
	elseif getAnalogControlState("backwards") == 1 then
		x, y = rotatePoint(getRotationFromCamera(180), x, y, speed)
	end

	if getAnalogControlState("left") == 1 then
		x, y = rotatePoint(getRotationFromCamera(-90), x, y, speed)
	elseif getAnalogControlState("right") == 1 then
		x, y = rotatePoint(getRotationFromCamera(90), x, y, speed)
	end

	if getKeyState("space") then
		z = z + 0.1 * speed
	elseif getKeyState("lctrl") or getKeyState("rctrl") then
		z = z - 0.1 * speed
	end

	setElementPosition(localPlayer, x, y, z)

	if lx ~= x or ly ~= y then
		setElementRotation(localPlayer, 0, 0, -math.deg(math.atan2(y - ly, x - lx)) + 90)
	end
end

function rotatePoint(angle, x, y, dist)
	angle = math.rad(angle)
	return x + math.sin(angle) * 0.1 * dist, y + math.cos(angle) * 0.1 * dist
end

function getRotationFromCamera(offset)
	local cameraX, cameraY, _, faceX, faceY = getCameraMatrix()
	local deltaX, deltaY = faceX - cameraX, faceY - cameraY
	local rotation = math.deg(math.atan(deltaY / deltaX))

	if (deltaY >= 0 and deltaX <= 0) or (deltaY <= 0 and deltaX <= 0) then
		rotation = rotation + 180
	end

	return -rotation + 90 + offset
end

local savedMarks = {}

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		local xmlFile = "Player/mark.xml"
		if xmlLoadFile(xmlFile) then 
			for k, v in ipairs(xmlNodeGetChildren(xmlFile)) do
				if not false then 
					savedMarks = {
						tonumber(xmlNodeGetAttribute(v, "x")),
				        tonumber(xmlNodeGetAttribute(v, "y")),
				        tonumber(xmlNodeGetAttribute(v, "z")),
				        tonumber(xmlNodeGetAttribute(v, "interior")),
				        tonumber(xmlNodeGetAttribute(v, "dimension")),
				        false
					}
				end
			end
		end
		xmlUnloadFile(xmlFile)
	end 
)

addCommandHandler("mark",
	function (counter, ...)
		if getElementData(localPlayer, "acc.adminLevel") > 0 then 
			if not ((...) and table.concat({...}, " "):lower()) then 
				outputChatBox("Teleport " .. ((...) and table.concat({...}, " "):lower() and "'" .. ((...) and table.concat({...}, " "):lower()) .. "' " or "") .. "sikeresen mentve.", 0, 255, 0)
			end
		end
	end 
)