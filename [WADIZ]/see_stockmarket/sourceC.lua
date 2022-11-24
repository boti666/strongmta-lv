local screenX, screenY = guiGetScreenSize()

pcall(loadstring(base64Decode(exports.see_draw:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.see_draw:getInterfaceElements())));end)

local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function resp(value)
    return value * responsiveMultipler
end

function respc(value)
    return math.ceil(value * responsiveMultipler)
end

local screenPos = {
    x = screenX / 2 - respc(800) / 2,
    y = screenY / 2 - respc(430) / 2,
    w = respc(800),
    h = respc(430)
    
}

function formatNumber(amount, stepper)
    local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
    return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

local notavaliablevalues = {"!","+","'","%","/","=","(",")",".","-","_","?",":","@","{","}",";",">","*","<","&"}
local wheel = 0
local wheel2 = 0
local lunabar = dxCreateFont("lunabar.ttf",respc(12))
local stock = {"strong","1","3","4","5"}
local show = false
local buystate = false



function pedClick (b, s, ax, ay, wx, wy, wz, element)
	if b == "right" and s == "down" then
		if isElement(element) then
			if drawState then return end
            local x,y,z = getElementPosition(localPlayer)
            local px,py,pz = getElementPosition(element)
			if getElementType(element) == "ped" and getDistanceBetweenPoints3D(x,y,z, px,py,pz) < 5 and getElementData(element,"forexped") and not show then
				addEventHandler("onClientRender",root,render)
                addEventHandler("onClientKey", getRootElement(), editBoxesKey)
                addEventHandler("onClientCharacter", getRootElement(), editBoxesCharacter)
                addEventHandler("onClientRender", getRootElement(), renderEditBoxes)
                addEventHandler("onClientClick", getRootElement(), click)
                show = true
                clickedPed = element
                pedx,pedy,pedz = getElementPosition(element)
			end
		end
	end
end
addEventHandler("onClientClick",getRootElement(),pedClick)


