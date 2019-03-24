This addon will make sure that the friends list contains the names of players in the chat channel 'f2ptwink' (the default, but can be changed).

By default this addon is disabled, so you will need to activate it for just the characters you want to be present in it's chat channel (you can activate it for all of them at once using the 'All' option from the dropdown on the log in screen's addons page).

More information about this addon can be found at http://wow.curseforge.com/addons/f2paddon/ or http://www.twinkinfo.com/forums/f43/yasuehs-macros-addons-f2p-21104/


WARNING - If the friends list becomes full the addon will remove all offline characters, unless they have something in their friends notes to make them a permanent friend.

--- Contributors ---

* Yasueh from Twinkinfo.com - Original and present author/project lead.
* Dax - French translations.
* Dragonsblood from Twinkinfo.com - Original invite addon code (was updated by Yasueh into an F2PI addon, which is now a part of F2PAddon).


--- Version History ---
1.2.21
Bugfixes:
Changed all occurences of IsTrialAccount() over to GameLimitedMode_IsActive(), so that the addon functions for veteran Starter Edition accounts.

Improvements:
* Added /f2pwho command, to list the people who are in the channel, and provide links of their names to access f2pinfo data.
* Added /f2paddon help command to go direct to the help section of the options page.


1.2.20
Bugfixes for 6.0.2 API changes:
* The special case for mages, where they include mentioning whether or not they can provide portals when someone makes a 'p2p?' query in the channel is now working again.  This feature is restricted so that they only offer portals when they are already at a portal destination (so they can get back if they have to travel to someone to provide a portal).  Bliz messed with the code that provided a character's location.  Bonus bugfix: portals will be offered while at Shrine of Two Moons / Seven Stars, as Bliz's new system returns those locations properly.

Improvements:
* Have a better way to decide if the version of an updated addon is compatible with the existing settings from the previous version.  Database wipes should no longer be happening unless necessary.


1.2.19
Bugfixes for 6.0.2 API changes:
* Achievements no longer causing errors when received.  New format character guids are now being extracted from text strings correctly.
* /who panel no longer showing up every time someone in channel dings.  The addon checks /who to confirm that someone is actually the level they claim they are (hack prevention).  Bliz changed a bunch of functions to use 'true/false' instead of '1/0'. SetWhoToUI() was one of them.


1.2.18
Improvements:
* Guild charter / invite messages are no longer blocked by default on non-trial accounts (only works for new installs/when the database is fully rebuilt).  If blocking is turned on for a P2P account, no message about the account being a trial is sent.
* Simplified a few things in the code.

Localisation:
* f2pguild now blocks messages containing 'guilde' and 'charte' in addition to the English versions, to cover French localisations, and to allow for multiple client languages sharing a server.


1.2.17
Improvements:
* Added localisation /support/ for the options window (translations are still needed, also the options help still still lacks /support/).
* The help subsection in options now expands automatically, so maybe more people will notice it and the commands for the addon.

