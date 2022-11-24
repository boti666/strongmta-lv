addEvent("giveWinnedItem", true)
addEventHandler("giveWinnedItem", root,
    function (playerElement, caseType, winnedItem, code)
        if code ~= "farAsFeelingsGoes" and client then 
            return iprint(playerElement)
        end
        if isElement(playerElement) and client and client == source then 
            if isElement(playerElement) and availableCases[caseType] then
                exports.see_items:giveItem(playerElement, winnedItem[1], 1)
            end
        end
    end
)

--[[
local hiddenPeds = {}

addEventHandler("onResourceStart", resourceRoot,
    function()
        for k, v in pairs(hiddenPositions) do 
            hiddenPeds[k] = createPed(getValidPedModels()[math.random(1, 100)], v[1], v[2], v[3], v[4])
            setElementData(hiddenPeds[k], "casePed", true)
            setElementData(hiddenPeds[k], "visibleName", "Láda event")
        end
    end
)
]]

addEvent("onClientCaseClick", true)
addEventHandler("onClientCaseClick", getRootElement(),
    function(clickedElement)
        for k, v in pairs(hiddenPeds) do
            if v == clickedElement then
                local randomize = math.random(1, 1000)
                if randomize > 950 then
                    itemId = 164 
                    isGoldenText = "z arany"
                else
                    itemId = 163
                    isGoldenText = ""
                end
                outputChatBox("#bc873d[WeakMTA - Láda]:#ffffff Gratulálunk a"..isGoldenText.." ládához!", source, 255, 255, 255, true)
                exports.see_items:giveItem(source, itemId, 1)
                destroyElement(hiddenPeds[k])
                setTimer(
                    function()
                        hiddenPeds[k] = createPed(getValidPedModels()[math.random(1, 100)], hiddenPositions[k][1], hiddenPositions[k][2], hiddenPositions[k][3], hiddenPositions[k][4])
                        setElementData(hiddenPeds[k], "casePed", true)
                        setElementData(hiddenPeds[k], "visibleName", "Láda event")
                    end, math.random(20, 240) * 60000, 1, k
                )
            end
        end
    end
)