function render()
    local playerx,playery,playerz = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(pedx,pedy,pedz,playerx,playery,playerz) > 5 then
        removeEventHandler("onClientRender",root,render)

        removeEventHandler("onClientKey", getRootElement(), editBoxesKey)
        removeEventHandler("onClientCharacter", getRootElement(), editBoxesCharacter)
        removeEventHandler("onClientRender", getRootElement(), renderEditBoxes)
        removeEventHandler("onClientClick", getRootElement(), click)
        show = false
        return
    end
    buttonsC = {}
    dxDrawRectangle(screenPos.x, screenPos.y, screenPos.w, screenPos.h+respc(80), tocolor(35, 35, 35))
    dxDrawRectangle(screenPos.x + 3, screenPos.y + 3, screenPos.w - 6, respc(40) - 6, tocolor(55, 55, 55))
    dxDrawText("#3d7abcStrong#c8c8c8MTA", screenPos.x + 3 + respc(10), screenPos.y + respc(20), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
    if isInSlot(screenPos.x + 3 + respc(772), screenPos.y + respc(15),respc(15),respc(15)) then
		dxDrawText("X", screenPos.x + 3 + respc(775), screenPos.y + respc(20), nil, nil, tocolor(255, 100, 100, 200), 1, lunabar, "left", "center", false, false, false, true)
    else
		dxDrawText("X", screenPos.x + 3 + respc(775), screenPos.y + respc(20), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)	
	end
	dxDrawText("Részvényes cégek", screenPos.x + 3 + respc(50), screenPos.y + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
    dxDrawText("Vételár", screenPos.x + 3 + respc(390), screenPos.y + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
    dxDrawText("Eladási ár", screenPos.x + 3 + respc(630), screenPos.y + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
    dxDrawText("Saját részvényeid", screenPos.x + 3 + respc(390), screenPos.y + respc(280), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
    if selected then
        dxDrawText("Mennyiség", screenPos.x + 3 + respc(20), screenPos.y + respc(280), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
        dxDrawText("Összeg", screenPos.x + 3 + respc(200), screenPos.y + respc(280), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
        dxDrawRectangle(screenPos.x + respc(165), screenPos.y+respc(250) + respc(50), screenPos.w - respc(670), respc(30)- 6, tocolor(55, 55, 55))
        dxDrawRectangle(screenPos.x + respc(5), screenPos.y+respc(250) + respc(50), screenPos.w - respc(670), respc(30)- 6, tocolor(55, 55, 55))
    end
    local count = 0
    for k, v in ipairs(exchanges) do  
        if k > wheel and count < 4 then

            count = count+0.5

            if k % 2 ~= 0 then
                rectangleColor = tocolor(15,15,15)
            else
                rectangleColor= tocolor(25,25,25)
            end 

            if isInSlot(screenPos.x + 3, screenPos.y+respc(40) + respc(50)*count, screenPos.w - 6, respc(30)- 6) then
                dxDrawRectangle(screenPos.x + 3, screenPos.y+respc(40) + respc(50)*count, screenPos.w - 6, respc(30)- 6, tocolor(61, 122, 188,200))
            else
                dxDrawRectangle(screenPos.x + 3, screenPos.y+respc(40) + respc(50)*count, screenPos.w - 6, respc(30)- 6, rectangleColor)
            end

            if selected == v then
                dxDrawRectangle(screenPos.x + 3, screenPos.y+respc(40) + respc(50)*count, screenPos.w - 6, respc(30)- 6, tocolor(61, 122, 188,200))
                if buystate == "buy" then
                    if dxGetEditText("stockedit") then
                        local amountof = tonumber(dxGetEditText("stockedit"))

                        if not tonumber(amountof) then
                             amountof = 1
                        end

                        dxDrawText(""..formatNumber(v["buy"]*amountof+(math.round(getElementData(clickedPed,""..selected["name"].." price")*amountof))).."#3d7abc$", screenPos.x + 3 + respc(225), screenPos.y+respc(261) + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "center", "center", false, false, false, true)
                    else
                        dxDrawText(""..formatNumber(v["buy"]).."#3d7abc$", screenPos.x + 3 + respc(225), screenPos.y+respc(261) + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "center", "center", false, false, false, true)
                    end
                elseif buystate == "sell" then
                    local amountof = tonumber(dxGetEditText("stockedit"))

                    if not tonumber(amountof) then
                        amountof = 1
                    end

                    dxDrawText(""..formatNumber(v["sell"]*amountof+(math.round(getElementData(clickedPed,""..selected["name"].." price")*amountof))).."#3d7abc$",screenPos.x + 3 + respc(225), screenPos.y+respc(261) + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "center", "center", false, false, false, true)
                end
                
                if buystate == "buy" then
                    dxDrawText("Vásárlás", screenPos.x + 3 + respc(20), screenPos.y+respc(301) + respc(50), nil, nil, tocolor(61, 122, 188,200), 1, lunabar, "left", "center", false, false, false, true)
                else
                    dxDrawText("Vásárlás", screenPos.x + 3 + respc(20), screenPos.y+respc(301) + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
                end
                if buystate == "sell" then
                    dxDrawText("Eladás", screenPos.x + 3 + respc(200), screenPos.y+respc(301) + respc(50), nil, nil, tocolor(61, 122, 188,200), 1, lunabar, "left", "center", false, false, false, true)
                else
                    dxDrawText("Eladás", screenPos.x + 3 + respc(200), screenPos.y+respc(301) + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
                end
            end
            dxDrawText(exchanges[k]["name"], screenPos.x + 3 + respc(10), screenPos.y+respc(50) + respc(50)*(count), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
            dxDrawText(formatNumber(exchanges[k]["buy"]+math.round(getElementData(clickedPed,""..exchanges[k]["name"].." price"),0)), screenPos.x + 3 + respc(400), screenPos.y+respc(50) + respc(50)*(count), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
            dxDrawText(formatNumber(exchanges[k]["sell"]+math.round(getElementData(clickedPed,""..exchanges[k]["name"].." price"),0)), screenPos.x + 3 + respc(650), screenPos.y+respc(50) + respc(50)*(count), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
        end
    end
    if selected then
        if isInSlot(screenPos.x + respc(15), screenPos.y+respc(350) + respc(50), screenPos.w - respc(550), respc(30)- 6) then
            dxDrawRectangle(screenPos.x + respc(15), screenPos.y+respc(350) + respc(50), screenPos.w - respc(550), respc(30)- 6, tocolor(61, 122, 188,200))
        else
            dxDrawRectangle(screenPos.x + respc(15), screenPos.y+respc(350) + respc(50), screenPos.w - respc(550), respc(30)- 6, tocolor(55, 55, 55))
        end
        dxDrawText("Tranzakció végrehajtása", screenPos.x + respc(15) + (screenPos.w - respc(550)) / 2, screenPos.y+respc(361) + respc(50), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "center", "center", false, false, false, true)
    end

    local count = 0
        for k, v in ipairs(exchanges) do  
            if k > wheel2 and count < 4 then
                        count = count+0.5
                        if k % 2 ~= 0 then
                            rectangleColor = tocolor(15,15,15)
                        else
                            rectangleColor = tocolor(25,25,25)
                        end 
                        if isInSlot(screenPos.x + respc(345), screenPos.y+respc(270) + respc(50)*count, screenPos.w - respc(350), respc(30)- 6) then
                            dxDrawRectangle(screenPos.x + respc(345), screenPos.y+respc(270) + respc(50)*count, screenPos.w - respc(350), respc(30)- 6, tocolor(61, 122, 188,200))
                        else
                            dxDrawRectangle(screenPos.x + respc(345), screenPos.y+respc(270) + respc(50)*count, screenPos.w - respc(350), respc(30)- 6, rectangleColor)
                        end
                  dxDrawRectangle(screenPos.x + respc(345), screenPos.y+respc(270) + respc(50)*count, screenPos.w - respc(350), respc(30)- 6, rectangleColor)
                if isInSlot(screenPos.x + respc(345), screenPos.y+respc(270) + respc(50)*count, screenPos.w - respc(350), respc(30)- 6) then
                    dxDrawRectangle(screenPos.x + respc(345), screenPos.y+respc(270) + respc(50)*count, screenPos.w - respc(350), respc(30)- 6, tocolor(61, 122, 188,200))
                else
                    dxDrawRectangle(screenPos.x + respc(345), screenPos.y+respc(270) + respc(50)*count, screenPos.w - respc(350), respc(30)- 6, rectangleColor)
                end 
                if getElementData(localPlayer,exchanges[k]["name"]) and getElementData(localPlayer,exchanges[k]["name"])  ~= 0 then
                    dxDrawText(getElementData(localPlayer,exchanges[k]["name"]), screenPos.x + 3 + respc(600), screenPos.y+respc(282) + respc(50)*(count), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
                else
                    dxDrawText("Nincs ilyen részvényed", screenPos.x + 3 + respc(600), screenPos.y+respc(282) + respc(50)*(count), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
                end
                dxDrawText(exchanges[k]["name"], screenPos.x + 3 + respc(350), screenPos.y+respc(282) + respc(50)*(count), nil, nil, tocolor(200, 200, 200, 200), 1, lunabar, "left", "center", false, false, false, true)
            end 
        end
    end

function click(button,state)
    if not show then return end

    if button =="left" and state=="down" then
        if isInSlot(screenPos.x + 3 + respc(772), screenPos.y + respc(15),respc(15),respc(15)) then
            removeEventHandler("onClientRender",root,render)

            removeEventHandler("onClientKey", getRootElement(), editBoxesKey)
            removeEventHandler("onClientCharacter", getRootElement(), editBoxesCharacter)
            removeEventHandler("onClientRender", getRootElement(), renderEditBoxes)
            removeEventHandler("onClientClick", getRootElement(), click)
            dxDestroyEdit("stockedit")
            selected = false
            show = false
        end
        local count = 0
        for k, v in ipairs(exchanges) do  
            if k > wheel and count < 4 then
                count = count+0.5
                if isInSlot(screenPos.x + 3, screenPos.y+respc(40) + respc(50)*count, screenPos.w - 6, respc(30)- 6) then
                    dxDestroyEdit("stockedit")
                     selected = v 
                     dxCreateEdit("stockedit","1","1",screenPos.x + respc(5), screenPos.y+respc(250) + respc(50), screenPos.w - respc(670), respc(30)- 6, lunabar)
         --            outputChatBox(v["name"])
                end
            end
        end
        if isInSlot(screenPos.x + 3 + respc(200), screenPos.y+respc(295) + respc(50),respc(60),respc(15)) then
            buystate = "sell"
        elseif isInSlot(screenPos.x + 3 + respc(22), screenPos.y+respc(295) + respc(50),respc(60),respc(15)) then
            buystate = "buy"				   
        elseif isInSlot(screenPos.x + respc(15), screenPos.y+respc(350) + respc(50), screenPos.w - respc(550), respc(30)- 6) then
                if buystate == "sell" then
                    if tonumber(dxGetEditText("stockedit")) and tonumber(dxGetEditText("stockedit")) > 100 then
                        exports.see_accounts:showInfo("e", "Maximum 100 részvényt adhatsz el!")
                        return
                       end
                    if tonumber(getElementData(localPlayer,selected["name"])) < tonumber(dxGetEditText("stockedit")) then
                        exports.see_accounts:showInfo("e", "Nincs elég részvényed az eladáshoz.")
                    return end
                    if tonumber(getElementData(localPlayer,selected["name"])) or 0 > 0 then
                        local price = selected["sell"]+math.round(getElementData(clickedPed,""..selected["name"].." price"))
                        if tonumber(dxGetEditText("stockedit")) and tonumber(dxGetEditText("stockedit")) > 0   then
                            triggerServerEvent("sellStock",localPlayer,localPlayer,selected["name"],dxGetEditText("stockedit"),price*dxGetEditText("stockedit"))
                        else
                            exports.see_accounts:showInfo("e", "Érvénytelen mennyiség.")
                        end  
                    end
                elseif buystate == "buy" then
                    local stockprice = selected["buy"]+math.round(getElementData(clickedPed,""..selected["name"].." price"))
                   if exports.see_core:getMoney(localPlayer) < (stockprice*dxGetEditText("stockedit")) then
                        exports.see_accounts:showInfo("e", "Nincs elég pénzed a részvény megvásárlásához.")
                        return
                     end
                    --local curr = getElementData(localPlayer,selected["name"]) or 0
                    --setElementData(localPlayer,selected["name"],curr+1)
                   -- exports.see_core:takeMoney(localPlayer,selected["buy"])
                   local price = selected["buy"]+math.round(getElementData(clickedPed,""..selected["name"].." price"))
                   if tonumber(dxGetEditText("stockedit")) and tonumber(dxGetEditText("stockedit")) > 100 then
                    exports.see_accounts:showInfo("e", "Maximum 100 részvényt vehetsz!")
                    return
                   end
                   if string.find(dxGetEditText("stockedit"), ".", 1,true) then
                    exports.see_accounts:showInfo("e", "Érvénytelen mennyiség.")
                    return 
                   end
                    if tonumber(dxGetEditText("stockedit")) and tonumber(dxGetEditText("stockedit")) > 0  then
                        triggerServerEvent("buyStock",localPlayer,localPlayer,selected["name"],dxGetEditText("stockedit"),price*dxGetEditText("stockedit"))
                    else
                        exports.see_accounts:showInfo("e", "Érvénytelen mennyiség.")
                    end
            end
        end
    end
end

function isInSlot(posX, posY, sizeX, sizeY)
    return exports.see_draw:isInSlot(posX, posY, sizeX, sizeY)
end


bindKey("mouse_wheel_up", "down",function()
    if not show then return end
    if isInSlot(screenPos.x, screenPos.y+respc(60), screenPos.w, screenPos.h-respc(220)) then
		if wheel < 1 then
			wheel = 0
		end
		wheel = wheel - 1
		if wheel < 1 then
			wheel = 0
		end	
    end
end)

bindKey("mouse_wheel_down", "down",function()
    if not show then return end
    if isInSlot(screenPos.x, screenPos.y+respc(60), screenPos.w, screenPos.h-respc(220)) then
		if wheel > #exchanges - 8 then
			wheel = #exchanges - 8
		end
		wheel = wheel + 1
		if wheel > #exchanges - 8 then
			wheel = #exchanges - 8
		end	
    end
end)

bindKey("mouse_wheel_up", "down",function()
    if not show then return end
    if isInSlot(screenPos.x + respc(345), screenPos.y+respc(270), screenPos.w - respc(350), screenPos.h - respc(200)) then
		if wheel2 < 1 then
			wheel2 = 0
		end
		wheel2 = wheel2 - 1
		if wheel2 < 1 then
			wheel2 = 0
		end	
    end
end)

bindKey("mouse_wheel_down", "down",function()
    if not show then return end
    if isInSlot(screenPos.x + respc(345), screenPos.y+respc(270), screenPos.w - respc(350), screenPos.h - respc(200)) then
		if wheel2 > #exchanges - 8 then
			wheel2 = #exchanges - 8
		end
		wheel2 = wheel2 + 1
		if wheel2 > #exchanges - 8 then
			wheel2 = #exchanges - 8
		end	
    end
end)


function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
 end