
-- Bind Keys required
function bindKeys()
	for k, arrayPlayer in ipairs(getElementsByType("player")) do
		if not(isKeyBound(arrayPlayer, "space", "down", stopAnimation)) then
			--bindKey(arrayPlayer, "space", "down", stopAnimation)
		end
	end
end

function bindKeysOnJoin()
	--bindKey(source, "space", "down", stopAnimation)
end
addEventHandler("onResourceStart", getResourceRootElement(), bindKeys)
addEventHandler("onPlayerJoin", getRootElement(), bindKeysOnJoin)

function bindAnimationStopKey()
	bindKey(source, "space", "down", stopAnimation)
end
addEvent("bindAnimationStopKey", false)
addEventHandler("bindAnimationStopKey", getRootElement(), bindAnimationStopKey)

function forcedAnim()
	setElementData(source, "forcedanimation", 1)
end
addEvent("forcedanim", true)
addEventHandler("forcedanim", getRootElement(), forcedAnim)

function unforcedAnim()
	setElementData(source, "forcedanimation", 0)
end
addEvent("unforcedanim", true)
addEventHandler("unforcedanim", getRootElement(), unforcedAnim)

function unbindAnimationStopKey()
	unbindKey(source, "space", "down", stopAnimation)
end
addEvent("unbindAnimationStopKey", false)
addEventHandler("unbindAnimationStopKey", getRootElement(), unbindAnimationStopKey)

function stopAnimation(thePlayer)
	if getElementHealth(thePlayer) > 20 then 
		local forcedanimation = getElementData(thePlayer, "forcedanimation")
		
		if not (forcedanimation==1) then
			removeAnimation(thePlayer)
			triggerEvent("unbindAnimationStopKey", thePlayer)
		end
	end
end
addCommandHandler("stopanim", stopAnimation, false, false)
addCommandHandler("stopani", stopAnimation, false, false)

function animationList(thePlayer)
	outputChatBox("/piss /wank /slapass /fixcar /handsup /hailtaxi /scratch /fu /carchat", thePlayer, 255, 194, 14)
	outputChatBox("/strip 1-2 /lightup /drink /beg /mourn /cheer 1-3 /dance 1-3", thePlayer, 255, 194, 14)
	outputChatBox("/gsign 1-5 /puke /rap 1-3 /sit 1-3 /smoke 1-3 /smokelean /laugh", thePlayer, 255, 194, 14)
	outputChatBox("/daps 1-2 /shove /bitchslap /shocked /dive /what /fall /fallfront /cpr", thePlayer, 255, 194, 14)
	outputChatBox("/copcome /copleft /copstop /wait /think /shake /idle /lay /cry /aim", thePlayer, 255, 194, 14)
	outputChatBox("/tired /crack 1-2 /walk 1-37 /drag /win 1-2 /startrace /bat 1-3", thePlayer, 255, 194, 14)
	outputChatBox("/copaway /bomb /cover /heil /beg /mourn /kickballs /grabbottle", thePlayer, 255, 194, 14)
	outputChatBox("/taichi 1-3 /nem /igen /meno /sex1 /sex2", thePlayer, 255, 194, 14)
	outputChatBox("/stopanim vagy SPACE az animáció befejezéséhez.", thePlayer, 255, 194, 14)
end
addCommandHandler("animlist", animationList, false, false)
addCommandHandler("animhelp", animationList, false, false)
addCommandHandler("anims", animationList, false, false)
addCommandHandler("animations", animationList, false, false)

function resetAnimation(thePlayer)
	removeAnimation(thePlayer)
end

-- /cover animtion -------------------------------------------------
function coverAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end

	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "ped", "duck_cower", -1, false, false, false)
	end
end
addCommandHandler("cover", coverAnimation, false, false)

-- /sex animtion -------------------------------------------------
function sex(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "SEX", "SEX_1_Cum_W", -1, true, false, false)
	end
end
addCommandHandler("sex1", sex, false, false)

-- /sex2 animtion -------------------------------------------------
function sex2(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "SEX", "SEX_1_Cum_P", -1, true, false, false)
	end
