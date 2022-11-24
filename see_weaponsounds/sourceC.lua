local shootSoundDistance = 75
local explodeSoundDistance = 150

addEventHandler("onClientPlayerWeaponFire", getRootElement(),
	function (weaponId, ammo, ammoInClip)
		local sourceX, sourceY, sourceZ = getElementPosition(source)
		local sourceDimension = getElementDimension(source)

		if weaponId == 31 then
			if ammoInClip == 0 then
				mgReload("sounds/weapon/m4.wav", sourceX, sourceY, sourceZ)
			else
				local soundEffect = playSound3D("sounds/weapon/m4.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)
				end
			end
		elseif weaponId == 22 then
			if ammoInClip == 0 then
				pistolReload("sounds/weapon/pistole.wav", sourceX, sourceY, sourceZ)
			else
				local soundEffect = playSound3D("sounds/weapon/pistole.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)
				end
			end
		elseif weaponId == 24 then
			if ammoInClip == 0 then
				pistolReload("sounds/weapon/deagle.wav", sourceX, sourceY, sourceZ)
			else
				local soundEffect = playSound3D("sounds/weapon/deagle.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)
				end
			end
		elseif weaponId == 25 or weaponId == 26 or weaponId == 27 then
			if weaponId == 25 then
				local soundEffect = playSound3D("sounds/weapon/shotgun.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)
					shotgunReload(sourceX, sourceY, sourceZ)
				end
			else
				local soundEffect = playSound3D("sounds/weapon/shotgun.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)

					local soundEffect2 = playSound3D("sounds/weapon/shotgun_shell.wav", sourceX, sourceY, sourceZ)
					if isElement(soundEffect2) then
						setElementDimension(soundEffect2, sourceDimension)
					end
				end
			end
		elseif weaponId == 28 then
			if ammoInClip == 0 then
				mgReload("sounds/weapon/uzi.wav", sourceX, sourceY, sourceZ)
			else
				local soundEffect = playSound3D("sounds/weapon/uzi.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)
				end
			end
		elseif weaponId == 29 then
			if ammoInClip == 0 then
				mgReload("sounds/weapon/mp5.wav", sourceX, sourceY, sourceZ)
			else
				local soundEffect = playSound3D("sounds/weapon/mp5.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)
				end
			end
		elseif weaponId == 32 then
			if ammoInClip == 0 then
				tec9Reload(sourceX, sourceY, sourceZ)
			else
				local soundEffect = playSound3D("sounds/weapon/tec-9.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)
				end
			end
		elseif weaponId == 30 then
			if ammoInClip == 0 then
				mgReload("sounds/weapon/ak.wav", sourceX, sourceY, sourceZ)
			else
				local soundEffect = playSound3D("sounds/weapon/ak.wav", sourceX, sourceY, sourceZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, shootSoundDistance)
					setElementDimension(soundEffect, sourceDimension)
				end
			end
		elseif weaponId == 33 or weaponId == 34 then
			local soundEffect = playSound3D("sounds/weapon/sniper.wav", sourceX, sourceY, sourceZ)
			if isElement(soundEffect) then
				setSoundMaxDistance(soundEffect, shootSoundDistance)
				setElementDimension(soundEffect, sourceDimension)
			end
		end
	end
)

addEventHandler("onClientExplosion", getRootElement(),
	function (explosionX, explosionY, explosionZ, typeOfExplosion)
		if typeOfExplosion == 0 then
			if not getElementData(source, "snowball") then
				local soundEffect = playSound3D("sounds/explosion/explosion1.wav", explosionX, explosionY, explosionZ)
				if isElement(soundEffect) then
					setSoundMaxDistance(soundEffect, explodeSoundDistance)
					setElementDimension(soundEffect, getElementDimension(localPlayer))
				end
			end
		elseif typeOfExplosion == 4 or typeOfExplosion == 5 or typeOfExplosion == 6 or typeOfExplosion == 7 then
			local soundEffect = playSound3D("sounds/explosion/explosion3.wav", explosionX, explosionY, explosionZ)
			if isElement(soundEffect) then
				setSoundMaxDistance(soundEffect, explodeSoundDistance)
				setElementDimension(soundEffect, getElementDimension(localPlayer))
			end
		end
	end
)

function mgReload(soundPath, posX, posY, posZ)
	local soundEffect = playSound3D(soundPath, posX, posY, posZ)
	local pedDimension = getElementDimension(localPlayer)

	if isElement(soundEffect) then
		setSoundMaxDistance(soundEffect, shootSoundDistance)
		setElementDimension(soundEffect, pedDimension)
		setTimer(
			function ()
				setElementDimension(playSound3D("sounds/reload/mg_clipin.wav", posX, posY, posZ), pedDimension)
			end,
		1250, 1)
	end
end

function tec9Reload(posX, posY, posZ)
	local soundEffect = playSound3D("sounds/weapon/tec-9.wav", posX, posY, posZ)
	local pedDimension = getElementDimension(localPlayer)

	if isElement(soundEffect) then
		setElementDimension(soundEffect, pedDimension)
		setSoundMaxDistance(soundEffect, shootSoundDistance)
		setElementDimension(playSound3D("sounds/reload/mg_clipin.wav", posX, posY, posZ), pedDimension)
	end
end

function pistolReload(soundPath, posX, posY, posZ)
	local soundEffect = playSound3D(soundPath, posX, posY, posZ)
	local pedDimension = getElementDimension(localPlayer)

	if isElement(soundEffect) then
		setSoundMaxDistance(soundEffect, shootSoundDistance)
		setElementDimension(soundEffect, pedDimension)
	end
end

function shotgunReload(posX, posY, posZ)
	setTimer(
		function ()
			local pedDimension = getElementDimension(localPlayer)

			setElementDimension(playSound3D("sounds/reload/shotgun_reload.wav", posX, posY, posZ), pedDimension)
			setElementDimension(playSound3D("sounds/reload/shotgun_shell.wav", posX, posY, posZ), pedDimension)
		end,
	500, 1)
end
