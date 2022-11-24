local screenSizeX, screenSizeY = guiGetScreenSize()
local renderTargetPoolList = {}

local function getUnusedRenderTarget(sx, sy)
	for k = 1, #renderTargetPoolList do
		local v = renderTargetPoolList[k]

		if v and not v[1] and v[2] == sx and v[3] == sy then
			renderTargetPoolList[k][1] = true
			return v[4]
		end
	end

	local rt = dxCreateRenderTarget(sx, sy)

	if rt then
		table.insert(renderTargetPoolList, {true, sx, sy, rt})
	end

	return rt
end

local function clearPoolList()
	for k = 1, #renderTargetPoolList do
		local v = renderTargetPoolList[k]

		if v and isElement(v[4]) then
			destroyElement(v[4])
		end
	end

	renderTargetPoolList = {}
end

local shaders = {}

local lumTarget = dxCreateRenderTarget(1, 1)
local nextLumSampleTime = 0
local currentFPS = 0

local screenSourceFull = false
local paletteShader = false
local luminanceSource = false
local luminanceTempSource = false
local paletteTexture = false
local screenSourceBloom = false
local brightPassShader = false
local blurHShader = false
local blurVShader = false
local addBlendShader = false
local modulationShader = false
local bloomExtractShader = false
local bloomCombineShader = false
local contrastShader = false
local vignetteTexture = false
local dBlurHShader = false
local dBlurVShader = false

local screenSourceReflect = false
local carPaintShader = false
local carGeneShader = false
local carShatShader = false
local carGrunShader = false
local textureVol = false
local textureCubeVeh = false
local texturegrun = {
	"predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing", "fcr90092body128",
	"hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128", 
	"rctiger92body128", "rhino92texpage256", "petrotr92interior128", "artict1logos", "rumpo92adverts256", "dash92interior128",
	"coach92interior128", "combinetexpage128", "hotdog92body256",
	"raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
	"polmavbody128a", "sparrow92body128", "hunterbody8bit256a", "seasparrow92floats64", 
	"dodo92body8bit256", "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256", 
	"shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256" 
}

local waterShader = false
local textureCubeWater = false
local lastWaterColorPick = 0

local brickWallShader = nil
local grassShader = nil
local roadShader = nil
local road2Shader = nil
local paveDirtyShader = nil
local paveStretchShader = nil
local barkShader = nil
local rockShader = nil
local mudShader = nil
local concreteShader = nil
local sandShader = nil
local detailTextures = {}
local detailSettings = {
	brickWall = {
		texture = "detail22Texture",
		detailScale = 3,
		fadeStart = 60,
		fadeEnd = 100,
		strength = 0.6,
		anisotropy = 1
	},
	grass = {
		texture = "detail58Texture",
		detailScale = 2,
		fadeStart = 60,
		fadeEnd = 100,
		strength = 0.6,
		anisotropy = 1
	},
	road = {
		texture = "detail68Texture",
		detailScale = 1,
		fadeStart = 60,
		fadeEnd = 100,
		strength = 0.6,
		anisotropy = 1
	},
	road2 = {
		texture = "detail63Texture",
		detailScale = 1,
		fadeStart = 90,
		fadeEnd = 100,
		strength = 0.4,
		anisotropy = 1
	},
	paveDirty = {
		texture = "dirtyTexture",
		detailScale = 1,
		fadeStart = 60,
		fadeEnd = 100,
		strength = 0.4,
		anisotropy = 1
	},
	paveStretch = {
		texture = "detail04Texture",
		detailScale = 1,
		fadeStart = 80,
		fadeEnd = 100,
		strength = 0.3,
		anisotropy = 1
	},
	treeBark = {
		texture = "detail29Texture",
		detailScale = 1,
		fadeStart = 80,
		fadeEnd = 100,
		strength = 0.6,
		anisotropy = 1
	},
	rock = {
		texture = "detail55Texture",
		detailScale = 1,
		fadeStart = 80,
		fadeEnd = 100,
		strength = 0.5,
		anisotropy = 1
	},
	mud = {
		texture = "detail35TTexture",
		detailScale = 2,
		fadeStart = 80,
		fadeEnd = 100,
		strength = 0.6,
		anisotropy = 1
	}
}

local fpsScaler = 1
local radialScreenSource = false
local radialMaskTexture = false
local radialBlurShader = false
local ticksSmooth = 10
local tickCountPrev = 0
local FPSValue = 60
local fpsScalerRaw = 0

-- addCommandHandler("ash",
-- 	function (cmd, name, state)
-- 		if state == "off" then
-- 			setActiveShader(name, false)
-- 		else
-- 			if tonumber(state) then
-- 				setActiveShader(name, tonumber(state))
-- 			else
-- 				setActiveShader(name, state)
-- 			end
-- 		end
-- 	end
-- )

local _destroyElement = destroyElement
function destroyElement(element)
	if isElement(element) then
		return _destroyElement(element)
	end
end

function getActiveShader(name)
	if name and shaders[name] then
		return shaders[name]
	end

	return false
end

