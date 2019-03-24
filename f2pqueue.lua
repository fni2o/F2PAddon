local L = F2PLoc.queue

local WSGStatus
local ABStatus
local EOSStatus
local AVStatus
local RStatus
local lastWSGStatus = "none"
local lastABStatus = "none"
local lastEOSStatus = "none"
local lastAVStatus = "none"
local lastRstatus = "none"

function F2PQ_SendUpdate()
	local msg = nil
	WSGStatus = "none"
	ABStatus = "none"
	EOSStatus = "none"
	AVStatus = "none"
	RStatus = "none"
	for i = 1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if mapName == L["WARSONG_GULCH"] then
			WSGStatus = status
		elseif mapName == L["ARATHI_BASIN"] then
			ABStatus = status	
		elseif mapName == L["EYE_OF_THE_STORM"] then
			EOSStatus = status
		elseif mapName == L["ALTERAC_VALLEY"] then
			AVStatus = status
		elseif mapName == L["RANDOM_BG"] then
			RStatus = status
		end
	end

	--as the server spam status events regardless of change, check to only send updates if it's actually changed
	if (WSGStatus ~= "none" and WSGStatus ~= lastWSGStatus) then
		msg = "W"..WSGStatus
	elseif (WSGStatus == "none" and lastWSGStatus ~= "none") then
		msg = "Wnone"
	end

	if (ABStatus ~= "none" and ABStatus ~= lastABStatus) then
		msg = "A"..ABStatus
	elseif (ABStatus == "none" and lastABStatus ~= "none") then
		msg = "Anone"
	end
	
	if (EOSStatus ~= "none" and EOSStatus ~= lastEOSStatus) then
		msg = "E"..EOSStatus
	elseif (EOSStatus == "none" and lastEOSStatus ~= "none") then
		msg = "Enone"
	end
	
	if (AVStatus ~= "none" and AVStatus ~= lastAVStatus) then
		msg = "V"..AVStatus
	elseif (AVStatus == "none" and lastAVStatus ~= "none") then
		msg = "Vnone"
	end
	
	if (RStatus ~= "none" and RStatus ~= lastRStatus) then
		msg = "R"..RStatus
	elseif (RStatus == "none" and lastRStatus ~= "none") then
		msg = "Rnone"
	end

	if (WSGStatus == "active") or (ABStatus == "active") or (EOSStatus == "active") or (AVStatus == "active") or (RStatus == "active") then
		F2PAddonQueueInfoFrame:Hide()
	end
	
	if msg then
		local f_num = GetNumFriends()
		for y = 1, f_num do
			local name, level, class, loc, connected, status = GetFriendInfo(y)
			if connected and name then
				ChatThrottleLib:SendAddonMessage("NORMAL", "f2pq", msg, "WHISPER", name)
			end
		end
	end
	lastWSGStatus = WSGStatus
	lastABStatus = ABStatus
	lastEOSStatus = EOSStatus
	lastAVStatus = AVStatus
	lastRStatus = RStatus
end

function F2PQ_ReceiveUpdate(...)
	local sender, msg = ...
	local state
	local map

	state = string.match(msg, "^.([%a]+)")

	if state == "none" then
		state = 0
	elseif state == "queued" then
		state = 1
	elseif state == "confirm" then
		state = 2
	elseif state == "active" then
		state = 0
	end
	
	map = string.match(msg, "^(.)")

	--update table
	if not F2PAddonGlobalVars.queueData[sender] then
		F2PAddonGlobalVars.queueData[sender] = {}
		F2PAddonGlobalVars.queueData[sender]["class"] = F2PChat_GetSenderClassColorAsHex(sender)
	end
	F2PAddonGlobalVars.queueData[sender][map] = state

	F2PQ_TableToDisplay()
end

