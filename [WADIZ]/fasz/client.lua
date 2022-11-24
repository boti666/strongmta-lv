local customIfp = nil
function setPedFortniteAnimation (ped,animation,tiempo,repetir,mover,interrumpible)
	print("asd")
 if (type(animation) ~= "string" or type(tiempo) ~= "number" or type(repetir) ~= "boolean" or type(mover) ~= "boolean" or type(interrumpible) ~= "boolean") then return false end
 if isElement(ped) then

  if animation == "dance2" or animation == "dance3" then
  	print("asd")
   for i = 1,3 do
    setPedAnimation(ped, animation, animation, tiempo, true, false, false) 
    if tiempo > 1 then
     setTimer(setPedAnimation,tiempo,1,ped,false)
     setTimer(setPedAnimation,tiempo+100,1,ped,false)
    end
   end
  end
 end
end
addEvent("setPedFortniteAnimation",true)
addEventHandler("setPedFortniteAnimation",getRootElement(),setPedFortniteAnimation)

addEventHandler("onClientResourceStart", resourceRoot,
function ( startedRes )
 customIfp = engineLoadIFP ("1.ifp", "dance2")
 customIfp2 = engineLoadIFP ("2.ifp", "dance3")
 --customIfp2 = engineLoadIFP ("Fortnite pt2.ifp", "Fortnite_2")
 --customIfp3 = engineLoadIFP ("Fortnite pt3.ifp", "Fortnite_3")
 if customIfp then
  outputDebugString ("Animaciones de Fortnite cargadas")
 else
  outputDebugString ("Las animaciones de Fortnite no fueron cargadas")
 end
end)
--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--
local x, y = guiGetScreenSize ()
local relposx = x/2
local medX = x/2
local ancho = -3780
local sizeX = ancho/3
local mitSize = sizeX*0.5
local botX = medX-mitSize
local relposx = y/2
local medX2 = y/2
local ancho2 = -2160
local sizeX2 = ancho2/3
local mitSize2 = sizeX2*0.5
local botX2 = medX2-mitSize2

animations = {}
painel = {
	[1] = false
}
function painelanim ()
	local mx,my = getCursorPosition ()
	local fullx,fully = guiGetScreenSize()
	dxDrawImage ( botX+sizeX+550, botX2+sizeX2+80, 120, 120,"Arquivos/Imagens/fuck.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+550, botX2+sizeX2+80, 120, 120) and 255 or 100 ))
	dxDrawImage ( botX+sizeX+440, botX2+sizeX2+140, 120, 120,"Arquivos/Imagens/chat.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+440, botX2+sizeX2+140, 120, 120) and 255 or 100))
	dxDrawImage ( botX+sizeX+350, botX2+sizeX2+230, 120, 120,"Arquivos/Imagens/smile.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+350, botX2+sizeX2+230, 120, 120) and 255 or 100))
	dxDrawImage ( botX+sizeX+360, botX2+sizeX2+350, 120, 120,"Arquivos/Imagens/handsup.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+360, botX2+sizeX2+350, 120, 120) and 255 or 100))
	dxDrawImage ( botX+sizeX+440, botX2+sizeX2+450, 120, 120,"Arquivos/Imagens/sentar.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+440, botX2+sizeX2+450, 120, 120) and 255 or 100))
	dxDrawImage ( botX+sizeX+550, botX2+sizeX2+490, 120, 120,"Arquivos/Imagens/cancel.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+550, botX2+sizeX2+490, 120, 120) and 255 or 100))
	dxDrawImage ( botX+sizeX+665, botX2+sizeX2+150, 120, 120,"Arquivos/Imagens/smoke.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+665, botX2+sizeX2+150, 120, 120) and 255 or 100))
	dxDrawImage ( botX+sizeX+760, botX2+sizeX2+230, 120, 120,"Arquivos/Imagens/sexy.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+760, botX2+sizeX2+230, 120, 120) and 255 or 100))
	dxDrawImage ( botX+sizeX+750, botX2+sizeX2+350, 120, 120,"Arquivos/Imagens/dance.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+750, botX2+sizeX2+350, 120, 120) and 255 or 100))
	dxDrawImage ( botX+sizeX+665, botX2+sizeX2+450, 120, 120,"Arquivos/Imagens/espere.png", 0, 0, 0, tocolor ( 255, 255, 255, isCursorOnElement(botX+sizeX+665, botX2+sizeX2+450, 120, 120) and 255 or 100) )
end

function animations.click (_, estado)
	if painel[1] == true then
		if estado == "down" then
			if isCursorOnElement(botX+sizeX+550, botX2+sizeX2+80, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				triggerServerEvent("anim.fuck", localPlayer)
			elseif isCursorOnElement(botX+sizeX+440, botX2+sizeX2+140, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				triggerServerEvent("anim.chat", localPlayer)
			elseif isCursorOnElement(botX+sizeX+665, botX2+sizeX2+150, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				sound = playSound("Arquivos/Sons/smoke.mp3")
				setTimer(stopSound, 40000, 1, sound)
				triggerServerEvent("anim.smoke", localPlayer)
			elseif isCursorOnElement(botX+sizeX+760, botX2+sizeX2+230, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				triggerServerEvent("anim.sexy", localPlayer)
			elseif isCursorOnElement(botX+sizeX+750, botX2+sizeX2+350, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				triggerServerEvent("anim.dance", localPlayer)
			elseif isCursorOnElement(botX+sizeX+665, botX2+sizeX2+450, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				triggerServerEvent("anim.espere", localPlayer)
			elseif isCursorOnElement(botX+sizeX+440, botX2+sizeX2+450, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				triggerServerEvent("anim.sentar", localPlayer)
			elseif isCursorOnElement(botX+sizeX+360, botX2+sizeX2+350, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				triggerServerEvent("anim.handsup", localPlayer)
			elseif isCursorOnElement(botX+sizeX+350, botX2+sizeX2+230, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				sound = playSound("Arquivos/Sons/BatendoUma.mp3")
				triggerServerEvent("anim.smile", localPlayer)
			elseif isCursorOnElement(botX+sizeX+550, botX2+sizeX2+490, 120, 120) then
				playSound("Arquivos/Sons/click.mp3")
				triggerServerEvent("anim.cancel", localPlayer)
			end
		end
	end
end
addEventHandler("onClientClick", root, animations.click )

function abrir ()
	if not painel[1] then 
		addEventHandler("onClientRender", root, painelanim)
		playSound("Arquivos/Sons/abrir.mp3")
	else
		removeEventHandler("onClientRender", root, painelanim)
		showCursor(false)
	end

	painel[1] = not painel[1]
	showCursor(painel[1])
end
bindKey("num_9", "both", abrir)

function isCursorOnElement(x,y,w,h)
	if (not isCursorShowing()) then
		return false
	end
	local mx,my = getCursorPosition ()
	local fullx,fully = guiGetScreenSize()
	cursorx,cursory = mx*fullx,my*fully
	if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
		return true
	else
		return false
	end
end