function setActiveShader(name, state)
	if name == "palette" then
		shaders.palette = state

		if state then
			if not screenSourceFull then
				screenSourceFull = dxCreateScreenSource(screenSizeX, screenSizeY)
			end

			if not paletteShader then
				paletteShader = dxCreateShader("files/shaders/addPalette.fx")
			end

			if not luminanceSource then
				luminanceSource = dxCreateScreenSource(1, 1)
			end

			if not luminanceTempSource then
				luminanceTempSource = dxCreateScreenSource(512, 512)
			end

			destroyElement(paletteTexture)
			paletteTexture = dxCreateTexture("files/palettes/enbpalette" .. state .. ".png")

			if isElement(paletteShader) and isElement(paletteTexture) then
				dxSetShaderValue(paletteShader, "sPaletteTexture", paletteTexture)
			end
		else
			destroyElement(paletteShader)
			destroyElement(luminanceSource)
			destroyElement(paletteTexture)
			destroyElement(luminanceTempSource)

			luminanceTempSource = nil
			paletteShader = nil
			luminanceSource = nil
			paletteTexture = nil

			if not shaders.contrast and not shaders.dof then
				destroyElement(screenSourceFull)
				screenSourceFull = nil
			end

			clearPoolList()
		end
	elseif name == "bloom" then
		shaders.bloom = state

		if state then
			if not screenSourceBloom then
				screenSourceBloom = dxCreateScreenSource(screenSizeX / 2, screenSizeY / 2)
			end

			if not brightPassShader then
				brightPassShader = dxCreateShader("files/shaders/brightPass.fx")
			end

			if not blurHShader then
				blurHShader= dxCreateShader("files/shaders/blurH.fx")
			end

			if not blurVShader then
				blurVShader = dxCreateShader("files/shaders/blurV.fx")
			end

			if not addBlendShader then
				addBlendShader = dxCreateShader("files/shaders/addBlend.fx")
			end

			if shaders.contrast then
				destroyElement(bloomExtractShader)
				destroyElement(bloomCombineShader)

				bloomExtractShader = nil
				bloomCombineShader = nil
			end
		else
			destroyElement(brightPassShader)
			destroyElement(addBlendShader)

			addBlendShader = nil
			brightPassShader = nil

			if not shaders.contrast then
				destroyElement(blurHShader)
				destroyElement(blurVShader)
				destroyElement(screenSourceBloom)

				screenSourceBloom = nil
				blurHShader = nil
				blurVShader = nil
			else
				if not bloomExtractShader then
					bloomExtractShader = dxCreateShader("files/shaders/bloom_extract.fx")
				end

				if not bloomCombineShader then
					bloomCombineShader = dxCreateShader("files/shaders/bloom_combine.fx")
				end
			end

			clearPoolList()
		end
	elseif name == "contrast" then
		shaders.contrast = state

		if state then
			if not screenSourceFull then
				screenSourceFull = dxCreateScreenSource(screenSizeX, screenSizeY)
			end

			if not screenSourceBloom then
				screenSourceBloom = dxCreateScreenSource(screenSizeX / 2, screenSizeY / 2)
			end

			if not modulationShader then
				modulationShader = dxCreateShader("files/shaders/modulation.fx")
			end

			if not blurHShader then
				blurHShader= dxCreateShader("files/shaders/blurH.fx")
			end

			if not blurVShader then
				blurVShader = dxCreateShader("files/shaders/blurV.fx")
			end

			if not bloomExtractShader then
				bloomExtractShader = dxCreateShader("files/shaders/bloom_extract.fx")
			end

			if not bloomCombineShader then
				bloomCombineShader = dxCreateShader("files/shaders/bloom_combine.fx")
			end

			if not contrastShader then
				contrastShader = dxCreateShader("files/shaders/contrast.fx")
			end

			if not vignetteTexture then
				vignetteTexture = dxCreateTexture("files/images/vignette1.dds")
			end
		else
			destroyElement(modulationShader)
			destroyElement(vignetteTexture)
			destroyElement(bloomExtractShader)
			destroyElement(bloomCombineShader)
			destroyElement(contrastShader)

			contrastShader = nil
			bloomCombineShader = nil
			bloomExtractShader = nil
			modulationShader = nil
			vignetteTexture = nil

			if not shaders.bloom then
				destroyElement(blurHShader)
				destroyElement(blurVShader)
				destroyElement(screenSourceBloom)

				screenSourceBloom = nil
				blurHShader = nil
				blurVShader = nil
			end

			if not shaders.palette and not shaders.dof then
				destroyElement(screenSourceFull)
				screenSourceFull = nil
			end

			clearPoolList()
		end
	elseif name == "dof" then
		shaders.dof = state

		if state then
			if not screenSourceFull then
				screenSourceFull = dxCreateScreenSource(screenSizeX, screenSizeY)
			end

			if not dBlurHShader then
				dBlurHShader = dxCreateShader("files/shaders/dBlurH.fx")
			end

			if not dBlurVShader then
				dBlurVShader = dxCreateShader("files/shaders/dBlurV.fx")
			end
		else
			destroyElement(dBlurHShader)
			destroyElement(dBlurVShader)

			dBlurVShader = nil
			dBlurHShader = nil

			if not shaders.palette and not shaders.contrast then
				destroyElement(screenSourceFull)
				screenSourceFull = nil
			end

			clearPoolList()
		end
	elseif name == "vehicle" then
		local currentState = shaders.vehicle

		if currentState then
			if currentState == 1 then
				engineRemoveShaderFromWorldTexture(carPaintShader, "vehiclegrunge256")
				engineRemoveShaderFromWorldTexture(carPaintShader, "?emap*")

				for i = 1, #texturegrun do
					engineRemoveShaderFromWorldTexture(carPaintShader, texturegrun[i])
				end

				destroyElement(carPaintShader)
				destroyElement(textureCubeVeh)

				textureCubeVeh = nil
				carPaintShader = nil
			elseif currentState == 2 or currentState == 3 then
				engineRemoveShaderFromWorldTexture(carGrunShader, "vehiclegrunge256")
				engineRemoveShaderFromWorldTexture(carGrunShader, "?emap*")
				engineRemoveShaderFromWorldTexture(carGeneShader, "vehiclegeneric256")
				engineRemoveShaderFromWorldTexture(carShatShader, "vehicleshatter128")
				engineRemoveShaderFromWorldTexture(carGeneShader, "hotdog92glass128")
				engineRemoveShaderFromWorldTexture(carGeneShader, "okoshko")
				
				for i = 1, #texturegrun do
					engineRemoveShaderFromWorldTexture(carGrunShader, texturegrun[i])
				end

				destroyElement(carGrunShader)
				destroyElement(carGeneShader)
				destroyElement(carShatShader)
				destroyElement(screenSourceReflect)
				screenSourceReflect = nil
				carGrunShader = nil
				carGeneShader = nil
				carShatShader = nil
			end

			if not shaders.water then
				destroyElement(textureVol)
				textureVol = nil
			end
		end

		shaders.vehicle = state

		if state then
			if state == 1 then
				if not carPaintShader then
					carPaintShader = dxCreateShader("files/shaders/car_paint.fx")
				end

				if not textureVol then
					textureVol = dxCreateTexture("files/images/smallnoise3d.dds")
				end

				if not textureCubeVeh then
					textureCubeVeh = dxCreateTexture("files/images/cube_veh256.dds")
				end

				dxSetShaderValue(carPaintShader, "sRandomTexture", textureVol)
				dxSetShaderValue(carPaintShader, "sReflectionTexture", textureCubeVeh)
				engineApplyShaderToWorldTexture(carPaintShader, "vehiclegrunge256")
				engineApplyShaderToWorldTexture(carPaintShader, "?emap*")
				
				for i = 1, #texturegrun do
					engineApplyShaderToWorldTexture(carPaintShader, texturegrun[i])
				end
			elseif state == 2 then
				if not carGeneShader then
					carGeneShader = dxCreateShader("files/shaders/car_refgene.fx", 1, 50, true)
				end

				if not carShatShader then
					carShatShader = dxCreateShader("files/shaders/car_refgene.fx", 1, 50, true)
				end

				if not carGrunShader then
					carGrunShader = dxCreateShader("files/shaders/car_refgrun.fx", 1, 50, false)
				end

				if not screenSourceReflect then
					screenSourceReflect = dxCreateScreenSource(screenSizeX, screenSizeY)
				end

				if not textureVol then
					textureVol = dxCreateTexture("files/images/smallnoise3d.dds")
				end

				dxSetShaderValue(carGrunShader, "sCutoff", 0.16)
				dxSetShaderValue(carGrunShader, "sPower", 2)
				dxSetShaderValue(carGrunShader, "sAdd", 0.5)
				dxSetShaderValue(carGrunShader, "sMul", 1.5)
				dxSetShaderValue(carGrunShader, "sRefFl", 1)
				dxSetShaderValue(carGrunShader, "sRefFlan", 0.25)
				dxSetShaderValue(carGrunShader, "sNorFac", 1.5)
				dxSetShaderValue(carGrunShader, "minusAlpha", 0.6)
				dxSetShaderValue(carGrunShader, "brightnessFactor", 0.1)
				dxSetShaderValue(carGeneShader, "sCutoff", 0.16)
				dxSetShaderValue(carGeneShader, "sPower", 2)
				dxSetShaderValue(carGeneShader, "sAdd", 0.5)
				dxSetShaderValue(carGeneShader, "sMul", 1.5)
				dxSetShaderValue(carGeneShader, "sRefFl", 1)
				dxSetShaderValue(carGeneShader, "sRefFlan", 0.25)
				dxSetShaderValue(carGeneShader, "sNorFac", 1.5)
				dxSetShaderValue(carGeneShader, "brightnessFactor", 0.49)
				dxSetShaderValue(carShatShader, "sCutoff", 0.16)
				dxSetShaderValue(carShatShader, "sPower", 2)
				dxSetShaderValue(carShatShader, "sAdd", 0.5)
				dxSetShaderValue(carShatShader, "sMul", 1.5)
				dxSetShaderValue(carShatShader, "sRefFl", 1)
				dxSetShaderValue(carShatShader, "sRefFlan", 0.25)
				dxSetShaderValue(carShatShader, "sNorFac", 1.5)
				dxSetShaderValue(carShatShader, "brightnessFactor", 0.49)
				dxSetShaderValue(carGrunShader, "dirtTex", 1)
				dxSetShaderValue(carGrunShader, "bumpSize", 0.02)
				dxSetShaderValue(carGrunShader, "bumpSize", 0)
				dxSetShaderValue(carGrunShader, "sProjectedXsize", 0.5)
				dxSetShaderValue(carGrunShader, "sProjectedXvecMul", 1)
				dxSetShaderValue(carGrunShader, "sProjectedXoffset", 0.021)
				dxSetShaderValue(carGrunShader, "sProjectedYsize", 0.5)
				dxSetShaderValue(carGrunShader, "sProjectedYvecMul", 1)
				dxSetShaderValue(carGrunShader, "sProjectedYoffset", -0.22)
				dxSetShaderValue(carGeneShader, "sProjectedXsize", 0.5)
				dxSetShaderValue(carGeneShader, "sProjectedXvecMul", 1)
				dxSetShaderValue(carGeneShader, "sProjectedXoffset", 0.021)
				dxSetShaderValue(carGeneShader, "sProjectedYsize", 0.5)
				dxSetShaderValue(carGeneShader, "sProjectedYvecMul", 1)
				dxSetShaderValue(carGeneShader, "sProjectedYoffset", -0.22)
				dxSetShaderValue(carShatShader, "sProjectedXsize", 0.5)
				dxSetShaderValue(carShatShader, "sProjectedXvecMul", 1)
				dxSetShaderValue(carShatShader, "sProjectedXoffset", 0.021)
				dxSetShaderValue(carShatShader, "sProjectedYsize", 0.5)
				dxSetShaderValue(carShatShader, "sProjectedYvecMul", 1)
				dxSetShaderValue(carShatShader, "sProjectedYoffset", -0.22)
				dxSetShaderValue(carGrunShader, "sRandomTexture", textureVol)
				dxSetShaderValue(carGrunShader, "sReflectionTexture", screenSourceReflect)
				dxSetShaderValue(carGeneShader, "gShatt", 0)
				dxSetShaderValue(carGeneShader, "sRandomTexture", textureVol)
				dxSetShaderValue(carGeneShader, "sReflectionTexture", screenSourceReflect)
				dxSetShaderValue(carShatShader, "gShatt", 1)
				dxSetShaderValue(carShatShader, "sRandomTexture", textureVol)
				dxSetShaderValue(carShatShader, "sReflectionTexture", screenSourceReflect)

				engineApplyShaderToWorldTexture(carGrunShader, "vehiclegrunge256")
				engineApplyShaderToWorldTexture(carGrunShader, "?emap*")
				engineApplyShaderToWorldTexture(carGeneShader, "vehiclegeneric256")
				engineApplyShaderToWorldTexture(carShatShader, "vehicleshatter128")
				engineApplyShaderToWorldTexture(carGeneShader, "hotdog92glass128")
				engineApplyShaderToWorldTexture(carGeneShader, "okoshko")

				for i = 1, #texturegrun do
					engineApplyShaderToWorldTexture(carGrunShader, texturegrun[i])
				end
			elseif state == 3 then
				if not carGeneShader then
					carGeneShader = dxCreateShader("files/shaders/car_refgene.fx", 1, 50, true)
				end

				if not carShatShader then
					carShatShader = dxCreateShader("files/shaders/car_refgene.fx", 1, 50, true)
				end

				if not carGrunShader then
					carGrunShader = dxCreateShader("files/shaders/car_refgrunL.fx", 1, 50, true)
				end

				if not screenSourceReflect then
					screenSourceReflect = dxCreateScreenSource(screenSizeX, screenSizeY)
				end

				if not textureVol then
					textureVol = dxCreateTexture("files/images/smallnoise3d.dds")
				end

				dxSetShaderValue(carGrunShader, "sCutoff", 0.16)
				dxSetShaderValue(carGrunShader, "sPower", 2)
				dxSetShaderValue(carGrunShader, "sAdd", 0.5)
				dxSetShaderValue(carGrunShader, "sMul", 1.5)
				dxSetShaderValue(carGrunShader, "sRefFl", 1)
				dxSetShaderValue(carGrunShader, "sRefFlan", 0.25)
				dxSetShaderValue(carGrunShader, "sNorFac", 1.5)
				dxSetShaderValue(carGrunShader, "minusAlpha", 0.6)
				dxSetShaderValue(carGrunShader, "brightnessFactor", 0.1)
				dxSetShaderValue(carGeneShader, "sCutoff", 0.16)
				dxSetShaderValue(carGeneShader, "sPower", 2)
				dxSetShaderValue(carGeneShader, "sAdd", 0.5)
				dxSetShaderValue(carGeneShader, "sMul", 1.5)
				dxSetShaderValue(carGeneShader, "sRefFl", 1)
				dxSetShaderValue(carGeneShader, "sRefFlan", 0.25)
				dxSetShaderValue(carGeneShader, "sNorFac", 1.5)
				dxSetShaderValue(carGeneShader, "brightnessFactor", 0.245)
				dxSetShaderValue(carShatShader, "sCutoff", 0.16)
				dxSetShaderValue(carShatShader, "sPower", 2)
				dxSetShaderValue(carShatShader, "sAdd", 0.5)
				dxSetShaderValue(carShatShader, "sMul", 1.5)
				dxSetShaderValue(carShatShader, "sRefFl", 1)
				dxSetShaderValue(carShatShader, "sRefFlan", 0.25)
				dxSetShaderValue(carShatShader, "sNorFac", 1.5)
				dxSetShaderValue(carShatShader, "brightnessFactor", 0.49)
				dxSetShaderValue(carGrunShader, "dirtTex", 1)
				dxSetShaderValue(carGrunShader, "bumpSize", 0.02)
				dxSetShaderValue(carGrunShader, "bumpSize", 0)
				dxSetShaderValue(carGrunShader, "sProjectedXsize", 0.5)
				dxSetShaderValue(carGrunShader, "sProjectedXvecMul", 1)
				dxSetShaderValue(carGrunShader, "sProjectedXoffset", 0.021)
				dxSetShaderValue(carGrunShader, "sProjectedYsize", 0.5)
				dxSetShaderValue(carGrunShader, "sProjectedYvecMul", 1)
				dxSetShaderValue(carGrunShader, "sProjectedYoffset", -0.22)
				dxSetShaderValue(carGeneShader, "sProjectedXsize", 0.5)
				dxSetShaderValue(carGeneShader, "sProjectedXvecMul", 1)
				dxSetShaderValue(carGeneShader, "sProjectedXoffset", 0.021)
				dxSetShaderValue(carGeneShader, "sProjectedYsize", 0.5)
				dxSetShaderValue(carGeneShader, "sProjectedYvecMul", 1)
				dxSetShaderValue(carGeneShader, "sProjectedYoffset", -0.22)
				dxSetShaderValue(carShatShader, "sProjectedXsize", 0.5)
				dxSetShaderValue(carShatShader, "sProjectedXvecMul", 1)
				dxSetShaderValue(carShatShader, "sProjectedXoffset", 0.021)
				dxSetShaderValue(carShatShader, "sProjectedYsize", 0.5)
				dxSetShaderValue(carShatShader, "sProjectedYvecMul", 1)
				dxSetShaderValue(carShatShader, "sProjectedYoffset", -0.22)
				dxSetShaderValue(carGrunShader, "sRandomTexture", textureVol)
				dxSetShaderValue(carGrunShader, "sReflectionTexture", screenSourceReflect)
				dxSetShaderValue(carGeneShader, "gShatt", 0)
				dxSetShaderValue(carGeneShader, "sRandomTexture", textureVol)
				dxSetShaderValue(carGeneShader, "sReflectionTexture", screenSourceReflect)
				dxSetShaderValue(carShatShader, "gShatt", 1)
				dxSetShaderValue(carShatShader, "sRandomTexture", textureVol)
				dxSetShaderValue(carShatShader, "sReflectionTexture", screenSourceReflect)

				engineApplyShaderToWorldTexture(carGrunShader, "vehiclegrunge256")
				engineApplyShaderToWorldTexture(carGrunShader, "?emap*")
				engineApplyShaderToWorldTexture(carGeneShader, "vehiclegeneric256")
				engineApplyShaderToWorldTexture(carShatShader, "vehicleshatter128")
				engineApplyShaderToWorldTexture(carGeneShader, "hotdog92glass128")
				engineApplyShaderToWorldTexture(carGeneShader, "okoshko")

				for i = 1, #texturegrun do
					engineApplyShaderToWorldTexture(carGrunShader, texturegrun[i])
				end
			end
		end
	elseif name == "water" then
		local currentState = shaders.water

		if currentState then
			engineRemoveShaderFromWorldTexture(waterShader, "waterclear256")

			destroyElement(waterShader)
			destroyElement(textureCubeWater)

			waterShader = nil
			textureCubeWater = nil

			if not shaders.vehicle then
				destroyElement(textureVol)
				textureVol = nil
			end
		end

		shaders.water = state

		if state then
			if state == 1 then
				if not waterShader then
					waterShader = dxCreateShader("files/shaders/water.fx")
				end

				if not textureVol then
					textureVol = dxCreateTexture("files/images/smallnoise3d.dds")
				end

				if not textureCubeWater then
					textureCubeWater = dxCreateTexture("files/images/cube_env256.dds")
				end

				dxSetShaderValue(waterShader, "sRandomTexture", textureVol)
				dxSetShaderValue(waterShader, "sReflectionTexture", textureCubeWater)

				engineApplyShaderToWorldTexture(waterShader, "waterclear256")
			elseif state == 2 then
				if not waterShader then
					waterShader = dxCreateShader("files/shaders/water_ref.fx")
				end

				if not textureVol then
					textureVol = dxCreateTexture("files/images/smallnoise3d.dds")
				end

				if not textureCubeWater then
					textureCubeWater = dxCreateTexture("files/images/cube_env256.dds")
				end

				dxSetShaderValue(waterShader, "normalMult", 0.55)
				dxSetShaderValue(waterShader, "gBuffAlpha", 0.39)
				dxSetShaderValue(waterShader, "gDepthFactor", 0.035)
				dxSetShaderValue(waterShader, "sRandomTexture", textureVol)
				dxSetShaderValue(waterShader, "sReflectionTexture", textureCubeWater)

				engineApplyShaderToWorldTexture(waterShader, "waterclear256")
			end
		end
	elseif name == "detail" then
		local currentState = shaders.detail

		if currentState then
			destroyElement(brickWallShader)
			destroyElement(grassShader)
			destroyElement(roadShader)
			destroyElement(road2Shader)
			destroyElement(paveDirtyShader)
			destroyElement(paveStretchShader)
			destroyElement(barkShader)
			destroyElement(rockShader)
			destroyElement(mudShader)
			destroyElement(concreteShader)
			destroyElement(sandShader)

			for k, v in pairs(detailTextures) do
				destroyElement(v)
			end

			detailTextures = {}
			brickWallShader = nil
			grassShader = nil
			roadShader = nil
			road2Shader = nil
			paveDirtyShader = nil
			paveStretchShader = nil
			barkShader = nil
			rockShader = nil
			mudShader = nil
			concreteShader = nil
			sandShader = nil
		end

		shaders.detail = state

		if state then
			detailTextures = {
				detail22Texture = dxCreateTexture("files/images/detail22.png", "dxt3"),
				detail58Texture = dxCreateTexture("files/images/detail58.png", "dxt3"),
				detail68Texture = dxCreateTexture("files/images/detail68.png", "dxt1"),
				detail63Texture = dxCreateTexture("files/images/detail63.png", "dxt3"),
				dirtyTexture = dxCreateTexture("files/images/dirty.png", "dxt3"),
				detail04Texture = dxCreateTexture("files/images/detail04.png", "dxt3"),
				detail29Texture = dxCreateTexture("files/images/detail29.png", "dxt3"),
				detail55Texture = dxCreateTexture("files/images/detail55.png", "dxt3"),
				detail35TTexture = dxCreateTexture("files/images/detail35T.png", "dxt3")
			}

			brickWallShader = makeDetailShader("brickWall")

			if brickWallShader then
				grassShader = makeDetailShader("grass")
				roadShader = makeDetailShader("road")
				road2Shader = makeDetailShader("road2")
				paveDirtyShader = makeDetailShader("paveDirty")
				paveStretchShader = makeDetailShader("paveStretch")
				barkShader = makeDetailShader("treeBark")
				rockShader = makeDetailShader("rock")
				mudShader = makeDetailShader("mud")
				concreteShader = makeDetailShader("brickWall")
				sandShader = makeDetailShader("mud")
			end

			engineApplyShaderToWorldTexture(roadShader, "*road*")
			engineApplyShaderToWorldTexture(roadShader, "*tar*")
			engineApplyShaderToWorldTexture(roadShader, "*asphalt*")
			engineApplyShaderToWorldTexture(roadShader, "*freeway*")
			engineApplyShaderToWorldTexture(concreteShader, "*wall*")
			engineApplyShaderToWorldTexture(concreteShader, "*floor*")
			engineApplyShaderToWorldTexture(concreteShader, "*bridge*")
			engineApplyShaderToWorldTexture(concreteShader, "*conc*")
			engineApplyShaderToWorldTexture(concreteShader, "*drain*")
			engineApplyShaderToWorldTexture(paveDirtyShader, "*walk*")
			engineApplyShaderToWorldTexture(paveDirtyShader, "*pave*")
			engineApplyShaderToWorldTexture(paveDirtyShader, "*cross*")
			engineApplyShaderToWorldTexture(mudShader, "*mud*")
			engineApplyShaderToWorldTexture(mudShader, "*dirt*")
			engineApplyShaderToWorldTexture(rockShader, "*rock*")
			engineApplyShaderToWorldTexture(rockShader, "*stone*")
			engineApplyShaderToWorldTexture(grassShader, "*grass*")
			engineApplyShaderToWorldTexture(grassShader, "desertgryard256")
			engineApplyShaderToWorldTexture(sandShader, "*sand*")
			engineApplyShaderToWorldTexture(barkShader, "*leave*")
			engineApplyShaderToWorldTexture(barkShader, "*log*")
			engineApplyShaderToWorldTexture(barkShader, "*bark*")
			engineApplyShaderToWorldTexture(roadShader, "*carpark*")
			engineApplyShaderToWorldTexture(road2Shader, "*hiway*")
			engineApplyShaderToWorldTexture(roadShader, "*junction*")
			engineApplyShaderToWorldTexture(paveStretchShader, "snpedtest*")
			engineApplyShaderToWorldTexture(paveStretchShader, "sidelatino*")
			engineApplyShaderToWorldTexture(paveStretchShader, "sjmhoodlawn41")

			engineRemoveShaderFromWorldTexture(brickWallShader, "tx*")
			engineRemoveShaderFromWorldTexture(brickWallShader, "lod*")
			engineRemoveShaderFromWorldTexture(grassShader, "tx*")
			engineRemoveShaderFromWorldTexture(grassShader, "lod*")
			engineRemoveShaderFromWorldTexture(roadShader, "tx*")
			engineRemoveShaderFromWorldTexture(roadShader, "lod*")
			engineRemoveShaderFromWorldTexture(road2Shader, "tx*")
			engineRemoveShaderFromWorldTexture(road2Shader, "lod*")
			engineRemoveShaderFromWorldTexture(paveDirtyShader, "tx*")
			engineRemoveShaderFromWorldTexture(paveDirtyShader, "lod*")
			engineRemoveShaderFromWorldTexture(paveStretchShader, "tx*")
			engineRemoveShaderFromWorldTexture(paveStretchShader, "lod*")
			engineRemoveShaderFromWorldTexture(barkShader, "tx*")
			engineRemoveShaderFromWorldTexture(barkShader, "lod*")
			engineRemoveShaderFromWorldTexture(rockShader, "tx*")
			engineRemoveShaderFromWorldTexture(rockShader, "lod*")
			engineRemoveShaderFromWorldTexture(mudShader, "tx*")
			engineRemoveShaderFromWorldTexture(mudShader, "lod*")
			engineRemoveShaderFromWorldTexture(sandShader, "tx*")
			engineRemoveShaderFromWorldTexture(sandShader, "lod*")
		end
	elseif name == "radial" then
		local currentState = shaders.radial

		if currentState then
			destroyElement(radialScreenSource)
			destroyElement(radialMaskTexture)
			destroyElement(radialBlurShader)

			radialScreenSource = nil
			radialMaskTexture = nil
			radialBlurShader = nil
		end

		shaders.radial = state

		if state then
			setBlurLevel(0)

			radialScreenSource = dxCreateScreenSource(screenSizeX / 2, screenSizeY / 2)
			radialMaskTexture = dxCreateTexture("files/images/radial_mask.tga", "dxt5")
			radialBlurShader = dxCreateShader("files/shaders/radial_blur.fx")

			dxSetShaderValue(radialBlurShader, "sSceneTexture", radialScreenSource)
			dxSetShaderValue(radialBlurShader, "sRadialMaskTexture", radialMaskTexture)
		end
	end
