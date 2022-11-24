local chatInstance = false
local chatLoaded = false
local chatInstancePaused = false

local chatPosX = 0
local chatPosY = 0
local chatMove = true

local chatWidth = false
local chatHeight = false
local chatResize = true

local inputHeight = 20

local oocChatPosX = 0
local oocChatPosY = 0
local oocChatMove = true

local oocChatWidth = false
local oocChatHeight = false
local oocChatResize = true

local oocChatVisible = true

local inputActive = false
local inputValue = ""
local canUseInput = false
local activeChatType = false

local chatMaxMessage = 55
local chatMessageNum = 0
local sentMessages = {}
local lastSentMessage = ""
local selectedMessage = 0

local oocChatMaxMessage = 10
local oocChatMessageNum = 0
local oocChatMessages = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		chatInstance = createBrowser(screenX, screenY, true, true)
	end)

addEventHandler("onClientBrowserCreated", getResourceRootElement(),
	function ()
		if source == chatInstance then
			loadBrowserURL(chatInstance, "http://mta/local/customchat/files/index.html")
		end
	end)

addEventHandler("onClientBrowserDocumentReady", getResourceRootElement(),
	function ()
		if source == chatInstance then
			executeBrowserJavascript(chatInstance, "document.getElementById(\"innercontents\").style.fontSize=\"" .. respc(97) .. "%\"; document.getElementById(\"chatinput\").style.fontSize=\"" .. respc(97) .. "%\"; document.getElementById(\"innercontents\").scrollTop = document.getElementById(\"innercontents\").scrollHeight; var element=document.getElementById(\"innercontents\"),temp=document.createElement(element.nodeName);temp.setAttribute(\"style\",\"opacity:0;margin:0px;padding:0px;font-family:\"+element.style.fontFamily+\";font-size:\"+element.style.fontSize),temp.innerHTML=\"test\",temp=element.parentNode.appendChild(temp);var ret=temp.clientHeight;temp.parentNode.removeChild(temp); document.title = ret;")
			setTimer(resizeTheChat, 500, 1)
		end
	end)

function resizeTheChat()
	chatLoaded = true
	inputHeight = tonumber(getBrowserTitle(chatInstance)) or 20

	chatMove = true
	chatResize = true

	oocChatMove = true
	oocChatResize = true
	
	executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").innerHTML = \"Chat: \"; document.getElementById(\"chatinput\").style.width: " .. screenX .. "px; document.getElementById(\"chatinput\").style.height: " .. inputHeight .. "px;")
	executeBrowserJavascript(chatInstance, "document.getElementById(\"oocchatinput\").innerHTML = \"OOC: \"; document.getElementById(\"oocchatinput\").style.width: " .. screenY .. "px; document.getElementById(\"oocchatinput\").style.height: " .. inputHeight .. "px;")
end

function chatInputSwitched()
	if inputActive then
		if activeChatType == "radio" then
			executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").style.visibility = \"visible\"; document.getElementById(\"chatinput\").innerHTML = \"Rádió: \"; document.getElementById(\"chatinput\").style.left=\"" .. chatPosX .. "px\";document.getElementById(\"chatinput\").style.top=\"" .. chatPosY + chatHeight - inputHeight .. "px\";")
		elseif activeChatType == "normal" then
			executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").style.visibility = \"visible\"; document.getElementById(\"chatinput\").innerHTML = \"Chat: \"; document.getElementById(\"chatinput\").style.left=\"" .. chatPosX .. "px\";document.getElementById(\"chatinput\").style.top=\"" .. chatPosY + chatHeight - inputHeight .. "px\";")
		end
	else
		inputActive = false
		executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").style.visibility = \"hidden\";")
	end
end

function oocChatInputSwitched()
	if inputActive then
		executeBrowserJavascript(chatInstance, "document.getElementById(\"oocchatinput\").style.visibility = \"visible\"; document.getElementById(\"oocchatinput\").innerHTML = \"OOC: \"; document.getElementById(\"oocchatinput\").style.left=\"" .. oocChatPosX .. "px\";document.getElementById(\"oocchatinput\").style.top=\"" .. oocChatPosY + oocChatHeight - inputHeight .. "px\";")
	else
		executeBrowserJavascript(chatInstance, "document.getElementById(\"oocchatinput\").style.visibility = \"hidden\";")
	end
