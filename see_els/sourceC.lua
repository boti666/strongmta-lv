local prepared = {}
local rendered = {}

local lights = {}
local coronas = {}

bindKey("o", "down",
	function ()
		local pedveh = getPedOccupiedVehicle(localPlayer)

		if isElement(pedveh) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			if presets[getElementModel(pedveh)] then
				if getElementData(pedveh, "emergencyStrobeLight2") then
					setElementData(pedveh, "emergencyStrobeLight2", false)
				else
					setElementData(pedveh, "emergencyStrobeLight2", true)
				end
			end
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function (deltaTime)
		local now = getTickCount()

		--deltaTime = deltaTime / 150
		--deltaTime = deltaTime * math.random(50, 10000)

		--local deltaTime = math.floor(now / 10000) % 10000
		local deltaTime = math.abs(now % 150) / 150

		for veh in pairs(rendered) do
			if isElement(veh) then
				local light = prepared[veh]
				local vehPosX, vehPosY, vehPosZ = getElementPosition(veh)
				local screenPosX, screenPosY = getScreenFromWorldPosition(vehPosX, vehPosY, vehPosZ, 100)

				if screenPosX and screenPosY then
					--local currentPhase = (now + light.order) % light.duration
					local currentPhase = (now + light.order) % (light.duration * deltaTime)

					for i = 1, #light.lights do
						local data = light.lights[i]

						if currentPhase > data.start and currentPhase < data.stop then
							local lightX, lightY, lightZ = getPositionFromElementOffset(veh, data.x, data.y, data.z)
							local lightDimension = 0.2 * (data.size or 1)

							if not data.noshine and true == false then
								if not lights[veh] then
									lights[veh] = {}
								end

								if not lights[veh][i] then
									local r, g, b = unpack(data.color)
									r, g, b = r / 255, g / 255, b / 255

									if data.rx or data.ry or data.rz then
										local vehRotX, vehRotY, vehRotZ = getElementRotation(veh)
										local angle = data.angle and data.angle / 2 or 70

										vehRotX = vehRotX + (data.rx or 0)
										vehRotY = vehRotY + (data.ry or 0)
										vehRotZ = vehRotZ + (data.rz or 0)
										
										lights[veh][i] = exports.dynamic_lighting:createSpotLight(lightX, lightY, lightZ, r, g, b, 1, vehRotX, vehRotY, vehRotZ, true, 40 * lightDimension, math.rad(angle / 1.5), math.rad(angle), 50 * lightDimension)
									else
										lights[veh][i] = exports.dynamic_lighting:createPointLight(lightX, lightY, lightZ, r, g, b, 1, 50 * lightDimension)
									end
								else
									exports.dynamic_lighting:setLightPosition(lights[veh][i], lightX, lightY, lightZ)

									if data.rx or data.ry or data.rz then
										local vehRotX, vehRotY, vehRotZ = getElementRotation(veh)

										vehRotX = vehRotX + (data.rx or 0)
										vehRotY = vehRotY + (data.ry or 0)
										vehRotZ = vehRotZ + (data.rz or 0)

										exports.dynamic_lighting:setLightDirection(lights[veh][i], vehRotX, vehRotY, vehRotZ, true)
									end
								end
							end

							if not coronas[veh] then
								coronas[veh] = {}
							end

							if not coronas[veh][i] then
								coronas[veh][i] = exports.custom_coronas:createCorona(lightX, lightY, lightZ, lightDimension * 3, data.color[1], data.color[2], data.color[3], 150)
							else
								exports.custom_coronas:setCoronaPosition(coronas[veh][i], lightX, lightY, lightZ)
							end
						else
							if lights[veh] and lights[veh][i] then
								exports.dynamic_lighting:destroyLight(lights[veh][i])
								lights[veh][i] = nil
							end

							if coronas[veh] and coronas[veh][i] then
								exports.custom_coronas:destroyCorona(coronas[veh][i])
								coronas[veh][i] = nil
							end
						end
					end
				end
			else
				if prepared[veh] then
					prepared[veh] = nil
					rendered[veh] = nil

					if lights[veh] then
						for k, v in pairs(lights[veh]) do
							exports.dynamic_lighting:destroyLight(lights[veh][k])
						end
					end

					if coronas[veh] then
						for k, v in pairs(coronas[veh]) do
							exports.custom_coronas:destroyCorona(coronas[veh][k])
						end
					end

					lights[veh] = nil
					coronas[veh] = nil
				end
			end
		end
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("vehicle")) do
			if getElementData(v, "emergencyStrobeLight2") and not prepared[v] then
				local model = getElementModel(v)

				if presets[model] then
					prepared[v] = presets[model]
					prepared[v].order = math.random(0, prepared[v].duration) or 0

					lights[v] = {}
					coronas[v] = {}

					if isElementStreamedIn(v) then
						rendered[v] = true
					end
				end
			end
		end
	end)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		for k, v in pairs(lights) do
			for k2, v2 in pairs(v) do
				exports.dynamic_lighting:destroyLight(v2)
			end
		end

		for k, v in pairs(coronas) do
			for k2, v2 in pairs(v) do
				exports.custom_coronas:destroyCorona(v2)
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "emergencyStrobeLight2" then
			local data = getElementData(source, dataName)

			if data then
				if not prepared[source] then
					local model = getElementModel(source)

					if presets[model] then
						prepared[source] = presets[model]
						prepared[source].order = math.random(0, prepared[source].duration) or 0

						lights[source] = {}
						coronas[source] = {}

						if isElementStreamedIn(source) then
							rendered[source] = true
						end
					end
				end
			elseif oldValue then
				if prepared[source] then
					prepared[source] = nil
					rendered[source] = nil

					if lights[source] then
						for k, v in pairs(lights[source]) do
							exports.dynamic_lighting:destroyLight(lights[source][k])
						end
					end

					if coronas[source] then
						for k, v in pairs(coronas[source]) do
							exports.custom_coronas:destroyCorona(coronas[source][k])
						end
					end

					lights[source] = nil
					coronas[source] = nil
				end
			end
		end
	end)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if prepared[source] then
			rendered[source] = true
		end
	end)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if prepared[source] then
			rendered[source] = nil

			if lights[source] then
				for k, v in pairs(lights[source]) do
					exports.dynamic_lighting:destroyLight(lights[source][k])
				end
			end

			if coronas[source] then
				for k, v in pairs(coronas[source]) do
					exports.custom_coronas:destroyCorona(coronas[source][k])
				end
			end
		end
	end)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if prepared[source] then
			prepared[source] = nil
			rendered[source] = nil

			if lights[source] then
				for k, v in pairs(lights[source]) do
					exports.dynamic_lighting:destroyLight(lights[source][k])
				end
			end

			if coronas[source] then
				for k, v in pairs(coronas[source]) do
					exports.custom_coronas:destroyCorona(coronas[source][k])
				end
			end

			lights[source] = nil
			coronas[source] = nil
		end
	end)