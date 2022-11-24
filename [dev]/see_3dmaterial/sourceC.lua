function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end

local drawPositions = {
	{
		origin = {1441.45, 2360.1328125, 13},
		position = {0, 0, 0},
		rotation = {1, 0, 0},
		texture = false,
		viewAngle = 0,
		size = {256 / 75, 256 / 75},
		color = tocolor(255, 255, 255)
	}
}

local function recalculateDrawPositions()
	for k = 1, #drawPositions do
		local v = drawPositions[k]

		v.position[1], v.position[2] = rotateAround(v.viewAngle, v.position[1], v.position[2], v.origin[1], v.origin[2])
		v.rotation[1], v.rotation[2] = rotateAround(v.viewAngle, v.rotation[1], v.rotation[2])
	end
end

addCommandHandler("3dmaterial",
	function (commandName)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local rt = dxCreateRenderTarget(256, 64, true)

			dxSetRenderTarget(rt)
			
			dxDrawImage(0, 0, 256, 64, ":see_job_factory/files/sign1.png")

			dxSetRenderTarget()

			local sx, sy = dxGetMaterialSize(rt)
			local pixels = dxConvertPixels(dxGetTexturePixels(rt), "png")

			if isElement(drawPositions[1].texture) then
				destroyElement(drawPositions[1].texture)
			end

			drawPositions[1].texture = dxCreateTexture(pixels)
			--drawPositions[1].origin = {getElementPosition(localPlayer)}
			drawPositions[1].size = {sx / 150, sy / 150}

			destroyElement(rt)
			rt = nil

			recalculateDrawPositions()

			outputConsole("dxDrawMaterialLine3D(" .. 
				table.concat({
					drawPositions[1].position[1], drawPositions[1].position[2], drawPositions[1].origin[3] + drawPositions[1].size[2] / 2,
					drawPositions[1].position[1], drawPositions[1].position[2], drawPositions[1].origin[3] - drawPositions[1].size[2] / 2,
					"TEXTÚRAELEMENT", drawPositions[1].size[1], "tocolor(255, 255, 255)",
					drawPositions[1].position[1] + drawPositions[1].rotation[1],
					drawPositions[1].position[2] + drawPositions[1].rotation[2],
					drawPositions[1].position[3] + drawPositions[1].rotation[3]
				}, ", ") .. ")"
			)
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			for k = 1, #drawPositions do
				local v = drawPositions[k]

				local x, y = rotateAround(v.viewAngle, 1, 0)
				local x2, y2 = rotateAround(v.viewAngle, 0, 1)

				dxDrawLine3D(v.position[1], v.position[2], v.origin[3] - 1, v.position[1], v.position[2], v.origin[3] + 1, tocolor(255, 255, 255), 2) -- segédvonal
				dxDrawLine3D(v.position[1] - x, v.position[2] - y, v.origin[3], v.position[1] + x, v.position[2] + y, v.origin[3], tocolor(255, 255, 255), 2) -- segédvonal
				dxDrawLine3D(v.position[1] - x2, v.position[2] - y2, v.origin[3], v.position[1] + x2, v.position[2] + y2, v.origin[3], tocolor(255, 255, 255), 2) -- segédvonal

				if v.texture then
					dxDrawMaterialLine3D(
						v.position[1], v.position[2], v.origin[3] + v.size[2] / 2,
						v.position[1], v.position[2], v.origin[3] - v.size[2] / 2,
						v.texture,
						v.size[1],
						v.color or -1,
						v.position[1] + v.rotation[1],
						v.position[2] + v.rotation[2],
						v.position[3] + v.rotation[3]
					)
				end
			end
		end
	end)