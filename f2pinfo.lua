local L = F2PLoc.info

--[[  --leaving this here because it might be useful to have icons matched to localised names in the help section as a future feature
local specTable = {
	["Deathknight"] = {	"Blood", "Frost", "Unholy" },
	["Druid"] = { "Balance", "Feral", "Guardian", "Restoration"	},
	["Hunter"] = { "Beast Mastery", "Marksmanship", "Survival" },
	["Mage"] = { "Arcane", "Fire", "Frost" },
	["Monk"] = { "Brewmaster", "Mistweaver", "Windwalker" },
	["Paladin"] = {	"Holy",	"Protection", "Retribution" },
	["Priest"] = { "Discipline", "Holy", "Shadow" },
	["Rogue"] = { "Assassination", "Combat", "Subtlety"	},
	["Shaman"] = { "Elemental", "Enhancement", "Restoration" },
	["Warlock"] = {	"Affliction", "Demonology",	"Destruction" },
	["Warrior"] = {	"Arms",	"Fury",	"Protection" },
}
--]]

local iconTable = {
	race = {	--positions of each race in the image block
		["Alliance"] = {
			["Human"] = 0,
			["Dwarf"] = 1,
			["Gnome"] = 2,
			["NightElf"] = 3,
			["Draenei"] = 4,
			["Worgen"] = 5,
			["Pandaren"] = 6,
		},
		["Horde"] = {
			["Tauren"] = 0,
			["Forsaken"] = 1,
			["Troll"] = 2,
			["Orc"] = 3,
			["BloodElf"] = 4,
			["Goblin"] = 5,
			["Pandaren"] = 6,
		},		
	},
	spec = {	--image paths for each class specialisation icon
		["Deathknight"] = {	"Spell_Deathknight_BloodPresence", "Spell_Deathknight_FrostPresence", "Spell_Deathknight_UnholyPresence" },
		["Druid"] = { "Spell_Nature_StarFall", "Ability_Druid_CatForm", "Ability_Racial_BearForm", "SPELL_NATURE_HEALINGTOUCH"	},
		["Hunter"] = { "ABILITY_HUNTER_BESTIALDISCIPLINE", "Ability_Hunter_FocusedAim", "Ability_Hunter_Camouflage" },
		["Mage"] = { "Spell_Holy_MagicalSentry", "Spell_Fire_FireBolt02", "Spell_Frost_FrostBolt02" },
		["Monk"] = { "Spell_Monk_Brewmaster_Spec", "Spell_Monk_MistWeaver_Spec", "Spell_Monk_WindWalker_Spec" },
		["Paladin"] = {	"Spell_Holy_HolyBolt", "Ability_Paladin_ShieldoftheTemplar", "Spell_Holy_AuraOfLight" },
		["Priest"] = { "Spell_Holy_PowerWordShield", "Spell_Holy_GuardianSpirit", "Spell_Shadow_ShadowWordPain" },
		["Rogue"] = { "Ability_Rogue_Eviscerate", "Ability_BackStab", "Ability_Stealth"	},
		["Shaman"] = { "Spell_Nature_Lightning", "Spell_Shaman_ImprovedStormstrike", "Spell_Nature_MagicImmunity" },
		["Warlock"] = {	"Spell_Shadow_DeathCoil", "Spell_Shadow_Metamorphosis",	"Spell_Shadow_RainOfFire" },
		["Warrior"] = {	"Ability_Warrior_SavageBlow", "Ability_Warrior_InnerRage", "Ability_Warrior_DefensiveStance" },	
	},
}

local classNamesM = {}
local classNamesF = {}
FillLocalizedClassList(classNamesM ,false)
FillLocalizedClassList(classNamesF ,true)

local HEX_CLASS_COLORS = {  --saves having to convert them from the r,g,b values bliz uses
	["Deathknight"] = "C41F3B",
	["Druid"] = "FF7D0A",
	["Hunter"] = "ABD473",
	["Mage"] = "69CCF0",
	["Monk"] = "00FF96",
	["Paladin"] = "F58CBA",
	["Priest"] = "FFFFFF",
	["Rogue"] = "FFF569",
	["Shaman"] = "0070DE",
	["Warlock"] = "9482C9",
	["Warrior"] = "C79C6E",
}