end

function makeDetailShader(detailType)
	if detailType and detailSettings[detailType] then
		local shader = dxCreateShader("files/shaders/detail.fx", 1, 100)

		if shader then
			dxSetShaderValue(shader, "sDetailTexture", detailTextures[detailSettings[detailType]["texture"]])
			dxSetShaderValue(shader, "sDetailScale", detailSettings[detailType]["detailScale"])
			dxSetShaderValue(shader, "sFadeStart", detailSettings[detailType]["fadeStart"])
			dxSetShaderValue(shader, "sFadeEnd", detailSettings[detailType]["fadeEnd"])
			dxSetShaderValue(shader, "sStrength", detailSettings[detailType]["strength"])
			dxSetShaderValue(shader, "sAnisotropy", detailSettings[detailType]["anisotropy"])
		end

		return shader
	end

	return false
end

addEventHandler("onClientHUDRender", getRootElement(),
	function ()
		if not isPedDead(localPlayer) and (shaders.palette or shaders.bloom or shaders.contrast or shaders.dof or shaders.vehicle or shaders.water or shaders.radial) then
			for k = 1, #renderTargetPoolList do
				local v = renderTargetPoolList[k]

				if v then
					v[1] = false
				end
			end

			if isElement(screenSourceBloom) then
				dxUpdateScreenSource(screenSourceBloom)
			end

			if isElement(screenSourceFull) then
				dxUpdateScreenSource(screenSourceFull)
			end

			if isElement(luminanceTempSource) then
				dxUpdateScreenSource(luminanceTempSource)
			end

			local current1 = screenSourceFull
			local current2 = screenSourceBloom
			local sceneLuminance = lumTarget
			local pixels = false

			if shaders.palette then
				pixels = countLuminanceForPalette(luminanceTempSource, 0.96)
			end

			if shaders.contrast then
				current1 = applyModulation(current1, sceneLuminance, 0.46, 0.7, 0.1, 0.11, 0.58, 4)
				current1 = applyContrast(current1, 0.32, 2.24)
			end

			if shaders.dof then
				current1 = applyGDepthBlurH(current1, 5.2, 0.0012, 0.0016)
				current1 = applyGDepthBlurV(current1, 5.2, 0.0012, 0.0016)
			end

			if shaders.palette then
				current1 = applyPalette(current1, pixels)
			end

			if shaders.bloom or shaders.contrast then
				if shaders.contrast and not shaders.bloom then
					current2 = applyBloomExtract(current2, sceneLuminance, 0.72)
				end

				if shaders.bloom then
					current2 = applyBrightPass(current2, 0.08, 1.6)
				end

				current2 = applyDownsampleSteps(current2, 2)
				current2 = applyGBlurH(current2, 1.68)
				current2 = applyGBlurV(current2, 1.52)

				if shaders.contrast and not shaders.bloom then
					current2 = applyBloomCombine(current2, current1, 0.94, 1.66, 0.94, 0.38)
				end

				if shaders.palette then
					current2 = applyPalette(current2, pixels)
				end
			end

			if shaders.contrast then
				updateLuminanceSource(current1, 51, 27)
			end

			dxSetRenderTarget()

			if shaders.contrast or shaders.palette or shaders.dof then
				dxDrawImage(0, 0, screenSizeX, screenSizeY, current1)
			end

			if shaders.bloom then
				if current2 then
					dxSetShaderValue(addBlendShader, "TEX0", current2)

					if shaders.contrast then
						dxDrawImage(0, 0, screenSizeX, screenSizeY, addBlendShader, 0, 0, 0, tocolor(204, 153, 130, 100))
					else
						dxDrawImage(0, 0, screenSizeX, screenSizeY, addBlendShader, 0, 0, 0, tocolor(204, 153, 130, 160))
					end
				end
			end

			if shaders.contrast then
				dxDrawImage(0, 0, screenSizeX, screenSizeY, vignetteTexture, 0, 0, 0, tocolor(255, 255, 255, 119.85))
			end

			if shaders.vehicle and shaders.vehicle == 2 or shaders.vehicle == 3 then
				if isElement(screenSourceReflect) then
					dxUpdateScreenSource(screenSourceReflect)
				end
			end

			if shaders.water then
				if getTickCount() - lastWaterColorPick > 5000 then
					local r, g, b, a = getWaterColor()

					dxSetShaderValue(waterShader, "sWaterColor", r / 255, g / 255, b / 255, a / 255)

					lastWaterColorPick = getTickCount()
				end
			end

			if shaders.radial then
				local vars = getBlurVars()

				if vars then
					dxSetShaderValue(radialBlurShader, "sLengthScale", vars.lengthScale)
					dxSetShaderValue(radialBlurShader, "sMaskScale", vars.maskScale)
					dxSetShaderValue(radialBlurShader, "sMaskOffset", vars.maskOffset)
					dxSetShaderValue(radialBlurShader, "sVelZoom", vars.velDirForCam[2])
					dxSetShaderValue(radialBlurShader, "sVelDir", vars.velDirForCam[1] * 0.5, -vars.velDirForCam[3] * 0.5)
					dxSetShaderValue(radialBlurShader, "sAmount", vars.amount)

					dxUpdateScreenSource(radialScreenSource, true)
					dxDrawImage(0, 0, screenSizeX, screenSizeY, radialBlurShader)
				end
			end
		end
	end, true, "high"
)

