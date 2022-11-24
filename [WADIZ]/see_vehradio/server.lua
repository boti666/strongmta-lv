addEvent("onEnableRadio", true)
addEventHandler("onEnableRadio", root, function(type, path)
    triggerClientEvent("onEnableRadio", source, type, path)
end)

addEvent("onDisableRadio", true)
addEventHandler("onDisableRadio", root, function()
    triggerClientEvent("onDisableRadio", source)
end)