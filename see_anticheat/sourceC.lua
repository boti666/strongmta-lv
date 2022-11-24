addEventHandler("onClientPreRender", getRootElement(),
	function ()
		if isWorldSpecialPropertyEnabled("aircars") then 
			setElementHealth(localPlayer, 0)
			setWorldSpecialPropertyEnabled("aircars", false)

			outputChatBox("jo probalkozas volt :D")
		end
	end 
)

addEventHandler("onClientExplosion", getRootElement(),
	function ()
		--cancelEvent()
	end 
)

addEventHandler("onClientProjectileCreation", getRootElement(),
	function (whoIsTheCreator)
		if isElement(source) then 
			destroyElement(source)
		end

		cancelEvent()
	end 
)

addEventHandler("onClientExplosion", getRootElement(),
	function ()
		cancelEvent()
	end 
)