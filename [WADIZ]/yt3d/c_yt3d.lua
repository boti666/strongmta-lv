local minimized
local players = {}
local peds = {}
function addYoutube3D(videoID, x, y, z, int, dim)
	if videoID then
		videoID = tostring(videoID)
		if not videoID:find("youtube.com") then
			return false
		end
			
		videoID = string.match(videoID, "v=(...........)")
	end
	
	ped = createPed(0, x, y, z)
	setElementInterior(ped, int)
	setElementDimension(ped, dim)
	setElementAlpha(ped, 0)
	setElementFrozen(ped, true)
	setElementCollisionsEnabled(ped, false)
	setElementData(ped,"ped >> noName",true)
	
	peds[ped] = videoID
	players[videoID] = {
		posX = x,
		posY = y,
		posZ = z,
		ped = ped,
	}
end

function addBrowser(videoID, player)
	if not player.browser then
		local browser = createBrowser(240, 240, false)
		if browser then
			player.browser = browser
			setBrowserRenderingPaused(browser, true)
			
			addEventHandler("onClientBrowserCreated", browser, function()
				loadBrowserURL(source, "https://www.youtube.com/embed/"..videoID.."?autoplay=1&controls=true&showinfo=0&controls=0&vq=small&start=")
				setBrowserVolume(source, 0)
			end)
		end
	end
end

function removeBrowser(player)
	if isElement(player.browser) then
		destroyElement(player.browser)
		player.browser = nil
	end
end

addEventHandler("onClientElementStreamIn", resourceRoot, function()
	if getElementType(source) == "ped" then
		local videoID = peds[source]
		if videoID then
			local player = players[videoID]
			if player then
				addBrowser(videoID, player)
			end
		end
	end
end)

addEventHandler("onClientElementStreamOut", resourceRoot, function()
	if getElementType(source) == "ped" then
		local videoID = peds[source]
		if videoID then
			local player = players[videoID]
			if player then
				removeBrowser(player)
			end
		end
	end
end)

addEventHandler("onClientRender", root, function()
	if not minimized then
		local x, y, z = getElementPosition(getCamera())
		for k, v in pairs(players) do
			if v.browser and not isBrowserLoading(v.browser) then
				local px, py, pz = getElementPosition(v.ped)
				local dist = getDistanceBetweenPoints3D(x, y, z, px, py, z)
				local newVolume = 1-dist/25
				if newVolume > 0.2 then newVolume = 0.2 end
				if newVolume < 0 then newVolume = 0 end
				setBrowserVolume(v.browser, newVolume / 4)
			end
		end
	end
end)

addEventHandler("onClientMinimize", root, function()
	minimized = true
	for k, v in pairs(players) do
		if v.browser and not isBrowserLoading(v.browser) then
			setBrowserVolume(v.browser, 0)
		end
	end
end)

addEventHandler("onClientRestore", root, function()
	minimized = false
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	local x,y,z = getElementPosition(getPedOccupiedVehicle(getPlayerFromName("Gyozo_Zoltan_Junior")))
	addYoutube3D("https://www.youtube.com/watch?v=7BrUUq1ljuM",x,y,z,getElementInterior(getPedOccupiedVehicle(getPlayerFromName("Gyozo_Zoltan_Junior"))),getElementDimension(getPedOccupiedVehicle(getPlayerFromName("Gyozo_Zoltan_Junior"))))
	addEventHandler("onClientRender", root, function()
		for k, v in pairs(players) do
			if v.browser and not isBrowserLoading(v.browser) then
				local x,y,z = getElementPosition(getPedOccupiedVehicle(getPlayerFromName("Gyozo_Zoltan_Junior")))
				setElementPosition(v.ped,x,y,z)
				setElementInterior(v.ped, getElementInterior(getPedOccupiedVehicle(getPlayerFromName("Gyozo_Zoltan_Junior"))))
				setElementDimension(v.ped, getElementDimension(getPedOccupiedVehicle(getPlayerFromName("Gyozo_Zoltan_Junior"))))
			end
		end
	end)
end)