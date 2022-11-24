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

function getElementDatabaseId(element)
    if isElement(element) then
        local elementType = getElementType(element)

        if elementType == "player" then
            return getElementData(element, "char.ID")
        elseif elementType == "vehicle" then
            return getElementData(element, "vehicle.dbID")
        elseif elementType == "object" then
            return getElementData(element, "safeId")
        else
            return false
        end
    else
        return false
    end
end

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

taxiPos = {
	[458] = {-0.4, 0.2, 0.79, -5, -6, 0}, -- BMW M4
}

sirenPos = {
	[445] = {-0.4,0.08, 0.78, 0, 0, 0}, -- M5
	[426] = {-0.5,0.08, 0.96, 0, 0, 0}, -- M5
	[540] = {-0.4,0.08, 0.98, 0, 0, 0}, -- M5
	[558] = {-0.48, 0.15, 0.89, -5, -3, 0}, -- BMW M4
	[602] = {-0.4,0.08, 0.80, 0, 0, 0}, -- m4
	[580] = {-0.45,0.02, 0.95, 0, 0, 0}, -- rs4
	[507] = {-0.45,0.02, 0.80, 0, 0, 0}, -- e500
	[400] = {-0.45,0.02, 1.27, 0, 0, 0}, -- SRT8 landstalker
	[458] = {-0.45,-0.22, 0.95, 0, 0, 0}, -- e500
	[550] = {-0.45,0.02, 0.68, 0, 0, 0}, -- e420
	[585] = {-0.45,0.02, 0.95, 0, 0, 0}, -- crown vic
	[547] = {-0.45,0.02, 0.80, 0, 0, 0}, -- gelemb galant
	[421] = {-0.45,0.12, 0.80, 0, 0, 0}, -- 760
	[438] = {-0.40,0.12, 0.80, 0, 0, 0}, -- 438 e39
	[551] = {-0.40,0.15, 1.10, 0, 0, 0}, -- 750 e38
	[529] = {-0.4,0.15, .8, 0, 0, 0}, -- charger srt8
	[541] = {-0.4,0.15, .7, 0, 0, 0}, -- camaro
	[560] = {-0.4,0.08, 1.1, 0, 0, 0}, -- evo
	[516] = {-0.4,0.08, 1, 0, 0, 0}, -- rs7
	[438] = {-0.4,0.08, 1.1, 0, 0, 0}, -- e39
	[494] = {-0.4,0.08, .95, 0, 0, 0}, -- e92
	[566] = {-0.4,0.08, .85, 0, 0, 0}, -- f10
	[489] = {-0.4,0.08, 1.2, 0, 0, 0} -- g65





}