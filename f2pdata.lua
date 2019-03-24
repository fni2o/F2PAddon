
--#############################################################
--# Form data packets containing this character's information #
--#############################################################

function F2PData_OutgoingDataPacket()
	
	local _, class = UnitClass("player")
	local c1, c2 = string.match(class, "^(.)(.+)$")
	class = c1..string.lower(c2)
	
	local level = UnitLevel("player")

	local i1, i2 = GetAverageItemLevel()
	local iLevel = math.floor(i1).."/"..math.floor(i2)
	
	local _, race = UnitRace("player")
	if race == "Scourge" then race = "Forsaken" end
	if race == "BloodElf" then race = "Blood Elf" end
	
	local gender = UnitSex("player")
	if gender == 3 then
		gender = "female"
	elseif gender == 2 then
		gender = "male"
	end

	local spec = GetSpecialization()

	local trial
	if GameLimitedMode_IsActive() then
		trial = "1"
	else
		trial = "0"
	end
		
	local xpLocked = IsXPUserDisabled()
	if xpLocked then
		xpLocked = "1"
	else
		xpLocked = "0"
	end

	local data = {
		["class"] = class,
		["level"] = level,
		["iLevel"] = iLevel,
		["race"] = race,
		["gender"] = gender,
		["spec"] = spec,
		["trial"] = trial,
		["xpLocked"] = xpLocked,
		["version"] = F2PAddonGlobalVars.addonVersion,
	}

	local dataMsg = ""
	
	for i, v in pairs(data) do
		dataMsg = dataMsg..i..","..tostring(v)..":"
	end

	return dataMsg
end

function F2PData_OutgoingAltsPacket()
	local altsMsg = "f2p=dataalts:"
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("My alts are:") end
	--[[]]if F2PAddon_Variables.Settings.Verbose then print(table.concat(F2PAddon_Variables.Alts[F2PAddonGlobalVars.thisRealm], ",")) end
	altsMsg = altsMsg..table.concat(F2PAddon_Variables.Alts[F2PAddonGlobalVars.thisRealm], ",")
	return altsMsg
end

--#########################################
--# Send data packets to other characters #
--#########################################

function F2PData_SendMyData_ToAll()
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("Sending to everyone: ".."f2p=datadall:"..F2PData_OutgoingDataPacket()) end
	F2PData_RouteDataPacket("f2p=datadall:"..F2PData_OutgoingDataPacket())
	if (#F2PAddon_Variables.Alts[F2PAddonGlobalVars.thisRealm] > 1) then --if this account has alts
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("Sending to everyone: "..F2PData_OutgoingAltsPacket()) end
		F2PData_RouteDataPacket(F2PData_OutgoingAltsPacket())
	end
end

function F2PData_SendMyData_ToOne(sender)
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("Sending to "..sender..": ".."f2p=datadone:"..F2PData_OutgoingDataPacket()) end
	ChatThrottleLib:SendAddonMessage("NORMAL", F2PAddonGlobalVars.AddonChannel1Name, "f2p=datadone:"..F2PData_OutgoingDataPacket(), "WHISPER", sender)
	if (#F2PAddon_Variables.Alts[F2PAddonGlobalVars.thisRealm] > 1) then --if this account has alts
		--[[]]if F2PAddon_Variables.Settings.Verbose then print("Sending to "..sender..": "..F2PData_OutgoingAltsPacket()) end
		ChatThrottleLib:SendAddonMessage("NORMAL", F2PAddonGlobalVars.AddonChannel1Name, F2PData_OutgoingAltsPacket(), "WHISPER", sender)
	end
end

--#########################
--# Data routing function #
--#########################

---[[
function F2PData_RouteDataPacket(msg)
	local f_num = GetNumFriends()
	for y = 1, f_num do
		local name, level, class, loc, connected, status = GetFriendInfo(y)
		if connected and name then
			--[[]]if F2PAddon_Variables.Settings.Verbose then print("sending data packet to "..name) end
			ChatThrottleLib:SendAddonMessage("NORMAL", F2PAddonGlobalVars.AddonChannel1Name, msg, "WHISPER", name)
		end
	end	
end
--]]

--####################################################################
--# Special case to have everyone request your level from the server #
--####################################################################

function F2PData_IDinged()
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("sending ding announcement") end
	F2PData_RouteDataPacket("f2p=ding")
end

function F2PData_RequestWhoLevel(sender)
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("received ding announcement from "..sender..", adding name to whoList and requesting /who.") end
	SetWhoToUI(false)
	SendWho('n-"'..sender..'"')
	tinsert(F2PAddonGlobalVars.whoList, sender)
end

function F2PData_ReceiveWhoLevel()
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("Who received.") end
	local numResults, totalCount = GetNumWhoResults()
	for x = 1, numResults do
		local name, guild, level, race, class, zone, classFileName, sex = GetWhoInfo(x)
		if tContains(F2PAddonGlobalVars.whoList, name) then
			if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name] then
				--[[]]if F2PAddon_Variables.Settings.Verbose then print("Updating database entry for "..name.." with level "..level) end
				F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name]["level"] = level
				for y = 1, #F2PAddonGlobalVars.whoList do
					if F2PAddonGlobalVars.whoList[y] == name then
						tremove(F2PAddonGlobalVars.whoList, y)
					end
				end
			end
		end
	end
