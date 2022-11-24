local sirenPoses = {
	[596] = { -- Police LS
		{-0.2, -0.25, 1, 255, 60, 60, 255, 255}, -- tető
		{0.2, -0.25, 1, 10, 50, 255, 255, 255}, -- tető

		{-0.55, -0.4, 1, 255, 60, 60, 255, 255}, -- tető
		{0.55, -0.4, 1, 10, 50, 255, 255, 255}, -- tető

		{0, -0.15, 1, 255, 255, 255, 150, 150}, -- tető
		{-0.4, -0.35, 1, 255, 255, 255, 150, 150}, -- tető
		{0.4, -0.35, 1, 255, 255, 255, 150, 150}, -- tető
	},
	[597] = { -- Police SF
		{-0.2, -0.475, 1, 255, 60, 60, 255, 255}, -- tető
		{0.2, -0.475, 1, 10, 50, 255, 255, 255}, -- tető

		{-0.4, -0.475, 1, 255, 60, 60, 255, 255}, -- tető
		{0.4, -0.475, 1, 10, 50, 255, 255, 255}, -- tető

		{-0.2, 2.55, -0.05, 255, 60, 60, 255, 255}, -- elöl
		{0.2, 2.55, -0.05, 10, 50, 255, 255, 255}, -- elöl

		{-0.75, -2.65, 0.2, 255, 255, 255, 150, 150}, -- hátul
		{0.75, -2.65, 0.2, 255, 255, 255, 150, 150}, -- hátul
	},
	[598] = { -- Police LV
		{-0.3, -0.3, 1, 255, 60, 60, 255, 255}, -- tető
		{0.3, -0.3, 1, 10, 50, 255, 255, 255}, -- tető

		{-0.6, -0.3, 1, 255, 60, 60, 255, 255}, -- tető
		{0.6, -0.3, 1, 10, 50, 255, 255, 255}, -- tető

		{-0.2, 2.65, 0.05, 255, 60, 60, 255, 255}, -- elöl
		{0.2, 2.65, 0.05, 10, 50, 255, 255, 255}, -- elöl
	},
	[599] = { -- Police Ranger
		{-0.5, 0, 1.2, 255, 60, 60, 255, 255}, -- tető
		{0.5, 0, 1.2, 10, 50, 255, 255, 255}, -- tető

		{-0.625, 2.65, -0.15, 255, 60, 60, 255, 255}, -- elöl
		{0.625, 2.65, -0.15, 10, 50, 255, 255, 255}, -- elöl
	},
	[490] = { -- FBI Rancher
		{-0.45, 2.65, 0.15, 10, 50, 255, 255, 255}, -- elöl
		{0.45, 2.65, 0.15, 255, 60, 60, 255, 255}, -- elöl

		{-0.15, 1.2, 0.5, 10, 50, 255, 255, 255}, -- szélvédő
		{0.15, 1.2, 0.5, 255, 60, 60, 255, 255}, -- szélvédő
	},
	[416] = { -- Ambulance
		{-0.6, 0.8, 1.1, 255, 60, 60, 255, 255}, -- tető
		{0, 0.8, 1.1, 255, 60, 60, 255, 255}, -- tető
		{0.6, 0.8, 1.1, 255, 60, 60, 255, 255}, -- tető

		{-0.4, 2.75, 0.05, 255, 60, 60, 255, 255}, -- elöl
		{0.4, 2.75, 0.05, 255, 60, 60, 255, 255}, -- elöl

		{-0.95, -3.75, 1.05, 255, 150, 0, 225, 225}, -- hátul szélen
		{0.95, -3.75, 1.05, 255, 150, 0, 225, 225}, -- hátul szélen

		{0, -3.75, 1.5, 255, 60, 60, 255, 255}, -- hátul fent középen
	},
	[407] = { -- Fire Truck
		
	}
}

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "sirenSound" then
			local sirenSound = getElementData(source, dataName)
			local sirenParams = getVehicleSirenParams(source)

			if sirenSound == 1 then
				if getVehicleSirensOn(source) then
					if sirenParams.Flags.Silent then
						switchTheSiren(source, false, true)
					else
						switchTheSiren(source, false, true)
					end
				else
					switchTheSiren(source, false, false)
				end
			else
				if getVehicleSirensOn(source) then
					if sirenParams.SirenType ~= 1 then
						switchTheSiren(source, true, true)
					else
						setVehicleSirensOn(source, false)
					end
				end
			end
		end
	end)

