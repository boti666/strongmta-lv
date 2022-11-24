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

function loadFonts()
	UbutuB = dxCreateFont("files/BebasNeueBold.otf", 30, false)
	BebasNeueRegular = dxCreateFont("files/BebasNeueRegular.otf", 15, false)
	Roboto = dxCreateFont("files/Roboto.ttf", 11, false)
end

loadFonts ()

local loadingStarted = false
local loadingStartTime = false
local loadingLogoGetStart = false
local loadingLogoGetInverse = false
local loadingTime = false
local currLoadingText = false
local loadingTexts = false
local loadingSound = false
local loadingBackground = false

addCommandHandler("asd",
	function ()
		showTheLoadingScreen(math.floor(10000, 15000), {"Adatok betöltése...", "Szinkronizációk folyamatban...", "Belépés Las Venturasba..."})
	end
)

function showTheLoadingScreen(loadTime, texts)
	local currentTick = getTickCount()

	currLoadingText = 1
	loadingTexts = {}

	for i = 1, #texts do
		loadingTexts[i] = {
			texts[i],
			currentTick + loadTime / #texts * (i - 1),
			currentTick + loadTime / #texts * i
		}
	end

	loadingStarted = true
	loadingTime = loadTime 	
	loadingStartTime = currentTick

	loadingBackGround = math.random(1, 6)

	if isElement(loadingSound) then
		destroyElement(loadingSound)
	end

	loadingSound = playSound("files/loading.mp3")

	addEventHandler("onClientRender", getRootElement(), renderTheLoadingScreen)
end

function renderTheLoadingScreen()
	if loadingStarted then 
		local currentTick = getTickCount()
		local progress = (currentTick - loadingStartTime) / loadingTime
		local alphaP = (currentTick - loadingStartTime) / 500
		local sizeP = (currentTick - loadingStartTime) / 500

		local alphaP = interpolateBetween(0, 0, 0, 1, 0, 0, alphaP, "Linear")
		local sizeP = interpolateBetween(1.3, 0, 0, 1, 0, 0, sizeP, "Linear")

		dxDrawImage(0, 0, screenX, screenY, "files/"..loadingBackGround .. ".png", 0, 0, 0, tocolor(255, 255, 255, 255 * alphaP))

		if progress >= 1 then 
			loadingStarted = false
			toggleLoad = true
			loadingStartTime = currentTick
		end

		local progress = interpolateBetween(0, 0, 0, loadingTime, 0, 0, progress, "Linear")

		dxDrawImage(screenX / 2 - respc(50) * sizeP, screenY / 2 - respc(50) * sizeP, respc(100) * sizeP, respc(100) * sizeP, "files/sp2.png", 0, 0, 0, tocolor(0, 0, 0, 120 * alphaP))
		dxDrawImage(screenX / 2 - respc(50) * sizeP, screenY / 2 - respc(50) * sizeP, respc(100) * sizeP, respc(100) * sizeP, "files/sp1.png", -progress / 5, 0, 0, tocolor(255, 255, 255, 255 * alphaP))
		
		if loadingTexts[currLoadingText] then
			if currentTick > loadingTexts[currLoadingText][3] then
				if loadingTexts[currLoadingText + 1] then
					currLoadingText = currLoadingText + 1
				end
			end

			local timediff = loadingTexts[currLoadingText][3] - loadingTexts[currLoadingText][2]
			local progress = loadingTexts[currLoadingText][2] + timediff / 2
			local alpha = 255

			if currentTick >= progress then
				alpha = interpolateBetween(255, 0, 0, 0, 0, 0, (currentTick - progress) / timediff * 2, "Linear")
			else
				alpha = interpolateBetween(0, 0, 0, 255, 0, 0, (currentTick - loadingTexts[currLoadingText][2]) / timediff * 2, "Linear")
			end

			--dxDrawImage(x, y, logoSize, logoSize, "files/images/logo1.png", tocolor(255, 255, 255, alpha))

			dxDrawText(loadingTexts[currLoadingText][1], 0, screenY / 2 + respc(70) * sizeP, screenX, nil, tocolor(200, 200, 200, alpha), 1 * sizeP, Roboto, "center", "center")
		end

	elseif toggleLoad then 
		local currentTick = getTickCount()
		local progress = (currentTick - loadingStartTime) / loadingTime
		local alphaP = (currentTick - loadingStartTime) / 1000
		local sizeP = (currentTick - loadingStartTime) / 1000
		
		local alphaP = interpolateBetween(1, 0, 0, 0, 0, 0, alphaP, "Linear")
		local sizeP = interpolateBetween(1, 0, 0, 1.3, 0, 0, sizeP, "Linear")

		dxDrawImage(0, 0, screenX, screenY, "files/"..loadingBackGround .. ".png", 0, 0, 0, tocolor(255, 255, 255, 255 * alphaP))

		if alphaP == 0 then 
			removeEventHandler("onClientRender", getRootElement(), renderTheLoadingScreen)
		elseif alphaP < 0.8 then
			if isElement(loadingSound) then
				destroyElement(loadingSound)
			end
		end
		
		local progress = interpolateBetween(0, 0, 0, loadingTime, 0, 0, progress, "Linear")

		dxDrawImage(screenX / 2 - respc(50) * sizeP, screenY / 2 - respc(50) * sizeP, respc(100) * sizeP, respc(100) * sizeP, "files/sp2.png", 0, 0, 0, tocolor(0, 0, 0, 120 * alphaP))
		dxDrawImage(screenX / 2 - respc(50) * sizeP, screenY / 2 - respc(50) * sizeP, respc(100) * sizeP, respc(100) * sizeP, "files/sp1.png", -progress / 5, 0, 0, tocolor(255, 255, 255, 255 * alphaP))

	end
end