end



--#####################################
--# Add incoming data to the database #
--#####################################

function F2PData_Data_Add(...)
	local input = ...
	local DB = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"]
	local dataName = string.match(input, ":([^:]+)$")

	if (DB[dataName] == nil) then
		DB[dataName] = {}
	end
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("------------") end
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("Adding data for "..dataName..":") end

	
	for i, v in string.gmatch(input, ":([^,]+),([^:]+)") do
		--[[]]if F2PAddon_Variables.Settings.Verbose then print(i..", "..v) end
		--if i == "version" and v == "1.3.13" then
			---[[]]if F2PAddon_Variables.Settings.Verbose then print(dataName.." REPORTING INVALID F2PAddon VERSION") end
			--[[local startingChannel = GetSelectedDisplayChannel()
			local z
			for x = 1, GetNumDisplayChannels() do
				y = GetChannelDisplayInfo(x)
				if y == F2PAddonGlobalVars.Channel1Name then
					z = x
				end
			end
			SetSelectedDisplayChannel(z)
			if IsDisplayChannelOwner() then
				ChannelKick(F2PAddonGlobalVars.Channel1Name, dataName)
				local msg = "Kicking "..dataName.." from the channel for using an F2Pddon version that interferes with the normal functioning of other user's addons."
				F2PChat_RouteChatMessage(msg)
				F2PChat_FormatIncoming(msg, F2PAddonGlobalVars.myName)
			end
			SetSelectedDisplayChannel(startingChannel)
		else ]]--
			DB[dataName][i] = v
		--end
	end
	F2PData_CleanUpClassNames(DB[dataName]) --make class names the right case
end

function F2PData_Alts_Add(sender, input)

	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender] = {}
	end
	
	local output = string.match(input, "^f2p=dataalts:([^:]+)$")

	output = string.gsub(output,"([^,]+)",F2PMisc_NamePlusRealm("%1")) --check that the name includes the realm
	
	--[[]]if F2PAddon_Variables.Settings.Verbose then print("alts of "..sender.." are: "..output) end
	F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][sender].Alts = output
end

--##########################
--# Log out time recording #
--##########################


function F2PData_LLIT_Single(...)	--Last Logged In Time
	local a,b,c,d,e,f,g,h,i = ...
	local currentTime = date("y%yM%md%dh%Hm%M")
	currentTime = string.gsub(currentTime,"h%d%d", "h"..string.format("%02d", GetGameTime()))
	
	b = F2PMisc_NamePlusRealm(b) --check that the name includes the realm
	
	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][b] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][b] = {}
	end
	F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][b]["LLIT"] = currentTime
