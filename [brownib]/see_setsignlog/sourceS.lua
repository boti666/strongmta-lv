  addCommandHandler("sendDCN", function(message)
      sendDiscordMessage("test", "adminlog")
  end)
  
  function WebhookCallback(responseData) 
     -- outputDebugString("(Discord webhook callback): responseData: "..responseData)
  end
  
  --//EXPORTHOZ//--
  --exports.cosmo_dclog:sendDiscordMessage("Az üzenet", "Tipus!")
  --Konkrét példa : exports.cosmo_dclog:sendDiscordMessage("A fegyverhajó várhatóan x órakor érkezik meg!", "weaponship")


local webhookTypes = {
    callsign = {"callsign", "https://discord.com/api/webhooks/1044982628085940315/NoOeLhE_tn2WTKsGFpQnu_lsTwsv4oHFKK0BqdpWb77SztqcjvmrMTfgYq-kNE_fGiNr"},
}

function sendWebhook(msg, type)
    sendOptions = {
        formField = {
            content = ""..msg..""
        },
    }
    fetchRemote(webhookTypes[type][2], sendOptions, webhookCallback)
end

function webhookCallback(responseData)
end

addCommandHandler("callsigntest",
    function(msg)
        sendWebhook("heloka", "callsign")
    end
)

-- Export
-- exports.see_webhook:sendWebhook("Message", "Type")