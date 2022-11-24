addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("object", resourceRoot)) do
			local breakable = getElementData(v, "breakable")
			if breakable then
				setObjectBreakable(v, breakable == "true")

				if breakable ~= "true" then
					setElementFrozen(v, true)
				end
			end
		end
	end)

addEventHandler("onClientObjectDamage", getResourceRootElement(),
	function ()
		cancelEvent()
	end)
