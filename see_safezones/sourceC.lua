local screenX, screenY = guiGetScreenSize()
local safeZones = {}
local isInColShape = false

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		for k, v in ipairs(availableZones) do 
			safeZones[k] = {}
			if safeZones[k] then 
				safeZones[k].colShape = createColCuboid(v.position[1], v.position[2], v.position[3], v.width, v.depth, v.height)
			end
		end
	end 
)

addEventHandler("onClientColShapeHit", resourceRoot,
	function (source)
		if getElementType(source) == "player" and source == localPlayer then 
			setElementData(source, "invulnerable", true)
			isInColShape = true
			for k, v in pairs(getElementsByType("player")) do 
				setElementCollidableWith(v, localPlayer, false)
			end
		end
	end 
)

addEventHandler("onClientColShapeLeave", resourceRoot,
	function (source)
		if getElementType(source) == "player" and source == localPlayer then 
			setElementData(source, "invulnerable", false)
			isInColShape = false
			for k, v in pairs(getElementsByType("player")) do 
				setElementCollidableWith(v, localPlayer, true)
			end
		end
	end 
)

local Roboto = dxCreateFont(":see_jail/files/Roboto.ttf", 15, false, "antialiased")

function renderText()
	if isInColShape then
		dxDrawRectangle(screenX / 2 - 75, screenY - 128 + 16, 150, 32, tocolor(0, 0, 0, 150))
		dxDrawText("Védett zóna", 0 + 1, screenY - 128 + 1, screenX + 1, screenY - 64 + 1, tocolor(0, 0, 0), 1, Roboto, "center", "center")
		dxDrawText("#d75959Védett zóna", 0, screenY - 128, screenX, screenY - 64, tocolor(255, 255, 255), 1, Roboto, "center", "center", false, false, false, true)
	end
end
addEventHandler("onClientRender", getRootElement(), renderText)