end
addCommandHandler("sex2", sex2, false, false)

-- /nem animtion -------------------------------------------------
function nem(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end

	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "GANGS", "Invite_No", -1, true, false, false)
	end
end
addCommandHandler("nem", nem, false, false)

-- /igen animtion -------------------------------------------------
function igen(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end

	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "GANGS", "Invite_Yes", -1, true, false, false)
	end
end
addCommandHandler("igen", igen, false, false)

-- /meno animtion -------------------------------------------------
function meno(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end

	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "benchpress", "gym_bp_celebrate", -1, true, false, false)
	end
end
addCommandHandler("meno", meno, false, false)

-- /bomb animtion -------------------------------------------------
function BOMBcoverAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end

	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "BOMBER", "BOM_Plant_Loop", -1, true, false, false)
	end
end
addCommandHandler("bomb", BOMBcoverAnimation, false, false)

-- /cpr animtion -------------------------------------------------
function cprAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "medic", "cpr", 8000, false, true, false)
	end
end
addCommandHandler("cpr", cprAnimation, false, false)

-- cop away Animation -------------------------------------------------------------------------
function copawayAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "police", "coptraf_away", 1300, true, false, false)
	end
end
addCommandHandler("copaway", copawayAnimation, false, false)

-- Cop come animation
function copcomeAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "POLICE", "CopTraf_Come", -1, true, false, false)
	end
end
addCommandHandler("copcome", copcomeAnimation, false, false)

-- Cop Left Animation -------------------------------------------------------------------------
function copleftAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "POLICE", "CopTraf_Left", -1, true, false, false)
	end
end
addCommandHandler("copleft", copleftAnimation, false, false)

-- Cop Stop Animation -------------------------------------------------------------------------
function copstopAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "POLICE", "CopTraf_Stop", -1, true, false, false)
	end
end
addCommandHandler("copstop", copstopAnimation, false, false)

-- Wait Animation -------------------------------------------------------------------------
function pedWait(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
	end
end
addCommandHandler ( "wait", pedWait, false, false )

-- Think Animation (/wait modifier) ---------------------------------------------------------------
function pedThink(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "COP_AMBIENT", "Coplook_think", -1, true, false, false)
	end
end
addCommandHandler ( "think", pedThink, false, false )

-- Shake Animation(/wait modifier) ---------------------------------------------------------------
function pedShake(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "COP_AMBIENT", "Coplook_shake", -1, true, false, false)
	end
end
addCommandHandler ( "shake", pedShake, false, false )

-- Lean Animation -------------------------------------------------------------------------
function pedLean(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "GANGS", "leanIDLE", -1, true, false, false)
	end
end
addCommandHandler ( "lean", pedLean, false, false )

-- /idle animtion -------------------------------------------------
function idleAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "DEALER", "DEALER_IDLE_01", -1, true, false, false)
	end
end
addCommandHandler("idle", idleAnimation, false, false)

-- Piss Animation -------------------------------------------------------------------------
function pedPiss(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "PAULNMAC", "Piss_loop", -1, true, false, false)
	end
end
addCommandHandler ( "piss", pedPiss, false, false )
addCommandHandler ( "pee", pedPiss, false, false )

-- Wank Animation -------------------------------------------------------------------------
function pedWank(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "PAULNMAC", "wank_loop", -1, true, false, false)
	end
end
addCommandHandler ( "wank", pedWank, false, false )

-- Slap Ass Animation -------------------------------------------------------------------------
function pedSlapAss(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "SWEET", "sweet_ass_slap", 2000, true, false, false)
	end
end
addCommandHandler ( "slapass", pedSlapAss, false, false )

-- fix car Animation -------------------------------------------------------------------------
function pedCarFix(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "CAR", "Fixn_Car_loop", -1, true, false, false)
	end
end
addCommandHandler ( "fixcar", pedCarFix, false, false )

-- Hands Up Animation -------------------------------------------------------------------------
function pedHandsup(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "ped", "handsup", -1, false, false, false)
	end
end
addCommandHandler ( "handsup", pedHandsup, false, false )

