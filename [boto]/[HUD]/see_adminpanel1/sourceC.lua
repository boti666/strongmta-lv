local sreenX, screenY = guiGetScreenSize()

addEventHandler("onClientResourceStart", getRootElement(), 
	function(_ARG_0_)
	  	if getResourceName(_ARG_0_) == "lv_hud" then
	    	responsiveMultipler = exports.lv_hud:getResponsiveMultipler()
	    
	    if not isElement(adminChatBrowser) then
	      	adminChatBrowser = createBrowser(respc(500), respc(465), true, true)
	      	Roboto = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")
	    end
	  elseif source == getResourceRootElement() and getResourceFromName("lv_hud") and getResourceState((getResourceFromName("lv_hud"))) == "running" then
	    	responsiveMultipler = exports.lv_hud:getResponsiveMultipler()
	    	
	    	if not isElement(adminChatBrowser) then
	      		adminChatBrowser = createBrowser(respc(500), respc(465), true, true)
	      		Roboto = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")
	    	end
	  	end
	end
)

function respc(x)
  return math.ceil(x * responsiveMultipler)
end

addEventHandler("onClientBrowserCreated", getRootElement(), 
	function()
  		if source == adminChatBrowser then
    		loadBrowserURL(adminChatBrowser, "http://mta/local/files/chat.html")
  		end
	end
)

local panelState = false

local panelPosX, panelPosY = screenX / 2 / respc(960) / 2, 

addCommandHandler("apanel", 
	function()
	  	if (getElementData(localPlayer, "acc.adminLevel") or 0) >= 1 then
	    	if not panelState then
		      	panelState = true

		      	addEventHandler("onClientRender", getRootElement(), renderTheMessageBrowser)
		      	addEventHandler("onClientKey", getRootElement(), onBrowserKey)
		      	addEventHandler("onClientClick", getRootElement(), onClientClick)
		      	addEventHandler("onClientCharacter", getRootElement(), onClientCharacter)
		    else
		      	panelState = false

		      	removeEventHandler("onClientRender", getRootElement(), renderTheMessageBrowser)
		      	removeEventHandler("onClientKey", getRootElement(), onBrowserKey)
		      	removeEventHandler("onClientClick", getRootElement(), onClientClick)
		      	removeEventHandler("onClientCharacter", getRootElement(), onClientCharacter)
		    end
		end
	end
)

showConfirmation = true

function renderTheMessageBrowser()
	if showConfirmation then
	
	else
		dxDrawRectangle(panelPosX - respc(480), panelPosY - respc(280), respc(960), respc(30), tocolor(0, 0, 0, 230))
	end
end