end

function F2PData_LLIT_Group()	--Last Logged In Time
	local currentTime = date("y%yM%md%dh%Hm%M")
	currentTime = string.gsub(currentTime,"h%d%d", "h"..string.format("%02d", GetGameTime()))
	for i, v in pairs(F2PAddonGlobalVars.onlineFriendsList) do
	
		v = F2PMisc_NamePlusRealm(v) --check that the name includes the realm
	
		if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][v] == nil) then
			F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][v] = {}
		end
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][v]["LLIT"] = currentTime
	end
end


--#########################################
--# show which alts belong to a character #
--#########################################

function F2PData_ConfirmedAlts(name)
	local confirmedList = {}
	if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name].Alts then  --DB entry exists check
		for n in string.gmatch(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name].Alts, "([^,]+)") do -- split list and iterate
			if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][n] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][n].Alts then --if entry for alt exists and lists alts of it's own
				if string.match(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][n].Alts, name) then --and has a matching entry for the char we're checking for
					tinsert(confirmedList, n)
				end
			end
		end
	end
	return confirmedList
end

function F2PData_unConfirmedAlts(name)
	local unConfirmedList = {}
	if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name].Alts then  --DB entry exists check
		for n in string.gmatch(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name].Alts, "([^,]+)") do -- split list and iterate
			if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][n] then --if entry for alt exists
				tinsert(unConfirmedList, n)
			end
		end
	end
	return unConfirmedList
end

function F2PData_unConfirmedXFAlts(name)
	local unConfirmedXFList = {}
	if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name].Alts then  --DB entry exists check
		for n in string.gmatch(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][name].Alts, "([^,]+)") do -- split list and iterate
			if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.otherFaction] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.otherFaction]["Characters"] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.otherFaction]["Characters"][n] and F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.otherFaction]["Characters"][n].Alts then  --if alt name exists in other faction section of DB
				tinsert(unConfirmedXFList, n)
			end
		end
	end
	return unConfirmedXFList
end


--###########################
--# Compare version numbers #
--###########################

function F2PData_GetIfOldVersion()
	local isOld = 0
	local ourVersion = F2PAddonGlobalVars.addonVersion
	local otherVersion
	for i, v in pairs(F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"]) do
		if F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][i].version then
			otherVersion = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][i]["version"]
			if (otherVersion ~= "1.3.13") and F2PData_CompareVersions(ourVersion, otherVersion) then --some people's addons keep wrongly reporting as 1.3.13 for some reason.  There will never be a 1.3.13 release.
				isOld = 1
				ourVersion = otherVersion
			end
		end
	end
	if isOld == 1 then
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF" .. string.format(F2PLoc.data["OUTDATED"], ourVersion))
	end
end

function F2PData_CompareVersions(ours, others)

	local a1 = string.match(ours, "^([%d]+)\.")
	local a2 = string.match(ours, "\.([%d]+)\.")
	local a3 = string.match(ours, "[%d]+\.[%d]+\.([^b]+)b?$")

	local b1 = string.match(others, "^([%d]+)\.")
	local b2 = string.match(others, "\.([%d]+)\.")
	local b3 = string.match(others, "[%d]+\.[%d]+\.([^b]+)b?$")

	if tonumber(a1) < tonumber(b1) then
		return true
	elseif tonumber(a1) == tonumber(b1) then
		if tonumber(a2) < tonumber(b2) then
			return true
		elseif tonumber(a2) == tonumber(b2) then
			if tonumber(a3) < tonumber(b3) then
				return true
			elseif tonumber(a3) == tonumber(b3) then
				return false
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
	
end

--###################################
--# Set up basic database structure #
--###################################