-- Hail Taxi -----------------------------------------------------------------------------------
function pedTaxiHail(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "MISC", "Hiker_Pose", -1, false, true, false)
	end
end
addCommandHandler ("hailtaxi", pedTaxiHail, false, false )

-- Scratch Balls Animation -------------------------------------------------------------------------
function pedScratch(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "MISC", "Scratchballs_01", -1, true, true, false)
	end
end
addCommandHandler ( "scratch", pedScratch, false, false )

-- F*** You Animation -------------------------------------------------------------------------
function pedFU(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "RIOT", "RIOT_FUKU", 800, false, true, false)
	end
end
addCommandHandler ( "fu", pedFU, false, false )

-- Strip Animation -------------------------------------------------------------------------
function pedStrip( thePlayer, cmd, arg )
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "STRIP", "STR_Loop_C", -1, false, true, false)
		else
			applyAnimation( thePlayer, "STRIP", "strip_D", -1, false, true, false)
		end
	end
end
addCommandHandler ( "strip", pedStrip, false, false )

-- Light up Animation -------------------------------------------------------------------------
function pedLightup (thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "SMOKING", "M_smk_in", 4000, true, true, false)
	end
end
addCommandHandler ( "lightup", pedLightup, false, false )

-- Light up Animation -------------------------------------------------------------------------
function pedHeil (thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "ON_LOOKERS", "Pointup_in", 999999, false, true, false)
	end
end
addCommandHandler ( "heil", pedHeil, false, false )

-- Drink Animation -------------------------------------------------------------------------
function pedDrink( thePlayer )
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "BAR", "dnk_stndM_loop", 2300, false, false, false)
	end
end
addCommandHandler ( "drink", pedDrink, false, false )

-- Lay Animation -------------------------------------------------------------------------
function pedLay( thePlayer, cmd, arg )
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "BEACH", "sitnwait_Loop_W", -1, true, false, false)
		else
			applyAnimation( thePlayer, "BEACH", "Lay_Bac_Loop", -1, true, false, false)
		end
	end
end
addCommandHandler ( "lay", pedLay, false, false )

-- beg Animation -------------------------------------------------------------------------
function begAnimation( thePlayer )
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "SHOP", "SHP_Rob_React", 4000, true, false, false)
	end
end
addCommandHandler ( "beg", begAnimation, false, false )

-- Mourn Animation -------------------------------------------------------------------------
function pedMourn( thePlayer )
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "GRAVEYARD", "mrnM_loop", -1, true, false, false)
	end
end
addCommandHandler ( "mourn", pedMourn, false, false )

-- Cry Animation -------------------------------------------------------------------------
function pedCry( thePlayer )
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "GRAVEYARD", "mrnF_loop", -1, true, false, false)
	end
end
addCommandHandler ( "cry", pedCry, false, false )

-- Cheer Amination -------------------------------------------------------------------------
function pedCheer(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "OTB", "wtchrcg_win", -1, true, false, false)
		elseif arg == 3 then
			applyAnimation( thePlayer, "RIOT", "RIOT_shout", -1, true, false, false)
		else
			applyAnimation( thePlayer, "STRIP", "PUN_HOLLER", -1, true, false, false)
		end
	end
end
addCommandHandler ( "cheer", pedCheer, false, false )

-- Dance Animation -------------------------------------------------------------------------
function danceAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "DANCING", "DAN_Down_A", -1, true, false, false)
		elseif arg == 3 then
			applyAnimation( thePlayer, "DANCING", "dnce_M_d", -1, true, false, false)
		else
			applyAnimation( thePlayer, "DANCING", "DAN_Right_A", -1, true, false, false)
		end
	end
end
addCommandHandler ( "dance", danceAnimation, false, false )

-- Crack Animation -------------------------------------------------------------------------
function crackAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "CRACK", "crckidle1", -1, true, false, false)
		elseif arg == 3 then
			applyAnimation( thePlayer, "CRACK", "crckidle3", -1, true, false, false)
		elseif arg == 4 then
			applyAnimation( thePlayer, "CRACK", "crckidle4", -1, true, false, false)
		else
			applyAnimation( thePlayer, "CRACK", "crckidle2", -1, true, false, false)
		end
	end