end

function refreshChatInputText()
	if activeChatType == "ooc" then
		executeBrowserJavascript(chatInstance, "document.getElementById(\"oocchatinput\").innerHTML = \"OOC: " .. escapeHTML(inputValue) .. "\";")
	elseif activeChatType == "radio" then
		executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").innerHTML = \"Rádió: " .. escapeHTML(inputValue) .. "\";")
	else
		executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").innerHTML = \"Chat: " .. escapeHTML(inputValue) .. "\";")
	end
end

function toggleChatInput(state)
	canUseInput = false
	
	if state then
		guiSetInputEnabled(true)
		showCursor(true)
		
		inputValue = ""
		lastSentMessage = inputValue
		selectedMessage = 0
		inputActive = true
		
		if activeChatType == "ooc" then
			oocChatInputSwitched()
		else
			chatInputSwitched()
		end
	else
		inputValue = ""
		lastSentMessage = inputValue
		inputActive = false
		
		if activeChatType == "ooc" then
			oocChatInputSwitched()
		else
			chatInputSwitched()
		end
		activeChatType = false
		
		guiSetInputEnabled(false)
		showCursor(false)
	end
	
	setElementData(localPlayer, "typing", inputActive or isChatBoxInputActive())
end

bindKey("t", "down",
	function ()
		if renderData.chatType == 1 and chatLoaded and not renderData.inTrash.chat then
			if not inputActive then
				activeChatType = "normal"
				toggleChatInput(true)
			end
		end
		
		setElementData(localPlayer, "typing", inputActive or isChatBoxInputActive())
	end)

bindKey("y", "down", "chatbox", "Rádió")
bindKey("y", "down",
	function ()
		if renderData.chatType == 1 and chatLoaded and not renderData.inTrash.chat then
			if not inputActive then
				activeChatType = "radio"
				toggleChatInput(true)
			end
		end
		
		setElementData(localPlayer, "typing", inputActive or isChatBoxInputActive())
	end)

addCommandHandler("Rádió",
	function (commandName, ...)
		if getElementData(localPlayer, "loggedIn") then
			local message = table.concat({...}, " ")
			
			if utf8.len(message) > 0 then
				local message2 = utf8.gsub(message, " ", "") or 0
	
				if utf8.len(message2) > 0 then
					triggerServerEvent("executeCommand", localPlayer, "r", message)
				end
			end
		end
	end)

bindKey("b", "down",
	function ()
		if renderData.chatType == 1 and chatLoaded and not renderData.inTrash.oocchat then
			if not inputActive then
				activeChatType = "ooc"
				toggleChatInput(true)
			end
		end
		
		setElementData(localPlayer, "typing", inputActive or isChatBoxInputActive())
	end)

function clearChatFunction()
	clearChatBox()

	if chatInstance then
		executeBrowserJavascript(chatInstance, "document.getElementById(\"innercontents\").innerHTML = \"<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>\"")
	end

	chatMessageNum = 0
end
addCommandHandler("clearchat", clearChatFunction)
addCommandHandler("cc", clearChatFunction)

function clearOOCChatFunction()
	if chatInstance then
		executeBrowserJavascript(chatInstance, "document.getElementById(\"oocinnercontents\").innerHTML = \"<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>\"")
	end

	oocChatMessageNum = 0
	oocChatMessages = {}
end
addCommandHandler("clearooc", clearOOCChatFunction)
addCommandHandler("co", clearOOCChatFunction)

addEventHandler("onClientCharacter", getRootElement(),
	function (character)
		if renderData.chatType == 1 and inputActive then
			if utf8.len(inputValue) < 128 then
				if canUseInput then
					inputValue = inputValue .. character
					refreshChatInputText()
				end

				canUseInput = true
			end
		end
	end)

local repeatStartTimer = false
local repeatTimer = false

local function subFakeInputText()
	inputValue = utf8.sub(inputValue, 1, -2)
	refreshChatInputText()
end

