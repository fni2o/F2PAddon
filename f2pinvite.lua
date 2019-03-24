local L = F2PLoc.invite

if not GameLimitedMode_IsActive() then --check for paid account
	local enabled = 1
	local fishing = nil
	local formingRaid = nil
	local f2piGroup = nil
	local askers = {}
	local passLeadTo

	local f = CreateFrame("frame")

	f:RegisterEvent("CHAT_MSG_WHISPER")
	f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("CHAT_MSG_ADDON")
    
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF" .. L["F2PI_LOADED"] .. "|r")
---[[
	local function F2PI_FilterOutgoing(self, event, ...)
		local msg = ...
		if msg:match("%[F2PI%]") then
			return true
		else
			return false
		end
	end
--]]
	local function F2PI_FilterIncoming(self, event, ...)
		local msg = ...
		if msg:match("^inv$") or msg:match("^lead$") or msg:match("^close$") or msg:match("%[F2PI%]") then
			return true
		else
			return false
		end
	end

	local function F2PI_IsBusy() --find out if the player is doing something and shouldn't be disturbed.
		local busy = false
		local lmode	--checks all LFG queue types
		for m = 1, 4 do
			lmode = GetLFGMode(m)
			if lmode then
				busy = true
			end
		end
		
		for x = 1, GetMaxBattlefieldID() do --checks for a BG or arena status, in BG/arena, or in a queue.
			if GetBattlefieldStatus(x) ~= "none" then
				busy = true
			end
		end
		local zone = GetRealZoneText() --checks if the player is within the Tol Barad or Wintergrasp zones.
		if ( zone == L["TOL_BARAD"] ) or ( zone == L["WINTERGRASP"] ) then
			busy = true
		end
		if IsInInstance() then --checks if the player is inside an instance
			busy = true
		end	
		return busy
	end
	

	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", F2PI_FilterOutgoing)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", F2PI_FilterOutgoing)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", F2PI_FilterIncoming)

	f:SetScript("OnEvent", function(self, event, ...)
		if event == ("CHAT_MSG_WHISPER") then
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("event happened - CHAT_MSG_WHISPER") end
			local level = UnitLevel(F2PAddonGlobalVars.myName)
			local msg, sender, _, _, _, flags = ...
			sender = F2PMisc_NamePlusRealm(sender) --check that the name includes the realm
			if not (flags == "GM") or (not IsInGuild(sender)) then
				if (not F2PChat_IsBlocked(sender)) then
					if (enabled) then
						
						local busy = F2PI_IsBusy()
						
						if not msg:match("\[F2PI\]") then --stop the addons getting into a loop of messaging each other
							-- if 'inv' was in the message, but was not it's only content; or the words 'group' or 'party' were used, indicating that the sender might have asked for a group.
							if ((msg:lower():match("inv")) and (not msg:lower():match("^inv$"))) or (msg:lower():match("group")) or (msg:lower():match("party")) then
								SendChatMessage(L["CLARIFY_COMMAND"], "WHISPER", nil, sender)

							-- specific 'inv' command received
							elseif msg:lower():match("^inv$") then
								--if not using BG/LFD, not yet in a party, or is leader of a party
								if (not busy) and ((not UnitExists("party1")) or UnitIsGroupLeader("player")) then
									--switch over to a raid to make space for additional members if we're at the party size limit
									if (level >= 10) and (GetNumGroupMembers() == 5) and (not IsInRaid()) then
										ConvertToRaid()
									end
									tinsert(askers, sender)
									InviteUnit(sender)
									if (not fishing) then
										SendChatMessage(L["ACCEPTED_COMMANDS_1"], "WHISPER", nil, sender)
										SendChatMessage(L["ACCEPTED_COMMANDS_2"], "WHISPER", nil, sender)
										SendChatMessage(L["ACCEPTED_COMMANDS_3"], "WHISPER", nil, sender)
									elseif (fishing) then
										SendChatMessage(L["FISHING_COMP_MODE"], "WHISPER", nil, sender)
									end
								elseif ( busy or (UnitExists("party1") and not UnitIsGroupLeader("player")) ) then
									SendChatMessage(L["BUSY_RESPONSE"], "WHISPER", nil, sender)
								end
	
							--'lead' command received
							elseif msg:lower():match("^lead$") and (not fishing) and UnitInParty(F2PMisc_NameMinusRealm(sender)) then
								if (not busy) and UnitExists("party1") and UnitIsGroupLeader("player") and UnitInParty(F2PMisc_NameMinusRealm(sender)) then
									passLeadTo = sender
									SendChatMessage(string.format(L["LEADER"], sender), "PARTY", nil, sender)
								elseif (not busy) and not (UnitExists("party1") or UnitInParty(F2PMisc_NameMinusRealm(sender))) then
									SendChatMessage(L["NOT_LEADING"], "WHISPER", nil, sender)
								end
							
							--'close' command received
							elseif msg:lower():match("^close$") and (not fishing) and UnitInParty(F2PMisc_NameMinusRealm(sender)) then
								F2PI_CloseGroup(passLeadTo)
							end
						end
					elseif (not enabled) and (not msg:match("\[F2PI\]")) and ( (msg:lower():match("inv")) )  then
						SendChatMessage(L["AUTO_DISABLED"], "WHISPER", nil, sender)
					end
				else
					SendChatMessage(L["LEVEL_LIMIT"], "WHISPER", nil, sender)
				end
			end
		
		elseif event == ("GROUP_ROSTER_UPDATE") and (enabled) then
			local level = UnitLevel(F2PAddonGlobalVars.myName)
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("event happened - GROUP_ROSTER_UPDATE") end
			--if we have reached the party limit, pass lead and leave the group
			if (  ((level >= 10) and (GetNumGroupMembers() == 6)) or ((level < 10) and (GetNumGroupMembers() == 5))  ) and (f2piGroup == 1) and (not fishing) then
				F2PI_CloseGroup(passLeadTo)
			
			--if anyone asked for a group
			elseif #askers > 0 then
				--[[]]if F2PAddon_Variables.Settings.Verbose then print("someone asked for a group") end
				--check if the person who joined is one of them
				for x = 1, #askers do
					if UnitInParty(F2PMisc_NameMinusRealm(askers[x])) then
						--[[]]if F2PAddon_Variables.Settings.Verbose then print("found "..tostring(askers[x]).." in party, setting f2piGroup to 1") end
						f2piGroup = 1  --mark this as an F2PI formed group if so
					end
				end
			
				--if it is...
				if f2piGroup then
					--and they're the first to join...
					if (GetNumGroupMembers() == 2) then
						passLeadTo = UnitName("party1")  --will be passing lead to them when the group closes
						--[[]]if F2PAddon_Variables.Settings.Verbose then print("passLeadTo = "..tostring(passLeadTo)) end
						--[[]]if F2PAddon_Variables.Settings.Verbose then print("party1 = "..tostring(UnitName("party1"))) end

					end
				end

			--if you're no longer in a party, reset the function's flags
			elseif (not UnitExists("party1")) then
				fishing = nil
				formingRaid = nil
				f2piGroup = nil
				askers = {}
				passLeadTo = nil
			end

		elseif (event == "CHAT_MSG_ADDON") then
			local a,b,c,d,e,f,g,h,i,j,k = ...
			local prefix, msg, channel, sender = a, b, c, d
			sender = F2PMisc_NamePlusRealm(sender) --check that the name includes the realm
			local level = UnitLevel(F2PAddonGlobalVars.myName)
			if (prefix == F2PAddonGlobalVars.AddonChannel1Name) and (channel == "WHISPER") and (enabled) then
				if msg:lower():match("^p2p%?$") and (not fishing) and (not F2PI_IsBusy()) and (not F2PChat_IsBlocked(sender))then
					local _, class = UnitClass(F2PAddonGlobalVars.myName)
					local c1, c2 = string.match(class, "^(.)(.+)$")
					class = c1..string.lower(c2)
					if class == "Mage" then
						if F2PI_CanPortalBack(level) == 1 then -- level 42 for portals to faction cities
							F2PChat_SendChatMessage(L["CAN_GROUP_AND_PORTAL1"], "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
						elseif F2PI_CanPortalBack(level) == 2 then -- level 66 adds shattrath
							F2PChat_SendChatMessage(L["CAN_GROUP_AND_PORTAL2"], "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
						elseif F2PI_CanPortalBack(level) == 3 then -- level 74 adds dalaran
							F2PChat_SendChatMessage(L["CAN_GROUP_AND_PORTAL3"], "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
						elseif F2PI_CanPortalBack(level) == 4 then -- level 90 adds the shrines in Valley of Eternal Blossoms
							F2PChat_SendChatMessage(L["CAN_GROUP_AND_PORTAL4"], "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
						elseif level >= 10 then --can make raids
							F2PChat_SendChatMessage(L["CAN_GROUP"], "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
						else  --can't make raids
							F2PChat_SendChatMessage(L["CAN_GROUP_4"], "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
						end
					else
						if level >= 10 then  --can make raids
							F2PChat_SendChatMessage(L["CAN_GROUP"], "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
						else  --can't make raids
							F2PChat_SendChatMessage(L["CAN_GROUP_4"], "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
						end
					end
				end
			end
		end
	end	
	)

	
	
	function F2PI_CloseGroup(newLead)
		if (GetNumGroupMembers() == 6) then
			SendChatMessage(L["QUEUEING_AS_RAID"], "RAID", nil)
		end
		local partyList = {}
		local channelNumber = F2PChat_GetChannelNumber(F2PAddonGlobalVars.Channel1Name)
		local channelColor = F2PChat_GetChannelColor(channelNumber)
		if UnitInRaid("player") then
			for x = 1, GetNumGroupMembers()-1 do
				local y = GetRaidRosterInfo(x)
				local z
				if y ~= (UnitName("player") or nil) then
					if y == newLead then
						--y = y.." (leader)"
						---[[
						z = "|cFF"..F2PChat_GetSenderClassColorAsHex(y).."|Hplayer:"..y.."|h"..y.."|h|cFF"..channelColor.." (leader)"
					else 
						z = "|cFF"..F2PChat_GetSenderClassColorAsHex(y).."|Hplayer:"..y.."|h"..y.."|h|cFF"..channelColor
						---]]
					end
					tinsert(partyList, z)
				end
			end
		elseif not UnitInRaid("player") then
			for x = 1, GetNumGroupMembers()-1 do
				local y = UnitName("party"..x)
				local z
				if y ~= (UnitName("player") or nil) then
					if y == newLead then
						--y = y.." (leader)"
						---[[
						z = "|cFF"..F2PChat_GetSenderClassColorAsHex(y).."|Hplayer:"..y.."|h"..y.."|h|cFF"..channelColor.." (leader)"
					else 
						z = "|cFF"..F2PChat_GetSenderClassColorAsHex(y).."|Hplayer:"..y.."|h"..y.."|h|cFF"..channelColor
						---]]
					end
					tinsert(partyList, z)
				end
			end
		end
		
		local msg = L["GROUP_FORMED"] .. table.concat(partyList, ", ")
		F2PChat_RouteChatMessage(msg)  --this one NEEDS to be sent via addon, otherwise the formatting gets stripped and no names show up
		F2PChat_FormatIncoming(msg, F2PAddonGlobalVars.myName) --print sent message
		PromoteToLeader(newLead, 1)
		LeaveParty()
	end

	
	
	function F2PI_CanPortalBack(level) -- needs localising
		local horde_city_names = {"Orgrimmar", "Thunder Bluff", "Undercity", "Silvermoon City "}
		local alliance_city_names = {"Darnassus", "Stormwind City", "Ironforge", "The Exodar"}
		local l_66_names = {"Shattrath City"}
		local l_74_names = {"Shattrath City", "Dalaran"}
		local h_90_names = {"Orgrimmar", "Thunder Bluff", "Undercity", "Silvermoon City ", "Shrine of Two Moons"}
		local a_90_names = {"Darnassus", "Stormwind City", "Ironforge", "The Exodar", "Shrine of Seven Stars"}
		--Neither of the MoP 'cities' have their own zones, instead being part of the Veil of Eternal Blossoms zone.  Because of this the method above won't work while in these areas, as it never returns the value for either of the shrines.
		--Instead, pulling the smaller subzone names from the minimap location with GetMinimapZoneText() could be used, then compared with:
		--local h_90_names = {"The Golden Terrace", "Shrine of Two Moons", "Hall of the Crescent Moon", "Hall of Secrets", "The Imperial Mercantile", The Keggary", "Summer's Rest", "Chamber of Masters", "Chamber of Wisdom", "The Jade Vaults", "Hall of Tranquility"}
		--local a_90_names = {"???Terrace???", "Shrine of Seven Stars", "The Emperor's Step", "The Star's Bazaar", "The Golden Lantern", "The Imperial Exchange", "Chamber of Reflection", "Ethereal Corridor", "The Celestial Vault", "Chamber of Enlightenment"}
		--That's going to be a pain in the ass for translators
		
		
		
		local faction = F2PAddonGlobalVars.myFaction
		
		local currentZone = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player")).name
		
		if level >= 90 and (   (faction == "Horde" and ( tContains(h_90_names, currentZone) or tContains(l_74_names, currentZone) ))  or (faction == "Alliance" and ( tContains(a_90_names, currentZone) or tContains(l_74_names, currentZone)))   ) then
			return 4
		elseif level >= 74 and (   (faction == "Horde" and ( tContains(horde_city_names, currentZone) or tContains(l_74_names, currentZone) ))  or (faction == "Alliance" and ( tContains(alliance_city_names, currentZone) or tContains(l_74_names, currentZone)))   ) then
			return 3
		elseif level >= 66 and (   (faction == "Horde" and ( tContains(horde_city_names, currentZone) or tContains(l_66_names, currentZone) ))  or (faction == "Alliance" and ( tContains(alliance_city_names, currentZone) or tContains(l_66_names, currentZone)))   ) then
			return 2
		elseif level >= 42 and ((faction == "Horde" and tContains(horde_city_names, currentZone)) or (faction == "Alliance" and tContains(alliance_city_names, currentZone))   ) then
			return 1
		else
			return 0
		end
	end
	
	
	
	local commandTable = {  --create the data structure that the slash commands work from
		["fish"] = function()	
			if fishing == 1 then
				fishing = nil
				print(L["FISHING_MODE_DISABLED"])
			else
				fishing = 1
				print(L["FISHING_MODE_ENABLED"])
			end
		end,
		["default"] = function()
			if enabled == 1 then
				enabled = nil
				--[[]]if F2PAddon_Variables.Settings.Verbose then print("[F2PI] disabled") end
				local msg = L["MANUALLY_DISABLED"]
				F2PChat_SendChatMessage(msg, "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
				--F2PChat_RouteChatMessage(msg)  --send via addon
				--F2PChat_FormatIncoming(msg, F2PAddonGlobalVars.myName) --print sent message
			else
				enabled = 1
				--[[]]if F2PAddon_Variables.Settings.Verbose then print("[F2PI] enabled") end
				local msg = L["MANUALLY_ENABLED"]
				F2PChat_SendChatMessage(msg, "CHANNEL", nil, GetChannelName(F2PAddonGlobalVars.Channel1Name))
				--F2PChat_RouteChatMessage(msg)  --send via addon
				--F2PChat_FormatIncoming(msg, F2PAddonGlobalVars.myName) --print sent message
			end
		end,
	}

	local function runSlashCommand(message, cmdTable)
		local command, parameters = string.split(" ", message, 2)
		if (command == nil) or (command == "") then
			commandTable.default()
		elseif command == "fish" then
			commandTable.fish()
		end
	end

	SLASH_F2PI1 = "/f2pi"
	SlashCmdList["F2PI"] = function(txt)
		runSlashCommand(txt, commandTable)
	end

else --for trials
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF" .. L["ON_TRIAL"] .. "|r")
end
