local startedJobs = {}

addEvent("requestPostmanJobStart", true)
addEventHandler("requestPostmanJobStart", getRootElement(),
	function ()
		if isElement(source) then
			local currentJob = startedJobs[source]

			if not currentJob then
				local job = {}

				job.recipientsNumber = math.random(6, 15)
				job.deliveryPositions = {}
				job.packageTypes = {}
				job.packageIdentifiers = {}
				job.deliveredPackages = {}
				job.colShapes = {}

				shuffleTable(deliveryPositions)

				for i = 1, job.recipientsNumber do
					local colshapeElement = createColSphere(deliveryPositions[i][1], deliveryPositions[i][2], deliveryPositions[i][3], 1)

					if isElement(colshapeElement) then
						setElementData(colshapeElement, "postmanCol", {source, i}, false)

						job.packageTypes[i] = math.random(1, 2)
						job.packageIdentifiers[i] = (job.packageTypes[i] == 1 and "L" or "P") .. math.random(100000, 999999)
						job.deliveryPositions[i] = deliveryPositions[i]
						job.colShapes[i] = colshapeElement
					end
				end

				currentJob = job
				startedJobs[source] = currentJob
			else
				if #currentJob.colShapes <= 0 then
					for i = 1, currentJob.recipientsNumber do
						local pedPosition = currentJob.deliveryPositions[i]

						if pedPosition and not currentJob.deliveredPackages[i] then
							local colshapeElement = createColSphere(pedPosition[1], pedPosition[2], pedPosition[3], 1)

							if isElement(colshapeElement) then
								setElementData(colshapeElement, "postmanCol", {source, i}, false)
								currentJob.colShapes[i] = colshapeElement
							end
						end
					end
				end
			end

			local jobVehicle = getElementData(source, "jobVehicle")

			if isElement(jobVehicle) then
				setElementData(jobVehicle, "postCarInventory", false)
			end

			triggerClientEvent(source, "onPostmanJobStarted", source, currentJob.recipientsNumber, currentJob.deliveryPositions, currentJob.packageTypes, currentJob.packageIdentifiers)
		end
	end
)

addEvent("carryAnimation", true)
addEventHandler("carryAnimation", getRootElement(),
	function ()
		if isElement(source) then
			setPedAnimation(source, "carry", "crry_prtial", 0, true, true, false, true)
		end
	end
)

addEventHandler("onElementClicked", getRootElement(),
	function (button, state, thePlayer)
		if button == "right" then
			if state == "up" then
				if isElement(thePlayer) then
					if isElement(source) then
						if getElementType(source) == "vehicle" then
							if getElementModel(source) == 498 then
								if getElementData(thePlayer, "char.Job") == jobID then
									local playerX, playerY, playerZ = getElementPosition(thePlayer)
									local targetX, targetY, targetZ = getElementPosition(source)

									if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 3 then
										local jobVehicle = getElementData(thePlayer, "jobVehicle")

										if getElementData(source, "vehicle.jobID") ~= jobID then
											outputChatBox("#d75959[StrongMTA - Postás]: #ffffffEz nem munkajármű.", thePlayer, 255, 255, 255, true)
											return
										end

										if isPedInVehicle(thePlayer) then
											outputChatBox("#d75959[StrongMTA - Postás]: #ffffffElőbb szállj ki a járművedből.", thePlayer, 255, 255, 255, true)
											return
										end

										if jobVehicle ~= source then
											outputChatBox("#d75959[StrongMTA - Postás]: #ffffffEz nem a te munkajárműved.", thePlayer, 255, 255, 255, true)
											return
										end

										local carryingMail = getElementData(thePlayer, "carryingMail")

										if carryingMail then
											local postCarInventory = getElementData(source, "postCarInventory") or {}

											if postCarInventory then
												for k, v in pairs(carryingMail) do
													postCarInventory[v[2]] = true
												end

												setElementData(source, "postCarInventory", postCarInventory)
												setElementData(thePlayer, "carryingMail", false)

												if #carryingMail == 1 then
													if carryingMail[1][1] == 2 then
														setPedAnimation(thePlayer, "carry", "putdwn", -1, false, false, false, false)
													end

													exports.see_chat:localAction(thePlayer, "berakott egy küldeményt az autóba.")
												else
													setPedAnimation(thePlayer, "carry", "putdwn", -1, false, false, false, false)
													exports.see_controls:toggleControl(thePlayer, {"jump", "aim_weapon", "fire", "enter_exit", "enter_passenger", "crouch"}, true)
													exports.see_chat:localAction(thePlayer, "berakott néhány küldeményt az autóba.")
												end
											end
										else
											setElementData(thePlayer, "usingPostCar", source)
											triggerClientEvent(thePlayer, "openPostCar", source)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
)

