local color			= 0xff111111
local font			= dxCreateFont("files/font.ttf", 20, true)
local size			= 1.5

local tex_plates    = {}
local raw_shader    = [[
    texture platetex;
    technique TexReplace {
        pass P0 {
            Texture[0] = platetex;
        }
    }
]]


local shader_plateback = dxCreateShader(raw_shader)
dxSetShaderValue(shader_plateback, "platetex", dxCreateTexture("files/plate.png", "dxt5"))
engineApplyShaderToWorldTexture(shader_plateback, "plateback*")



local function getPlateShader(vehicle)
    if tex_plates[vehicle] then
        if isElement(tex_plates[vehicle]) then
            destroyElement(tex_plates[vehicle])
        end
        tex_plates[vehicle] = nil
    end

    local rt = dxCreateRenderTarget(350, 60)

    local plateText = getVehiclePlateText(vehicle)

    local plateSections = {}
    plateText = split(plateText, "-")

    for i = 1, #plateText do
        if utf8.len(plateText[i]) > 0 then
            table.insert(plateSections, plateText[i])
        end
    end
    
    dxSetRenderTarget(rt)
        dxDrawRectangle(0, 0, 350, 60, tocolor(0, 0, 0))
        dxDrawText(table.concat(plateSections, "-") or "", 0, 0, 350, 60, tocolor(255, 255, 255, 255), size, font, "center", "center")
    dxSetRenderTarget()
    
    tex_plates[vehicle] = dxCreateShader(raw_shader)
    dxSetShaderValue(tex_plates[vehicle], "platetex", rt)

    return tex_plates[vehicle]
end



local function onStreamIn(vehicle)
	local shader = getPlateShader(vehicle)
    engineApplyShaderToWorldTexture(shader, "custom_car_plate", vehicle)
end

local function onStreamOut(vehicle)
    if tex_plates[vehicle] then
        engineRemoveShaderFromWorldTexture(tex_plates[vehicle], "custom_car_plate", vehicle)
        if isElement(tex_plates[vehicle]) then
            destroyElement(tex_plates[vehicle])
        end
        tex_plates[vehicle] = nil
    end
end

addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "vehicle" then
		onStreamIn(source)
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    if getElementType(source) == "vehicle" then
		onStreamOut(source)
    end
end)



addEventHandler("onClientResourceStart", resourceRoot, function()
	local vehicles = getElementsByType("vehicle", root, true)
	for i = 1, #vehicles do
		onStreamIn(vehicles[i])
	end
end)

addEventHandler("onClientRestore", root, function(cleared)
    if cleared then
        for vehicle in pairs(tex_plates) do
            tex_plates[vehicle] = getPlateShader(vehicle)
            engineApplyShaderToWorldTexture(tex_plates[vehicle], "custom_car_plate", vehicle)
        end
    end
end)