addEvent("killedByShark", true)
addEventHandler("killedByShark", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			if getElementData(source, "loggedIn") then 
				setElementData(source, "customDeath", "megette a cápa")
				setElementHealth(source, 0)
			end
		end
	end
)
