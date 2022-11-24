local tazerModel = 2044
local tazers = {}
local effects = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local txd = engineLoadTXD("tazer/files/tazer.txd")
		if txd then
			local dff = engineLoadDFF("tazer/files/tazer.dff")
			if dff then
				engineImportTXD(txd, tazerModel)
				engineReplaceModel(dff, tazerModel)
			end
		end

		setElementData(localPlayer, "tazerState", false)
		setElementData(localPlayer, "tazed", false)
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "tazerState" then
			if isElement(tazers[source]) then
				destroyElement(tazers[source])
			end

			if getElementData(source, dataName) then
				local tazerObject = createObject(tazerModel, 0, 0, 0)

				if isElement(tazerObject) then
					setElementCollisionsEnabled(tazerObject, false)
					setObjectScale(tazerObject, 1)
					setElementInterior(tazerObject, getElementInterior(source))
					setElementDimension(tazerObject, getElementDimension(source))

					exports.see_boneattach:attachElementToBone(tazerObject, source, 12, 0, 0, 0, 0, -90, 0)
					tazers[source] = tazerObject
				end
			end
		end
	end)

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		if tazers[source] then
			if isElement(tazers[source]) then
				destroyElement(tazers[source])
			end

			tazers[source] = nil
		end
	end)

addEvent("playTazerSound", true)
addEventHandler("playTazerSound", getRootElement(),
	function ()
		playSound("tazer/files/noise.mp3", false)
	end)

addEventHandler("onClientPlayerWeaponFire", getRootElement(),
	function (weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ)
		if weapon == 24 and getElementData(source, "tazerState") then
			if getDistanceBetweenPoints3D(startX, startY, startZ, hitX, hitY, hitZ) <= 10 then
				local effect = true

				if not isElement(hitElement) or getElementType(hitElement) ~= "player" or isPedInVehicle(hitElement) then
					hitElement = false
				end

				if isElement(hitElement) then
					if getElementData(hitElement, "tazed") then
						effect = false
					end

					if effect then
						local soundEffect = playSound3D("tazer/files/shock.mp3", startX, startY, startZ)
						if isElement(soundEffect) then
							setElementInterior(soundEffect, getElementInterior(source))
							setElementDimension(soundEffect, getElementDimension(source))
						end
					end
				end

				if effect then
					table.insert(effects, {getTickCount(), source, hitX, hitY, hitZ, hitElement})

					for i = 1, 5, 1 do
						fxAddPunchImpact(hitX, hitY, hitZ, 0, 0, 0)
						fxAddSparks(hitX, hitY, hitZ, 0, 0, 0, 8, 1, 0, 0, 0, true, 3, 1)
					end

					fxAddPunchImpact(startX, startY, startZ, 0, 0, -3)
				end
			end

			if source == localPlayer then
				setElementData(localPlayer, "tazerReloadNeeded", true)
				exports.see_controls:toggleControl({"fire", "vehicle_fire", "action"}, false)
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local now = getTickCount()

		for k = 1, #effects do
			local v = effects[k]

			if v then
				if isElement(v[2]) then
					local x, y, z = getPedBonePosition(v[2], 26)
					local x2, y2, z2 = v[3], v[4], v[5]

					if isElement(v[6]) then
						x2, y2, z2 = getPedBonePosition(v[6], 3)
					end

					local elapsedTime = now - v[1]
					local progress = elapsedTime / 750
					local lx, ly, lz = interpolateBetween(x, y, z, x2, y2, z2, progress, "Linear")

					if elapsedTime >= 2000 then
						lx, ly, lz = interpolateBetween(x2, y2, z2, x, y, z, (elapsedTime - 2000) / 750, "Linear")
					end

					dxDrawLine3D(x, y, z, lx, ly, lz, tocolor(100, 100, 100, 100), 0.5, false)
					dxDrawLine3D(x, y + 0.02, z, lx, ly + 0.02, lz, tocolor(100, 100, 100, 100), 0.5, false)

					if elapsedTime >= 4000 then
						table.remove(effects, k)
					end
				else
					table.remove(effects, k)
				end
			end
		end
	end)