function F2PData_BuildDBSkeleton()
	if (F2PAddon_Variables == nil) or (F2PAddon_Variables.Version == nil) then --if the complete table is blank, as when the addon is first installed, or the database predates versioning
		F2PAddon_Variables = {			--make this it's basic structure
			["Version"] = F2PAddonGlobalVars.addonVersion,
			["Settings"] = {
				["Verbose"] = F2PAddonGlobalVars.verbose,
				["TrialFix"] = F2PAddonGlobalVars.stillTreatedAsTrialFix,
			},
			["Alts"] = {
				[F2PAddonGlobalVars.thisRealm] = {},
			},
			["Realms"] = {
				[F2PAddonGlobalVars.thisRealm] = {
					[F2PAddonGlobalVars.myFaction] = {
						["Characters"] = {},
						["Settings"] = {
							["Channel"] = F2PAddonGlobalVars.DefaultChannelName,
						},
					},
				},
			},
		}
	end
	
	if (F2PAddon_Variables.Alts[F2PAddonGlobalVars.thisRealm] == nil) then --if the Alts data for this realm doesn't exist
		F2PAddon_Variables.Alts[F2PAddonGlobalVars.thisRealm] = {}		 --add a new blank table for it
	end
	
	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm] == nil) then --if the data for this realm doesn't exist,
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm] = {}		 --add a new blank table for it
	end

	if (F2PAddon_Variables.Settings.Verbose == nil) then
		F2PAddon_Variables.Settings.Verbose = false
	end
	
	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction] == nil) then --if the data for this faction doesn't exist for this realm,
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction] = {}		 --add a new blank table for it
	end

	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"] = {} -- make a new sub table for the character names
	end

	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"] = {} --set it to the default
	end
	
	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["Channel"] == nil) then --if there's no channel set for this realm/faction
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["Channel"] = F2PAddonGlobalVars.DefaultChannelName --set it to the default
	end

	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["BlockLowLevel"] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["BlockLowLevel"] = F2PAddonGlobalVars.blockLowLevel --set it to the default
	end
	
	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["BlockTwentyFour"] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["BlockTwentyFour"] = F2PAddonGlobalVars.blockTwentyFour --set it to the default
	end

	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["BlockGuild"] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["BlockGuild"] = F2PAddonGlobalVars.blockGuild --set it to the default
	end
	
	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["ShowCharacterTooltips"] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["ShowCharacterTooltips"] = F2PAddonGlobalVars.showCharacterTooltips --set it to the default
	end
	
	if (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["ChannelWindows"] == nil) then
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["ChannelWindows"] = F2PAddonGlobalVars.DefaultChannelWindows --set it to the default
	end	

	if not tContains(F2PAddon_Variables.Alts[F2PAddonGlobalVars.thisRealm], F2PAddonGlobalVars.myName) then
		tinsert(F2PAddon_Variables.Alts[F2PAddonGlobalVars.thisRealm], F2PAddonGlobalVars.myName)
	end
	
end