local function sendMessage(message)
	if utf8.len(message) >= 1 then
		message = utf8.gsub(message, "#%x%x%x%x%x%x", "")

		if utf8.find(utf8.sub(message, 1, 1), "/") then
			local parts = split(message, " ")
			local command = utf8.gsub(parts[1], "/", "")

			table.remove(parts, 1)

			local args = table.concat(parts, " ")

			if not executeCommandHandler(command, args) then
				--triggerServerEvent("executeCommand", localPlayer, command, args)
			end
		else
			if activeChatType == "radio" then
				--triggerServerEvent("executeCommand", localPlayer, "r", message)
				executeCommandHandler("r", message)
			elseif activeChatType == "ooc" then
				executeCommandHandler("b", message)
			else
				executeCommandHandler("say", message)
			end
		end

		table.insert(sentMessages, message)
		selectedMessage = 0
	end

	toggleChatInput(false)
end

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if renderData.chatType == 1 then
			if inputActive then
				if press then
					if key == "enter" or key == "num_enter" then
						cancelEvent()
						sendMessage(inputValue)
					elseif key == "backspace" then
						if utf8.len(inputValue) ~= 0 then
							inputValue = utf8.sub(inputValue, 1, -2)
							refreshChatInputText()

							repeatStartTimer = setTimer(
								function ()
									subFakeInputText()
									repeatTimer = setTimer(subFakeInputText, 50, 0)
								end,
							500, 1)
						end
					elseif key == "escape" then
						cancelEvent()
						toggleChatInput(false)
					elseif key == "arrow_u" then
						if sentMessages[selectedMessage + 1] or selectedMessage + 1 == 0 then
							selectedMessage = selectedMessage + 1
							
							if selectedMessage == 0 then
								inputValue = lastSentMessage
								refreshChatInputText()
							else
								inputValue = sentMessages[selectedMessage]
								refreshChatInputText()
							end
						end
					elseif key == "arrow_d" then
						if sentMessages[selectedMessage - 1] or selectedMessage - 1 == 0 then
							selectedMessage = selectedMessage - 1
							
							if selectedMessage == 0 then
								inputValue = lastSentMessage
								refreshChatInputText()
							else
								inputValue = sentMessages[selectedMessage]
								refreshChatInputText()
							end
						end
					end
				else
					if key == "backspace" then
						if isTimer(repeatStartTimer) then
							killTimer(repeatStartTimer)
						end
						
						if isTimer(repeatTimer) then
							killTimer(repeatTimer)
						end
					end
				end
			end
		end
	end)

chatRenderedOut = false

render.chat = function (x, y)
	if renderData.chatType == 1 then
		if chatInstance and chatLoaded then
			if chatInstancePaused then
				setBrowserRenderingPaused(chatInstance, false)
				chatInstancePaused = false
			end

			if not chatRenderedOut then
				dxDrawImage(0, 0, screenX, screenY, chatInstance)
				chatRenderedOut = true
			end

			if chatPosX ~= x then
				chatPosX = x
				chatMove = true
			end
			
			if chatPosY ~= y then
				chatPosY = y
				chatMove = true
			end
			
			if chatWidth ~= renderData.size.chatX then
				chatWidth = renderData.size.chatX
				chatResize = true
			end
			
			if chatHeight ~= renderData.size.chatY then
				chatHeight = renderData.size.chatY
				chatResize = true
			end

			if chatMove then
				executeBrowserJavascript(chatInstance, "document.getElementById(\"innercontents\").style.left=\"" .. chatPosX .. "px\";document.getElementById(\"innercontents\").style.top=\"" .. chatPosY .. "px\"; document.getElementById(\"innercontents\").scrollTop = document.getElementById(\"innercontents\").scrollHeight;")
			
				if inputActive then
					executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").style.left=\"" .. chatPosX .. "px\";document.getElementById(\"chatinput\").style.top=\"" .. chatPosY + chatHeight - inputHeight .. "px\";")
				end

				chatMove = false
			end
			
			if chatResize then
				executeBrowserJavascript(chatInstance, "document.getElementById(\"innercontents\").style.width=\"" .. chatWidth .. "px\";document.getElementById(\"innercontents\").style.height=\"" .. chatHeight - inputHeight .. "px\"; document.getElementById(\"innercontents\").scrollTop = document.getElementById(\"innercontents\").scrollHeight;")
			
				if inputActive then
					executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").style.left=\"" .. chatPosX .. "px\";document.getElementById(\"chatinput\").style.top=\"" .. chatPosY + chatHeight - inputHeight .. "px\";")
				end

				chatResize = false
			end

			return true
		end
	elseif not chatInstancePaused then
		if chatInstance and chatLoaded then
			setBrowserRenderingPaused(chatInstance, true)
			chatInstancePaused = true
		end
	end

	return false
