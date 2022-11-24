vehicleDatas = {
	["911turbo"] = {587, "911turbo", "Porsche 911 Turbo S"},
	["senna"] = {502, "senna", "McLaren Senna"},
	["amgone"] = {506, "amgone", "Mercedes Benz AMG One"},
	["roadster"] = {587, "roadster", "Tesla Roadster"},
	["modelx"] = {400, "modelx", "Tesla Model X"},
	["models"] = {566, "models", "Tesla Model S"},
	["charger"] = {560, "charger", "Dodge Charger SRT8 '18"},
	["chiron"] = {415, "chiron", "Bugatti Chiron"},
	--["regera"] = {503, "regera", "Koenigsegg Regera"},
	--["lc500"] = {506, "lc500", "Lexus LC500"}, --ádii..#3383 egyedi protected
	--["jesko"] = {503, "jesko", "Koenigsegg Jesko"},
	["scooby"] = {445, "scooby", "Mystery Scooby Doo"},
	["brabus800"] = {426, "brabus800", "Mercedes-AMG Brabus 800"}, -- Salgó ppzte kocsi #1
	["cls63"] = {560, "cls63", "Mercedes-Benz W223"}, -- Salgó ppzte kocsi #2
	["pontiacgto"] = {566, "pontiacgto", "BMW E90 320d M Sport '10"}, -- Salgó ppzte kocsi #3 | MODELL CSERE VOLT
	["bmwx6m"] = {415, "bmwx6m", "BMW X6M Competition '22"}, -- CsakSimánKrisztián#2525 | pp-zte
	["pb18"] = {506, "pb18", "Audi RS7 C8 '20"}, -- pumpedhot#5647 | pp-zte
	["brownibm5e60"] = {560, "brownibm5e60", "BMW M5 e60 525d"}, -- CSAK IS BROWNIB HASZNALHATJA MEG MARLBORO! MEG BOTIKA MEG GERGO
	["bmwm5touring"] = {400, "bmwm5touring", "BMW M5 Touring"}, -- Drentonkaaa#9783 | pp-zte
	["bmwi8"] = {506, "bmwi8", "BMW i8"}, -- Drentonkaaa#9783 | pp-zte
}

vehDataToId = {}

function getVehicleCustomName(modelName)
	if vehicleDatas[modelName] then
		return vehicleDatas[modelName][3]
	end
end

function getVehicleModel(vehCustomID)
	if vehDataToId[vehCustomID] then
		return vehDataToId[vehCustomID]
	end
end

function GetVehicleDefaultID(ModelID)
	if vehicleDatas[ModelID] then
		return vehicleDatas[ModelID][1]
	end
end

function splitEx(inputstr, sep)
	if not sep then
		sep = "%s"
	end

	local t = {}
	local i = 1

	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end