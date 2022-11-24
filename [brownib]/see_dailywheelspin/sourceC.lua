addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local txd = engineLoadTXD("files/models/fortunewheel.txd")
		if txd then
			local dff = engineLoadDFF("files/models/fortunewheel.dff")
			if dff then
				engineImportTXD(txd, 1945)
				engineReplaceModel(dff, 1945)
			end
		end
        engineReplaceCOL(engineLoadCOL("files/models/fortunewheel.col"), 1945)
    end
)

addEventHandler("onClientClick", getRootElement(),
    function(button, state, _, _, _, _, _, clickedElement)
        if state == "up" then
            if button == "right" then
                if isElement(clickedElement) then
                    if getElementData(clickedElement, "dailySpinObject") then
                        if getElementData(clickedElement, "dailySpin.inUse") then
                            exports.see_accounts:showInfo("e", "Ezt a szerencsekereket valaki használja már!")
                        elseif (getElementData(localPlayer, "alreadySpinned") and not exports.see_items:playerHasItem(5)) then
                            exports.see_accounts:showInfo("w", "Te ma már pörgettél!")
                        else
                            triggerServerEvent("startDailySpin", localPlayer, clickedElement)
                            setElementData(localPlayer, "alreadySpinned", true)
                        end
                    end
                end
            end
        end
    end
)

local clickerElements = {}
local clickerElementRotations = {}
local wheelRotations = {}

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
    function()
        if getElementModel(source) == 1945 then
            local fortunePosition = {getPositionFromElementOffset(source, 0, -0.35, -0.15)}
            local fortuneRZ = select(3, getElementRotation(source))

            local tx, ty = rotateAround(fortuneRZ, 0, 0.415)

            if isElement(clickerElements[source]) then
                destroyElement(clickerElements[source])
            end

            clickerElements[source] = nil
            clickerElements[source] = createObject(1898, fortunePosition[1] + tx, fortunePosition[2] + ty, fortunePosition[3] + 2.2, 0, 0, rz)

            setElementDoubleSided(clickerElements[source], true)
            setObjectScale(clickerElements[source], 2)
            setElementInterior(clickerElements[source], getElementInterior(source))
            setElementDimension(clickerElements[source], getElementDimension(source))
        end
    end
)

addEventHandler("onClientElementStreamOut", getResourceRootElement(),
    function()
        if clickerElements[source] then
            if isElement(clickerElements[source]) then
                destroyElement(clickerElements[source])
            end

            clickerElements[source] = nil
            clickerElementRotations[source] = nil
            wheelRotations[source] = nil
        end
    end
)

addEventHandler("onClientElementDestroy", getResourceRootElement(),
    function()
        if clickerElements[source] then
            if isElement(clickerElements[source]) then
                destroyElement(clickerElements[source])
            end

            clickerElements[source] = nil
            clickerElementRotations[source] = nil
            wheelRotations[source] = nil
        end
    end
)

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		for element, obj in pairs(clickerElements) do
			if not clickerElementRotations[obj] then
				clickerElementRotations[obj] = 0
			end

			if not wheelRotations[obj] then
				wheelRotations[obj] = 0
			end

			local rx, ry, rz = getElementRotation(element)

			clickerElementRotations[obj] = clickerElementRotations[obj] + math.abs(ry - wheelRotations[obj])
			wheelRotations[obj] = ry

			if clickerElementRotations[obj] > 4 then
				clickerElementRotations[obj] = 0

				local x, y, z = getElementPosition(element)
				local sound = playSound3D(":see_casino/files/wheelf.mp3", x, y, z)

				setElementInterior(sound, getElementInterior(element))
				setElementDimension(sound, getElementDimension(element))
			end

			if clickerElementRotations[obj] > 1 then
				setElementRotation(obj, 0, -(clickerElementRotations[obj] - 1) / 3 * -10, rz)
			end
		end
	end)