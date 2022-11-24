local ghostElements = {}

addEventHandler("onResourceStart", getResourceRootElement(),
    function()
        setTimer(
            function()
                for k, v in ipairs(ghostPositions) do
                    local skins = getValidPedModels()
                    local ghostElement = createPed(skins[math.random(#skins)], v[1], v[2], v[3], v[4])
                    setElementData(ghostElement, "isHalloweenPed", true)
                    setElementData(ghostElement, "halloween.id", k)

                    setElementAlpha(ghostElement, 75)
                    setElementCollisionsEnabled(ghostElement, false)

                    ghostElements[k] = ghostElement
                end
            end,
        1000, 1)

        setTimer(
            function()
                for k, v in ipairs(ghostPositions) do
                    for k, v in ipairs(ghostElements) do
                        if isElement(v) then
                            destroyElement(v)
                        end
                    end

                    ghostElements = {}

                    local ghostElement = createPed(math.random(10, 20), v[1], v[2], v[3], v[4])
                    setElementData(ghostElement, "isHalloweenPed", true)
                    setElementData(ghostElement, "halloween.id", k)

                    setElementAlpha(ghostElement, 75)
                    setElementCollisionsEnabled(ghostElement, false)

                    ghostElements[k] = ghostElement
                end
            end,
        3600000, 0)
    end
)

addEvent("halloweenCamera", true)
addEventHandler("halloweenCamera", getRootElement(),
    function(ghostID)
        if isElement(source) and client and client == source then
            if isElement(ghostElements[ghostID]) then  
                if isElement(ghostElements[ghostID]) then
                    destroyElement(ghostElements[ghostID])
                end

                ghostElements[ghostID] = false

                outputChatBox("#efad5f[StrongMTA - Halloween]:#ffffff Kaptál egy halloween-i tököt.", source, 255, 255, 255, true)
                exports.see_items:giveItem(source, 383, 1)
            end
        end
    end
)