function F2PQ_TableToDisplay()
	--parse table and if both maps for a name have no state remove the name
	local toRemove = {}
	for i, v in pairs(F2PAddonGlobalVars.queueData) do
		if (F2PAddonGlobalVars.queueData[i]["W"] == 0 or F2PAddonGlobalVars.queueData[i]["W"] == nil) and (F2PAddonGlobalVars.queueData[i]["A"] == 0 or F2PAddonGlobalVars.queueData[i]["A"] == nil) and (F2PAddonGlobalVars.queueData[i]["E"] == 0 or F2PAddonGlobalVars.queueData[i]["E"] == nil) and (F2PAddonGlobalVars.queueData[i]["V"] == 0 or F2PAddonGlobalVars.queueData[i]["V"] == nil)and (F2PAddonGlobalVars.queueData[i]["R"] == 0 or F2PAddonGlobalVars.queueData[i]["R"] == nil)then
			tinsert(toRemove, i)
		end
	end
	for x = 1, #toRemove do
		F2PAddonGlobalVars.queueData[toRemove[x]] = nil
	end
	
	--parse table and convert contents to text
	local nameList = {}
	local appendText
	local outputText = "\124cFFFFFFFF" .. L["OUTPUT_TEXT"]
	
	--create a sorted list of names from the table
	for i, v in pairs(F2PAddonGlobalVars.queueData) do
		tinsert(nameList, i)
	end
	
	table.sort(nameList)
	
	for x = 1, #nameList do
		local wState
		local aState
		local eState
		local vState
		local rState
		if F2PAddonGlobalVars.queueData[nameList[x]]["W"] == 1 then
			wState = "\124cFFFF0000" .. L["QUEUED"]
		elseif F2PAddonGlobalVars.queueData[nameList[x]]["W"] == 2  then
			wState = "\124cFF00FF00" .. L["POPPED"]
		else
			wState = "      "
		end
		
		if F2PAddonGlobalVars.queueData[nameList[x]]["A"] == 1 then
			aState = "\124cFFFF0000" .. L["QUEUED"]
		elseif F2PAddonGlobalVars.queueData[nameList[x]]["A"] == 2  then
			aState = "\124cFF00FF00" .. L["POPPED"]
		else
			aState = "      "
		end
		
		if F2PAddonGlobalVars.queueData[nameList[x]]["E"] == 1 then 
			eState = "\124cFFFF0000" .. L["QUEUED"]
		elseif F2PAddonGlobalVars.queueData[nameList[x]]["E"] == 2  then
			eState = "\124cFF00FF00" .. L["POPPED"]
		else
			eState = "      "
		end
		
		if F2PAddonGlobalVars.queueData[nameList[x]]["V"] == 1 then
			vState = "\124cFFFF0000" .. L["QUEUED"]
		elseif F2PAddonGlobalVars.queueData[nameList[x]]["V"] == 2  then
			vState = "\124cFF00FF00" .. L["POPPED"]
		else
			vState = "      "
		end
		
		if F2PAddonGlobalVars.queueData[nameList[x]]["R"] == 1 then
			rState = "\124cFFFF0000" .. L["QUEUED"]
		elseif F2PAddonGlobalVars.queueData[nameList[x]]["R"] == 2  then
			rState = "\124cFF00FF00" .. L["POPPED"]
		else
			rState = "      "
		end
		
		--fix for regional characters that are considered to have a length of 2 while displayed as 1
		local trimmed_name = F2PMisc_NameMinusRealm(nameList[x])
		local nameLength = #trimmed_name
		for i, v in string.gmatch(trimmed_name, "[^a-zA-Z]") do
			nameLength = nameLength - 0.5
		end
		local name = trimmed_name..string.rep("  ", 2 - nameLength)
		
		appendText = "|cFF"..F2PAddonGlobalVars.queueData[nameList[x]]["class"]..name.." |cFFFFFFFF| "..wState.."|cFFFFFFFF| "..aState.."|cFFFFFFFF| "..eState.."|cFFFFFFFF| "..vState.."|cFFFFFFFF| "..rState.."\n"
		outputText = outputText..appendText
	end
	
	F2PQText:SetText(outputText)
end


