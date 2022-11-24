local connection = exports.see_database:getConnection()
local strongColor = "#3d7abc"
local whiteColor = "#ffffff"
local errorColor = "#d75959"
local serverPrefix = strongColor .. "[StrongMTA]: #ffffff"
local usagePrefix = strongColor .. "[StrongMTA - Használat]: #ffffff"
local errorPrefix = errorColor .. "[StrongMTA]: #ffffff"

local serials = {
    ["AD2CCC92EDB6F442D813D59392575083"] = true, -- brownib
    ["18A43ED858F30EA01B4D299FF5BBE6A1"] = true, -- clayton
    ["12B2178B3BE2E23B8C20F3183B26E9B2"] = true, -- SyS
    ["F83E9120B55F20AF9DEAFFD825AE6684"] = true, -- marlboro
    ["F4E63263335F3164CB9F83E37E117C94"] = true, -- razypain
    ["A9D86084C49812DD047949EFCB1DCA84"] = true, -- enemy
    ["3964A9A5103CDA070946DED861649B52"] = true, -- boti
    ["A4D3F4DEE43259D7899C47E6E5272143"] = true, -- ádi pp-zés
    ["E03246658A1D887085F33042EFCACDA4"] = true, -- lövős erik [pp-zte a yt radiot]
    ["B6CE8C56BD802D751761F7C7E72DB042"] = true, -- Salgó [ppzte yt radio]
    ["625E295B8FEAFCF3016EA204AFAADEA4"] = true, -- Salgó haverja
    ["69E4149CCCDDF2B8A479304972EAFDD2"] = true, -- CsakSimánKrisztián#2525 #ppzte brownibnal a yt radiot meg a nitrot 
    ["DA04A82D923BFDF3D288B2B88068DC04"] = true, -- pumpedhot#5647 #yt radio
    ["6AC8AB2DE77AE45683648A91D22312E4"] = true, -- Bencce85
}

local serials2 = {
    ["AD2CCC92EDB6F442D813D59392575083"] = true, -- brownib
    ["18A43ED858F30EA01B4D299FF5BBE6A1"] = true, -- clayton
    ["12B2178B3BE2E23B8C20F3183B26E9B2"] = true, -- SyS
    ["F83E9120B55F20AF9DEAFFD825AE6684"] = true, -- marlboro
    ["F4E63263335F3164CB9F83E37E117C94"] = true, -- razypain
    ["A9D86084C49812DD047949EFCB1DCA84"] = true, -- enemy
    ["3964A9A5103CDA070946DED861649B52"] = true, -- boti
    ["A4D3F4DEE43259D7899C47E6E5272143"] = false, -- ádi pp-zés
    ["E03246658A1D887085F33042EFCACDA4"] = false, -- lövős erik [pp-zte a yt radiot]
    ["69E4149CCCDDF2B8A479304972EAFDD2"] = true, -- CsakSimánKrisztián#2525 #ppzte brownibnal a yt radiot meg a nitrot
    ["6AC8AB2DE77AE45683648A91D22312E4"] = true, -- Bencce85
}

local brownibSkin = {
    ["AD2CCC92EDB6F442D813D59392575083"] = true, -- brownib aki egyedul lesz ebbe benne
    ["F4E63263335F3164CB9F83E37E117C94"] = true, -- razypain
    ["3964A9A5103CDA070946DED861649B52"] = true, -- boti
    ["A9D86084C49812DD047949EFCB1DCA84"] = true, -- enemy
}

local CsakSimanKrisztian = {
    ["69E4149CCCDDF2B8A479304972EAFDD2"] = true, -- CsakSimánKrisztián#2525 #ppzte az egyedi skint id: 12
}

local pumpedhot = {
    ["DA04A82D923BFDF3D288B2B88068DC04"] = true, -- pumpedhot#5647 sajat skin
}

local jpSerials = {
    ["AD2CCC92EDB6F442D813D59392575083"] = true, -- brownib aki egyedul lesz ebbe benne
    ["A9D86084C49812DD047949EFCB1DCA84"] = false, -- enemy
}

addCommandHandler("dzsetpak",
    function(source)
        if jpSerials[getPlayerSerial(source)] then
            setPedWearingJetpack(source, not isPedWearingJetpack(source))
    
        end
    end
)

addCommandHandler("strongradio",
    function(source)
        if serials[getPlayerSerial(source)] and isPedInVehicle(source) then
            local vehicle = getPedOccupiedVehicle(source)
            setElementData(vehicle, "tuning.radio", true)
            outputChatBox(serverPrefix.."bonibe ezt is megcsinata na wadulj meg strongmta. ✌️", source, 255, 255, 255, true)
        end
    end
)

addCommandHandler("strongnitro",
    function(source)
        if serials2[getPlayerSerial(source)] then
            local vehicle = getPedOccupiedVehicle(source)
            setElementData(vehicle, "vehicle.nitroLevel", 999999)
            outputChatBox("#3d7abc[StrongMTA]:#ffffff Vegtelen nitro vrum vrum", source, 255, 255, 255, true)
        end
    end
)

addEventHandler("onElementModelChange", root, 
    function(oldModel, newModel) 
        if getElementType(source) == "player" then 
            if not brownibSkin[getPlayerSerial(source)] then
                if newModel == 214 then
                    outputChatBox("#3d7abc[StrongMTA - brownib]:#ffffff Ezt a skint nem használhatod, mivel védett.", source, 255, 0, 0, true); 
                    setTimer(  
                        function(p)
                            setElementModel(p, oldModel); 
                        end 
                    , 100, 1, source); 
                end 
            end 
        end 
    end 
);

