function playNotification(typ)
	if typ then
		if typ == "error" then
			playSound("files/error.mp3", false)
		elseif typ == "epanel" then
			playSound("files/epanel.mp3", false)
		end
	end
end

addEvent("playNotification", true)
addEventHandler("playNotification", getRootElement(),
	function (typ)
		if typ then
			playNotification(typ)
		end
	end)