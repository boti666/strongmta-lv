local customCarsLightOn = dxCreateTexture("files/vehiclelights_on.png", "dxt3")
--local customCarsLightOff = dxCreateTexture("files/vehiclelights.png", "dxt3")

local customLightShader = dxCreateShader("files/texturechanger.fx")
dxSetShaderValue(customLightShader, "gTexture", customCarsLightOn)

local sennaLight = exports.see_infinity:getVehicleModel("senna")

local customCars = {
	[549] = true,
	[411] = true,
	[503] = true,
	[sennaLight] = true,
	[426] = true,
}

addEventHandler("onClientElementStreamIn", getRootElement(),
	function()
		if getElementType(source) == "vehicle" then
			if customCars[getElementModel(source)] then
				engineApplyShaderToWorldTexture(customLightShader, "vehiclelightson128", source)
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function()
		if getElementType(source) == "vehicle" then
			if customCars[getElementModel(source)] then
				engineRemoveShaderFromWorldTexture(customLightShader, "vehiclelightson128", vehicle)
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("vehicle", getRootElement(), true)) do
			if customCars[getElementModel(v)] then
				engineApplyShaderToWorldTexture(customLightShader, "vehiclelightson128", v)
			end
		end
	end
)