--If changes to the addon also require a change to the database structure, put code here to make those changes (or wipe the DB)
--then update the DB version to match the current addon version
function F2PData_NewVersionDatabase()
	local DBVersion = F2PAddon_Variables["Version"]
	
	--pull the list of compatible database versions from the .toc file, to avoid having to remember to change them here
	local compatableVersions = {}
	local i=1
	for str in string.gmatch(GetAddOnMetadata("F2PAddon", "X-CompatDBVers"), "[^/]+") do
	   compatableVersions[i] = str
	   i=i+1
	end
	
	if tContains( compatableVersions, DBVersion ) then  --if the database is compatible, mark it as matching the current version
		F2PAddon_Variables.Version = F2PAddonGlobalVars.addonVersion
	elseif (F2PAddonGlobalVars.addonVersion ~= DBVersion) then
		--all versions pre 1.2.15 will need purging, as the name format in those DBs doesn't include realm
		print("|cFFFF00FF[F2PAddon] Database structure has changed excessively between versions, and cannot be rebuilt, so it is being wiped and reset to an empty state compatable with the current addon version.")
		--wipe the DB and rebuild
		F2PAddon_Variables = nil
		F2PData_BuildDBSkeleton()

		--[[  leaving this here as example code, even though it's obsolete
		
		if DBVersion == "1.2.10b" then
			--fix stuff
			local DB = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"]
			--specs changed in mop, so each class has specs numbered 1-3 (4 for druids), instead of the old system where each spec had it's own code.
			--also since cata characters under level 10 can no longer pick a specialisation.
			--this wipes the old version specs from the database.
			print("|cFFFF00FF[F2PAddon] cleaning up the database to keep it compatable with the new addon version.")
			local under10s, over10druids, over10s, noversion = 0, 0, 0, 0
			for i, v in pairs(DB) do
				--Clean up specs that aren't within the 1-3 range (1-4 for druids), or are on characters under level 10.
				if DB[i]["level"] then
					if tonumber(DB[i]["level"]) < 10 then
						if DB[i]["spec"] then
							DB[i]["spec"] = nil
							under10s = under10s + 1
						end
					elseif tonumber(DB[i]["level"]) > 10 then
						if DB[i]["spec"] and DB[i]["class"] then
							if DB[i]["class"] == "Druid" and tonumber(DB[i]["spec"]) > 4 then
								DB[i]["spec"] = nil
								over10druids = over10druids + 1
							elseif DB[i]["class"] ~= "Druid" and tonumber(DB[i]["spec"]) > 3 then
								DB[i]["spec"] = nil
								over10s = over10s + 1
							end
						end
					end
				end
				--Remove entries that have no version number listed
				if not DB[i]["version"] then
					DB[i] = nil
					noversion = noversion + 1
				end
			end

			print("|cFFFF00FF"..under10s.." under 10s, "..over10druids.." over 10 druids, and "..over10s.." other over 10s have had their spec wiped from the addon's database, due to having pre MoP values.|r")
			print("|cFFFF00FF"..noversion.." entries were removed due to not having an addon version listed.|r")

		elseif (DBVersion == "1.2.11") or (DBVersion == "1.2.12") or (DBVersion == "1.2.13") or (DBVersion == "1.2.14") then  --Clean up invalid class names so that class colors can work
			print("|cFFFF00FF[F2PAddon] Fixing uppercase entries for class names in the database.")
			local DB = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"]
			
			for i, v in pairs(DB) do --make the class names the right case
				F2PData_CleanUpClassNames(DB[i])
			end
			F2PData_BuildDBSkeleton()			
		else
			print("|cFFFF00FF[F2PAddon] Database structure has changed excessively between versions, and cannot be rebuilt, so it is being wiped and reset to an empty state compatable with the current addon version.")
			--wipe the DB and rebuild
			F2PAddon_Variables = nil
			F2PData_BuildDBSkeleton()
		end  ]]--
		
	end
end

function F2PData_CleanUpClassNames(character)
	if character["class"] then
		if character["class"] == "DEATHKNIGHT" then
			character["class"] = "Deathknight"
		elseif character["class"] == "DRUID" then
			character["class"] = "Druid"
		elseif character["class"] == "HUNTER" then
			character["class"] = "Hunter"
		elseif character["class"] == "MAGE" then
			character["class"] = "Mage"
		elseif character["class"] == "MONK" then
			character["class"] = "Monk"
		elseif character["class"] == "PALADIN" then
			character["class"] = "Paladin"
		elseif character["class"] == "PRIEST" then
			character["class"] = "Priest"
		elseif character["class"] == "ROGUE" then
			character["class"] = "Rogue"
		elseif character["class"] == "SHAMAN" then
			character["class"] = "Shaman"
		elseif character["class"] == "WARLOCK" then
			character["class"] = "Warlock"
		elseif character["class"] == "WARRIOR" then
			character["class"] = "Warrior"
		end
	end
end