end

render.oocchat = function (x, y)
	if renderData.chatType == 1 then
		if chatInstance and chatLoaded then
			if chatInstancePaused then
				setBrowserRenderingPaused(chatInstance, false)
				chatInstancePaused = false
			end

			if not chatRenderedOut then
				dxDrawImage(0, 0, screenX, screenY, chatInstance)
				chatRenderedOut = true
			end

			if oocChatPosX ~= x then
				oocChatPosX = x
				oocChatMove = true
			end
			
			if oocChatPosY ~= y then
				oocChatPosY = y
				oocChatMove = true
			end
			
			if oocChatWidth ~= renderData.size.oocchatX then
				oocChatWidth = renderData.size.oocchatX
				oocChatResize = true
			end
			
			if oocChatHeight ~= renderData.size.oocchatY then
				oocChatHeight = renderData.size.oocchatY
				oocChatResize = true
			end

			if oocChatMove then
				executeBrowserJavascript(chatInstance, "document.getElementById(\"oocinnercontents\").style.left=\"" .. oocChatPosX .. "px\";document.getElementById(\"oocinnercontents\").style.top=\"" .. oocChatPosY .. "px\"; document.getElementById(\"oocinnercontents\").scrollTop = document.getElementById(\"oocinnercontents\").scrollHeight;")
			
				if inputActive then
					executeBrowserJavascript(chatInstance, "document.getElementById(\"oocchatinput\").style.left=\"" .. oocChatPosX .. "px\";document.getElementById(\"oocchatinput\").style.top=\"" .. oocChatPosY + oocChatHeight - inputHeight .. "px\";")
				end

				oocChatMove = false
			end
			
			if oocChatResize then
				executeBrowserJavascript(chatInstance, "document.getElementById(\"oocinnercontents\").style.width=\"" .. oocChatWidth .. "px\";document.getElementById(\"oocinnercontents\").style.height=\"" .. oocChatHeight - inputHeight .. "px\"; document.getElementById(\"oocinnercontents\").scrollTop = document.getElementById(\"oocinnercontents\").scrollHeight;")
			
				if inputActive then
					executeBrowserJavascript(chatInstance, "document.getElementById(\"oocchatinput\").style.left=\"" .. oocChatPosX .. "px\";document.getElementById(\"oocchatinput\").style.top=\"" .. oocChatPosY + oocChatHeight - inputHeight .. "px\";")
				end

				oocChatResize = false
			end

			return true
		end
	else
		if not chatInstancePaused then
			if chatInstance and chatLoaded then
				setBrowserRenderingPaused(chatInstance, true)
				chatInstancePaused = true
			end
		end

		if renderData.chatType == 0 then
			if isChatVisible() and oocChatVisible then
				dxDrawText("OOC Chat (eltüntetéshez /tog ooc)", x + 1, y + 1, 0, 0, tocolor(0, 0, 0), 1, "default-bold", "left", "top")
				dxDrawText("OOC Chat (eltüntetéshez /tog ooc)", x, y, 0, 0, tocolor(205, 205, 205), 1, "default-bold", "left", "top")

				for i = 1, #oocChatMessages do
					local v = oocChatMessages[i]

					dxDrawText(v[1], x + 1, y + (oocChatMessageNum + 1) * 15 - i * 15 + 1, 0, 0, tocolor(0, 0, 0), 1, "default-bold", "left", "top")
					dxDrawText(v[1], x, y + (oocChatMessageNum + 1) * 15 - i * 15, 0, 0, v[2], 1, "default-bold", "left", "top")
				end

				return true
			end
		end
	end

	return false
