addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("removeWorldObject", source)) do
			local model = getElementData(v, "model")
			local lodModel = getElementData(v, "lodModel")
			local posX = getElementData(v, "posX")
			local posY = getElementData(v, "posY")
			local posZ = getElementData(v, "posZ")
			local interior = getElementData(v, "interior") or 0
			local radius = getElementData(v, "radius")

			removeWorldModel(model, radius, posX, posY, posZ, interior)
			removeWorldModel(lodModel, radius, posX, posY, posZ, interior)
		end
	end)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for k, v in ipairs(getElementsByType("removeWorldObject", source)) do
			local model = getElementData(v, "model")
			local lodModel = getElementData(v, "lodModel")
			local posX = getElementData(v, "posX")
			local posY = getElementData(v, "posY")
			local posZ = getElementData(v, "posZ")
			local interior = getElementData(v, "interior") or 0
			local radius = getElementData(v, "radius")

			restoreWorldModel(model, radius, posX, posY, posZ, interior)
			restoreWorldModel(lodModel, radius, posX, posY, posZ, interior)
		end
	end)