addEvent("getOutMail", true)
addEventHandler("getOutMail", getRootElement(),
	function (postCarElement, packageIdentifier, packageType)
		if isElement(source) then
			local postCarInventory = getElementData(postCarElement, "postCarInventory") or {}

			if postCarInventory then
				postCarInventory[packageIdentifier] = nil

				setElementData(postCarElement, "postCarInventory", postCarInventory)
				setElementData(source, "carryingMail", {{packageType, packageIdentifier}})

				if packageType == 2 then
					setPedAnimation(source, "carry", "crry_prtial", 0, true, true, false, true)
				end

				exports.see_controls:toggleControl(thePlayer, {"jump", "aim_weapon", "fire", "enter_exit", "enter_passenger", "crouch"}, false)
			end
		end
	end
)

addEventHandler("onColShapeHit", getRootElement(),
	function (thePlayer, sameDimension)
		if isElement(source) then
			if getElementType(thePlayer) == "player" then
				if sameDimension then
					local currentJob = startedJobs[thePlayer]

					if currentJob then
						local colData = getElementData(source, "postmanCol")

						if colData and colData[1] == thePlayer then
							local carryingMail = getElementData(thePlayer, "carryingMail") or {}

							if carryingMail[1] then
								local deliveryId = colData[2]

								if carryingMail[1][2] == currentJob.packageIdentifiers[deliveryId] then
									local remainingPackages = 0
									local postCarElement = getElementData(thePlayer, "usingPostCar")

									if isElement(postCarElement) then
										local postCarInventory = getElementData(postCarElement, "postCarInventory") or {}

										for k in pairs(postCarInventory) do
											remainingPackages = remainingPackages + 1
										end
									end

									destroyElement(source)

									if remainingPackages <= 0 then
										startedJobs[thePlayer] = nil
										setElementData(postCarElement, "postCarInventory", false)
									else
										currentJob.deliveredPackages[deliveryId] = true
									end

									exports.see_core:giveMoney(thePlayer, 30000, "postDelivered")

									setElementData(thePlayer, "usingPostCar", false)
									setElementFrozen(thePlayer, true)
									setPedAnimation(thePlayer, false)
									setElementFrozen(thePlayer, false)

									triggerClientEvent(thePlayer, "postDeliveredSuccessfully", thePlayer, deliveryId, remainingPackages)

									exports.see_hud:showInfobox(thePlayer, "s", "Sikeresen leszállítottad a küldeményt és kerestél 15000$-t!")
								else
									exports.see_hud:showInfobox(thePlayer, "e", "Ez a küldemény másnak van címezve!")
								end
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if startedJobs[source] then
			for i = 1, #startedJobs[source].colShapes do
				local colshapeElement = startedJobs[source].colShapes[i]

				if isElement(colshapeElement) then
					destroyElement(colshapeElement)
				end
			end

			startedJobs[source].colShapes = {}
		end
	end
)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "char.Job" or dataName == "jobVehicle" then
			local characterJob = getElementData(source, "char.Job")
			local jobVehicle = getElementData(source, "jobVehicle")

			if characterJob ~= jobID or not jobVehicle then
				if startedJobs[source] then
					for i = 1, #startedJobs[source].colShapes do
						local colshapeElement = startedJobs[source].colShapes[i]

						if isElement(colshapeElement) then
							destroyElement(colshapeElement)
						end
					end

					startedJobs[source].colShapes = {}
				end
			end
		end
	end
)