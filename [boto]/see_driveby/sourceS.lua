addEvent("togDriveby", true)
addEventHandler("togDriveby", getRootElement(),
    function(state)
        if isElement(source) then 
            setPedDoingGangDriveby(source, state)
        end
    end
)

addEvent("executeCommand", true)
addEventHandler("executeCommand", getRootElement(),
    function ()
    end 
)