defaultSettings = {
	characterId = "char.ID",
	vehicleId = "vehicle.dbID",
	objectId = "object.dbID",
	slotLimit = 50,
	width = 10,
	weightLimit = {
		player = 20,
		vehicle = 100,
		object = 60
	},
	slotBoxWidth = 36,
	slotBoxHeight = 36
}

local weightLimits = {}

function getWeightLimit(elementType, element)
	return weightLimits[getElementModel(element)] or defaultSettings.weightLimit[elementType]
end

local trashModels = {
	[1359] = true,
	[1439] = true,
	[1372] = true,
	[1334] = true,
	[1330] = true,
	[1331] = true,
	[1339] = true,
	[1343] = true,
	[1227] = true,
	[1329] = true,
	[1328] = true,
	[2770] = true,
	[1358] = true,
	[1415] = true,
	[3035] = true
}

function isTrashModel(model)
	return trashModels[model]
end