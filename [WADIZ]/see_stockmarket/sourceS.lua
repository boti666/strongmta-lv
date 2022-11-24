local ped = createPed(299, 2026.7066650391, 1017.6330566406, 10.8203125)
setElementData(ped, "visibleName", "Steve Octans")
setElementData(ped, "pedNameType", "Részvényes")
setElementData(ped,"forexped", true)
setElementData(ped, "invulnerable", true)
setElementFrozen(ped,true)
setElementRotation(ped,0,0,252)

savestock = {}
addEvent("buyStock",true)
local pwcount = 1
connection = exports.see_database:getConnection()
function buyStock(player,type,amount,price)
    local curr = getElementData(player,type) or 0
    setElementData(player,type,curr+amount)
    exports.see_core:takeMoney(player,price)
    local dbid = getElementData(player,"char.ID")
    dbExec(connection, "INSERT INTO stocks SET name = ?, amount = ? ON DUPLICATE KEY UPDATE amount = amount +? ",type,amount,amount/10)
    loadCharacter2(player)
    loadCharacter3(player)
    loadCharacter4(player)
    loadCharacter5(player)
    loadCharacter6(player)
    loadCharacter7(player)
    loadCharacter8(player)
    loadCharacter9(player)
    loadCharacter10(player)
    loadCharacter11(player)
    loadCharacter12(player)
    loadCharacter13(player)
    loadCharacter14(player)
    loadCharacter15(player)
end
addEventHandler("buyStock",root,buyStock)
--dbExec(connection, "INSERT INTO stocks SET name = ?, amount = ?, owner =?",type,amount,dbid)

addEvent("sellStock",true)
function sellStock(player,type,amount,price)
    local curr = getElementData(player,type) or 0
    setElementData(player,type,curr-amount)
    exports.see_core:giveMoney(player,price)
    local dbid = getElementData(player,"char.ID")
    dbExec(connection, "INSERT INTO stocks SET name = ?, amount = ? ON DUPLICATE KEY UPDATE amount = amount -? ",type,amount,amount/10)
    loadCharacter2(player)
    loadCharacter3(player)
    loadCharacter4(player)
    loadCharacter5(player)
    loadCharacter6(player)
    loadCharacter7(player)
    loadCharacter8(player)
    loadCharacter9(player)
    loadCharacter10(player)
    loadCharacter11(player)
    loadCharacter12(player)
    loadCharacter13(player)
    loadCharacter14(player)
    loadCharacter15(player)
end
addEventHandler("sellStock",root,sellStock)


function saveStock(quitType )

    for k, v in ipairs(exchanges) do
      savestock[#savestock +1] = {
        ['name'] = exchanges[k]["name"], 
        ['amount'] = getElementData(source,exchanges[k]["name"]) or 0 , 
     }
    end
    for k,v in ipairs(savestock) do
   -- outputChatBox(v["amount"])
    end
    dbExec(connection, "UPDATE characters SET stock = ? WHERE characterId = ?", toJSON(savestock), getElementData(source,"char.ID"))
end
addEventHandler("onPlayerQuit",getRootElement(),saveStock)

addEventHandler("onResourceStop",resourceRoot,
    function()
        for k2, v2 in ipairs(getElementsByType("player")) do
            for k, v in ipairs(exchanges) do
                savestock[#savestock +1] = {
                    ['name'] = exchanges[k]["name"], 
                    ['amount'] = getElementData(v2, exchanges[k]["name"]) or 0 , 
                }

                for k,v in ipairs(savestock) do
                    iprint(v["amount"])
                end

                dbExec(connection, "UPDATE characters SET stock = ? WHERE characterId = ?", toJSON(savestock), getElementData(v2, "char.ID")) 
            end
        end
    end
)

function loadCharacter2(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
         local  countpw = data.amount
         local  pwcount = pwcount*countpw
         --   --outputChatBox(pwcount)
        --    outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Burger King price",pwcount)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Burger King'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter2)

function loadCharacter3(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"CrossFit price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'CrossFit'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter3)

function loadCharacter4(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Electro-Harmonix price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Electro-Harmonix'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter4)

function loadCharacter5(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Looking Class Studios price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Looking Class Studios'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter5)

function loadCharacter6(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"ZeniMax Media price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'ZeniMax Media'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter6)

function loadCharacter7(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"United Parcel Service price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'United Parcel Service'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter7)

function loadCharacter8(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Kellogg Company price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Kellogg Company'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter8)

function loadCharacter9(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"IBM price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'IBM'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter9)

function loadCharacter10(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Kaos Studios price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Kaos Studios'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter10)

function loadCharacter11(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Paws Inc. price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Paws Inc.'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter11)

function loadCharacter12(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Pizza Hut price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Pizza Hut'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter12)

function loadCharacter13(player)
    player = player
   -- outputChatBox(savedbid)
  -- local   countpw = 0
   --local    pwcount = 0
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"THQ price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'THQ'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter13)

function loadCharacter14(player)
    player = player

   -- outputChatBox(savedbid)
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Viacom price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Viacom'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter14)

function loadCharacter15(player)
    player = player

   -- outputChatBox(savedbid)
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = data.name
           local   countpw = data.amount
           local    pwcount = pwcount*countpw
            --outputChatBox(pwcount)
       --     outputChatBox(exchanges[1]["buy"]+pwcount)
            setElementData(ped,"Westing House Electric price",pwcount or 0)
       else

       end
    end, {player, stock}, connection, "SELECT * FROM stocks WHERE name = 'Westing House Electric'")
end
addEventHandler("onResourceStart",resourceRoot,loadCharacter15)




function loadCharacter(player)
    local savedbid = getElementData(player,"char.ID")
    player = player
   -- outputChatBox(savedbid)
    dbQuery(function(handler, stock)
       local result, rows, err = dbPoll(handler, 0)
       if rows > 0 then
          local data = result[1]
          
           pw = fromJSON(data.stock)
        for k,v in ipairs(pw) do
            setElementData(player,v["name"],v["amount"])
        end
       else

       end
    end, {player, stock}, connection, "SELECT * FROM characters WHERE characterId =?", savedbid)
end

function checkChange(theKey, oldValue,newValue)
   if (theKey== "loggedIn") then
       loadCharacter(source)
   end
end
addEventHandler("onElementDataChange", getRootElement(), checkChange)
