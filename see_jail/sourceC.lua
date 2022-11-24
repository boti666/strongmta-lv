local screenX, screenY = guiGetScreenSize()

createObject(1537, 2352.025, 2500, 9.75, 0, 0, 90) -- lvpd door

local jailColShape = createColSphere(-18.462890625, 2321.8916015625, 24.303373336792, 10)
local jailTimer = false

local jailTime = false
local adminJail = false

local jailHandler = false
local loggedIn = false

local Roboto = false

local Roboto2 = dxCreateFont("files/Roboto.ttf", 14, false, "antialiased")

function createFonts()
	destroyFonts()
	Roboto = dxCreateFont("files/Roboto.ttf", 14, false, "antialiased")
end

function destroyFonts()
	if isElement(Roboto) then
		destroyElement(Roboto)
	end
	Roboto = nil
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		jailTimer = setTimer(jailProcess, 60000, 0)

		jailTime = getElementData(localPlayer, "acc.adminJailTime") or 0
		adminJail = getElementData(localPlayer, "acc.adminJail") or 0
		loggedIn = getElementData(localPlayer, "loggedIn")

		if adminJail > 0 and not jailHandler then
			jailHandler = true
			addEventHandler("onClientRender", getRootElement(), renderJail)
			createFonts()
		end
	end)

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName, oldValue)
		if dataName == "acc.adminJail" then
			adminJail = getElementData(localPlayer, "acc.adminJail")
			jailTime = getElementData(localPlayer, "acc.adminJailTime")

			if adminJail > 0 then
				if not jailHandler then
					jailHandler = true
					addEventHandler("onClientRender", getRootElement(), renderJail)
					createFonts()
				end
			elseif jailHandler then
				jailHandler = false
				removeEventHandler("onClientRender", getRootElement(), renderJail)
				destroyFonts()
			end
		elseif dataName == "loggedIn" then
			if not isTimer(jailTimer) then
				jailTimer = setTimer(jailProcess, 60000, 0)
			end

			adminJail = getElementData(localPlayer, "acc.adminJail") or 0
			jailTime = getElementData(localPlayer, "acc.adminJailTime") or 0
			loggedIn = getElementData(localPlayer, "loggedIn")

			if adminJail > 0 and not jailHandler then
				jailHandler = true
				addEventHandler("onClientRender", getRootElement(), renderJail)
				createFonts()
			end
		elseif dataName == "acc.adminJailTime" then
			local adminJailTime = tonumber(getElementData(localPlayer, "acc.adminJailTime"))

			if adminJailTime then
				jailTime = adminJailTime
			end
		end
	end)

addEventHandler("onClientElementColShapeLeave", getRootElement(),
	function (theShape)
		if theShape == jailColShape and source == localPlayer then
			local adminJail = tonumber(getElementData(localPlayer, "acc.adminJail"))

			if adminJail and adminJail > 0 then
				setElementPosition(source, getElementPosition(theShape))
			end
		end
	end)

addEvent("loadingScreenOnAJ", true)
addEventHandler("loadingScreenOnAJ", getRootElement(),
	function ()
		exports.see_hud:showTheLoadScreen(10000, {"Jail létrehozása...", "Jail betöltése..."})
	end)

function jailProcess()
	if getElementData(localPlayer, "loggedIn") then
		local charJail = getElementData(localPlayer, "char.jail") or 0

		if charJail ~= 0 then
			local jailTime = getElementData(localPlayer, "char.jailTime") or 0

			if jailTime - 1 <= 0 then
				fadeCamera(false, 1)
				setTimer(
					function ()
						setElementData(localPlayer, "char.jail", 0)
						setElementInterior(localPlayer, 0)
						setElementDimension(localPlayer, 0)
						setElementPosition(localPlayer, 2355.9521484375, 2498.85546875, 10.8203125)
						setElementPosition(localPlayer, 0, 0, 270)
						triggerServerEvent("getPlayerOutOfJail", localPlayer)

						exports.see_hud:showInfobox("i", "Szabadultál a börtönből. Légy jó állampolgár.")
						fadeCamera(true, 1)
					end,
				1000, 1)
			else
				setElementData(localPlayer, "char.jailTime", jailTime - 1)
				triggerServerEvent("updatePrisonTime", localPlayer, jailTime)
			end
		end

		local adminJail = getElementData(localPlayer, "acc.adminJail") or 0

		if adminJail ~= 0 then
			local jailTime = getElementData(localPlayer, "acc.adminJailTime") or 0

			if not isElementWithinColShape(localPlayer, jailColShape) then
				setElementPosition(localPlayer, getElementPosition(jailColShape))
			end

			if not jailHandler then
				jailHandler = true
				addEventHandler("onClientRender", getRootElement(), renderJail)
				createFonts()
			end

			if jailTime - 1 <= 0 then
				fadeCamera(false, 1)
				setTimer(
					function()
						setElementData(localPlayer, "acc.adminJail", 0)
						setElementData(localPlayer, "acc.adminJailTime", 0)
						
						setElementInterior(localPlayer, 0)
				 		setElementDimension(localPlayer, 0)
						setElementPosition(localPlayer, 2355.9521484375, 2498.85546875, 10.8203125)
						setElementRotation(localPlayer, 0, 0, 270)

				 		triggerServerEvent("getPlayerOutOfJail", localPlayer)
				 		exports.see_hud:showInfobox("info", "Szabadultál a börtönből. Ezentúl viselkedj normálisan.")

						fadeCamera(true, 1)
					end,
				1000, 1)
			else
				--print(jailTime - 1)
				--setElementData(localPlayer, "acc.adminJailTime", jailTime - 1)
				triggerServerEvent("updateJailTime", localPlayer, jailTime)
				--print(jailTime - 1)
			end
		end
	end
end

function renderJail()
	if loggedIn then
		dxDrawText("Hátralévő idő: " .. jailTime .. " perc", 0 + 1, screenY - 128 + 1, screenX + 1, screenY - 64 + 1, tocolor(0, 0, 0), 1, Roboto, "center", "center")
		dxDrawText("Hátralévő idő: #d75959" .. jailTime .. " perc", 0, screenY - 128, screenX, screenY - 64, tocolor(255, 255, 255), 1, Roboto, "center", "center", false, false, false, true)
	end
end