addEventHandler("onClientPreRender", getRootElement(),
	function (timeSlice)
		if shaders.palette then
			currentFPS = (1 / timeSlice) * 1000
		end

		if shaders.radial then
			local tickCount = getTickCount()

			ticks = tickCount - tickCountPrev
			ticks = math.min(ticks, 100)
			tickCountPrev = tickCount

			ticksSmooth = math.lerp(ticksSmooth, 0.025, ticks)
			FPSValue = math.lerp(FPSValue, 0.05, 1000 / ticksSmooth)

			local maxFPSPercent = 100 * FPSValue / 60

			if fpsScalerRaw > 0 and maxFPSPercent < 88 then
				fpsScalerRaw = 0
			end

			if fpsScalerRaw == 0 and maxFPSPercent > 95 then
				fpsScalerRaw = 1
			end

			local dif = fpsScalerRaw - fpsScaler
			local maxDif = ticksSmooth / 1000

			dif = math.clamp(-maxDif, dif, maxDif)
			fpsScaler = fpsScaler + dif
		end
	end
)

function getBlurVars()
	local vehVars = getVehicleSpeedBlurVars()
	local camVars = getCameraRotateBlurVars()

	if camVars and camVars.amount > 0.1 then
		return camVars
	end

	if vehVars then
		return vehVars
	end

	if camVars then
		return camVars
	end

	return false
