local thisAddon_version = F2PAddonGlobalVars.addonVersion
local startup = 0
local tmpEventVars = {}
local delay = 1
local counter = 0
local channelListWait


function F2PAddon_OnLoad(self)
	C_ChatInfo.RegisterAddonMessagePrefix("f2pq")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
	self:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
	self:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("ACHIEVEMENT_EARNED")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHANNEL_PASSWORD_REQUEST")
	local msg =  "|cFFFF00FF"..string.format(F2PLoc.addon["F2PADDON_VERSION_"], thisAddon_version).."|r"
	DEFAULT_CHAT_FRAME:AddMessage(msg)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", F2PChat_FilterP2PTrolls)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", F2PChat_FilterP2PTrolls)
end

function F2PAddon_OnEvent(self, event, ...)
	local a,b,c,d,e,f,g,h,i,j,k = ...
	local prefix, msg, channel, sender = a, b, c, d
	
	if (event == "ADDON_LOADED") then
		if (a == "F2PAddon") then
			F2PData_BuildDBSkeleton()  --makes sure the DB has the required basic structure
			F2PData_NewVersionDatabase() --Make updates to the database structure if it's changed between versions, or just update it's version number
			F2PAddonGlobalVars.Channel1Name = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["Channel"] --set the channel to the one set in the database
		
			if F2PAddonGlobalVars.Channel1Name == F2PAddonGlobalVars.DefaultChannelName then --if it's the default
				F2PAddonGlobalVars.AddonChannel1Name = F2PAddonGlobalVars.DefaultAddonChannelName --use the old addon channel name
			else
				F2PAddonGlobalVars.AddonChannel1Name = F2PAddonGlobalVars.Channel1Name .. "AC" --use a new addon channel name to go with the chat channel name
			end
			
			C_ChatInfo.RegisterAddonMessagePrefix(F2PAddonGlobalVars.AddonChannel1Name)

			F2PAddon_CreateOptionsFrames()
		end
		
	elseif (event == "PLAYER_LOGIN") then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("PLAYER_LOGIN") end
		startup = 1
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("startup = 1") end
		
	
	elseif (event == "PLAYER_ENTERING_WORLD") and (startup == "done") then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("PLAYER_ENTERING_WORLD") end
		ListChannelByName(F2PAddonGlobalVars.Channel1Name)  --get a new channel listing every time we do a zone change
		
	elseif (event == "CHAT_MSG_CHANNEL_LIST") and (i == F2PAddonGlobalVars.Channel1Name) then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("CHAT_MSG_CHANNEL_LIST") end
		F2PChannel_GetAll(...)  --update the list of who's in the channel
		channelListWait = 3 --set a wait time, in case the channel list is multi part

		
	elseif (event == "CHAT_MSG_CHANNEL_JOIN") and (i == F2PAddonGlobalVars.Channel1Name) and (startup == "done") then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("adding "..b.." to channel and friends.") end
		F2PChannel_AddOne(...)
		F2PFriends_AddJoiner(...)
		--F2PChannel_PassOwner(...)  --future function. only enable here when the PassOwner function can pass to one of a set list of moderators
		--F2PChannel_BanNoAddon(...) --future function to tag someone as they join the channel, wait 10s, then ban them if they're not running the addon
		
	elseif (event == "CHAT_MSG_CHANNEL_LEAVE") and (i == F2PAddonGlobalVars.Channel1Name) and (startup == "done")  then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("removing "..b.." from channel, setting LLIT") end
		F2PChannel_RemoveOne(...)
		F2PData_LLIT_Single(...) 
		--Remove the player's entries from f2pq
		F2PQ_ReceiveUpdate(b,"Wnone")
		F2PQ_ReceiveUpdate(b,"Anone")
		
	elseif (event == "CHANNEL_PASSWORD_REQUEST") and (a == F2PAddonGlobalVars.Channel1Name) then
		startup = "done"
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF" .. string.format(F2PLoc.addon["CHANNEL_PASSWORDED"], a))
		
	elseif (event == "CHAT_MSG_ADDON") and (prefix == F2PAddonGlobalVars.AddonChannel1Name) and (channel == "WHISPER") and ((startup == 4) or (startup == "done"))  then --needs to be to run while waiting for the first pass
		if not string.match(msg, "^f2p=") then --if not a data packet, consider to be a chat message
			F2PChat_FormatIncoming(msg, sender)
		elseif string.match(msg, "^f2p=achid=") then
			F2PAchi_Receive(...)
		elseif string.match(msg, "^f2p=data") then
			if (string.match(msg, "^f2p=datadall:")) then --multi target data packet
				F2PData_Data_Add(msg..sender) --incorporate data packet
				F2PData_SendMyData_ToOne(sender) --send single target packet in return
			elseif  (string.match(msg, "^f2p=datadone:")) then  --single target data packet
				F2PData_Data_Add(msg..sender) --incorporate data packet
			elseif  (string.match(msg, "^f2p=dataalts:")) then
				F2PData_Alts_Add(sender, msg) --incorporate alts data packet
			end
		elseif string.match(msg, "^f2p=ding$") then
			F2PData_RequestWhoLevel(sender)
		end

	elseif (event == "CHAT_MSG_ADDON") and (prefix == "f2pq") and (channel == "WHISPER") then
		F2PQ_ReceiveUpdate(sender,msg)
		
	elseif (event == "FRIENDLIST_UPDATE") then
		F2PFriends_onlineFriendsList_Update()
		
	elseif (event == "ACHIEVEMENT_EARNED") and (startup == "done")  then
		F2PAchi_Send(...)
		
	elseif (event == "UPDATE_BATTLEFIELD_STATUS") and (UnitLevel("player") < 21) then
		F2PQ_SendUpdate()
		
	elseif (event == ("PLAYER_LEVEL_UP")) then --to have everyone request your level from the server via /who
		if (a == 3) then
			F2PData_IDinged()
		end

	elseif (event == ("CHAT_MSG_SYSTEM")) then
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("CHAT_MSG_SYSTEM") end
		--[[]]if F2PAddon_Variables.Settings.Verbose then print(a) end
		if #F2PAddonGlobalVars.whoList ~= 0 then
			for x = 1, #F2PAddonGlobalVars.whoList do
				--[[]]if F2PAddon_Variables.Settings.Verbose then print(F2PAddonGlobalVars.whoList[x]) end
				if string.match(a, "%["..F2PAddonGlobalVars.whoList[x].."%]") then
					--[[]]if F2PAddon_Variables.Settings.Verbose then print("who name found in whoList") end
					F2PData_ReceiveWhoLevel()
				end
			end	
		end
			
	elseif (event == "PLAYER_LOGOUT")  and (startup == "done") then
		F2PData_LLIT_Group()
		F2PChannel_PassOwner()
	end
