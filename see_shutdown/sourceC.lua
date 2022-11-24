local screenX, screenY = guiGetScreenSize()
local Roboto = dxCreateFont("files/Roboto.ttf", 22, false, "antialiased")
local shutdownTimer = false

addEvent("shutdownTick", true)
addEventHandler("shutdownTick", getRootElement(),
	function ()
		playSound("files/count.mp3", false)
	end)

addEvent("startShutdown", true)
addEventHandler("startShutdown", getRootElement(),
	function (seconds)
		if isTimer(shutdownTimer) then
			killTimer(shutdownTimer)
		end

		shutdownTimer = setTimer(dummyFunction, seconds * 1000, 1)
	end)

addEvent("stopShutdown", true)
addEventHandler("stopShutdown", getRootElement(),
	function ()
		if isTimer(shutdownTimer) then
			killTimer(shutdownTimer)
		end

		shutdownTimer = false
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if shutdownTimer then
			local timeLeft = getTimerDetails(shutdownTimer)

			dxDrawBorderText("Szerver leállás: " .. secondsToMinutes(math.ceil(timeLeft / 1000)), 0, 5, screenX, screenY, tocolor(215, 89, 89), 1, Roboto, "center", "top")
		end
	end)

function dxDrawBorderText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	text = text:gsub("#......", "")
	dxDrawText(text, x - 1, y - 1, w - 1, h - 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x - 1, y + 1, w - 1, h + 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x + 1, y - 1, w + 1, h - 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end

function dummyFunction()
	shutdownTimer = false
end

function secondsToMinutes(seconds)
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds - math.floor(seconds / 60) * 60)
end