local function showTooltip(...)
	local frame, linkdata, link = ...

	if string.match(linkdata, "^player:") and (F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction].Settings.ShowCharacterTooltips == 1) then
		local playerName = string.match(linkdata, "player:([^:$]+)")
		playerName = F2PMisc_NamePlusRealm(playerName) -- to handle the names that are missing their realm name in the chat
		local DB = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][playerName]
		if DB then --excludes all players that aren't part of the database
			ShowUIPanel(GameTooltip)
			GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
			GameTooltip:SetText(F2PInfo_GetTooltipContents(playerName))
			--F2PInfo_EnumerateTooltipLines_helper(GameTooltip:GetRegions())
			GameTooltip:Show()
		end
	end
end

local function hideTooltip(...)
    HideUIPanel(GameTooltip)
end
	
local function setOrHookHandler(frame, script, func)
    if frame:GetScript(script) then
        frame:HookScript(script, func)
    else
        frame:SetScript(script,func)
	end
end

for v = 1, NUM_CHAT_WINDOWS do
	local frame = getglobal("ChatFrame"..v)
	if frame then
		setOrHookHandler(frame, "OnHyperLinkEnter", showTooltip)
		setOrHookHandler(frame, "OnHyperLinkLeave", hideTooltip)
    end
end

function F2PInfo_GetTooltipContents(playerName)  --constructs and returns the text string that will be shown in the tooltip.
	local DB = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][playerName]
	if DB["race"] and DB["gender"] and DB["level"] and DB["class"] then --if there's basic data in the DB for the player
		local playerString = F2PInfo_GetFormattedPlayerData(playerName,F2PAddonGlobalVars.myFaction) --get the text/icon string for that character
		local thisFactionAltsString = ""
		local otherFactionAltsString = ""
		
		local thisFactionColorString = ""
		local otherFactionColorString = ""
		
		if F2PAddonGlobalVars.myFaction == "Horde" then
			thisFactionColorString = "AD0018"
			otherFactionColorString = "004BA6"
		else
			thisFactionColorString = "004BA6"
			otherFactionColorString = "AD0018"
		end
		if DB["Alts"] then	--if the character has listed alts
			local playerAlts = F2PData_unConfirmedAlts(playerName) --get the list of alts who have entries in the database themselves, from the character's faction
			local playerXFAlts = F2PData_unConfirmedXFAlts(playerName) --ditto, for the opposite faction alts


			local toRemove = nil  --strip out the player's name from the list of alts
			for i,v in ipairs(playerAlts) do
				if v == playerName then
					toRemove = i
				end
			end
			if toRemove then
				table.remove(playerAlts, toRemove)
			end
			
			if #playerAlts > 0 then  --if there's still alts for this faction start building the text for them
			
				--sort playerAlts by level
				table.sort(playerAlts, F2PInfo_AltsSortFunction)
			
				for i,v in ipairs(playerAlts) do
					--print(v)
					local DBt = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"][v]
					if ( DBt["race"] and DBt["gender"] ) and DBt["level"] and DBt["class"] then
						thisFactionAltsString = thisFactionAltsString.." "..F2PInfo_GetFormattedPlayerData(v,F2PAddonGlobalVars.myFaction)
					end
				end
				if thisFactionAltsString ~= "" then --only pretty up the text if there's actual content
					thisFactionAltsString = "|cFF"..thisFactionColorString.."\n "..L["ALTS"].."|r\n\n"..thisFactionAltsString
				end
			end

			if #playerXFAlts > 0 then  --if there's any cross faction alts build the text for those
			
				--sort playerXFAlts by level
				table.sort(playerXFAlts, F2PInfo_XFAltsSortFunction)
			
				for i,v in ipairs(playerXFAlts) do
					--print(v)
					local DBo = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.otherFaction]["Characters"][v]
					if ( DBo["race"] and DBo["gender"] ) and DBo["level"] and DBo["class"] then
						otherFactionAltsString = otherFactionAltsString.." "..F2PInfo_GetFormattedPlayerData(v,F2PAddonGlobalVars.otherFaction)
					end
				end
				if otherFactionAltsString ~= "" then --only pretty up the text if there's actual content
					otherFactionAltsString = "|cFF"..otherFactionColorString.."\n Alts:|r\n\n"..otherFactionAltsString
				end
			end
		end
		
		local accountType, addonVersion = "", ""
		if DB["trial"] == "1" then accountType = "|TInterface\\COMMON\\icon-noloot:16:16:0:0|t" elseif DB["trial"] == "0" then accountType = "|TInterface\\MONEYFRAME\\Ui-GoldIcon:16:16:0:0|t" end
		if DB["version"] then addonVersion = "F2PAddon "..DB["version"] end
	
		local footer = " \n"..accountType..addonVersion
		
		return "|cFFCCCCCC "..playerString..thisFactionAltsString..otherFactionAltsString..footer.."|r"
	else
		return playerName.." is either not running the addon, or has an obsolete version."
	end
