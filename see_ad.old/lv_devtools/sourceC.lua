local serials = {
  ["3964A9A5103CDA070946DED861649B52"] = true,
}

local state = false

addCommandHandler("aircars",
  function()
    --if getPlayerSerial(localPlayer)[serials] then
      state = not state
      setWorldSpecialPropertyEnabled("aircars", state)
      outputChatBox("allapot: "..tostring(state))
    --end
  end
)