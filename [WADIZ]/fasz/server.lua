function setPedFortniteAnimation (ped,animation,tiempo,repetir,mover,interrumpible)
    print(animation)
 if (type(animation) ~= "string" or type(tiempo) ~= "number" or type(repetir) ~= "boolean" or type(mover) ~= "boolean" or type(interrumpible) ~= "boolean") then return false end
 if isElement(ped) then
  if animation == "dance2" or animation == "dance3" then
   for i = 1,3 do
    triggerClientEvent ( root, "setPedFortniteAnimation", root, ped,animation,tiempo,repetir,mover,interrumpible )
    if tiempo > 1 then
     setTimer(setPedAnimation,tiempo,1,ped,false)
     setTimer(setPedAnimation,tiempo+100,1,ped,false)
    end
   end
  end
 end
end

function howtouse ( player, command, dance )
if isElement(player) then
setPedFortniteAnimation(player,"baile3"..dance.."",-1,true,false,false,false)
end
end
addCommandHandler ( "553453535", howtouse )
--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--
anim = {}
function anim.fuck()
setPedFortniteAnimation(source,"dance2",-1,true,false,false,false)
print("asdasa")
end
addEvent("anim.fuck", true)
addEventHandler("anim.fuck", root, anim.fuck)

function anim.chat()
setPedFortniteAnimation(source,"dance3",-1,true,false,false,false)
print("fsdnfhndpsndcpő")
end
addEvent("anim.chat", true)
addEventHandler("anim.chat", root, anim.chat)

function anim.smoke()
setPedFortniteAnimation(source,"baile 6",-1,true,false,false,false)
end
addEvent("anim.smoke", true)
addEventHandler("anim.smoke", root, anim.smoke)

function anim.sexy()
setPedFortniteAnimation(source,"baile 7",-1,true,false,false,false)
end
addEvent("anim.sexy", true)
addEventHandler("anim.sexy", root, anim.sexy)

function anim.dance()
setPedFortniteAnimation(source,"baile 8",-1,true,false,false,false)
end
addEvent("anim.dance", true)
addEventHandler("anim.dance", root, anim.dance)

function anim.espere()
setPedFortniteAnimation(source,"baile 9",-1,true,false,false,false)
end
addEvent("anim.espere", true)
addEventHandler("anim.espere", root, anim.espere)

function anim.sentar()
setPedFortniteAnimation(source,"baile 10",-1,true,false,false,false)
end
addEvent("anim.sentar", true)
addEventHandler("anim.sentar", root, anim.sentar)


function anim.handsup()
setPedFortniteAnimation(source,"baile 11",-1,true,false,false,false)
end
addEvent("anim.handsup", true)
addEventHandler("anim.handsup", root, anim.handsup)

function anim.smile()
setPedFortniteAnimation(source,"baile 12",-1,true,false,false,false)
end
addEvent("anim.smile", true)
addEventHandler("anim.smile", root, anim.smile)

function anim.cancel()
	setPedAnimation(source)
end
addEvent("anim.cancel", true)
addEventHandler("anim.cancel", root, anim.cancel)
