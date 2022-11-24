function showInfobox(el, type, str)
	if isElement(el) then
		triggerClientEvent(el, "showInfobox", el, type, str)
	end
end

addEvent("tiredAnim", true)
addEventHandler("tiredAnim", getRootElement(),
	function (state)
		if isElement(source) and client and client == source then
			if state then
				setPedAnimation(source, "FAT", "idle_tired", -1, true, false, false)
			else
				setPedAnimation(source, false)
			end
		end
	end)

addEvent("setPedFightingStyle", true)
addEventHandler("setPedFightingStyle", getRootElement(),
	function (style)
		if isElement(source) and client and client == source  then
			setPedFightingStyle(source, style)
		end
	end)

addEvent("setPedWalkingStyle", true)
addEventHandler("setPedWalkingStyle", getRootElement(),
	function (style)
		if isElement(source) and client and client == source then
			setPedWalkingStyle(source, style)
		end
	end)

addEvent("kickPlayerCuzScreenSize", true)
addEventHandler("kickPlayerCuzScreenSize", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			kickPlayer(source, "Alacsony képernyőfelbontás! (Minimum 1024x768)")
		end
	end
)