end

local camMatPrev = matrix({
	{1, 0, 0, 0},
	{0, 1, 0, 0},
	{0, 0, 1, 0},
	{0, 0, 0, 1}
})

function getVehicleSpeedBlurVars()
	local camTarget = getCameraTarget()

    if not camTarget then
    	return false
    end

	local vx, vy, vz = getElementVelocity(camTarget)
	local vehSpeed = math.sqrt(vx * vx + vy * vy + vz * vz)
	local amount = math.unlerpclamped(0.025, vehSpeed, 1.22)

	if amount < 0.001 then
		return false
	end

	local camMat = getRealCameraMatrix()
	local camMatInv = matrix.invert(camMat)

	if not camMatInv then
		camMatInv = matrix.invert(camMatPrev)
	else
		camMatPrev = matrix.copy(camMat)
	end

	local velDir = Vector3D:new(vx, vy, vz)
	velDir:Normalize()
	local velDirForCam = matTransformNormal(camMatInv, {velDir.x, velDir.y, velDir.z})

	local vars = {}
	vars.lengthScale = 1
	vars.maskScale = {1, 1.25}
	vars.maskOffset = {0, 0.1}
	vars.velDirForCam = velDirForCam
	vars.amount = amount
	return vars
end

function getCameraRotateBlurVars()
	local camTarget = getCameraTarget()

	if not camTarget then
		return false
	end

	local obx, oby, obz = getCameraOrbitVelocity()
	local camSpeed = math.sqrt(obx * obx + oby * oby + obz * obz)
	local amount = math.unlerpclamped(4.20, camSpeed, 8.52)

	if getElementType(camTarget) == "vehicle" then
		amount = math.unlerpclamped(8.20, camSpeed, 16.52)
	end

	if amount < 0.001 then
		return
	end

	local velDir = Vector3D:new(-obz, oby, -obx)
	velDir:Normalize()
	local velDirForCam = {velDir.x, velDir.y, velDir.z * 2}

	local vars = {}
	vars.lengthScale = 0.8
	vars.maskScale = {3, 1.25}
	vars.maskOffset = {0, -0.15}
	vars.velDirForCam = velDirForCam
	vars.amount = amount
	return vars
