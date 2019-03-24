

--  /f2pi slash commands are handled in f2pinvite.lua, as it still functions like a separate addon.


local commandTableA = {
	["channel"] = function(parameters)	
		LeaveChannelByName(F2PAddonGlobalVars.Channel1Name)
		F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction]["Settings"]["Channel"] = parameters
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF" .. string.format(F2PLoc.slash["CHANNEL_CHANGED"], parameters))
		ReloadUI()
	end,
	["help"] = function()
		InterfaceOptionsFrame_OpenToCategory("F2PAddon Help")
	end,
	["default"] = function()
		InterfaceOptionsFrame_OpenToCategory("F2PAddon")
		InterfaceOptionsFrame_OpenToCategory("F2PAddon")
		
	end,
}

local function runSlashCommandA(message, cmdTable)
	local command, parameters = string.split(" ", message, 2)
	if (command == nil) or (command == "") then
		commandTableA.default()
	elseif command == "help" then
		commandTableA.help()
	elseif (command == "channel") then
		commandTableA.channel(parameters)
	end
end

SLASH_F2PADDON1 = "/f2paddon"
SlashCmdList["F2PADDON"] = function(txt)
	runSlashCommandA(txt, commandTableA)
end



local commandTableW = {
	["default"] = function()
		F2PInfo_ListChannelMembers()
	end,
}

local function runSlashCommandW(message, cmdTable)
	local command, parameters = string.split(" ", message, 2)
	if (command == nil) or (command == "") then
		commandTableW.default()
	end
end

SLASH_F2PWHO1 = "/f2pwho"
SlashCmdList["F2PWHO"] = function(txt)
	runSlashCommandW(txt, commandTableW)
end



local commandTableQ = {
	["reset"] = function()
		F2PAddonGlobalVars.queueData = {}
		F2PQ_TableToDisplay()
	end,
	["default"] = function()
		if not PVEFrame_ToggleFrame then
            LoadAddOn("Blizzard_PVPUI")
        end
        if not F2PAddonQueueInfoFrame:IsVisible() and not PVEFrame:IsVisible() then
            if F2PAddonGlobalVars.f2pq_docked == true then
                F2PAddonQueueInfoFrame:SetPoint("TOPLEFT", PVEFrame, "TOPRIGHT")
			    F2PAddonQueueInfoFrame:SetPoint("BOTTOMRIGHT", PVEFrame, "TOPRIGHT", 238, -290)
			    F2PAddonQueueInfoFrame:SetPoint("BOTTOMLEFT", PVEFrame, "TOPRIGHT", 0, -290)
			    F2PAddonQueueInfoFrame:SetPoint("TOPRIGHT", PVEFrame, "TOPRIGHT", 238, 0)
            end
            F2PAddonQueueInfoFrame:Show()
            F2PQ_TableToDisplay()
            PVEFrame_ToggleFrame()
        elseif F2PAddonQueueInfoFrame:IsVisible() and PVEFrame:IsVisible() then
				PVEFrame_ToggleFrame()
		elseif F2PAddonQueueInfoFrame:IsVisible() and not PVEFrame:IsVisible() then
                F2PAddonQueueInfoFrame:Hide()		
		elseif not F2PAddonQueueInfoFrame:IsVisible() and PVEFrame:IsVisible() then
			F2PAddonQueueInfoFrame:Show()		
			F2PQ_TableToDisplay()
		end
	end,
}

local function runSlashCommandQ(message, cmdTable)
	local command, parameters = string.split(" ", message, 2)
	if (command == nil) or (command == "") then
		commandTableQ.default()
	elseif command == "reset" then
		commandTableQ.reset()
	end
end

SLASH_F2PQ1 = "/f2pq"
SlashCmdList["F2PQ"] = function(txt)
	runSlashCommandQ(txt, commandTableQ)
end
