addEventHandler('onClientKey', root, function(key, press)
    if (key == 'F12') then 
        if (press) then 
            triggerServerEvent("onScreenShot", resourceRoot, localPlayer)
        end 
    end 
end);

addEventHandler('onClientConsole', root, function(key, press)
    --if (key == 'F12') then 
        --if (press) then 
            triggerServerEvent("onScreenShot", resourceRoot, localPlayer)
        --end 
    --end 
end);