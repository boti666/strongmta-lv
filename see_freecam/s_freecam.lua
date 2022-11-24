function setPlayerFreecamEnabled(player)
	removePedFromVehicle(player)

	return triggerClientEvent(player,"doSetFreecamEnabled", player)
end

function setPlayerFreecamDisabled(player)
	return triggerClientEvent(player,"doSetFreecamDisabled", player)
end

function setPlayerFreecamOption(player, theOption, value)
	return triggerClientEvent(player,"doSetFreecamOption", player, theOption, value)
end

function isPlayerFreecamEnabled(player)
	return getElementData(player,"freecam:state")
end