Bugfixes:
* Added a function to take realm names /off/ character names.
* Realm names are now stripped in the f2pq window, so they fit again.
* The UnitInParty() function now has names of the right format passed to it (it doesn't work if they include realm).  This allows F2PInvite to work correctly when 'lead' or 'close' commands are sent.


1.2.16
Bugfixes:
* Added a function to append realm name to character names when running several internal checks, to handle WoW's new behaviour of sending chat messages with a realm name appended to the sender's name.  Fixes class colors in chat and tooltips.
* Put iLevel sending back in for tooltips.  Seems it got omitted from the code when I switched to a local repository.
* 1.3.13 is no longer considered a valid addon version.

Notes:
* Purges the databases, as character names are now stored with the realm name appended.  Old entries can no longer be accessed by the addon so were just wasting space.  You'll be missing info from tooltips until you see peoples alts.
* This <name-realm name> thing makes things really complicated, as the addon regularly compares names from chat, the friends list and the database.  I've probably missed a few instances where I should be checking for it, so there are probably other things in the addon it's broken.


1.2.15
Bugfixes:
* Going to 1.2.15 should take into account having an older database than version 1.2.13, where 2.1.14 didn't, and didn't make necessary changes to the DB structure.
* Should correctly handle levels < 10 who invite.

1.2.14
Improvements
* f2pdata now sends iLevel data.
* f2pinfo tooltips now use icons instead of words, which both looks nicer, and saves having to localise the text.  They'll also include iLevels sent by f2pdata.
* f2pinvite will no longer say that it is able to make groups just because the player is p2p, and they have it enabled.  They must also not be queueing for LFD/LFR, arenas or BGs, or not currently be inside a raid, dungeon, BG, arena or world PvP zone such as Wintergrasp/Tol Barad.
* When f2pinvite makes a group, it now makes the names displayed into links, and colors them according to class.
* f2pinvite will also say if a p2p is on a mage to provide portals, so long as they are of appropriate level, and in a city that they are able to portal back to.  This is to avoid advertising portal services when out in the middle of nowhere.
* p2p characters lower than level 10 will now respond differently to the 'p2p?' command, saying that they can make groups of only 4, as they are unable to create the raid needed to invite 5 f2ps for a full group.
* p2p characters will no longer respond to 'p2p?' commands sent by characters under level 3 or 24s, when they have them set to be blocked (although they would have ignored the 'inv' command anyway).
* f2pi now sends all the outgoing messages through F2PChat_SendChatMessage, the function that checks if the sender is p2p, and if true sends to channel normally, otherwise calling F2PChat_RouteChatMessage to route via the addon channel.  Previously several messages were calling F2PChat_RouteChatMessage directly, which is kind of pointless given that p2ps have unrestricted use of the chat channel.

Bugfixes:
* Fixed the f2pq window so that what you see matches the area that responds to mouse click and drag (there was a big area off to the right that was responding to these).


1.2.13
Bugfixes:
* Fixed f2pq to work with the changes to the game's PVP UI code.

1.2.12
Bugfixes:
* Fixed the issues with the text in the options and help frames not fitting the available space at low resolutions.  That's 600 lines of code just for what's in those 2 windows.  This is why it took so long to add an options pane to the addon ;)
Improvements:
* The /f2paddon slash command now opens the addon's options pane without going through Escape > Interface > Addons > F2PAddon.
* The addon now remembers which chat windows were set to display it's channel when you change the channel name, so you don't have to reset them.

1.2.11
New Features:
* F2PInfo module finished.  This allows the addon to display information from it's database in tooltips, when you mouseover people's names in the chat window.  Should make it easier to work out who everyone is.
* The invite module now recognises the command 'p2p?', which will cause all P2P characters who are available for forming groups to say so in the channel (at least the ones running this version).
* People who aren't on your friends list, who send you whispers containing the words 'guild' or 'charter', will have their whispers hidden, and an appropriate reply sent back to them (the people who use bots to spam guild invites to the whole server will be getting a lot of replies from us ;) ).
Improvements:
* Added some more items to the options page, tidied it up a bit, and added a help page too (the text might be messy on low resolution monitors because of the way the UI scales).
* If someone posts a Mogit link to the addon channel, it will now be converted to a working link, instead of just being an unlinked string of characters.
Bugfixes:
* You don't need to set a leader before closing the group any more, and the groups will again close automatically once the P2P has invited 5 people (missed an API call that got changed with MoP).


1.2.10b
* 1.2.9 wiped the addon database, but not the friends list.  As friends not in the database couldn't be removed by the addon (because it was checking them to find those who hadn't logged in in ages), this lead to the friends list being stuck full.  Now the addon just wipes all offline friends who don't have notes set, whenever it needs to add someone and there isn't space.
* Attempted to fix issues with the invite functions that were caused by major changes to group/raid functions that came with MoP.  These changes have been tested as far as possible on the PTR, but there may still be issues.
* Deleted a lot of unused code from the addon's files that was commented out.

1.2.9b
* The addon now has a few options available via. [Escape] > Interface > Addons > F2PAddon.
* Slightly modified database structure, to allow more per realm+faction settings, for people who play on several realms.
* The database now stores the version of the addon that created it, allowing the addon to either wipe or modify the database when updated, depending on how big a difference there is between versions.
* Outgoing messages are no longer blocked by level filters, and the option to disable blocking incoming messages from low levels or 24s is in the config menu.
* Tidied up the code a little.

