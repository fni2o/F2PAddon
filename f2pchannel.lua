
function F2PChannel_GetAll(...) -- Puts everyone from the channel list (less the player) into a global variable
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("F2PChannel_GetAll called.") end
	local a,b,c,d,e,f,g,h,i,j,k = ...
	a = string.gsub(a,"*","") --take the leading '*' off any channel owner's name
	a = string.gsub(a,"@","") --take the leading '@' off the channel mod's name
	for chatmember in string.gmatch(a, "[^%s,]+") do --split the list of people in channel into a table
		--[[]]if F2PAddon_Variables.Settings.Verbose then print(chatmember) end
		if chatmember ~= GetUnitName("player",0) then
			tinsert(F2PAddonGlobalVars.inChatList, chatmember)
		end
	end
	F2PAddonGlobalVars.channelListOK = true
end

function F2PChannel_AddOne(...)
	local a,b,c,d,e,f,g,h,i = ...
	tinsert(F2PAddonGlobalVars.inChatList, b)
end

function F2PChannel_RemoveOne(...)
	local a,b,c,d,e,f,g,h,i = ...
	for i, v in pairs(F2PAddonGlobalVars.inChatList) do
		if v == b then
			tremove(F2PAddonGlobalVars.inChatList, i)
		end
	end
end

function F2PChannel_MemberSortFunction1(a, b)
	--f2p @ 20
	--p2p @ 20
	--f2p < 20
	--p2p < 20
	local x = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"]
	if tonumber(x[a].level) == tonumber(x[b].level) then
		return tostring(x[a].trial) < tostring(x[b].trial)
	elseif tostring(x[a].trial) == tostring(x[b].trial) then
		return  tonumber(x[a].level) > tonumber(x[b].level)
	end
end

function F2PChannel_MemberSortFunction2(a, b)
	local x = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"]
end

function F2PChannel_GetBestOwnerCandidate()
	--F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"]


	table.sort(F2PAddonGlobalVars.inChatList, F2PChannel_MemberSortFunction1)
	return F2PAddonGlobalVars.inChatList[1]
end

function F2PChannel_PassOwner(...)
	local a,b,c,d,e,f,g,h,i = ...
	--if <b is a listed moderator> then
		
	--else
		local channelNum = 0
		for x = 1, GetNumDisplayChannels() do
			if GetChannelDisplayInfo(x) == F2PAddonGlobalVars.Channel1Name then
				channelNum = x
			end
		end 
		SetSelectedDisplayChannel(channelNum)
		if IsDisplayChannelOwner() and F2PChannel_GetBestOwnerCandidate() then
			SetChannelOwner(F2PAddonGlobalVars.Channel1Name, F2PChannel_GetBestOwnerCandidate())
		end
	--end
end