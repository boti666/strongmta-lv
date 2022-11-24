local lastplayer

function screenShotHandler(player)
	takePlayerScreenShot(player, 1920, 1080, "screenshot", 100, 875000,875000)
	--iprint("nigger screenshot detected", player)
	lastplayer = player
end
addEvent("onScreenShot", true)
addEventHandler("onScreenShot", resourceRoot, screenShotHandler)

addEventHandler("onPlayerScreenShot", root,
    function (theResource, status, pixels, timestamp, tag)
    	if status == "ok" then
        	local newFile = fileCreate("test.jpg")
			if (newFile) then
    			fileWrite(newFile, pixels)
    			fileClose(newFile)
    			faszretek()
			end
		end
    end
)

local imgur = "https://api.imgur.com/3/upload"

function faszretek()
	local file = fileOpen ( "test.jpg", true )
	local data = fileRead ( file, fileGetSize ( file ) )
	data = base64Encode ( data )
	fileClose ( file )
	sendOptions = {
    	method = "POST",
    	headers = {
        	[ "Authorization" ] = "Client-ID 620659b4dda7173",
        	[ "Content-Type" ] = "multipart/form-data"
    	},
    	formFields = {
        	[ "image" ] = data,
        	[ "type" ] = "base64"
    	}
	}
	fetchRemote(imgur, sendOptions, uploadCallback)
end

function uploadCallback(responseData) 
    if responseData~="" then
        outputDebugString("Imgur said: "..responseData)
        discordLogger(responseData)
    end
end

local remaining, executesRemaining, timeInterval;
local discordWebhookchat = "https://discord.com/api/webhooks/1036292207344353340/hJ74EzR8H5vCff5AtTvABouPv-nIMICSkLnCMtj24QzCz44UfCCqLHbJpA2O05UdRDXt"
local time="";
function discordLogger(responseData)
	responseData = fromJSON(responseData)
	imgurid = responseData['data']['id']
	imgurlink = "https://i.imgur.com/"..imgurid..".jpg"
    if isTimer(time)then
        remaining, executesRemaining, timeInterval=getTimerDetails(time);
        time=setTimer(function() 
        sendOptions = {
            formFields = {
                content="```📷 "..getPlayerName(lastplayer).." screenshotja:```" .. imgurlink
            },
        }
        fetchRemote(discordWebhookchat, sendOptions, loggerCallback)
        end, remaining+2500, 1) 
    else
        time=setTimer(function() 
            sendOptions = {
                formFields = {
                    content="```📷 "..getPlayerName(lastplayer).." screenshotja:```" .. imgurlink
                },
            }
            fetchRemote(discordWebhookchat, sendOptions, loggerCallback)
            end, 2500, 1) 
    end
end

function loggerCallback(responseData) 
    if responseData~="" then
        --outputDebugString("Discord said: "..responseData)
    end
end
