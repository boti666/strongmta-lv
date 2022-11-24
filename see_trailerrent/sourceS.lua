local lastTrailerPlate = 0
local availableTrailers = {
	["445"] = true
}

local availablePositions = {
	{0, 0, 0, 0}

addEvent("rentTheTrailer", true)
addEventHandler("rentTheTrailer", getRootElement(), 
	function ()
		if isElement(source) and client and client == source then 
			local randomPositions = math.random(1, #availablePositions)
			local trailerVehicle = createVehicle(445, randomPositons, 0, 0)
		lastTrailerPlate = lastTrailerPlate + 1
		local trailerPlate = setVehiclePlateText(trailerVehicle, lastTrailetPlate)
		end
	end
)