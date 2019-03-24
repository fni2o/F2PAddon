local L = F2PLoc.guild

local f = CreateFrame("frame")

f:RegisterEvent("CHAT_MSG_WHISPER")


local function F2PGuild_FilterIncoming(self, event, ...)
    local msg, sender, _, _, _, flags = ...
    local f_num = GetNumFriends()
    local isafriend = 0
    for y = 1, f_num do
        local name, level, class, loc, connected, status = GetFriendInfo(y)
        if name == sender then
            isafriend = 1
        end
    end
    if (isafriend == 0) and (not msg:match(L["RESPONSE"])) and (msg:lower():match(L["GUILD"]) or msg:lower():match(L["CHARTER"])) and (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction].Settings.BlockGuild == 1) then
        return true
    end
end

local function F2PGuild_FilterOutgoing(self, event, ...)
    local msg = ...
    if msg:match(L["RESPONSE"]) then
        return true
    else
        return false
    end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", F2PGuild_FilterIncoming)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", F2PGuild_FilterOutgoing)

--I know the SendChatMessage() could have been called at the same time as the filter function above does the blocking, but for some stupid
--reason the filter gets triggered twice on an incoming message, so 2 whispers get sent, while this ensures that only one goes out
f:SetScript("OnEvent", function(self, event, ...)
    if event == ("CHAT_MSG_WHISPER") then
        local msg, sender, _, _, _, flags = ...
        local f_num = GetNumFriends()
        local isafriend = 0
        for y = 1, f_num do
            local name, level, class, loc, connected, status = GetFriendInfo(y)
            if name == sender then
                isafriend = 1
            end
        end
        if (isafriend == 0) and GameLimitedMode_IsActive() and (not msg:match(L["RESPONSE"])) and (msg:lower():match(L["GUILD"]) or msg:lower():match(L["CHARTER"])) and (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction].Settings.BlockGuild == 1) then
            SendChatMessage(L["RESPONSE"], "WHISPER",nil, sender)
        end
    end
end
)        
        


