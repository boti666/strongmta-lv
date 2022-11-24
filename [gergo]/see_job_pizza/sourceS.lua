local startedJobs = {}

addEvent("requestPizzaJobStart", true)
addEventHandler("requestPizzaJobStart", getRootElement(),
	function ()
		if isElement(source) then
			local currentJob = startedJobs[source]

			if not currentJob then
				local job = {}

				job.recipients = math.random(3, 6)
				job.positions = {}
				job.pizzas = {}
				job.colshapes = {}
				job.delivered = {}

				shuffleTable(deliveryPositions)

				for i = 1, job.recipients do
					local colshapeElement = createColSphere(deliveryPositions[i][1], deliveryPositions[i][2], deliveryPositions[i][3], 1)

					if isElement(colshapeElement) then
						setElementData(colshapeElement, "pizzaCol", {source, i}, false)

						job.pizzas[i] = math.random(#pizzaTypes)
						job.positions[i] = deliveryPositions[i]
						job.colshapes[i] = colshapeElement
					end
				end

				currentJob = job
				startedJobs[source] = currentJob
			else
				if #currentJob.colshapes <= 0 then
					for i = 1, currentJob.recipients do
						if currentJob.positions[i] and not currentJob.delivered[i] then
							local colshapeElement = createColSphere(currentJob.positions[i][1], currentJob.positions[i][2], currentJob.positions[i][3], 1)

							if isElement(colshapeElement) then
								setElementData(colshapeElement, "pizzaCol", {source, i}, false)
								currentJob.colshapes[i] = colshapeElement
							end
						end
					end
				end
			end

			local jobVehicle = getElementData(source, "jobVehicle")

			if isElement(jobVehicle) then
				setElementData(jobVehicle, "pizzaBoyInventory", false)
			end

			triggerClientEvent(source, "onPizzaJobStarted", source, currentJob.recipients, currentJob.positions, currentJob.pizzas)
		end
	end
)

addEvent("pizzaCarryAnimation", true)
addEventHandler("pizzaCarryAnimation", getRootElement(),
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
							if getElementModel(source) == 448 then
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
											outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffElőbb szállj ki a járműből.", thePlayer, 255, 255, 255, true)
											return
										end

										if jobVehicle ~= source then
											outputChatBox("#d75959[StrongMTA - Pizzafutár]: #ffffffEz nem a te robogód.", thePlayer, 255, 255, 255, true)
											return
										end

										local carryingPizza = getElementData(thePlayer, "carryingPizza")

										if carryingPizza then
											local pizzaBoyInventory = getElementData(source, "pizzaBoyInventory") or {}

											if pizzaBoyInventory then
												for i = 1, #carryingPizza do
													local pizzaType = carryingPizza[i]

													if not pizzaBoyInventory[pizzaType] then
														pizzaBoyInventory[pizzaType] = 0
													end

													pizzaBoyInventory[pizzaType] = pizzaBoyInventory[pizzaType] + 1
												end

												setElementData(source, "pizzaBoyInventory", pizzaBoyInventory)
												setElementData(thePlayer, "carryingPizza", false)

												setPedAnimation(thePlayer, "carry", "putdwn", -1, false, false, false, false)
												exports.see_controls:toggleControl(thePlayer, {"jump", "aim_weapon", "fire", "enter_exit", "enter_passenger", "crouch"}, true)
												
												exports.see_chat:localAction(thePlayer, "berakott " .. #carryingPizza .. " darab pizzát a robogóba.")
											end
										else
											setElementData(thePlayer, "usingPizzaBoy", source)
											triggerClientEvent(thePlayer, "openPizzaBoy", source)
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

addEvent("getOutPizza", true)
addEventHandler("getOutPizza", getRootElement(),
	function (pizzaBoyElement, pizzaType)
		if isElement(source) then
			local pizzaBoyInventory = getElementData(pizzaBoyElement, "pizzaBoyInventory") or {}

			if pizzaBoyInventory then
				if pizzaBoyInventory[pizzaType] then
					pizzaBoyInventory[pizzaType] = pizzaBoyInventory[pizzaType] - 1

					if pizzaBoyInventory[pizzaType] <= 0 then
						pizzaBoyInventory[pizzaType] = nil
					end
				end

				setElementData(pizzaBoyElement, "pizzaBoyInventory", pizzaBoyInventory)
				setElementData(source, "carryingPizza", {pizzaType})

				setPedAnimation(source, "carry", "crry_prtial", 0, true, true, false, true)
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
						local colData = getElementData(source, "pizzaCol")

						if colData and colData[1] == thePlayer then
							local carryingPizza = getElementData(thePlayer, "carryingPizza") or {}

							if carryingPizza[1] then
								local orderId = colData[2]

								if carryingPizza[1] == currentJob.pizzas[orderId] then
									local remainingPizzas = 0
									local pizzaBoyElement = getElementData(thePlayer, "usingPizzaBoy")

									if isElement(pizzaBoyElement) then
										local pizzaBoyInventory = getElementData(pizzaBoyElement, "pizzaBoyInventory") or {}

										for k in pairs(pizzaBoyInventory) do
											remainingPizzas = remainingPizzas + 1
										end
									end

									destroyElement(source)

									if remainingPizzas <= 0 then
										startedJobs[thePlayer] = nil
										setElementData(pizzaBoyElement, "pizzaBoyInventory", false)
									else
										currentJob.delivered[orderId] = true
									end

									exports.see_core:giveMoney(thePlayer, 50000, "pizzaDelivered")

									setElementData(thePlayer, "usingPizzaBoy", false)
									setPedAnimation(thePlayer, false)
									setElementFrozen(thePlayer, false)

									triggerClientEvent(thePlayer, "pizzaDeliveredSuccessfully", thePlayer, orderId, remainingPizzas)

									exports.see_hud:showInfobox(thePlayer, "s", "Sikeresen leszállítottad a pizzát és kerestél 25000$-t!")
								else
									exports.see_hud:showInfobox(thePlayer, "e", "Ez a megrendelő nem ilyen pizzát kért!")
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
			for i = 1, #startedJobs[source].colshapes do
				local colshapeElement = startedJobs[source].colshapes[i]

				if isElement(colshapeElement) then
					destroyElement(colshapeElement)
				end
			end

			startedJobs[source].colshapes = {}
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
					for i = 1, #startedJobs[source].colshapes do
						local colshapeElement = startedJobs[source].colshapes[i]

						if isElement(colshapeElement) then
							destroyElement(colshapeElement)
						end
					end

					startedJobs[source].colshapes = {}
				end
			end
		end
	end
)