addEvent("switchTheSiren", true)
addEventHandler("switchTheSiren", getRootElement(),
	function ()
		if isElement(source) then
			local model = getElementModel(source)
			local sirenSound = getElementData(source, "sirenSound")
			local sirenParams = getVehicleSirenParams(source)

			if getVehicleSirensOn(source) then
				if sirenSound == 1 then
					if sirenParams.Flags.Silent then
						setVehicleSirensOn(source, false)
					else
						if sirenParams.SirenType ~= 1 then
							switchTheSiren(source, false, false)
						else
							switchTheSiren(source, false, true)
						end
					end
				else
					setVehicleSirensOn(source, false)
				end
			else
				switchTheSiren(source, true, true)
			end
		end
	end)

function switchTheSiren(vehicle, silent, lights)
	local model = getElementModel(vehicle)

	if sirenPoses[model] then
		addVehicleSirens(vehicle, #sirenPoses[model], lights and math.random(2, 3) or 1, false, false, true, silent)

		for i = 1, #sirenPoses[model] do
			if lights then
				setVehicleSirens(vehicle, i, unpack(sirenPoses[model][i]))
			else
				setVehicleSirens(vehicle, i, 0, 0, 0, 0, 0, 0, 0, 0)
			end
		end

		setVehicleSirensOn(vehicle, true)
	end
end

addCommandHandler("ticket",
	function (sourcePlayer, commandName, targetName, fine, ...)
		local groupId = exports.see_groups:isPlayerHavePermission(sourcePlayer, "jail")

		if groupId or exports.see_groups:isPlayerOfficer(sourcePlayer) then
			fine = tonumber(fine)

			if not (targetName and fine and fine >= 0 and (...)) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Név / ID] [Bírság] [Indok]", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetName)
				local playerX, playerY, playerZ = getElementPosition(sourcePlayer)
				local targetX, targetY, targetZ = getElementPosition(targetPlayer)
				local between = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 3 

				if not between then
					outputChatBox("#d75959[StrongMTA - Ticket]: #ffffffNem vagy a kiválasztott játékos közelében!", sourcePlayer, 0, 0, 0, true)
					return
				end

				if not targetPlayer then
					return
				end

				if fine < 0 or fine > 1000000 then
					outputChatBox("#d75959[StrongMTA - Ticket]: #ffffffA bírság maximum #d759591,000,000 $ #fffffflehet.", sourcePlayer, 0, 0, 0, true)
					return
				end

				local currTime = getRealTime().timestamp
				local reason = table.concat({...}, " ")

				if fine > 0 then
					exports.see_core:takeMoney(targetPlayer, fine, "jailFine")
				end

				local playerName = getElementData(sourcePlayer, "visibleName"):gsub("_", " ")
				local groupPrefix = exports.see_groups:getGroupPrefix(groupId)
				local groupRankName = select(2, exports.see_groups:getPlayerRank(sourcePlayer, groupId))
				local theOfficer = string.format("[%s] %s %s", groupPrefix, groupRankName, playerName)

				outputChatBox("#32b3ef[Ticket]: #ff9600" .. theOfficer .. " #ffffffmegbűntetett téged.", targetPlayer, 0, 0, 0, true)
				outputChatBox("#32b3ef[Ticket]: #ffffffÖsszeg: #ff9600" .. fine .. "$.", targetPlayer, 0, 0, 0, true)
				outputChatBox("#32b3ef[Ticket]: #ffffffOka: #ff9600" .. reason, targetPlayer, 0, 0, 0, true)

				exports.see_groups:sendGroupMessage(groupId, {
					"#32b3ef[Ticket]: #ff9600" .. theOfficer .. " #ffffffmegbűntette #ff9600" .. targetName .. " #ffffffjátékost.",
					"#32b3ef[Ticket]: #ffffffÖsszeg: #ff9600" .. fine .. "$.",
					"#32b3ef[Ticket]: #ffffffOka: #ff9600" .. reason
				})
			end
		end
	end
)