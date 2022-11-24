local connection = false
local cupons = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function(db)
		connection = db
	end
)

addEventHandler("onResourceStart", root,
    function()
        connection = exports.see_database:getConnection()

        dbQuery(loadCupons, connection, "SELECT * FROM cupons")
    end
)

function loadCupons(qh)
    local result = dbPoll(qh, 0)

    if result then
        for k, v in pairs(result) do
            table.insert(cupons, {cuponID = v.dbID, cuponCode = v.code, cuponAmount = tonumber(v.amount), cuponType = v.type, cuponTypeAmount = tonumber(v.typeAmount), cuponActivatedBy = fromJSON(v.activatedBy) or {}})
        end
    end
end


local enabledSerials = {
    ["BE26A9713CE36BD23DB953BBBC4817A3"] = true,
    ["0EB993DA466366F4F7A9DE8AD585B391"] = true,
    ["E5CE8ECD0559A241A012012D454AB6A1"] = true,
    ["F45E1565719BE0F6425C5CE6C2D30BE3"] = true,
}

addCommandHandler("kupon",
    function(sourcePlayer, commandName, cuponCode)
        if not getElementData(sourcePlayer, "loggedIn") then
            return
        end
        local foundCupon = false
        for k, v in pairs(cupons) do
            if v.cuponCode == cuponCode then
                foundCupon = v
            end
        end
        if cuponCode then
            v = foundCupon
            local alreadyUsed = false
            if not foundCupon then
                outputChatBox("#d75959[Kupon]: #ffffffNincs ilyen kód!", sourcePlayer, 255, 255, 255, true)
                return
            end
            for k, v in pairs(v.cuponActivatedBy) do
                if tonumber(v) == getElementData(sourcePlayer, "char.accID") then
                    alreadyUsed = true
                    break
                end
            end
            if alreadyUsed then
                outputChatBox("#d75959[Kupon]: #ffffffTe már felhasználtad ezt a kódot!", sourcePlayer, 255, 255, 255, true)
                return
            end
            
            if v.cuponAmount > 0 then
                --local cuponReward = v.cuponTypeAmount
                if v.cuponType == 1 then
                    cuponReward = v.cuponTypeAmount.." PP"
                    setElementData(sourcePlayer, "acc.premiumPoints", getElementData(sourcePlayer, "acc.premiumPoints") + v.cuponTypeAmount)
                    local newPP, accID = getElementData(sourcePlayer, "acc.premiumPoints"), getElementData(sourcePlayer, "char.accID")
                    print("asd")
                    dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", newPP, getElementData(sourcePlayer, "char.accID"))
                elseif v.cuponType == 2 then
                    cuponReward = exports.wm_items:getItemName(v.cuponTypeAmount)
                    exports.wm_items:giveItem(sourcePlayer, v.cuponTypeAmount, 1)
                elseif v.cuponType == 3 then
                    cuponReward = exports.wm_items:getItemName(exports.wm_vehiclenames:getCustomVehicleName(v.cuponTypeAmount))
                    local x, y, z = getElementPosition(sourcePlayer)
                    exports.wm_vehicles:createPermVehicle({
                        modelId = v.cuponTypeAmount,
                        color1 = string.format("#%.2X%.2X%.2X", 200, 200, 200),
                        color2 = string.format("#%.2X%.2X%.2X", 200, 200, 200),
                        targetPlayer = sourcePlayer,
                        posX = x,
                        posY = y,
                        posZ = z,
                        rotX = 0,
                        rotY = 0,
                        rotZ = getPedRotation(sourcePlayer),
                        interior = getElementInterior(sourcePlayer),
                        dimension = getElementDimension(sourcePlayer)
                    })
                end
                table.insert(v.cuponActivatedBy, getElementData(sourcePlayer, "char.accID"))
                v.cuponAmount = v.cuponAmount - 1
                dbExec(connection, "UPDATE cupons SET amount = ?, activatedBy = ? WHERE dbID = ?", v.cuponAmount, toJSON(v.cuponActivatedBy), v.cuponID)
                outputChatBox("#bc873d[Kupon]: #ffffffSikeresen felhasználtad a kódot! #bc873d("..cuponReward..")", sourcePlayer, 255, 255, 255, true)
            else
                outputChatBox("#d75959[Kupon]: #ffffffElfogyott!", sourcePlayer, 255, 255, 255, true)
            end
        else
            outputChatBox("#d75959[Használat]: #ffffff/"..commandName.." [Kód]", sourcePlayer, 255, 255, 255, true)
        end
    end
)

addCommandHandler("createkupon",
    function(sourcePlayer, commandName, code, amount, type, typeAmount)
        if enabledSerials[getPlayerSerial(sourcePlayer)] then
            if typeAmount then
                if tonumber(amount) and tonumber(type) and tonumber(typeAmount) and tonumber(type) <= 3 then
                    for k, v in pairs(cupons) do
                        if v.cuponCode == code then
                            outputChatBox("#d75959[Kupon]: #ffffffIlyen azonosítóval már létezik kupon!", sourcePlayer, 255, 255, 255, true)
                            return
                        end
                    end
                    if code == "0" then
                        code = sha256((math.random(1, 100000)/1000)*getTickCount()/1002)
                        code = utfSub(code, 1, 8)
                    end
                    dbExec(connection, "INSERT INTO cupons (code, amount, type, typeAmount, activatedBy) VALUES (?,?,?,?,?)", code, amount, type, typeAmount, toJSON({}))
                    outputChatBox("#bc873d[Kupon]: #ffffffSikeresen létrehoztad a kupont! #bc873d("..code..")", sourcePlayer, 255, 255, 255, true)
                    dbQuery(loadCupons, connection, "SELECT * FROM cupons")
                end
            else
                outputChatBox("#d75959[Használat]: #ffffff/"..commandName.." [Kód (0 = random)] [Mennyiség] [Típus (1 = PP, 2 = Item, 3 = Jármű)] [Mennyiség (PP mennyiség, ItemID, ModellID)]", sourcePlayer, 255, 255, 255, true)
            end
        end
    end
)