end
addCommandHandler ( "crack", crackAnimation, false, false )

-- /gsign animtion -------------------------------------------------
function gsignAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation(thePlayer, "GHANDS", "gsign2", 4000, true, false, false)
		elseif arg == 3 then
			applyAnimation(thePlayer, "GHANDS", "gsign3", 4000, true, false, false)
		elseif arg == 4 then
			applyAnimation(thePlayer, "GHANDS", "gsign4", 4000, true, false, false)
		elseif arg == 5 then
			applyAnimation(thePlayer, "GHANDS", "gsign5", 4000, true, false, false)
		else
			applyAnimation(thePlayer, "GHANDS", "gsign1", 4000, true, false, false)
		end
	end
end
addCommandHandler("gsign", gsignAnimation, false, false)

-- /puke animtion -------------------------------------------------
function pukeAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "FOOD", "EAT_Vomit_P", 8000, true, false, false)
	end
end
addCommandHandler("puke", pukeAnimation, false, false)

-- /rap animtion -------------------------------------------------
function rapAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "LOWRIDER", "RAP_B_Loop", -1, true, false, false)
		elseif arg == 3 then
			applyAnimation( thePlayer, "LOWRIDER", "RAP_C_Loop", -1, true, false, false)
		else
			applyAnimation( thePlayer, "LOWRIDER", "RAP_A_Loop", -1, true, false, false)
		end
	end
end
addCommandHandler("rap", rapAnimation, false, false)

-- /aim animtion -------------------------------------------------
function aimAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "SHOP", "ROB_Loop_Threat", -1, false, true, false)
	end
end
addCommandHandler("aim", aimAnimation, false, false)

-- /sit animtion -------------------------------------------------
function sitAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if isPedInVehicle( thePlayer ) then
			if arg == 2 then
				setPedAnimation( thePlayer, "CAR", "Sit_relaxed" )
			else
				setPedAnimation( thePlayer, "CAR", "Tap_hand" )
			end
			source = thePlayer
			bindAnimationStopKey()
		else
			if arg == 2 then
				applyAnimation( thePlayer, "FOOD", "FF_Sit_Look", -1, true, false, false)
			elseif arg == 3 then
				applyAnimation( thePlayer, "Attractors", "Stepsit_loop", -1, true, false, false)
			elseif arg == 4 then
				applyAnimation( thePlayer, "BEACH", "ParkSit_W_loop", 1, true, false, false)
			elseif arg == 5 then
				applyAnimation( thePlayer, "BEACH", "ParkSit_M_loop", 1, true, false, false)
			else
				applyAnimation( thePlayer, "ped", "SEAT_idle", -1, true, false, false)
			end
		end
	end
end
addCommandHandler("sit", sitAnimation, false, false)

-- /smoke animtion -------------------------------------------------
function smokeAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "SMOKING", "M_smkstnd_loop", -1, true, false, false)
		elseif arg == 3 then
			applyAnimation( thePlayer, "LOWRIDER", "M_smkstnd_loop", -1, true, false, false)
		else
			applyAnimation( thePlayer, "GANGS", "smkcig_prtl", -1, true, false, false)
		end
	end
end
addCommandHandler("smoke", smokeAnimation, false, false)

-- /smokelean animtion -------------------------------------------------
function smokeleanAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "LOWRIDER", "M_smklean_loop", -1, true, false, false)
	end
end
addCommandHandler("smokelean", smokeleanAnimation, false, false)

-- /drag animtion -------------------------------------------------
function smokedragAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "SMOKING", "M_smk_drag", 4000, true, false, false)
	end
end
addCommandHandler("drag", smokedragAnimation, false, false)

-- /laugh animtion -------------------------------------------------
function laughAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "RAPPING", "Laugh_01", -1, true, false, false)
	end
end
addCommandHandler("laugh", laughAnimation, false, false)

-- /startrace animtion -------------------------------------------------
function startraceAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "CAR", "flag_drop", 4200, true, false, false)
	end
end
addCommandHandler("startrace", startraceAnimation, false, false)

