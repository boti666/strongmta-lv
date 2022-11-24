chargerPoints = {
    
}

GetElementModel = getElementModel
function getElementModel(Vehicle)
    local Model = getElementData(Vehicle, "vehicleSpecialMod")
  
    return Model
end

for Key = 1, 10 do
    table.insert(chargerPoints, {362.48245239258 + (Key - 1) * 3.5, 2546.3857421875, 16.5390625, 90})
end

enabledModels = {
    ["roadster"] = true,
    ["modelx"] = true,
    ["models"] = true,
    ["wvid6"] = true,
}

function IsVehicleElectric(Vehicle)
    local Model = getElementData(Vehicle, "vehicleSpecialMod")

    if enabledModels[Model] then
        return true
    end
end

modelOffsets = {
    ["roadster"] = {-1.10, -0.80, -0.17},
    ["modelx"] = {-0.85, -1.91, 0.32},
    ["models"] = {-0.85, -1.96, 0.07},
    ["wvid6"] = {0.85, -1.51, 0.32},
}

function getPositionFromElementOffset(element, x, y, z)
    if element then
        m = getElementMatrix(element)
        return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1], x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2], x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
    end
end