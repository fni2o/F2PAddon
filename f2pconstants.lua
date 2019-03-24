

--Set/declare some values that will be accessable throughout the addon code
F2PAddonGlobalVars = {}
F2PAddonGlobalVars.addonVersion = GetAddOnMetadata("F2PAddon", "Version")
F2PAddonGlobalVars.myName = GetUnitName("player",0)
F2PAddonGlobalVars.myFaction, _ = UnitFactionGroup("player")

if F2PAddonGlobalVars.myFaction == "Horde" then
	F2PAddonGlobalVars.otherFaction = "Alliance"
elseif F2PAddonGlobalVars.myFaction == "Alliance" then
	F2PAddonGlobalVars.otherFaction = "Horde"
else
	F2PAddonGlobalVars.otherFaction = "Neutral"
end


F2PAddonGlobalVars.thisRealm = GetRealmName()

local l = GetLocale()
if  l == "enUS" or l == "esMX" or l == "ptBR" then
	F2PAddonGlobalVars.Region = "US"
elseif l == "koKR" then
	F2PAddonGlobalVars.Region = "Korea"
elseif l == "zhTW" then
	F2PAddonGlobalVars.Region = "Taiwan"
elseif l == "zhCN" then
	F2PAddonGlobalVars.Region = "China"
else
	F2PAddonGlobalVars.Region = "EU"
end


F2PAddonGlobalVars.inChatList = {}
F2PAddonGlobalVars.onlineFriendsList = {}
F2PAddonGlobalVars.whoList = {}
F2PAddonGlobalVars.queueData = {}

F2PAddonGlobalVars.channelListOK = false
F2PAddonGlobalVars.friendsListOK = false

F2PAddonGlobalVars.f2pq_docked = true