end

showChat(false)

function escapeHTML(html)
	html = utf8.gsub(html, "&", "&amp;")
	html = utf8.gsub(html, "<", "&lt;")
	html = utf8.gsub(html, ">", "&gt;")
	html = utf8.gsub(html, "\"", "&quot;")
	html = utf8.gsub(html, "'", "&#39;")
	html = utf8.gsub(html, "/", "&#x2F;")
	return html
end

addEventHandler("onClientChatMessage", getRootElement(),
	function (msg, r, g, b)
		if r == 255 and g == 150 and b == 255 then
			return
		end
		
		local formatted = false

		if utf8.find(msg, "\n") then
			local lines = split(msg, "\n")

			for i = 1, #lines do
				outputChatBox(lines[i], 255, 255, 255, true)
			end

			return
		end

		if utf8.sub(msg, 1, 12) == "[formatting]" then
			msg = utf8.sub(msg, 13, utf8.len(msg))
			formatted = true
			cancelEvent()
		end
		
		local color = string.format("#%02x%02x%02x", r, g, b)
		local html = color .. escapeHTML(msg)
		
		if utf8.find(utf8.sub(html, 8, 16), "#%x%x%x%x%x%x%[") then
			local endpos = utf8.find(html, "%]:")

			if endpos then
				html = "<b>" .. utf8.sub(html, 1, endpos) .. "</b>" .. utf8.sub(html, endpos + 1, utf8.len(html))
			end
		end

		html = utf8.gsub(html, "#%x%x%x%x%x%x", "</font><font style='color: %1;'>")
		
		if formatted then
			msg = utf8.gsub(msg, "%[(fa%-(.-))%]", "")
			msg = utf8.gsub(msg, "%[b%]", "")
			msg = utf8.gsub(msg, "%[/b%]", "")
			msg = utf8.gsub(msg, "%[i%]", "")
			msg = utf8.gsub(msg, "%[/i%]", "")
			msg = utf8.gsub(msg, "%[u%]", "")
			msg = utf8.gsub(msg, "%[/u%]", "")
			
			html = utf8.gsub(html, "%[(fa%-(.-))%]", "<i class='fa %1' style='color: inherit; vertical-align: middle;'></i>")
			html = utf8.gsub(html, "%[b%]", "<b style='color: inherit;'>")
			html = utf8.gsub(html, "%[&#x2F;b%]", "</b>")
			html = utf8.gsub(html, "%[i%]", "<i style='color: inherit;'>")
			html = utf8.gsub(html, "%[&#x2F;i%]", "</i>")
			html = utf8.gsub(html, "%[u%]", "<ins style='color: inherit;'>")
			html = utf8.gsub(html, "%[&#x2F;u%]", "</ins>")
			
			outputChatBox(color .. msg, 255, 150, 255, true)
		end

		chatMessageNum = chatMessageNum + 1
		
		if chatInstance and chatLoaded then
			executeBrowserJavascript(chatInstance, "document.getElementById(\"innercontents\").innerHTML=document.getElementById(\"innercontents\").innerHTML+\"" .. html .. "<br />\"; document.getElementById(\"innercontents\").scrollTop = document.getElementById(\"innercontents\").scrollHeight;")
		end

		if chatMessageNum > chatMaxMessage then
			chatMessageNum = chatMaxMessage

			if chatInstance and chatLoaded then
				executeBrowserJavascript(chatInstance, "var lines=document.getElementById(\"innercontents\").innerHTML.split(\"<br>\");lines.splice(0,1);document.getElementById(\"innercontents\").innerHTML = lines.join(\"<br />\");")
			end
		end
	end, true, "high+99999")