addEventHandler("onElementModelChange", root, 
    function(oldModel, newModel) 
        if getElementType(source) == "player" then 
            if not CsakSimanKrisztian[getPlayerSerial(source)] then
                if newModel == 12 then
                    outputChatBox("#3d7abc[StrongMTA - Egyedi skin]:#ffffff Ezt a skint nem használhatod, mivel védett.", source, 255, 0, 0, true); 
                    setTimer(  
                        function(p)
                            setElementModel(p, oldModel); 
                        end 
                    , 100, 1, source); 
                end 
            end 
        end 
    end 
);

addEventHandler("onElementModelChange", root, 
    function(oldModel, newModel) 
        if getElementType(source) == "player" then 
            if not pumpedhot[getPlayerSerial(source)] then
                if newModel == 43 then
                    outputChatBox("#3d7abc[StrongMTA - Egyedi skin]:#ffffff Ezt a skint nem használhatod, mivel védett.", source, 255, 0, 0, true); 
                    setTimer(  
                        function(p)
                            setElementModel(p, oldModel); 
                        end 
                    , 100, 1, source); 
                end 
            end 
        end 
    end 
);

addCommandHandler("remkiraly",
    function(source)
        if CsakSimanKrisztian[getPlayerSerial(source)] then
            setElementModel(source, 12)
            outputChatBox("#3d7abc[StrongMTA - Egyedi Skin]:#ffffff Megkaptad a dara skint, na csa.", source, 255, 255, 255, true)
        else
            outputChatBox("#3d7abc[StrongMTA - Egyedi Skin]:#ffffff Nincs beirva a serialod :( szar lehet.", source, 255, 255, 255, true)
        end
    end
)

addCommandHandler("pumpedhot",
    function(source)
        if pumpedhot[getPlayerSerial(source)] then
            setElementModel(source, 43)
            outputChatBox("#3d7abc[StrongMTA - Egyedi Skin]:#ffffff Megkaptad a skined, na csa.", source, 255, 255, 255, true)
        else
            outputChatBox("#3d7abc[StrongMTA - Egyedi Skin]:#ffffff Nincs beirva a serialod :( szar lehet.", source, 255, 255, 255, true)
        end
    end
)

addCommandHandler("brownibskin",
    function(source)
        if brownibSkin[getPlayerSerial(source)] then
            setElementModel(source, 214)
            outputChatBox("#3d7abc[StrongMTA - brownib]:#ffffff Megkaptad a dara skint, na csa.", source, 255, 255, 255, true)
        else
            outputChatBox("#3d7abc[StrongMTA - brownib]:#ffffff Nincs beirva a serialod :( szar lehet.", source, 255, 255, 255, true)
        end
    end
)

function startJumpS()
    if isPedInVehicle(source) then
        triggerClientEvent(source, "startJump", getRootElement())
    else
        outputChatBox("no kocsi", source, 255, 255, 255, true)
    end
end
addEvent("startJumpS", true)
addEventHandler("startJumpS", getRootElement(), startJumpS)

function stopJumpS()
	if isPedInVehicle(source) then
		triggerClientEvent(source, "stopJump", getRootElement())
	else
        outputChatBox("no kocsi", source, 255, 255, 255, true)
    end
end
addEvent("stopJumpS", true)
addEventHandler("stopJumpS", getRootElement(), stopJumpS)

--[[addCommandHandler("setuserlogin",
    function(source, cmd, userName, newUsername)
        if getElementData(source, "acc.adminLevel") >= 6 then
            if not userName and not newUsername then
                outputChatBox(usagePrefix.."[Felhasználónév] [Új felhasználónév]", source, 255, 255, 255, true)
            else
                dbExec(connection, "UPDATE accounts SET username = ? WHERE username = ?", newUsername, userName)
                outputChatBox(serverPrefix.."Sikeresen megváltoztattad a(z) "..strongColor..userName..whiteColor.." nevű account nevét erre: "..strongColor..newUsername, source, 255, 255, 255, true)
            end
        end
    end
)

addCommandHandler("setuserpassword",
    function(source, cmd, accountID, password)
        if getElementData(source, "acc.adminLevel") >= 6 then
            if not accountID and not password then
                outputChatBox(usagePrefix.."[Account ID] [Új jelszó]", source, 255, 255, 255, true)
            else
                dbExec(connection, "UPDATE accounts SET password = ? WHERE accountId = ?", password, accountID)
                outputChatBox(serverPrefix.."Sikeresen megváltoztattad a(z) "..strongColor..accountID..whiteColor.." AccountID-vel rendelkező felhasználó jelszavát erre: "..strongColor..password, source, 255, 255, 255, true)
            end
        end
    end
)

addCommandHandler("setuserserial",
    function(source, cmd, serial, newSerial)
        if getElementData(source, "acc.adminLevel") >= 6 then
            if not serial and not newSerial then
                outputChatBox(usagePrefix.."[Serial] [Új Serial]", source, 255, 255, 255, true)
            else
                dbExec(connection, "UPDATE accounts SET serial = ? WHERE serial = ?", newSerial, serial)
                outputChatBox(serverPrefix.."Sikeresen megváltoztattad a(z) "..strongColor..serial..whiteColor.." serialt a következőre: "..strongColor..newSerial, source, 255, 255, 255, true)
            end
        end
    end
)]]