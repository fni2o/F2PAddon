--If you wish to contribute a language file for your region use this one as a basis, and post sections relevant to your modified version (using code tags), on the comments page for the addon at http://wow.curseforge.com/addons/f2paddon/ or at http://twinkinfo.com/f2p-twinking/21104-yasueh-s-macros-addons-f2p.html
--
--the format for this file is as follows:
--
--    ["THE_NAME_USED_IN_THE_CODE"] = "The text you should change",
--
--or
--
--    ["THE_NAME_USED_IN_THE_CODE"] = "The text you should change %s more text you should change",
--
--where '%s' represents a variable that the code will insert into your text string, such as a name or achievement.
--Don't forget the closing comma at the end of every line like the above ones (even the last one in a set)
--Each file in the addon has a section here that corresponds to the .lua filename following 'f2p', to make finding exactly where the text occurs easier (using the Notepad++ editor will also make editing code a lot easier, as it colors different parts according to their purpose).  You may have to refer to those files to get the context of the text right, in particular the correct location for the variables signified by '%s' below.
--Bear in mind that many of the messages below are what your addon sends to other players, so they may be better off left in english in any future localisation files, if you are on a multi language server (I may try to get separate send receive messages set up at some point).
--Also the instructions given by f2pi have to be worded correctly, to avoid people misunderstanding them.
--For the moment the commands recognised by the addon will have to remain constant, but will hopefully become modifiable in future versions, when a better interface can provide in game help for them.
--Don't forget to include the name of everyone who contributed to the translation in a comment, that starts like these with a pair of dashes.


F2PLoc = {}

F2PLoc.achi = {
	["HAS_EARNED_THE_ACHIEVEMENT_"] = " has earned the achievement %s.",
}

F2PLoc.addon = {
	["F2PADDON_VERSION_"] = "F2PAddon version %s loaded.",
	["CHANNEL_PASSWORDED"] = "The %s channel has been passworded.",
}

F2PLoc.chat = {
	["WHY_SOME_LEVELS_ARE_BLOCKED"] = "[F2PAddon] Levels 1, 2 and 24 have been prevented from posting to the channel, in order to limit trolling.",
	["NO_SUBBED_CHAT_WINDOW_1"] = "F2PAddon has received a message, but has not found a chat window subscribed to display the %s channel.",
	["NO_SUBBED_CHAT_WINDOW_2"] = "Right click the name tab for a chat window > Settings > Global Channels > ensure that there is a tick before %s.",
}

F2PLoc.data = {
	["OUTDATED"] = "Your version of F2PAddon is outdated.  %s is the current release.",
}

F2PLoc.friends = {
	["TOO_MANY_FRIENDS"] = "Too many in friends list, removing those that are both offline and without notes.",
	["ADDING_FRIENDS"] = "Adding %s to friends list",
	["REMOVING_FRIENDS"] = "Removing %s from friends list",
}

F2PLoc.info = {
	["ALTS"] = "Alts:",
}

F2PLoc.invite = {
	["F2PI_LOADED"] = "F2PI loaded.\nType /f2pi in chat to toggle off/on (will automatically be disabled when using LFD/BGs).",
	["CLARIFY_COMMAND"] = "[F2PI] If you are trying to form a group, the command to whisper to the addon is 'inv'.",
	["ACCEPTED_COMMANDS_1"] = "[F2PI] In addition to the 'inv' command, this addon also understands the following commands:",
	["ACCEPTED_COMMANDS_2"] = "[F2PI] 'close' - to have me leave the party.  Please use this so that others may use the addon.",
	["ACCEPTED_COMMANDS_3"] = "[F2PI] 'lead' - changes who I pass leadership to when I leave, otherwise it will be the first person I invited.",
--	["ACCEPTED_COMMANDS_4"] = "[F2PI] 'raid' - I will normally invite a maximum of 5 other people, then leave automatically.  If you want to make a group of more than 5, use this to remove the limit, and 'close' when everyone has been invited.",
	["FISHING_COMP_MODE"] = "[F2PI] Fishing Competition mode is active.  Leadership will not be passed, and the group cannot be closed.",
	["BUSY_RESPONSE"] = "[F2PI] I'm doing dungeons or BGs right now, so I'm not available to invite.",
	["LEADER"] = "[F2PI] %s will now be leading this party when I drop.  Send 'close' when everyone has joined to ask me to do that.",
	["NOT_LEADING"] = "[F2PI] I am not leading your party.",
	["LIMIT_REMOVED"] = "[F2PI] Party size limit removed.  I will no longer automatically leave the group after it has reached a size of 6 people.",
	["AUTO_DISABLED"] = "[F2PI] My invite addon is currently disabled.",
	["LEVEL_LIMIT"] = "[F2PI] You must reach level 10 to be eligible for invites.",
	["QUEUEING_AS_RAID"] = "[F2PI] You will need to convert from raid to party before queueing for LFD.  BGs may still be queued as a raid of 5 though.",
	["GROUP_FORMED"] = "[F2PI] Group formed: ",
	["FISHING_MODE_DISABLED"] = "[F2PI] fishing competition mode disabled",
	["FISHING_MODE_ENABLED"] = "[F2PI] fishing competition mode enabled",
	["MANUALLY_DISABLED"] = "[F2PI] I have disabled my invite addon.",
	["MANUALLY_ENABLED"] = "[F2PI] Invite addon enabled. Whisper me 'inv' to request an invite to a party.",
	["ON_TRIAL"] = "F2PI is disabled as you are on a trial account, and cannot invite.",
	--these 2 are needed to disable f2pi while in those zones.  the values need to be what is returned by "/run print(GetRealZoneText())"
	["TOL_BARAD"] = "Tol Barad Peninsula",
	["WINTERGRASP"] = "Wintergrasp",
    ["CAN_GROUP"] = "[F2PI] I'm available to make groups.",
    ["CAN_GROUP_4"] = "[F2PI] I'm available to make groups of no more than 4.",
    ["CAN_GROUP_AND_PORTAL1"] = "[F2PI] I'm available to make groups and portals (Faction cities.  Ask in channel as I may be on an alt).",
    ["CAN_GROUP_AND_PORTAL2"] = "[F2PI] I'm available to make groups and portals (Faction cities and Shattrath.  Ask in channel as I may be on an alt).",
    ["CAN_GROUP_AND_PORTAL3"] = "[F2PI] I'm available to make groups and portals (Faction cities, Shattrath and Dalaran.  Ask in channel as I may be on an alt).",
	["CAN_GROUP_AND_PORTAL4"] = "[F2PI] I'm available to make groups and portals (Faction cities, Shattrath, Dalaran and Pandaria.  Ask in channel as I may be on an alt).",
}