end

local prevOrbitX, prevOrbitY, prevOrbitZ = 0, 0, 0
local prevVel, prevVelX, prevVelY, prevVelZ = 0, 0, 0, 0

function getCameraOrbitVelocity ()
	local x, y, z = getCameraOrbitRotation()
	local vx, vy, vz = x - prevOrbitX, y - prevOrbitY, z - prevOrbitZ
	
	prevOrbitX, prevOrbitY, prevOrbitZ = x, y, z

	vz = vz % 360

	if vz > 180 then
		vz = vz - 360
	end

	local newVel = math.sqrt(vx * vx + vy * vy + vz * vz)
	if prevVel < 0.01 then
		vx, vy, vz = 0, 0, 0
	end
	prevVel = newVel

	local avgX = (prevVelX + vx) * 0.5
	local avgY = (prevVelY + vy) * 0.5
	local avgZ = (prevVelZ + vz) * 0.5

	prevVelX, prevVelY, prevVelZ = vx, vy, vz

	return avgX, avgY, avgZ
end

function getCameraOrbitRotation()
	local px, py, pz = getCameraMatrix()
	local tx, ty, tz = getElementPosition(getCameraTarget() or localPlayer)
	return getRotationFromDirection(tx - px, ty - py, tz - pz)
end

function getRotationFromDirection(dx, dy, dz)
	local rotz = 6.2831853071796 - math.atan2(dx, dy) % 6.2831853071796
 	local rotx = math.atan2(dz, math.sqrt(dx * dx + dy * dy))
 	return math.deg(rotx), 180, -math.deg(rotz)