-- /carchat animtion -------------------------------------------------
function carchatAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "CAR_CHAT", "car_talkm_loop", -1, true, false, false)
	end
end
addCommandHandler("carchat", carchatAnimation, false, false)

-- /tired animtion -------------------------------------------------
function tiredAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "FAT", "idle_tired", -1, true, false, false)
	end
end
addCommandHandler("tired", tiredAnimation, false, false)

-- /daps animtion -------------------------------------------------
function handshakeAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "GANGS", "hndshkca", -1, true, false, false)
		else
			applyAnimation( thePlayer, "GANGS", "hndshkfa", -1, true, false, false)
		end
	end
end
addCommandHandler("daps", handshakeAnimation, false, false)

-- /shove animtion -------------------------------------------------
function shoveAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "GANGS", "shake_carSH", -1, true, false, false)
	end
end
addCommandHandler("shove", shoveAnimation, false, false)

-- /bitchslap animtion -------------------------------------------------
function bitchslapAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "MISC", "bitchslap", -1, true, false, false)
	end
end
addCommandHandler("bitchslap", bitchslapAnimation, false, false)

-- /shocked animtion -------------------------------------------------
function shockedAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "ON_LOOKERS", "panic_loop", -1, true, false, false)
	end
end
addCommandHandler("shocked", shockedAnimation, false, false)

-- /dive animtion -------------------------------------------------
function diveAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation(thePlayer, "ped", "EV_dive", -1, false, true, false)
	end
end
addCommandHandler("dive", diveAnimation, false, false)

-- /what Amination -------------------------------------------------------------------------
function whatAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "RIOT", "RIOT_ANGRY", -1, true, false, false)
	end
end
addCommandHandler ( "what", whatAnimation, false, false )

-- /fallfront Amination -------------------------------------------------------------------------
function fallfrontAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "ped", "FLOOR_hit_f", -1, false, false, false)
	end
end
addCommandHandler ( "fallfront", fallfrontAnimation, false, false )

-- /fall Amination -------------------------------------------------------------------------
function fallAnimation(thePlayer)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "ped", "FLOOR_hit", -1, false, false, false)
	end
end
addCommandHandler ( "fall", fallAnimation, false, false )

-- /walk animation -------------------------------------------------------------------------
local walk = {
	"WALK_armed", "WALK_civi", "WALK_csaw", "Walk_DoorPartial", "WALK_drunk", "WALK_fat", "WALK_fatold", "WALK_gang1", "WALK_gang2", "WALK_old",
	"WALK_player", "WALK_rocket", "WALK_shuffle", "Walk_Wuzi", "woman_run", "WOMAN_runbusy", "WOMAN_runfatold", "woman_runpanic", "WOMAN_runsexy", "WOMAN_walkbusy",
	"WOMAN_walkfatold", "WOMAN_walknorm", "WOMAN_walkold", "WOMAN_walkpro", "WOMAN_walksexy", "WOMAN_walkshop", "run_1armed", "run_armed", "run_civi", "run_csaw",
	"run_fat", "run_fatold", "run_gang1", "run_old", "run_rocket", "Run_Wuzi"
}
function walkAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if not walk[arg] then
			arg = 2
		end
		
		applyAnimation( thePlayer, "PED", walk[arg], -1, true, true, false)
	end
end
addCommandHandler("walk", walkAnimation, false, false)

-- /bat animtion -------------------------------------------------
function batAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "CRACK", "Bbalbat_Idle_02", -1, true, false, false)
		elseif arg == 3 then
			applyAnimation( thePlayer, "Baseball", "Bat_IDLE", -1, true, false, false)
		else
			applyAnimation( thePlayer, "CRACK", "Bbalbat_Idle_01", -1, true, false, false)
		end
	end
end
addCommandHandler("bat", batAnimation, false, false)

-- /win Amination -------------------------------------------------------------------------
function winAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	
	if getElementData(thePlayer, "loggedIn") then
		if arg == 2 then
			applyAnimation( thePlayer, "CASINO", "manwinb", 2000, false, false, false)
		else
			applyAnimation( thePlayer, "CASINO", "manwind", 2000, false, false, false)
		end
	end