F2PLoc.queue = {
	--the following 2 items must exactly match the name that the game functions use to refer to the maps, otherwise F2PI will fail to recognise them
	["WARSONG_GULCH"] = "Warsong Gulch",
	["ARATHI_BASIN"] = "Arathi Basin",
	["EYE_OF_THE_STORM"] = "Eye of the Storm",
	["ALTERAC_VALLEY"] = "Alterac Valley",
	["RANDOM_BG"] = "Random Battleground",
	--The text for the F2PQ window is arranged neatly in columns using a monospaced font (the horizontal space each character takes up on the line is equal, as opposed to most fonts where the width of the characters can vary).
	--If your language uses a different number of letters for the below texts, then padding with more/less spaces/dashes may be required.  The total width of the window is also limited, so some experimentation may be needed to make the text fit neatly.
	--for enUS the columns are as follows:
	--
	--12 characters for the player names, plus a following space
	--1 character for the '|' separating the columns
	--leading space + 6 characters for the words 'popped' or 'queued' + following space (WSG column)
	--1 character for the '|' separating the columns
	--leading space + 6 characters for the words 'popped' or 'queued' + following space (AB column)
	--
	-- '\n' is the code for a newline, so ["OUTPUT_TEXT"] covers the 2 lines of the table header and the separating line underneath it.
	["OUTPUT_TEXT"] = "Name         |   WSG |  AB   |  EOS  |  AV   |  RBG  \n-------------|-------|-------|-------|-------|------\n",
	["QUEUED"] = "queued",
	["POPPED"] = "popped",
}

F2PLoc.slash = {
	["CHANNEL_CHANGED"] = "The channel that the addon will use has been switched to %s.  You may need to set a chat window to display messages from the new channel.",
}

F2PLoc.guild = {
	["RESPONSE"] = "Trial accounts cannot join guilds or sign guild charters.",
	["GUILD"] = "guild",
	["CHARTER"] = "charter",
}

F2PLoc.options = {  --text for the options window
	["TITLE"] = "F2PAddon %s Options",
	["AUTHOR"] = "Author: %s",
	["CHANNEL_NAME"] = "Channel Name:",
	["CHANNEL_NAME_BUTTON_TEXT"] = "Update",
	["CHANNEL_NAME_RELOADS"] = "(Reloads the UI)",
	["MESSAGE_BLOCKING"] = "Message Blocking:",
	["L1+2"] = "Level 1 and 2 characters (whispers and channel messages).",
	["L24"] = "Level 24 characters (whispers and channel messages).",
	["GUILD"] = "Whispers from people you don't know, containing the words 'guild' or 'charter'.",
	["TOOLTIPS"] = "Character & alt info tooltips:",
	["TOOLTIPS_DESC"] = "(Only shows alts that the addon has seen, and that it can confirm are on the same account.)",
	["UPGRADE"] = "Account waiting to be upgraded fix:",
	["UPGRADE_DESC"] = "Checking this allows F2PAddon to function correctly when a recently upgraded account still has restrictions on chat, for the approximately 72 hours that it takes for Blizzard to fully process the upgrade.",
	["DEBUG"] = "Debugging messages:",
}

F2PLoc.help = {  --text for the options help window

}