end

function F2PAddon_OnUpdate(self, elapsed)
	counter = counter + elapsed
	if counter >= delay then
		if (startup == 1) and not (tContains({GetChannelList()}, F2PAddonGlobalVars.Channel1Name)) then --if we're not yet in the channel,
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("joining channel") end
			--[[if F2PAddonGlobalVars.ToU[F2PAddonGlobalVars.Region][F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.Channel1Name] and (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["ToUAccepted"] == 1) then
				if not <dialogue shown> then
					<show dialogue>
				else
					<wait>
				end
			else			--]]
				JoinTemporaryChannel(F2PAddonGlobalVars.Channel1Name) --joined the channel
			--end
			counter = 0
		elseif (startup == 1) and (#F2PChat_GetSubscribedChannels(F2PAddonGlobalVars.Channel1Name) < 1) then --if no windows are subscribed to display the channel we just joined
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("no chat windows showing channel, subscribing default window") end
			for i, v in ipairs(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["ChannelWindows"]) do --make sure the default chat window(s) will show the channel
				AddChatWindowChannel(v, F2PAddonGlobalVars.Channel1Name)
			end
			counter = 0
		elseif  (startup == 1) and (F2PAddonGlobalVars.channelListOK == false) then --if we've sucessfully joined the channel and have it displaying,
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("requesting channel list") end
			ListChannelByName(F2PAddonGlobalVars.Channel1Name) --request names of people in channel if we don't have them yet,
			counter = 0
			startup = 2 -- go into section 2 of the startup process
		
		--Channel list OK, copy it to friends list
		elseif (startup == 2) and (F2PAddonGlobalVars.channelListOK == true) then --once we've got an up to date list of channel members into the addon's global table
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("global channel table updated") end
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("updating friends list") end
			F2PFriends_FLUpdate()  --add people who aren't in the friends list who are in the channel list
			counter = 0
			startup = 3 -- go into section 3 of the startup process
			
		--Friends list OK, update database
		elseif (startup == 3) and (F2PAddonGlobalVars.friendsListOK == true) then --once that's done
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("friends list updated") end
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("adding friend's data to our database, sending our data to friends") end
			F2PData_SendMyData_ToAll() --provide our own info to everyone,
			startup = 4
			counter = 0
			delay = 3 --wait for other people's data to come back
		elseif (startup == 4) then
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("Checking version") end
			F2PData_GetIfOldVersion() --check to see if anyone has a newer version than us
			startup = "done" --finish startup and return to normal event driven running
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("Startup complete.") end
			delay = 86400 --set delay really high to stop checks on updates
		end
		
		
		
		
		if channelListWait then
			if (F2PAddonGlobalVars.channelListOK == false) and (channelListWait == 0) then
				F2PAddonGlobalVars.channelListOK = true
			elseif (F2PAddonGlobalVars.channelListOK == false) and (channelListWait > 0) then
				--[[]]if F2PAddon_Variables.Settings.Verbose then print("waiting for extra channel list parts") end
				channelListWait = channelListWait - 1
			end
		end
	end
end

