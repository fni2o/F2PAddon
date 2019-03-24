local L = F2PLoc.options

--Values for the spacing of items in the options panel
local leftInset = 15	       -- first 3 set how far inside the frame's border content starts
local rightInset = 15
local topInset = 15
local checkboxInset = 5        --sets the additional inset from the title text for the section
local subsectionInset = 10
local subSubsectionInset = 10
local column1Width = 100
local rowSpacing = 15          --spacing between rows of checkboxes or title and checkbox
local sectionSpacing = 20      --space between the last line of a section and the title of the next
local checkboxTextVAlign = 10  --used to center the first line of text after a checkbox with the box itself

function F2PAddon_CreateOptionsFrames()

	local DBLocalSettings = F2PAddon_Variables.Realms[F2PAddonGlobalVars.thisRealm][F2PAddonGlobalVars.myFaction].Settings
	local DBGlobalSettings = F2PAddon_Variables.Settings

	--Options frame that fits inside the game's interface > addons section
	local F2PAddon_OptionsFrame = CreateFrame("Frame", "F2PAddonOptionsFrame", InterfaceOptionsFramePanelContainer)
	F2PAddon_OptionsFrame.name = "F2PAddon"
	F2PAddon_OptionsFrame.okay = function (self) return end
	F2PAddon_OptionsFrame.cancel = function (self) return end

	F2PAddon_OptionsFrame:SetPoint('TOPLEFT', InterfaceOptionsFramePanelContainer, 'TOPLEFT', 0, 0)
	F2PAddon_OptionsFrame:SetPoint('BOTTOMRIGHT', InterfaceOptionsFramePanelContainer, 'BOTTOMRIGHT', 0, 0)
	--[[
	F2PAddon_OptionsFrame:CreateTexture("F2PAddon_OptionsFrameBG")
	F2PAddon_OptionsFrameBG:SetTexture(1,0,0,0.5)
	F2PAddon_OptionsFrameBG:SetAllPoints()
	--]]
	
	--Container for a scrolling frame that will in turn contain the content of the options
	local F2PAddon_Options_ScrollContainer = CreateFrame("ScrollFrame", "F2PAddonOptionsScrollFrame", F2PAddon_OptionsFrame)
	F2PAddon_Options_ScrollContainer:SetAllPoints()
	
	--Scrollbar to the side of the container
	local F2PAddon_Options_Scrollbar = CreateFrame("Slider", nil, F2PAddon_Options_ScrollContainer, "UIPanelScrollBarTemplate")
	F2PAddon_Options_Scrollbar:SetPoint("TOPLEFT", F2PAddon_OptionsFrame, "TOPRIGHT", 0, -16)
	F2PAddon_Options_Scrollbar:SetPoint("BOTTOMLEFT", F2PAddon_OptionsFrame, "BOTTOMRIGHT", 0, 16)
	F2PAddon_Options_Scrollbar:SetMinMaxValues(1, 500)
	F2PAddon_Options_Scrollbar:SetValueStep(1)
	F2PAddon_Options_Scrollbar.scrollStep = 1
	F2PAddon_Options_Scrollbar:SetValue(0)
	F2PAddon_Options_Scrollbar:SetWidth(16)
	F2PAddon_Options_Scrollbar:SetScript("OnValueChanged", function (self)
		F2PAddon_Options_ScrollContainer:SetVerticalScroll(self:GetValue())
	end)
	local scrollbg = F2PAddon_Options_Scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(F2PAddon_Options_Scrollbar)
	scrollbg:SetTexture(0, 0, 0, 0.4)
	
	--The scrolling content frame that contains the page items
	local F2PAddon_OptionsScrollingFrame = CreateFrame("Frame", nil, F2PAddon_Options_ScrollContainer)
	F2PAddon_OptionsScrollingFrame:SetPoint('TOPLEFT', F2PAddon_OptionsFrame, 'TOPLEFT', 0, 0)
	
	--attach the scrolling frame to it's container
	F2PAddon_Options_ScrollContainer:SetScrollChild(F2PAddon_OptionsScrollingFrame)




	--Main title - "F2PAddon n.n.nn Options"
    local optionsTitle = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    optionsTitle:SetPoint("TOPLEFT", leftInset, -topInset)
    optionsTitle:SetText(string.format(L["TITLE"], F2PAddonGlobalVars.addonVersion))
	
	
	
	--Info - "Author: Yasueh, Aerie Peak US"
    local info = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    info:SetPoint("TOPLEFT", optionsTitle, "BOTTOMLEFT", 0, -rowSpacing)
    info:SetText(string.format(L["AUTHOR"], GetAddOnMetadata("F2PAddon", "Author")))
	
		
	
	--Section heading - "Channel Name:"
	local channelNameText1 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	channelNameText1:SetPoint('TOPLEFT', info, 'BOTTOMLEFT', 0, -sectionSpacing)
	channelNameText1:SetText(L["CHANNEL_NAME"])
	
	--Channel name edit box
	local channelNameBox = CreateFrame("EditBox", nil, F2PAddon_OptionsScrollingFrame, "InputBoxTemplate")
	channelNameBox:SetPoint("TOPLEFT", channelNameText1, "TOPRIGHT", 10, 8)
	channelNameBox:SetWidth(100);
	channelNameBox:SetHeight(25);
	channelNameBox:SetMaxLetters(16)
	channelNameBox:SetText(F2PAddonGlobalVars.Channel1Name)
	
	--Update button
	local updateChannelNameButton = CreateFrame("Button", nil, F2PAddon_OptionsScrollingFrame, "UIPanelButtonTemplate")
	updateChannelNameButton:SetPoint('TOP', channelNameText1, 'TOP', 0, 7)
	updateChannelNameButton:SetPoint("LEFT", channelNameBox, "RIGHT", 5, 0)
	updateChannelNameButton:SetSize(80 ,22)
	updateChannelNameButton:SetText(L["CHANNEL_NAME_BUTTON_TEXT"])
	updateChannelNameButton:SetScript("OnClick", function(self, button, down)
		if channelNameBox:GetText() ~= F2PAddonGlobalVars.Channel1Name then
			DBLocalSettings.ChannelWindows = F2PChat_GetSubscribedChannels(F2PAddonGlobalVars.Channel1Name)
			LeaveChannelByName(F2PAddonGlobalVars.Channel1Name)
			DBLocalSettings.Channel = channelNameBox:GetText()
			ReloadUI()
		end
	end)
	
	--"(Reloads the UI)"
	local channelNameText2 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	channelNameText2:SetPoint('TOP', channelNameText1, 'TOP', 0, 0)
	channelNameText2:SetPoint('LEFT', updateChannelNameButton, 'RIGHT', 5, 0)
	channelNameText2:SetText(L["CHANNEL_NAME_RELOADS"])
	
	
	
	--[[
	future code here to:
	* Implement a dropdown menu listing all the chat windows that the channel could be shown in.  Dropdowns will need a library such as Ace, as they aren't a part of the default widgets.  Will also allow changes to the channel name to no longer reset which window shows the channel.
	* color picker for the channel text color
	--]]
		
	
	
	--Section heading - "Message Blocking:"
	local messageBlockingText1 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	messageBlockingText1:SetPoint('TOPLEFT', channelNameText1, 'BOTTOMLEFT', 0, -sectionSpacing)
	messageBlockingText1:SetText(L["MESSAGE_BLOCKING"])

	-- checkbox to block level 1 and 2s
	local lowLevelCheckBox = CreateFrame("CheckButton", nil, F2PAddon_OptionsScrollingFrame, "UICheckButtonTemplate")
	lowLevelCheckBox:SetPoint("TOPLEFT", messageBlockingText1, "TOPLEFT", checkboxInset, -rowSpacing)
	lowLevelCheckBox:SetScript("OnClick", function(self, button, down)
		if DBLocalSettings.BlockLowLevel == 1 then
			DBLocalSettings.BlockLowLevel = 0
		elseif DBLocalSettings.BlockLowLevel == 0 then
			DBLocalSettings.BlockLowLevel = 1
		end
		if DBLocalSettings.BlockLowLevel == 1 then
			lowLevelCheckBox:SetChecked(true)
		elseif DBLocalSettings.BlockLowLevel == 0 then
			lowLevelCheckBox:SetChecked(false)
		end
	end)
	
	--"Level 1 and 2 characters (whispers and channel messages)."
	local messageBlockingText2 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	messageBlockingText2:SetPoint('TOPLEFT', lowLevelCheckBox, 'TOPRIGHT', 0, -checkboxTextVAlign)
	messageBlockingText2:SetJustifyH("LEFT")
	messageBlockingText2:SetWordWrap(true)
	messageBlockingText2:SetText(L["L1+2"])	
	

	-- checkbox to block level 24s
	local twentyFourCheckBox = CreateFrame("CheckButton", nil, F2PAddon_OptionsScrollingFrame, "UICheckButtonTemplate")
	twentyFourCheckBox:SetPoint("TOP", messageBlockingText2, "TOP", 0, -rowSpacing)
	twentyFourCheckBox:SetPoint("LEFT", messageBlockingText1, "LEFT", checkboxInset, 0)
	twentyFourCheckBox:SetScript("OnClick", function(self, button, down)
		if DBLocalSettings.BlockTwentyFour == 1 then
			DBLocalSettings.BlockTwentyFour = 0
		elseif DBLocalSettings.BlockTwentyFour == 0 then
			DBLocalSettings.BlockTwentyFour = 1
		end

		if DBLocalSettings.BlockTwentyFour == 1 then
			twentyFourCheckBox:SetChecked(true)
		elseif DBLocalSettings.BlockTwentyFour == 0 then
			twentyFourCheckBox:SetChecked(false)
		end
	end)
	
	--"Level 24 characters (whispers and channel messages)."
	local messageBlockingText3 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	messageBlockingText3:SetPoint('TOPLEFT', twentyFourCheckBox, 'TOPRIGHT', 0, -checkboxTextVAlign)
	messageBlockingText3:SetJustifyH("LEFT")
	messageBlockingText3:SetWordWrap(true)
	messageBlockingText3:SetText(L["L24"])	

	-- checkbox to block whispers mentioning guilds or charters, from people not on friends list
	local guildCheckBox = CreateFrame("CheckButton", nil, F2PAddon_OptionsScrollingFrame, "UICheckButtonTemplate")
	guildCheckBox:SetPoint("TOP", messageBlockingText3, "TOP", 0, -rowSpacing)
	guildCheckBox:SetPoint("LEFT", messageBlockingText1, "LEFT", checkboxInset, 0)
	guildCheckBox:SetScript("OnClick", function(self, button, down)
		if DBLocalSettings.BlockGuild == 1 then
			DBLocalSettings.BlockGuild = 0
		elseif DBLocalSettings.BlockGuild == 0 then
			DBLocalSettings.BlockGuild = 1
		end

		if DBLocalSettings.BlockGuild == 1 then
			guildCheckBox:SetChecked(true)
		elseif DBLocalSettings.BlockGuild == 0 then
			guildCheckBox:SetChecked(false)
		end
	end)

	--"Whispers from people you don't know, containing the words 'guild' or 'charter'."
	local messageBlockingText4 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	messageBlockingText4:SetPoint('TOPLEFT', guildCheckBox, 'TOPRIGHT', 0, -checkboxTextVAlign)
	messageBlockingText4:SetJustifyH("LEFT")
	messageBlockingText4:SetWordWrap(true)
	messageBlockingText4:SetText(L["GUILD"])


	
	--Section heading - Character & alt info tooltips:
	local characterTooltipsText1 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	characterTooltipsText1:SetPoint("TOP", messageBlockingText4, "BOTTOM", 0, -sectionSpacing)
	characterTooltipsText1:SetPoint("LEFT", channelNameText1, "LEFT", 0, 0)
	characterTooltipsText1:SetText(L["TOOLTIPS"])	
	
	--checkbox to enable character name tooltips
	local characterTooltipsCheckBox = CreateFrame("CheckButton", nil, F2PAddon_OptionsScrollingFrame, "UICheckButtonTemplate")
	characterTooltipsCheckBox:SetPoint("TOPLEFT", characterTooltipsText1, "TOPLEFT", checkboxInset, -rowSpacing)
	characterTooltipsCheckBox:SetScript("OnClick", function(self, button, down)
		if DBLocalSettings.ShowCharacterTooltips == 1 then
			DBLocalSettings.ShowCharacterTooltips = 0
		elseif DBLocalSettings.ShowCharacterTooltips == 0 then
			DBLocalSettings.ShowCharacterTooltips = 1
		end

		if DBLocalSettings.ShowCharacterTooltips == 1 then
			characterTooltipsCheckBox:SetChecked(true)
		elseif DBLocalSettings.ShowCharacterTooltips == 0 then
			characterTooltipsCheckBox:SetChecked(false)
		end
	end)

	--"(Only shows alts that the addon has seen, and that it can confirm are on the same account.)"
	local characterTooltipsText2 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	characterTooltipsText2:SetPoint('TOPLEFT', characterTooltipsCheckBox, 'TOPRIGHT', 0, -checkboxTextVAlign)
	characterTooltipsText2:SetJustifyH("LEFT")
	characterTooltipsText2:SetWordWrap(true)
	characterTooltipsText2:SetText(L["TOOLTIPS_DESC"])
	
	
	
	--Section heading - "Account waiting to be upgraded fix:"
	local trialFixText1 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	trialFixText1:SetPoint("TOP", characterTooltipsText2, "BOTTOM", 0, -sectionSpacing)
	trialFixText1:SetPoint("LEFT", channelNameText1, "LEFT", 0, 0)
	trialFixText1:SetText(L["UPGRADE"])
	
	--checkbox for trial upgrading fix
	local trialFixCheckBox = CreateFrame("CheckButton", nil, F2PAddon_OptionsScrollingFrame, "UICheckButtonTemplate")
	trialFixCheckBox:SetPoint("TOPLEFT", trialFixText1, "TOPLEFT", checkboxInset, -rowSpacing)
	trialFixCheckBox:SetScript("OnClick", function(self, button, down)
		if DBGlobalSettings.TrialFix then
			DBGlobalSettings.TrialFix = false
		elseif DBGlobalSettings.TrialFix == false then
			DBGlobalSettings.TrialFix = true
		end
		
		if DBGlobalSettings.TrialFix then
			trialFixCheckBox:SetChecked(true)
		elseif DBGlobalSettings.TrialFix == false then
			trialFixCheckBox:SetChecked(false)
		end
	end)
	
	--"Checking this allows F2PAddon to function correctly when a recently upgraded account still has restrictions on chat, for the approximately 72 hours that it takes for Blizzard to fully process the upgrade."
	local trialFixText2 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	trialFixText2:SetPoint('TOPLEFT', trialFixCheckBox, 'TOPRIGHT', 0, -10)
	trialFixText2:SetJustifyH("LEFT")
	trialFixText2:SetWordWrap(true)
	trialFixText2:SetWidth(F2PAddon_OptionsScrollingFrame:GetWidth() - (leftInset + checkboxInset + rightInset + trialFixCheckBox:GetWidth()))
	trialFixText2:SetText(L["UPGRADE_DESC"])
	
	

	--Section heading - "Debugging messages:"
	local debuggingText1 = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	debuggingText1:SetPoint("TOP", trialFixText2, "BOTTOM", 0, -sectionSpacing)
	debuggingText1:SetPoint("LEFT", channelNameText1, "LEFT", 0, 0)
	debuggingText1:SetText(L["DEBUG"])	

	local verboseCheckBox = CreateFrame("CheckButton", nil, F2PAddon_OptionsScrollingFrame, "UICheckButtonTemplate") --checkbox for debugging messages
	verboseCheckBox:SetPoint("TOPLEFT", debuggingText1, "TOPLEFT", checkboxInset, -rowSpacing)
	verboseCheckBox:SetScript("OnClick", function(self, button, down)
		if DBGlobalSettings.Verbose then
			DBGlobalSettings.Verbose = false
		elseif DBGlobalSettings.Verbose == false then
			DBGlobalSettings.Verbose = true
		end

		if DBGlobalSettings.Verbose then
			verboseCheckBox:SetChecked(true)
		elseif DBGlobalSettings.Verbose == false then
			verboseCheckBox:SetChecked(false)
		end
	end)
	
	--[[
	local testText = F2PAddon_OptionsScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	testText:SetPoint("TOP", verboseCheckBox, "BOTTOM", 0, -sectionSpacing)
	testText:SetPoint("LEFT", channelNameText1, "LEFT", 0, 0)
	testText:SetText("a\nb\nc\nd\ne\nf\ng\nh\ni\nj\nk\nl\nm\nn\no\np\nq\nr\ns\nt\nu\nv\nw\nx\ny\nz")
	--]]
	
	
	
	--These lines repeated here to display the check boxes correctly the first time the window is shown.  The calls inside the per-item SetScripts handle changes after that.
	if DBLocalSettings.BlockLowLevel == 1 then
		lowLevelCheckBox:SetChecked(true)
	elseif DBLocalSettings.BlockLowLevel == 0 then
		lowLevelCheckBox:SetChecked(false)
	end
	
	if DBLocalSettings.BlockTwentyFour == 1 then
		twentyFourCheckBox:SetChecked(true)
	elseif DBLocalSettings.BlockTwentyFour == 0 then
		twentyFourCheckBox:SetChecked(false)
	end
	
	if DBLocalSettings.BlockGuild == 1 then
		guildCheckBox:SetChecked(true)
	elseif DBLocalSettings.BlockGuild == 0 then
		guildCheckBox:SetChecked(false)
	end

	if DBLocalSettings.ShowCharacterTooltips == 1 then
		characterTooltipsCheckBox:SetChecked(true)
	elseif DBLocalSettings.ShowCharacterTooltips == 0 then
		characterTooltipsCheckBox:SetChecked(false)
	end
	
	if DBGlobalSettings.TrialFix then
		trialFixCheckBox:SetChecked(true)
	elseif DBGlobalSettings.TrialFix == false then
		trialFixCheckBox:SetChecked(false)
	end
	
	if DBGlobalSettings.Verbose then
		verboseCheckBox:SetChecked(true)
	elseif DBGlobalSettings.Verbose == false then
		verboseCheckBox:SetChecked(false)
	end

		
	--Set the frame up as it's shown
	F2PAddon_OptionsFrame:SetScript("OnShow", function(F2PAddonOptionsFrame)
		--InterfaceOptionsFrame_OpenToCategory("F2PAddon Help") -- expands the help subsection so people can see it exists more easily
		--InterfaceOptionsFrame_OpenToCategory("F2PAddon")      -- ^^
		channelNameBox:SetText(F2PAddonGlobalVars.Channel1Name)
		--items need to be scaled when they are first shown instead of as they are created, because the frame that they're scaled relative to changes sizes after they're created
		F2PAddon_OptionsScrollingFrame:SetSize(F2PAddon_OptionsFrame:GetWidth(), 500)
		F2PAddon_Options_ScrollContainer:SetVerticalScroll(0)
		F2PAddon_Options_Scrollbar:SetValue(0)
		local textSpace = F2PAddon_OptionsFrame:GetWidth() - (leftInset + checkboxInset + rightInset + trialFixCheckBox:GetWidth())
		messageBlockingText2:SetWidth(textSpace)
		messageBlockingText3:SetWidth(textSpace)
		messageBlockingText4:SetWidth(textSpace)
		characterTooltipsText2:SetWidth(textSpace)
		trialFixText2:SetWidth(textSpace)
	end)
	
	
	--Help frame
	local F2PAddon_HelpFrame = CreateFrame("Frame", "F2PAddonOptionsFrame", InterfaceOptionsFramePanelContainer)
	F2PAddon_HelpFrame.parent = "F2PAddon"
	F2PAddon_HelpFrame.name = "F2PAddon Help"
	F2PAddon_HelpFrame.okay = function (self) return end
	F2PAddon_HelpFrame.cancel = function (self) return end

	F2PAddon_HelpFrame:SetPoint('TOPLEFT', InterfaceOptionsFramePanelContainer, 'TOPLEFT', 0, 0)
	F2PAddon_HelpFrame:SetPoint('BOTTOMRIGHT', InterfaceOptionsFramePanelContainer, 'BOTTOMRIGHT', 0, 0)
	--[[
	F2PAddon_HelpFrame:CreateTexture("F2PAddon_HelpFrameBG")
	F2PAddon_HelpFrameBG:SetTexture(1,0,0,0.5)
	F2PAddon_HelpFrameBG:SetAllPoints()
	--]]
	
	--Container for a scrolling frame that will in turn contain the content of the options
	local F2PAddon_Help_ScrollContainer = CreateFrame("ScrollFrame", "F2PAddonHelpScrollFrame", F2PAddon_HelpFrame)
	F2PAddon_Help_ScrollContainer:SetAllPoints()
	
	--Scrollbar to the side of the container
	local F2PAddon_Help_Scrollbar = CreateFrame("Slider", nil, F2PAddon_Help_ScrollContainer, "UIPanelScrollBarTemplate")
	F2PAddon_Help_Scrollbar:SetPoint("TOPLEFT", F2PAddon_HelpFrame, "TOPRIGHT", 0, -16)
	F2PAddon_Help_Scrollbar:SetPoint("BOTTOMLEFT", F2PAddon_HelpFrame, "BOTTOMRIGHT", 0, 16)
	F2PAddon_Help_Scrollbar:SetMinMaxValues(1, 500)
	F2PAddon_Help_Scrollbar:SetValueStep(1)
	F2PAddon_Help_Scrollbar.scrollStep = 1
	F2PAddon_Help_Scrollbar:SetValue(0)
	F2PAddon_Help_Scrollbar:SetWidth(16)
	F2PAddon_Help_Scrollbar:SetScript("OnValueChanged", function (self)
		F2PAddon_Help_ScrollContainer:SetVerticalScroll(self:GetValue())
	end)
	local scrollbg = F2PAddon_Help_Scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(F2PAddon_Help_Scrollbar)
	scrollbg:SetTexture(0, 0, 0, 0.4)
	
	--The scrolling content frame that contains the page items
	local F2PAddon_HelpScrollingFrame = CreateFrame("Frame", nil, F2PAddon_Help_ScrollContainer)
	F2PAddon_HelpScrollingFrame:SetPoint('TOPLEFT', F2PAddon_HelpFrame, 'TOPLEFT', 0, 0)
	
	--attach the scrolling frame to it's container
	F2PAddon_Help_ScrollContainer:SetScrollChild(F2PAddon_HelpScrollingFrame)	
	

	
	--Main title - "F2PAddon Help"
	local helpTitle = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") --Title for the window
    helpTitle:SetPoint("TOPLEFT", leftInset, -topInset)
    helpTitle:SetText("F2PAddon Help")


	
	--Section heading - "Invite module commands:"
    local helpSection1Heading = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection1Heading:SetPoint("TOPLEFT", helpTitle, "BOTTOMLEFT", 0, -rowSpacing)
    helpSection1Heading:SetText("Invite module commands:")

	
	
	--Subsection heading - "In channel:"
    local helpSection1Subsection1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection1Subsection1:SetPoint("TOPLEFT", helpSection1Heading, "BOTTOMLEFT", subsectionInset, -rowSpacing)
    helpSection1Subsection1:SetText("In channel:")	
	
	--Command - "p2p?"
    local helpSection1Subsection1Command1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    helpSection1Subsection1Command1:SetPoint("TOPLEFT", helpSection1Subsection1, "BOTTOMLEFT", subSubsectionInset, -rowSpacing)
    helpSection1Subsection1Command1:SetText("p2p?")	
	
	--"Will cause all P2P characters running the addon to respond in the channel if they're available to invite."
    local helpSection1Subsection1Text1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection1Subsection1Text1:SetPoint("TOP", helpSection1Subsection1Command1, "TOP", 0, 0)
    helpSection1Subsection1Text1:SetPoint("LEFT", helpSection1Subsection1Command1, "LEFT", (column1Width), 0)
	helpSection1Subsection1Text1:SetJustifyH("LEFT")
	helpSection1Subsection1Text1:SetWordWrap(true)
    helpSection1Subsection1Text1:SetText("Will cause all P2P characters running the addon to respond in the channel if they're available to invite.")	


	
	--Subsection heading - "Whispered to a P2P:"
    local helpSection1Subsection2 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection1Subsection2:SetPoint("TOP", helpSection1Subsection1Text1, "BOTTOM", 0, -sectionSpacing)
    helpSection1Subsection2:SetPoint("LEFT", helpSection1Heading, "LEFT", subsectionInset, 0)
    helpSection1Subsection2:SetText("Whispered to a P2P:")	
	
	--Command - "inv"
    local helpSection1Subsection2Command1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    helpSection1Subsection2Command1:SetPoint("TOPLEFT", helpSection1Subsection2, "BOTTOMLEFT", subSubsectionInset, -rowSpacing)
    helpSection1Subsection2Command1:SetText("inv")		
	
	--"Will ask the P2P to invite you to a group."
    local helpSection1Subsection2Text1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection1Subsection2Text1:SetPoint("TOP", helpSection1Subsection2Command1, "TOP", 0, 0)
    helpSection1Subsection2Text1:SetPoint("LEFT", helpSection1Subsection2Command1, "LEFT", (column1Width), 0)
	helpSection1Subsection2Text1:SetJustifyH("LEFT")
	helpSection1Subsection2Text1:SetWordWrap(true)
    helpSection1Subsection2Text1:SetText("Will ask the P2P to invite you to a group.")		

	--Command - "lead"
    local helpSection1Subsection2Command2 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	helpSection1Subsection2Command2:SetPoint("TOP", helpSection1Subsection2Text1, "BOTTOM", 0, -rowSpacing)
	helpSection1Subsection2Command2:SetPoint("LEFT", helpSection1Subsection2, "LEFT", subsectionInset, 0)
    helpSection1Subsection2Command2:SetText("lead")		
	
	--"Will ask the P2P to pass lead to you before they leave the group (The first person to join the group will automaticallly be given lead, unless someone else uses this command)."
    local helpSection1Subsection2Text2 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection1Subsection2Text2:SetPoint("TOP", helpSection1Subsection2Command2, "TOP", 0, 0)
    helpSection1Subsection2Text2:SetPoint("LEFT", helpSection1Subsection2Command2, "LEFT", (column1Width), 0)
	helpSection1Subsection2Text2:SetJustifyH("LEFT")
	helpSection1Subsection2Text2:SetWordWrap(true)
    helpSection1Subsection2Text2:SetText("Will ask the P2P to pass lead to you before they leave the group (The first person to join the group will automatically be given lead, unless someone else uses this command).")	
	
	--Command - "close"
    local helpSection1Subsection2Command3 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	helpSection1Subsection2Command3:SetPoint("TOP", helpSection1Subsection2Text2, "BOTTOM", 0, -rowSpacing)
	helpSection1Subsection2Command3:SetPoint("LEFT", helpSection1Subsection2, "LEFT", subsectionInset, 0)
    helpSection1Subsection2Command3:SetText("close")		
	
	--"Will ask the P2P to leave the group (they will automatically leave after inviting 5 people)."
    local helpSection1Subsection2Text3 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection1Subsection2Text3:SetPoint("TOP", helpSection1Subsection2Command3, "TOP", 0, 0)
    helpSection1Subsection2Text3:SetPoint("LEFT", helpSection1Subsection2Command3, "LEFT", (column1Width), 0)
	helpSection1Subsection2Text3:SetJustifyH("LEFT")
	helpSection1Subsection2Text3:SetWordWrap(true)
    helpSection1Subsection2Text3:SetText("Will ask the P2P to leave the group (they will automatically leave after inviting 5 people).")		



	--Section heading - "Slash commands:"
    local helpSection2Heading = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	helpSection2Heading:SetPoint("TOP", helpSection1Subsection2Text3, "BOTTOM", 0, -sectionSpacing)
	helpSection2Heading:SetPoint("LEFT", helpTitle, "LEFT", 0, 0)
    helpSection2Heading:SetText("Slash commands:")	
	
	--Subsection heading - "General:"
    local helpSection2Subsection1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection2Subsection1:SetPoint("TOPLEFT", helpSection2Heading, "BOTTOMLEFT", subsectionInset, -rowSpacing)
    helpSection2Subsection1:SetText("General:")	

	--Command - "/f2paddon"
    local helpSection2Subsection1Command1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    helpSection2Subsection1Command1:SetPoint("TOPLEFT", helpSection2Subsection1, "BOTTOMLEFT", subSubsectionInset, -rowSpacing)
    helpSection2Subsection1Command1:SetText("/f2paddon")		

	--"Opens the options page for the addon, without having to hit Escape > Interface > Addons > F2PAddon."
    local helpSection2Subsection1Text1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection2Subsection1Text1:SetPoint("TOPLEFT", helpSection2Subsection1Command1, "TOPLEFT", column1Width, 0)
	helpSection2Subsection1Text1:SetJustifyH("LEFT")
	helpSection2Subsection1Text1:SetWordWrap(true)
    helpSection2Subsection1Text1:SetText("Opens the options page for the addon, without having to hit Escape > Interface > Addons > F2PAddon.")		

	--Subsection heading - "Invite module (only for P2Ps):"
    local helpSection2Subsection2 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection2Subsection2:SetPoint("TOP", helpSection2Subsection1Text1, "BOTTOM", 0, -sectionSpacing)
    helpSection2Subsection2:SetPoint("LEFT", helpSection2Heading, "LEFT", subsectionInset, 0)	
    helpSection2Subsection2:SetText("Invite module (only for P2Ps):")	

	--Command - "/f2pi"
    local helpSection2Subsection2Command1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	helpSection2Subsection2Command1:SetPoint("TOPLEFT", helpSection2Subsection2, "BOTTOMLEFT", subSubsectionInset, -rowSpacing)
    helpSection2Subsection2Command1:SetText("/f2pi")		
	
	--"Enable/disable the invite module (it's automatically disabled while you're queued for something, in a dungeon/raid group, or in arenas, battlegrounds or PvP zones)."
    local helpSection2Subsection2Text1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection2Subsection2Text1:SetPoint("TOPLEFT", helpSection2Subsection2Command1, "TOPLEFT", column1Width, 0)
	helpSection2Subsection2Text1:SetJustifyH("LEFT")
	helpSection2Subsection2Text1:SetWordWrap(true)
    helpSection2Subsection2Text1:SetText("Enable/disable the invite module (it's automatically disabled while you're queued for something, in a dungeon/raid group, or in arenas, battlegrounds or PvP zones).")		

	--Command - "/f2pi fish"
    local helpSection2Subsection2Command2 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	helpSection2Subsection2Command2:SetPoint("TOP", helpSection2Subsection2Text1, "BOTTOM", 0, -rowSpacing)
	helpSection2Subsection2Command2:SetPoint("LEFT", helpSection2Subsection2, "LEFT", subSubsectionInset, 0)	
    helpSection2Subsection2Command2:SetText("/f2pi fish")		
	
	--"Removes the cap to allow more than 5 players to be invited, and disables the lead and close commands (used to be used to see where everyone was during a fishing competition, so my shaman could fly round and give them all water-walking)."
    local helpSection2Subsection2Text2 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection2Subsection2Text2:SetPoint("TOPLEFT", helpSection2Subsection2Command2, "TOPLEFT", column1Width, 0)
	helpSection2Subsection2Text2:SetJustifyH("LEFT")
	helpSection2Subsection2Text2:SetWordWrap(true)
    helpSection2Subsection2Text2:SetText("Removes the cap to allow more than 5 players to be invited, and disables the lead and close commands (intended to be used to see where everyone was during a fishing competition, so a shaman can fly round and give them all water-walking).")	





	--Subsection heading - "BG queueing module:"
    local helpSection2Subsection3 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection2Subsection3:SetPoint("TOP", helpSection2Subsection2Text2, "BOTTOM", 0, -sectionSpacing)
    helpSection2Subsection3:SetPoint("LEFT", helpSection2Heading, "LEFT", subsectionInset, 0)	
    helpSection2Subsection3:SetText("BG queueing module:")	

	--Command - "/f2pq"
    local helpSection2Subsection3Command1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	helpSection2Subsection3Command1:SetPoint("TOPLEFT", helpSection2Subsection3, "BOTTOMLEFT", subSubsectionInset, -rowSpacing)
    helpSection2Subsection3Command1:SetText("/f2pq")		
	
	--"Toggles the BG pane and the F2PQ windows open closed.  The F2PQ window displays the queue state of other players in the channel to help with simultaneous queueing or premades of more than 5."
    local helpSection2Subsection3Text1 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection2Subsection3Text1:SetPoint("TOPLEFT", helpSection2Subsection3Command1, "TOPLEFT", column1Width, 0)
	helpSection2Subsection3Text1:SetJustifyH("LEFT")
	helpSection2Subsection3Text1:SetWordWrap(true)
    helpSection2Subsection3Text1:SetText("Toggles the BG pane and the F2PQ windows open or closed.  The F2PQ window displays the queue state of other players in the channel to help with simultaneous queueing or premades of more than 5.")		

	--Command - "/f2pq reset"
    local helpSection2Subsection3Command2 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	helpSection2Subsection3Command2:SetPoint("TOP", helpSection2Subsection3Text1, "BOTTOM", 0, -rowSpacing)
	helpSection2Subsection3Command2:SetPoint("LEFT", helpSection2Subsection3, "LEFT", subSubsectionInset, 0)	
    helpSection2Subsection3Command2:SetText("/f2pq reset")		
	
	--"Removes all the entries from the F2PQ window, in case you need it clear to start your own group queue."
    local helpSection2Subsection3Text2 = F2PAddon_HelpScrollingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    helpSection2Subsection3Text2:SetPoint("TOPLEFT", helpSection2Subsection3Command2, "TOPLEFT", column1Width, 0)
	helpSection2Subsection3Text2:SetJustifyH("LEFT")
	helpSection2Subsection3Text2:SetWordWrap(true)
    helpSection2Subsection3Text2:SetText("Removes all the entries from the F2PQ window, in case you need it clear to start your own group queue.")	

	
	
	F2PAddon_HelpFrame:SetScript("OnShow", function(F2PAddon_HelpFrame)
		F2PAddon_HelpScrollingFrame:SetSize(F2PAddon_HelpFrame:GetWidth(),500)
		F2PAddon_Help_ScrollContainer:SetVerticalScroll(0)
		F2PAddon_Help_Scrollbar:SetValue(0)
		local helpTextSpace = F2PAddon_HelpScrollingFrame:GetWidth() - (leftInset + subsectionInset + subSubsectionInset + column1Width + rightInset)
		helpSection1Subsection1Text1:SetWidth(helpTextSpace)
		
		helpSection1Subsection2Text1:SetWidth(helpTextSpace)
		helpSection1Subsection2Text2:SetWidth(helpTextSpace)
		helpSection1Subsection2Text3:SetWidth(helpTextSpace)
		
		helpSection2Subsection1Text1:SetWidth(helpTextSpace)
		
		helpSection2Subsection2Text1:SetWidth(helpTextSpace)
		helpSection2Subsection2Text2:SetWidth(helpTextSpace)
		
		helpSection2Subsection3Text1:SetWidth(helpTextSpace)
		helpSection2Subsection3Text2:SetWidth(helpTextSpace)
	end)

	
	

F2PAddon_OptionsFrame:Hide()
F2PAddon_HelpFrame:Hide()
	
InterfaceOptions_AddCategory(F2PAddon_OptionsFrame)
InterfaceOptions_AddCategory(F2PAddon_HelpFrame)

end