end

function F2PInfo_GetFormattedPlayerData(playerName,faction)
	local DB = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][faction]["Characters"][playerName]
	
	local playerLevel, playerGender, playerRace, playerIcon, playerClass, playerSpec, playerILevel = "", "", "", "", "", "", ""
	if DB["level"] then playerLevel = " "..DB["level"].." " end
	if DB["gender"] and DB["race"] then
		--crop the image containing the race icons
		local imageY = 0
		if faction == "Horde" then imageY = imageY + 1 end
		if DB["gender"] == "female" then  imageY = imageY + 2 end
		local race = DB["race"]
		if race == "Blood Elf" then race = "BloodElf" end
		
		local x1 = 64 * iconTable.race[faction][race]
		local x2 = x1 + 64
		local y1 = 64 * imageY
		local y2 = 64 + y1
		
		--textures are in the format:
		--	|T<path>:<display width>:<display height>:<xoffset>:<yoffset>:<source image x dimension>:<source image y dimension>:<crop x from left>:<crop x from left>:<crop y from top>:<crop y from top>|t
		--note: it's possible to flip an image area by cropping back across it from the far side (x1 > x2)
		
		--print("Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-RACES:24:24:0:-8:512:256:"..x1..":"..x2..":"..y1..":"..y2)
		playerIcon = "|TInterface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-RACES:24:24:0:0:512:256:"..x1..":"..x2..":"..y1..":"..y2.."|t"
	end
	if DB["spec"] and (tonumber(DB["spec"]) < 5) and DB["class"] then playerSpec = iconTable.spec[DB["class"]][tonumber(DB["spec"])] end
	if not playerSpec or playerSpec == "" then playerSpec = "|TInterface\\Glues\\loadingOld:24:24:0:0|t" else playerSpec = "|TInterface\\ICONS\\"..playerSpec..":24:24:0:0|t" end
	
	if DB["iLevel"] then playerILevel = " iLevel="..DB["iLevel"] end

	local playerString = " |r"..playerIcon.." "..playerSpec..playerLevel.."|cFF"..F2PInfo_GetCharacterClassColorAsHex(playerName,faction)..playerName.."|r "..playerILevel.." "
	return playerString.."\n"
end


function F2PInfo_AltsSortFunction(a, b)
	local x = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Characters"]
	if x[a].level and x[b].level then
		return  tonumber(x[a].level) > tonumber(x[b].level)
	end
end

function F2PInfo_XFAltsSortFunction(a, b)
	local x = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.otherFaction]["Characters"]
	if x[a] and x[b] then
		if x[a].level and x[b].level then
			return  tonumber(x[a].level) > tonumber(x[b].level)
		end
	end
end

function F2PInfo_GetCharacterClassColorAsHex(character,faction)
	local n = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][faction]["Characters"][character]["class"]
	if n then
		return HEX_CLASS_COLORS[n]
	end
	return "808080"
end

function F2PInfo_ListChannelMembers()
	local channelNumber = F2PChat_GetChannelNumber(F2PAddonGlobalVars.Channel1Name)
	local channelColor = F2PChat_GetChannelColor(channelNumber)
	F2PChat_FormatIncoming("|cFF"..channelColor.."The following players are in this channel:", "F2PAddon")
	local f_num = GetNumFriends()
	for y = 1, f_num do
		local name, level, class, loc, connected, status = GetFriendInfo(y)
		level = tostring(level)
		local levelLength = #level
		local level = "|c00000000"..string.rep("_", 3 - levelLength).."|cFF"..channelColor..level --pad the level with leading spaces
		if connected and name and tContains(F2PAddonGlobalVars.inChatList, name) then --tContains to keep non channel friends out of the list
			local classColor = F2PChat_GetSenderClassColorAsHex(name)
			F2PChat_FormatIncoming(level .. " [|cFF"..classColor.."|Hplayer:"..name.."|h"..name.."|h|cFF"..channelColor.."]", "F2PAddon")
		end
	end

end

--[[
function F2PInfo_EnumerateTooltipLines_helper(...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region:GetObjectType() == "FontString" and region:GetText() ~= nil then
            print(region:GetText().."\n"..region:GetSpacing()) -- string or nil
        end
    end
end
--]]