1.2.8
* If you're channel owner, the addon no longer passes to the next most viable owner, every time someone new logs in (left a line of code uncommented).
* Now treats Wintergrasp / Tol Barad the same as BGs or queued dungeons, as far as f2pi is concerned (included Localised names for the other available languages).
* Automatically does a /reloadui if you change to a different channel.

1.2.7
* The /f2pi command now correctly disables all of the F2PI functions, so F2PI won't be automatically closing raids you'd like to form when it should be disabled.
* F2PI now also counts guild members as people not to send warning messages to when they send you whispers.
* The 'raid' command has been removed, because too many were using it when they didn't need to (and keeping me from doing quests ;), and because there's really nothing to do in a raid as an F2P
* Supports localisation.  If you'd like contribute please edit a renamed copy of the f2ploc.enUS.lua file as far as possible and post the new contents as a ticket on the addon's page at curseforge.com.  
* F2PQ entries for a player will now be removed when they leave the channel (log out/DC/whatever), so the /f2pq reset shouldn't be needed any more, unless you want a clear window for your group.
* F2PQ should now work for those with clients that use French, Spanish or German for the interface language.
* The channel that the addon uses for chat can now be changed for just the realm/faction that you are logged into, by using the command '/f2paddon channel newchannelname' (This will also cause the game to leave the currently used channel).  You must give the /reload command to make the addon switch to the new channel, and may need to set one of your chat windows to display text from the new channel.
* Default behaviour for whispers from people who aren't on your friends list is no longer block.

1.2.6
* Now available from curse.com!
* Integrated F2PI into the main addon, and reworked the wording of it's messages to be a bit clearer regarding when to use the 'raid' command.
* F2PI should now disable if a GM whispers you, so they don't get a 'too low level for invites' message from you every time they say something.

1.2.5
* Fixed a couple of issues caused by the WoW 4.3 patch.
* Stopped calling it a beta, because people thought that alone meant there would be bugs.  There are always bugs.  Beta just means I want to find them ;)

1.2.4b
* While the automatic subscribing of chat windows to show the channel may not be reliable down to a Blizzard API function providing unreliable data, the addon will now give a warning if it is receiving messages, but a chat window is not subscribed to show them in. 
* The command '/f2pq reset' will now clear all the names from the F2PQ window before a group queues, in case there are some names already in the list who aren't in your group.  These are caused by people DCing/logging out while queued (sorry, you'll need another macro to go with your '/f2pq' one until I learn a bit more about interface coding).
* Also rejects whispers sent by people who have joined the channel who are levels 1, 2 or 24 (the trolls can be flaming away, but no-one will even see it).
* Fixes the bug in 1.2.3b where dinging 3 or 25 didn't stop people from blocking your chat messsages.  You now send an announcement if you ding those levels, so other players can immediately request your current level from /who (they don't trust that a spammer would tell them their real level).

1.2.3b
* No longer accepts the incompatible data packets sent by the old separate F2PAchi.
* Rejects all chat messages sent by characters under level 3, or at level 24, even if they're on a payed account.  Will inform them that they need to level if they are posting with addon versions from this one on.
BUG: Do not enable your addon/join the channel until level 3, or other players will not see that you have levelled to stop blocking your messages, unless they open their friends list/log out/in to get your current level.

1.2.2b
* Improved the data sending functions:
	Old method:
		Send our data to everyone on the friends list on login.
	New Method:
		Send our data to everyone on the friends list on login.
		Reply with our data if somone has just logged in and sent theirs.

* Data now includes a list of alts (ready for future player info functions)		
* Merged F2PQ into the main addon
* Added version checking
		
1.2.1b
* ChatThrottleLib wasn't included as one of the dependancies for this addon, so could only be found if used in one of your other addons. Fixed.

1.2.0b
* Combined F2PChannelToFriend, F2PChat and F2PAchi with the early version of F2PData, as they all shared several similar functions.  Released for beta testing.