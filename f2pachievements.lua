function F2PAchi_Receive(...)
	---[[
	local prefix, msg, channel, sender = ...
	--[[]]if F2PAddon_Variables.Settings.Verbose then print(msg) end
	-- last check excludes messages for the player's addon, not the player
	local achid = string.match(msg, "^f2p=achid=(%d+):")
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("achid = "..tostring(achid)) end
	
	local guid, month, day, year, name, tail
	if achid == "0" and F2PMisc_NameMinusRealm(sender) == "Yasueh" then
		tail = "[God of All F2Ps]"
	else
		guid = string.match(msg, ":guid=([%w-]+):")
		month = string.match(msg, ":M=(%d+):")
		day = string.match(msg, ":d=(%d+):")
		year = string.match(msg, ":y=(%d+)$")
		_, name = GetAchievementInfo(achid)
		tail = "[|Hachievement:"..achid..":"..guid..":1:"..month..":"..day..":"..year..":0:0:0:0|h"..name.."|h]"
	end
	msg = "|cffffff00" .. string.format(F2PLoc.achi["HAS_EARNED_THE_ACHIEVEMENT_"], tail)
	F2PChat_FormatIncoming(msg, sender)
	--]]
end
		
function F2PAchi_Send(...)
	---[[
	local achId = ...
	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch = GetAchievementInfo(achId)
	local msg = "f2p=achid="..achId..":guid="..UnitGUID("player")..":M="..month..":d="..day..":y="..year
	F2PChat_RouteChatMessage(msg)
	local tail = "[|Hachievement:"..achId..":"..UnitGUID("player")..":1:"..month..":"..day..":"..year..":0:0:0:0|h"..name.."|h]"
	msg = "|cffffff00" .. string.format(F2PLoc.achi["HAS_EARNED_THE_ACHIEVEMENT_"], tail)
	F2PChat_FormatIncoming(msg, F2PAddonGlobalVars.myName)
	--]]
end