end

function getRealCameraMatrix()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local fwd = Vector3D:new(lx - px, ly - py, lz - pz)
	local up = Vector3D:new(0, 0, 1)
	
	fwd:Normalize()

	local dot = fwd:Dot(up)

	up = up:AddV(fwd:Mul(-dot))
	up:Normalize()

	local right = fwd:CrossV(up)

	return matrix{{right.x, right.y, right.z, 0}, {fwd.x, fwd.y, fwd.z, 0}, {up.x, up.y, up.z, 0}, {px, py, pz, 1}}
end

function math.lerp(from, alpha, to)
	return from + (to - from) * alpha
end

function math.unlerp(from, pos, to)
	if to == from then
		return 1
	end
	return (pos - from) / (to - from)
end

function math.clamp(low, value, high)
	return math.max(low, math.min(value, high))
end

function math.unlerpclamped(from, pos, to)
	return math.clamp(0, math.unlerp(from, pos, to), 1)
end

function matTransformNormal(mat, vec)
	local offX = vec[1] * mat[1][1] + vec[2] * mat[2][1] + vec[3] * mat[3][1]
	local offY = vec[1] * mat[1][2] + vec[2] * mat[2][2] + vec[3] * mat[3][2]
	local offZ = vec[1] * mat[1][3] + vec[2] * mat[2][3] + vec[3] * mat[3][3]
	return {offX, offY, offZ}
end

function countMedianPixelColor(pixels)
	local r, g, b, a = dxGetPixelColor(pixels, 0, 0)
	return {r / 255, g / 255, b / 255}
end

local lastPixel = {1, 1, 1}

function countLuminanceForPalette(luminance, lerpValue)
	local lerpAdj = lerpValue ^ (25 / currentFPS)
	local mx, my = dxGetMaterialSize(luminance)
	local size = 1

	while (size < mx * 0.5 or size < my * 0.5) do
		size = size * 2
	end

	luminance = applyResize(luminance, size, size)

	while size > 1 do
		size = size * 0.5
		luminance = applyDownsample(luminance, 2)
	end

	local pixelColor = countMedianPixelColor(dxGetTexturePixels(luminance))
	local thisPixel = {
		lerpAngle(pixelColor[1], lastPixel[1], lerpAdj),
		lerpAngle(pixelColor[2], lastPixel[2], lerpAdj),
		lerpAngle(pixelColor[3], lastPixel[3], lerpAdj)
	}

	lastPixel = thisPixel

	return thisPixel
end

function lerpAngle(a1, a2, t)
	if a2 - a1 > math.pi then
		a2 = a2 - 2 * math.pi
	elseif a1 - a2 > math.pi then
		a1 = a1 - 2 * math.pi
	end
	return a1 + (a2 - a1) * t
end

function updateLuminanceSource(current, changeRate, changeAlpha)
	if not current then
		return nil
	end

	changeRate = changeRate or 50

	local mx, my = dxGetMaterialSize(current)
	local size = 1

	while (size < mx * 0.5 or size < my * 0.5) do
		size = size * 2
	end

	current = applyResize(current, size, size)

	while size > 1 do
		size = size * 0.5
		current = applyDownsample(current, 2)
	end

	if getTickCount() > nextLumSampleTime then
		nextLumSampleTime = getTickCount() + changeRate

		dxSetRenderTarget(lumTarget)

		if not current then
			return
		end

		dxDrawImage(0, 0, 1, 1, current, 0, 0, 0, tocolor(255, 255, 255, changeAlpha))
	end

	current = applyResize(lumTarget, 1, 1)

	return lumTarget
end

function applyResize(src, tx, ty)
	if not src then
		return nil
	end

	local newRT = getUnusedRenderTarget(tx, ty)
	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT)
	dxDrawImage(0,  0, tx, ty, src)

	return newRT
