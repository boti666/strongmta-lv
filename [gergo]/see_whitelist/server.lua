local whitelist = {}
local connection = exports['see_database']:getConnection(getThisResource())
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "see_database" then
	        connection = exports['see_database']:getConnection()
            restartResource(getThisResource())
        end
	end
)


addEventHandler('onResourceStart', resourceRoot,
    function()		
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, -1)
            if query_lines > 0 then
                for i, row in pairs(query) do
                    local serial = row["serial"]
                    local name = row["name"]
                    whitelist[serial] = name
                end
            end
        end, connection, "SELECT * FROM `whitelist`")
	end
)

addEventHandler("onPlayerConnect", root,
    function(name,_,_,serial)
        if not whitelist[serial] then
           cancelEvent(true, "Whitelist: discord.gg/strongmta")
           --redirectPlayer(getPlayerFromName(name), "37.17.172.181", 22003)
        end
    end
)

addCommandHandler("addserial", 
    function(thePlayer, cmd, serial, name)
        --if getPlayerSerial(thePlayer) == "6506960425D3D38103C9D76F43AC2B44" or getPlayerSerial(thePlayer) == "35D28D601C8A9AC3F684DEA0A79645A1" then
        if getElementData(thePlayer, "acc.adminLevel") >= 9 then
            if not serial or not name then
                outputChatBox("#3d7abc[StrongMTA] #ffffff/"..cmd.." [serial] [név]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if whitelist[serial] then
                outputChatBox("Ez a serial már hozzá lett adva whitelisthez!", thePlayer, 255, 255, 255, true)
                return
            end
            
            dbExec(connection, "INSERT INTO `whitelist` SET `serial` = ?, `name` = ?", serial, name)
            whitelist[serial] = true
            local aName = getPlayerName(thePlayer)
            outputChatBox("#3d7abc"..aName.."#ffffff hozzáadta#3d7abc "..name.."-t #ffffffa whitelisthez!", root, 255, 255, 255, true)
            outputChatBox("Sikeresen hozzáadtad #3d7abc"..name.."-t #ffffffa whitelisthez!", thePlayer, 255, 255, 255, true)
        end
    end
)

addCommandHandler("delserial", 
    function(thePlayer, cmd, serial)
        --if getPlayerSerial(thePlayer) == "6506960425D3D38103C9D76F43AC2B44" or getPlayerSerial(thePlayer) == "35D28D601C8A9AC3F684DEA0A79645A1" then
        if getElementData(thePlayer, "acc.adminLevel") >= 9 then
            if not serial then
                outputChatBox("#3d7abc[StrongMTA] #ffffff/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if not whitelist[serial] then
                outputChatBox(syntax3 .. "Ez a serial nem szerepel a whitelisten!", thePlayer, 255, 255, 255, true)
                return
            end
            dbExec(connection, "DELETE FROM `whitelist` WHERE `serial` = ?", serial)
            local aName = getPlayerName(thePlayer)
            outputChatBox("#3d7abc"..aName.."#ffffff törölte#3d7abc "..serial.." #ffffffa whitelistből!", root, 255, 255, 255, true)
            outputChatBox("Sikeresen törölted #3d7abc"..serial.." #ffffffa whitelistből!", thePlayer, 255, 255, 255, true)
            whitelist[serial] = nil
        end
    end
)