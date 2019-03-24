--Default settings that will be copied into the database for each account/realm combination.

--Default channels used by the addon.  Don't change these here, if you want to make a change to the channel that the addon uses do it in the in game options for the addon.
F2PAddonGlobalVars.DefaultChannelName = "f2ptwink"
F2PAddonGlobalVars.DefaultAddonChannelName = "f2paddonchannel"
F2PAddonGlobalVars.DefaultChannelWindows = {1,}

--You can set this to give a different channel header name, such as "Guild" if you want to display that instead of the default "[1_ f2ptwink]".  This only affects the messages sent through the addon.  Not those sent by payed accounts to the channel normally.
F2PAddonGlobalVars.channelHeader = false

--these must be set as 1 or 0, otherwise no DB entry would evaluate to false
F2PAddonGlobalVars.blockLowLevel = 1
F2PAddonGlobalVars.blockTwentyFour = 1
if GameLimitedMode_IsActive() then
	F2PAddonGlobalVars.blockGuild = 1
else
		F2PAddonGlobalVars.blockGuild = 0
end
	
	
--shows tooltips whn character names in the chat window are mouseovered
F2PAddonGlobalVars.showCharacterTooltips = 1

--When enabled this will show test messages that are embedded in the addon code to help with debugging.  While the macros '/run F2PAddon_Variables.Settings.Verbose = true' and '/run F2PAddon_Variables.Settings.Verbose = false' can be used in game to turn the messages on and off, you will need to make the change here to see the messages displayed as the addon starts up.
F2PAddonGlobalVars.verbose = false

--Blizzard return false to their IsTrialAccount() function before they actually take off all the trial resrictions (which is used in GameLimitedMode_IsActive()).  Enable this to use the addon in the ~72 hour period between upgrading an account, and the restrictions being fully lifted, then set it back to false.
F2PAddonGlobalVars.stillTreatedAsTrialFix = false