end

function applyDownsample(src)
	if not src then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	mx, my = mx * 0.5, my * 0.5

	local newRT = getUnusedRenderTarget(mx, my)
	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT)
	dxDrawImage(0, 0, mx, my, src)

	return newRT
end

function applyPalette(src, lumPixel)
	if not src then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT, true)
	dxSetShaderValue(paletteShader, "sBaseTexture", src)
	dxSetShaderValue(paletteShader, "sLumPixel", lumPixel)
	dxDrawImage(0, 0, mx, my, paletteShader)

	return newRT
end

function applyContrast(src, brightness, contrast)
	if not src then
		return nil
	end

	local mx,my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT)
	dxSetShaderValue(contrastShader, "sBaseTexture", src)
	dxSetShaderValue(contrastShader, "sBrightness", brightness)
	dxSetShaderValue(contrastShader, "sContrast", contrast)
	dxDrawImage(0, 0, mx, my, contrastShader)

	return newRT
end

function applyModulation(src, sceneLuminance, multAmount, mult, add, extraFrom, extraTo, extraMult)
	if not src or not sceneLuminance then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT)
	dxSetShaderValue(modulationShader, "sBaseTexture", src)
	dxSetShaderValue(modulationShader, "sMultAmount", multAmount)
	dxSetShaderValue(modulationShader, "sMult", mult)
	dxSetShaderValue(modulationShader, "sAdd", add)
	dxSetShaderValue(modulationShader, "sLumTexture", sceneLuminance)
	dxSetShaderValue(modulationShader, "sExtraFrom", extraFrom)
	dxSetShaderValue(modulationShader, "sExtraTo", extraTo)
	dxSetShaderValue(modulationShader, "sExtraMult", extraMult)
	dxDrawImage(0, 0, mx, my, modulationShader)

	return newRT
end

function applyBrightPass(src, cutoff, power)
	if not src then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT) 
	dxSetShaderValue(brightPassShader, "TEX0", src)
	dxSetShaderValue(brightPassShader, "CUTOFF", cutoff)
	dxSetShaderValue(brightPassShader, "POWER", power)
	dxDrawImage(0, 0, mx, my, brightPassShader)

	return newRT
end

function applyDownsampleSteps(src, steps)
	if not src then
		return nil
	end

	for i = 1, steps do
		src = applyDownsample(src)
	end

	return src
end

function applyBloomCombine(src, base, bloomIntensity, bloomSaturation, baseIntensity, baseSaturation)
	if not src or not base then
		return nil
	end

	local mx, my = dxGetMaterialSize(base)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT, true) 
	dxSetShaderValue(bloomCombineShader, "sBloomTexture", src)
	dxSetShaderValue(bloomCombineShader, "sBaseTexture", base)
	dxSetShaderValue(bloomCombineShader, "sBloomIntensity", bloomIntensity)
	dxSetShaderValue(bloomCombineShader, "sBloomSaturation", bloomSaturation)
	dxSetShaderValue(bloomCombineShader, "sBaseIntensity", baseIntensity)
	dxSetShaderValue(bloomCombineShader, "sBaseSaturation", baseSaturation)
	dxDrawImage(0, 0, mx, my, bloomCombineShader)

	return newRT
end

function applyBloomExtract(src, sceneLuminance, bloomThreshold)
	if not src or not sceneLuminance then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT, true) 
	dxSetShaderValue(bloomExtractShader, "sBaseTexture", src)
	dxSetShaderValue(bloomExtractShader, "sBloomThreshold", bloomThreshold)
	dxSetShaderValue(bloomExtractShader, "sLumTexture", sceneLuminance)
	dxDrawImage(0, 0, mx, my, bloomExtractShader)

	return newRT
end

function applyGBlurH(src, bloom)
	if not src then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil 
	end

	dxSetRenderTarget(newRT, true) 
	dxSetShaderValue(blurHShader, "tex0", src)
	dxSetShaderValue(blurHShader, "tex0size", mx, my)
	dxSetShaderValue(blurHShader, "bloom", bloom)
	dxDrawImage(0, 0, mx, my, blurHShader)

	return newRT
end

function applyGBlurV(src, bloom)
	if not src then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT, true) 
	dxSetShaderValue(blurVShader, "tex0", src)
	dxSetShaderValue(blurVShader, "tex0size", mx, my)
	dxSetShaderValue(blurVShader, "bloom", bloom)
	dxDrawImage(0, 0, mx, my, blurVShader)

	return newRT
end

function applyGDepthBlurH(src, blurDiv, blur, depthFactor)
	if not src then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT, true) 
	dxSetShaderValue(dBlurHShader, "TEX0", src)
	dxSetShaderValue(dBlurVShader, "gblurFactor", blur)
	dxSetShaderValue(dBlurVShader, "gDepthFactor", depthFactor)
	dxSetShaderValue(dBlurHShader, "blurDiv", blurDiv)
	dxDrawImage(0, 0, mx, my, dBlurHShader)

	return newRT
end

function applyGDepthBlurV(src, blurDiv, blur, depthFactor)
	if not src then
		return nil
	end

	local mx, my = dxGetMaterialSize(src)
	local newRT = getUnusedRenderTarget(mx, my)

	if not newRT then
		return nil
	end

	dxSetRenderTarget(newRT, true) 
	dxSetShaderValue(dBlurVShader, "TEX0", src)
	dxSetShaderValue(dBlurVShader, "gblurFactor", blur)
	dxSetShaderValue(dBlurVShader, "gDepthFactor", depthFactor)
	dxSetShaderValue(dBlurVShader, "blurDiv", blurDiv)
	dxDrawImage(0, 0, mx, my, dBlurVShader)

	return newRT
end

Vector3D = {
	new = function(self, _x, _y, _z)
		local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
		return setmetatable(newVector, { __index = Vector3D })
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Module()
		if mod < 0.00001 then
			self.x, self.y, self.z = 0,0,1
		else
			self.x = self.x / mod
			self.y = self.y / mod
			self.z = self.z / mod
		end
	end,

	Dot = function(self, V)
		return self.x * V.x + self.y * V.y + self.z * V.z
	end,

	Module = function(self)
		return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	end,

	AddV = function(self, V)
		return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
	end,

	SubV = function(self, V)
		return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
	end,

	CrossV = function(self, V)
		return Vector3D:new(self.y * V.z - self.z * V.y,
		                    self.z * V.x - self.x * V.z,
							self.x * V.y - self.y * V.x)
	end,

	Mul = function(self, n)
		return Vector3D:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Vector3D:new(self.x / n, self.y / n, self.z / n)
	end,
}