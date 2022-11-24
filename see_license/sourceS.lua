local licenseVehicles = {}
local licensePeds = {}

addEvent("checkQuizTest", true)
addEventHandler("checkQuizTest", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			local carLicense = getElementData(source, "license.car") or 0

			if carLicense == 0 then
				if exports.see_core:takeMoneyEx(source, 120, "quizTest") then
					triggerClientEvent(source, "checkQuizTest", source, "Y")
				else
					exports.see_accounts:showInfo(source, "e", "Nincs elég pénzed az elméleti vizsga elkezdéséhez.")
					triggerClientEvent(source, "checkQuizTest", source, "N")
				end
			else
				triggerClientEvent(source, "checkQuizTest", source, "N")
			end
		end
	end)

addEvent("checkDrivingTest", true)
addEventHandler("checkDrivingTest", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			local carLicense = getElementData(source, "license.car") or 0

			if carLicense == 1 then
				if exports.see_core:takeMoneyEx(source, 240, "drivingTest") then
					triggerClientEvent(source, "checkDrivingTest", source, "Y")
				else
					exports.see_accounts:showInfo(source, "e", "Nincs elég pénzed a gyakorlati vizsga elkezdéséhez.")
					triggerClientEvent(source, "checkDrivingTest", source, "N")
				end
			else
				triggerClientEvent(source, "checkDrivingTest", source, "N")
			end
		end
	end)

addEvent("createLicenseVehicle", true)
addEventHandler("createLicenseVehicle", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			local carLicense = getElementData(source, "license.car") or 0

			if carLicense == 1 then
				local playerPosX, playerPosY, playerPosZ = getElementPosition(source)
				local playerRotX, playerRotY, playerRotZ = getElementRotation(source)

				local vehicleElement = createVehicle(585, playerPosX, playerPosY, playerPosZ, playerRotX, playerRotY, playerRotZ)
				--setVehicleEngineState(vehicleElement, true)

				if isElement(vehicleElement) then
					local vehicleId = 0

					for k, v in pairs(getElementsByType("vehicle")) do
						if getElementData(v, "licenseVehicleId") then
							vehicleId = vehicleId + 1
						end
					end

					vehicleId = vehicleId + 1

					setElementData(vehicleElement, "noCollide", true)
					setElementAlpha(vehicleElement, 150)

					setTimer(
						function ()
							if isElement(vehicleElement) then
								removeElementData(vehicleElement, "noCollide")
								setElementAlpha(vehicleElement, 255)
							end
						end,
					10000, 1)

					exports.see_tuning:applyHandling(vehicleElement)

					setElementData(vehicleElement, "vehicle.engine", 1)
					setElementData(vehicleElement, "vehicle.lights", 0)
					setElementData(vehicleElement, "vehicle.locked", 0)
					setElementData(vehicleElement, "vehicle.windowState", true)
					setElementData(vehicleElement, "vehicle.fuel", exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(585))
					setElementData(vehicleElement, "licenseVehicleId", vehicleId)

					setVehicleEngineState(vehicleElement, false)
					setVehicleOverrideLights(vehicleElement, 1)
					setVehicleLocked(vehicleElement, false)

					setVehicleColor(vehicleElement, 127, 127, 127, 127, 127, 127)
					setVehicleFuelTankExplodable(vehicleElement, false)
					setVehiclePlateText(vehicleElement, "-EXAM-" .. vehicleId)

					warpPedIntoVehicle(source, vehicleElement)

					local instructorPed = createPed(57, playerPosX, playerPosY, playerPosZ + 10)

					if isElement(instructorPed) then
						setElementData(instructorPed, "visibleName", "Oktató")
						setElementData(instructorPed, "invulnerable", true)
						setElementData(instructorPed, "player.seatBelt", true)
						warpPedIntoVehicle(instructorPed, vehicleElement, 1)
					end

					licenseVehicles[source] = vehicleElement
					licensePeds[source] = instructorPed

					triggerClientEvent(source, "startDrivingTest", source, vehicleElement)
				end
			end
		end
	end)

addEvent("destroyLicenseVehicle", true)
addEventHandler("destroyLicenseVehicle", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			local carLicense = getElementData(source, "license.car") or 0

			removePedFromVehicle(source)

			if isElement(licensePeds[source]) then
				destroyElement(licensePeds[source])
			end

			if isElement(licenseVehicles[source]) then
				destroyElement(licenseVehicles[source])
			end

			licenseVehicles[source] = nil
			licensePeds[source] = nil

			if carLicense == 1 then
				triggerClientEvent(source, "destroyLicenseVehicle", source)
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if licenseVehicles[source] then
			if isElement(licensePeds[source]) then
				destroyElement(licensePeds[source])
			end

			if isElement(licenseVehicles[source]) then
				destroyElement(licenseVehicles[source])
			end

			licenseVehicles[source] = nil
			licensePeds[source] = nil
		end
	end)