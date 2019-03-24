local classNamesM = {}
local classNamesF = {}
FillLocalizedClassList(classNamesM ,false)
FillLocalizedClassList(classNamesF ,true)

local subbedChannels = {} -- chat windows that are subbed to show /f2ptwink

local HEX_CLASS_COLORS = {  --saves having to convert them from the r,g,b values bliz uses
	["DEATHKNIGHT"] = "C41F3B",
	["DRUID"] = "FF7D0A",
	["HUNTER"] = "ABD473",
	["MAGE"] = "69CCF0",
	["MONK"] = "00FF96",
	["PALADIN"] = "F58CBA",
	["PRIEST"] = "FFFFFF",
	["ROGUE"] = "FFF569",
	["SHAMAN"] = "0070DE",
	["WARLOCK"] = "9482C9",
	["WARRIOR"] = "C79C6E",
}

local wowSendChatMessage = SendChatMessage;  --Backup the existing version of SendChatMessage, so it can be called as part of our own version.

function F2PChat_SendChatMessage(msg, chatType, ...)  --Create the hooking fuction
	local a = {...}
	--if the message is being sent to our custom channel, you aren't capable of sending normally (not on P2P), and isn't for another addon.
	if ( (chatType == "CHANNEL") and (a[#a] == GetChannelName(F2PAddonGlobalVars.Channel1Name))) and (not string.match(msg, "^f2p=")) and (GameLimitedMode_IsActive() or F2PAddon_Variables.Settings.TrialFix) then
		F2PChat_RouteChatMessage(msg)  --send via addon
		F2PChat_FormatIncoming(msg, F2PAddonGlobalVars.myName) --print sent message
	else  --otherwise send as normal
		wowSendChatMessage(msg, chatType, ...)
	end
end

SendChatMessage = F2PChat_SendChatMessage  --Hook WoW's SendChatMessage, so our version gets called first.

function F2PChat_RouteChatMessage(msg)
	local f_num = GetNumFriends()
	for y = 1, f_num do
		local name, level, class, loc, connected, status = GetFriendInfo(y)
		if connected and name then
			ChatThrottleLib:SendAddonMessage("NORMAL", F2PAddonGlobalVars.AddonChannel1Name, msg, "WHISPER", name)
		end
	end	
end

function F2PChat_FilterP2PTrolls(self, event, ...)  --filters messages sent to the channel by p2ps, or as a whisper from anyone
	local msg, sender, _, _, _, _, _, _, chanName, _, _, _ = ...
	if (event == "CHAT_MSG_CHANNEL") and (chanName == F2PAddonGlobalVars.Channel1Name) and (F2PChat_IsBlocked(sender)) then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_FilterP2PTrolls - "..sender.."'s message to the channel was blocked.") end
		return true
	elseif (event == "CHAT_MSG_WHISPER") and (F2PChat_IsBlocked(sender)) then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_FilterP2PTrolls - "..sender.."'s whisper was blocked.") end
		return true
    else
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_FilterP2PTrolls - "..sender.."'s message was allowed.") end
		return false
	end
end

function F2PChat_FormatIncoming(msg, sender)

	local senderClassColor
	local channelNumber = F2PChat_GetChannelNumber(F2PAddonGlobalVars.Channel1Name)
	local channelColor = F2PChat_GetChannelColor(channelNumber)
	local chanHeader = channelNumber..". "..F2PAddonGlobalVars.Channel1Name
	local playerLink
	if F2PAddonGlobalVars.channelHeader then
		chanHeader = F2PAddonGlobalVars.channelHeader
	end
	
	if sender == "F2PAddon" then --messages sent by the addon, first example being /f2pwho
		senderClassColor = channelColor
		playerLink = sender
	else -- messages sent by players
		sender = F2PMisc_NamePlusRealm(sender) --check that the name includes the realm
		if F2PChat_IsBlocked(sender) and (sender ~= F2PAddonGlobalVars.myName) then  --filters messages to the channel that come in via the addon-addon channel
			return
		end
		senderClassColor = F2PChat_GetSenderClassColorAsHex(sender)
		playerLink = "|Hplayer:"..sender.."|h"..sender.."|h"
	end

	local header = "|cFF"..channelColor.."["..chanHeader.."] [|cFF"..senderClassColor..playerLink.."|cFF"..channelColor.."] "
	msg = msg:gsub("%[(MogIt[^%]]+)%]","|cFFCC99FF|H%1|h[MogIt]|h|r");
	local body = string.gsub(msg,"|r","|cFF"..channelColor) --fixes item links reverting channel color back to white
	
	local subbedCheck = 0
	for i,v in ipairs(F2PChat_GetSubscribedChannels(F2PAddonGlobalVars.Channel1Name)) do
		getglobal("ChatFrame"..v):AddMessage(header..body)
		subbedCheck = 1
	end
	if subbedCheck == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF" .. string.format(F2PLoc.chat["NO_SUBBED_CHAT_WINDOW_1"], F2PAddonGlobalVars.Channel1Name) ..".|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF" .. string.format(F2PLoc.chat["NO_SUBBED_CHAT_WINDOW_2"], F2PAddonGlobalVars.Channel1Name) ..".|r")
	end
end

--returns the chat frame numbers that are subscribed to the channel
function F2PChat_GetSubscribedChannels(cName)
	local subbedChannels = {}
	for i = 1,NUM_CHAT_WINDOWS do
		if tContains({GetChatWindowChannels(i)}, cName) then
			tinsert(subbedChannels, i)
		end
	end
	return subbedChannels
end

function F2PChat_GetChannelNumber(channelName)
	return GetChannelName(channelName)
end

function F2PChat_GetSenderClassColorAsHex(sender)
	if ( sender == F2PMisc_NamePlusRealm(F2PAddonGlobalVars.myName) ) then
		local lname, name = UnitClass("player")
		return HEX_CLASS_COLORS[name]
	end
	local f_num = GetNumFriends()
	for y = 1, f_num do
		local name, level, localizedClass, loc, connected, status = GetFriendInfo(y)
		--print("Testing " .. name .. " | " .. localizedClass)
		if (sender == name) or (sender == F2PMisc_NamePlusRealm(name)) then
			for n, v in pairs(classNamesM) do
				--print("localizedclass M = " .. n .. " | " .. v)
				if (v == localizedClass) then
					return HEX_CLASS_COLORS[n]
				end
			end
			for n, v in pairs(classNamesF) do
				--print("localizedclass F = " .. n .. " | " .. v)
				if v == localizedClass then
					return HEX_CLASS_COLORS[n]
				end
			end
		end
	end
	return "808080"
end


--returns the hex value color of the channel
function F2PChat_GetChannelColor(cNumber)
	local r, g, b
	for i, v in pairs({ChatTypeInfo["CHANNEL"..cNumber]}) do
		for x, y in pairs(v) do
			if x == "r" then
				r = y
			elseif x == "g" then
				g = y
			elseif x == "b" then
				b = y
			end
		end
	end
	return F2PChat_RGBToHex(r, g, b)
end	

function F2PChat_RGBToHex(r, g, b)
   local r = r <= 1 and r >= 0 and r or 1
   local g = g <= 1 and g >= 0 and g or 1
   local b = b <= 1 and b >= 0 and b or 1
   return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

function F2PChat_IsBlocked(sender)
	local senderLevel
	sender = F2PMisc_NamePlusRealm(sender) --check that the name includes the realm
	
	--if the sending character has a level entry in the database
	if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender]["level"] then
		--if they've been flagged as having been banned
		if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender]["banned"]) then
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - "..sender.." has been banned from the channel") end
			return true
		--if their level is OK
		elseif F2PChat_LevelOK(tonumber(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender]["level"])) then
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - "..sender.."'s database entry has an acceptable level: "..tostring(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender]["level"])) end
			return false
		--if their level is not OK
		elseif not F2PChat_LevelOK(tonumber(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender]["level"])) and (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender]["level"])  then
			local alts = F2PData_ConfirmedAlts(sender)
			for x = 1, #alts do
				if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][alts[x]] then
					--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - checking alt "..alts[x]) end
					--check for banned alts (not yet implemented)
					if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][alts[x]]["banned"]) then
						--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - "..sender.." has had an alt banned from the channel") end
						return true					
					--check for a confirmed L20 alt
					elseif (tonumber(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][alts[x]]["level"]) == 20) then
						--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - "..sender.." had a level 20 alt") end
						return false
					end
				end
			end
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - "..sender.."'s database entry has an unacceptable level: "..tostring(senderLevel)) end
			return true
		end
	end
	
	--otherwise fall back to the friends list
	local f_num = GetNumFriends()
	for y = 1, f_num do
		local name, level, class, loc, connected, status = GetFriendInfo(y)
		name = F2PMisc_NamePlusRealm(name) --check that the name includes the realm
		if name == sender then
			senderLevel = tonumber(level)
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - "..sender.."'s friends list entry has level: "..tostring(senderLevel)) end
		end
	end
	if not senderLevel then
		senderLevel = 0
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - No level found for "..sender) end
	end
	if F2PChat_LevelOK(senderLevel) then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - "..sender.." was of an acceptable level") end
		return false
	end
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChat_IsBlocked - "..sender.." was of an unknown level") end
	return false
end

function F2PChat_LevelOK(playerLevel)
	if (playerLevel < 3) and (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction].Settings.BlockLowLevel == 1) then
		return false
	elseif (playerLevel == 24) and (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction].Settings.BlockTwentFour == 1) then
		return false
	else
		return true
	end
end






















