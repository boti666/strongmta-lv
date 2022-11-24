function toggleControl(playerElement, control, enabled)
	if isElement(playerElement) then
		triggerClientEvent(playerElement, "toggleControl", playerElement, control, enabled, getResourceName(sourceResource))
	end
end