addEvent("onClientRecieveOOCMessage", true)
addEventHandler("onClientRecieveOOCMessage", getRootElement(),
	function (msg, sender, spectated)
		oocChatMessageNum = oocChatMessageNum + 1

		if chatInstance and chatLoaded then
			local html = escapeHTML(sender .. ": (( " .. msg .. " ))")

			if html:find("#%x%x%x%x%x%x") then
				local col = html:match("#%x%x%x%x%x%x")

				html = html:gsub("#%x%x%x%x%x%x", "<span style='color:" .. col .. "'>") .. "</span>"
			end

			if spectated then
				html = "<i class='fa fa-headphones' style='color: #5E5E5E; vertical-align: middle;'></i> " .. html
			end

			executeBrowserJavascript(chatInstance, "document.getElementById(\"oocinnercontents\").innerHTML=document.getElementById(\"oocinnercontents\").innerHTML+\"" .. html .. "<br />\"; document.getElementById(\"oocinnercontents\").scrollTop = document.getElementById(\"oocinnercontents\").scrollHeight;")
		end

		if oocChatMessageNum > oocChatMaxMessage then
			oocChatMessageNum = oocChatMaxMessage

			if chatInstance and chatLoaded then
				executeBrowserJavascript(chatInstance, "var lines=document.getElementById(\"oocinnercontents\").innerHTML.split(\"<br>\");lines.splice(0,1);document.getElementById(\"oocinnercontents\").innerHTML = lines.join(\"<br />\");")
			end
		end

		if #oocChatMessages >= oocChatMaxMessage then
			table.remove(oocChatMessages, oocChatMaxMessage)
		end

		local col = false

		if sender:find("#%x%x%x%x%x%x") then
			col = sender:match("#%x%x%x%x%x%x")
		end

		sender = sender:gsub("#%x%x%x%x%x%x", "")

		if spectated then
			sender = "[>o<] " .. sender
		end

		table.insert(oocChatMessages, 1, {sender .. ": (( " .. msg .. " ))", tocolor(hex2rgb(col))})
		
		outputConsole(sender .. ": (( " .. msg .. " ))")
	end)

function hex2rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

addCommandHandler("tog",
	function (commandName, str)
		if str == "ooc" or str == "OOC" then
			oocchatVisible = not oocchatVisible
		end
	end)

function getChatInstance()
	return chatInstance
end

function getChatBackgroundAlpha()
	return renderData.chatBGAlpha
end

function setChatBackgroundAlpha(alpha)
	if tonumber(alpha) and alpha >= 0 and alpha <= 255 then
		renderData.chatBGAlpha = alpha
		executeBrowserJavascript(chatInstance, "document.getElementById(\"oocchatinput\").style.backgroundColor=\"rgba(0,0,0," .. alpha / 255 .. ")\";")
		executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").style.backgroundColor=\"rgba(0,0,0," .. alpha / 255 .. ")\";")
		executeBrowserJavascript(chatInstance, "document.getElementById(\"innercontents\").style.backgroundColor=\"rgba(0,0,0," .. alpha / 255 .. ")\";")
		executeBrowserJavascript(chatInstance, "document.getElementById(\"oocinnercontents\").style.backgroundColor=\"rgba(0,0,0," .. alpha / 255 .. ")\";")
	end
end

function getChatFontBackgroundAlpha()
	return renderData.chatFontBGAlpha
end

function setChatFontBackgroundAlpha(alpha)
	if tonumber(alpha) and alpha >= 0 and alpha <= 255 then
		renderData.chatFontBGAlpha = alpha
		executeBrowserJavascript(chatInstance, "document.getElementById(\"shadow\").innerHTML = \"* { text-shadow: 1px 1px rgba(0, 0, 0, " .. alpha / 255 .. "); }\";")
	end
end

function getChatFontSize()
	return renderData.chatFontSize or 100
end

function setChatFontSize(size)
	if tonumber(size) then
		size = math.floor(tonumber(size))
		
		if size >= 50 and size <= 200 then
			renderData.chatFontSize = size
			executeBrowserJavascript(chatInstance, "document.getElementById(\"oocchatinput\").style.fontSize=\"" .. size .. "%\";")
			executeBrowserJavascript(chatInstance, "document.getElementById(\"chatinput\").style.fontSize=\"" .. size .. "%\";")
			executeBrowserJavascript(chatInstance, "document.getElementById(\"innercontents\").style.fontSize=\"" .. size .. "%\";")
			executeBrowserJavascript(chatInstance, "document.getElementById(\"oocinnercontents\").style.fontSize=\"" .. size .. "%\";")
			setTimer(resizeTheChat, 500, 1)
		end
	end
end