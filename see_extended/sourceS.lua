addEvent("getExtendKeys", true)
addEventHandler("getExtendKeys", getRootElement(),
	function()
		local file = fileOpen("keys.json")

	    if not file then
	        return false
	    end

	    local count = fileGetSize(file)
	    local data = fileRead(file, count)
	    fileClose(file)

	    triggerClientEvent(source, "gotKey", source, fromJSON(data))
	end
)