local screenX, screenY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local Roboto = dxCreateFont("files/opensans_semibold.ttf", respc(16), false, "antialiased")

local panelState = false
local headerHeight = respc(35)
local panelW, panelH = respc(450), respc(300)
local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2


local lastTrailerPlate = 0

addCommandHandler("boto",
	function ()
		setElementData(localPlayer, "boto", true)
	end
)

function renderTheRentPanel()
	if getElementData(localPlayer, "boto") then
		dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(25, 25, 25, 255))
		dxDrawRectangle(panelX, panelY, panelW, headerHeight, tocolor(0, 0, 0, 255))
		dxDrawText("StrongMTA - Utánfutóbérlő", panelX + respc(5), panelY + respc(2), nil, nil, tocolor(200, 200, 200), 1, Roboto, "left", "top")
	end
end
addEventHandler("onClientRender", root, renderTheRentPanel)