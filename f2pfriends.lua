
local friendsCap = 95

function F2PFriends_FLPurge()  --removes all offline friends who do not have a note
	local f_num = GetNumFriends()
	for y = 1, f_num do
		local name, level, class, loc, connected, status, note = GetFriendInfo(y)
		if (not connected) and (not note) then
			RemoveFriend(name)
		end
	end
end

function F2PFriends_FLUpdate()  --updates the game friends list with people from the channel.
	local preUpdateFriendsList = {}
	local addList = {}
	local f_num = GetNumFriends()
	--make a list of who's in friends at the moment
	for y = 1, f_num do
		local name = GetFriendInfo(y);
		tinsert(preUpdateFriendsList, name)
	end

	--create a list of just those people in the channel who aren't yet in the friends list
	for i, v in pairs(F2PAddonGlobalVars.inChatList) do
		if not tContains(preUpdateFriendsList, v) then
			tinsert(addList, F2PAddonGlobalVars.inChatList[i])
		end
	end
	local overflow = GetNumFriends() + #addList - friendsCap
	--ensure there is space in the friends list for the names that are to be added
	if overflow > 0 then
		print("|cFFFF00FF"..F2PLoc.friends["TOO_MANY_FRIENDS"].."|r")
		F2PFriends_FLPurge()
	end

	--finally add the names to the friends list
	for i = 1, #addList do
		AddFriend(addList[i])
		F2PAddonGlobalVars.friendsListOK = false
	end	
end

function F2PFriends_AddJoiner(...)
	local a,b,c,d,e,f,g,h,i = ...
	local friends = {}
	local f_num = GetNumFriends()
	for y = 1, f_num do		--make a list containing current friends
		local name = GetFriendInfo(y)
		tinsert(friends, name)
	end	
	
	--make space for them in the friends list if it's close to capacity
	if not tContains(friends, b) then	--if the person who just joined the channel isn't in it
		if GetNumFriends() > friendsCap then
			F2PFriends_FLPurge()
		end
		AddFriend(b)
		F2PAddonGlobalVars.friendsListOK = false
	end
end

function F2PFriends_onlineFriendsList_Update()
	F2PAddonGlobalVars.onlineFriendsList = {}
	local f_num = GetNumFriends()
	for y = 1, f_num do
		local name, level, class, loc, connected, status, note = GetFriendInfo(y);	
		if connected then
			tinsert(F2PAddonGlobalVars.onlineFriendsList, name)
		end
	end	
	F2PAddonGlobalVars.friendsListOK = true	
end
	