end
addCommandHandler ( "win", winAnimation, false, false )

-- /kickballs Amination -------------------------------------------------------------------------
function kickballsAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "FIGHT_E", "FightKick_B", 1, false, true, false)
	end
end
addCommandHandler ( "kickballs", kickballsAnimation, false, false )

-- /grabbottle Amination -------------------------------------------------------------------------
function grabbAnimation(thePlayer, cmd, arg)
	if ( getElementData(thePlayer, "tazed") == 1 ) then return end

	if getElementData(thePlayer, "loggedIn") then
		applyAnimation( thePlayer, "BAR", "Barserve_bottle", 2000, false, false, false)
	end
end
addCommandHandler ( "grabbottle", grabbAnimation, false, false )
-- /taichi animtion -------------------------------------------------
function taichiAnimation(thePlayer, cmd, arg)
if ( getElementData(thePlayer, "tazed") == 1 ) then return end
	arg = tonumber(arg)
	if getElementData(thePlayer, "loggedIn") then
	if arg == 2 then
	applyAnimation( thePlayer, "PARK", "Tai_Chi_in", -1, true, false, false)
	elseif arg == 3 then
	applyAnimation( thePlayer, "PARK", "Tai_Chi_Loop", -1, true, false, false)
	else
	applyAnimation( thePlayer, "PARK", "Tai_Chi_Out", -1, true, false, false)
	end	end
	end
	addCommandHandler("taichi", taichiAnimation, false, false)


function applyAnimation(thePlayer, block, name, animtime, loop, updatePosition, forced)
	if animtime==nil then animtime=-1 end
	if loop==nil then loop=true end
	if updatePosition==nil then updatePosition=true end
	if forced==nil then forced=true end
	
	local forcedanimation = getElementData(thePlayer, "forcedanimation")
	if (forcedanimation==1) then return end
	if isElementInWater ( thePlayer ) then return end

	if isElement(thePlayer) and getElementType(thePlayer)=="player" and not getPedOccupiedVehicle(thePlayer) and getElementData(thePlayer, "freeze") ~= 1 then
		if getElementData(thePlayer, "injuriedanimation") or ( not forced and not getElementData(thePlayer, "forcedanimation")==1 ) then
			return false
		end
	
		triggerEvent("bindAnimationStopKey", thePlayer)
		toggleAllControls(thePlayer, false, true, false)
		
		if (forced) then
			setElementData(thePlayer, "forcedanimation", 1)
		else
			setElementData(thePlayer, "forcedanimation", 0)
		end
		
		local setanim = setPedAnimation(thePlayer, block, name, animtime, loop, updatePosition, false)
		if animtime > 100 then
			setTimer(setPedAnimation, 50, 2, thePlayer, block, name, animtime, loop, updatePosition, false)
		end
		if animtime > 50 then
			setElementData(thePlayer, "animationt", setTimer(removeAnimation, animtime, 1, thePlayer), false)
		end
		return setanim
	else
		return false
	end
end

function onSpawn()
	setPedAnimation(source)
	toggleAllControls(source, true, true, false)
	setElementData(source, "forcedanimation", 0)
end
addEventHandler("onPlayerSpawn", getRootElement(), onSpawn)
addEvent( "onPlayerStopAnimation", true )
function removeAnimation(thePlayer)
	if isElement(thePlayer) and getElementType(thePlayer)=="player" and getElementData(thePlayer, "freeze") ~= 1 and not getElementData(thePlayer, "injuriedanimation") then
		if isTimer( getElementData( thePlayer, "animationt" ) ) then
			killTimer( getElementData( thePlayer, "animationt" ) )
		end
		local setanim = setPedAnimation(thePlayer)
		setElementData(thePlayer, "forcedanimation", 0)
		setElementData(thePlayer, "animationt", 0)
		toggleAllControls(thePlayer, true, true, false)
		setPedAnimation(thePlayer)
		setTimer(setPedAnimation, 50, 2, thePlayer)
		setTimer(triggerEvent, 100, 1, "onPlayerStopAnimation", thePlayer)
		return setanim
	else
		return false
	end
end