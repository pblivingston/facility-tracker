# facility-tracker
Facility tracker for Monster Hunter Wilds

Displays a tracker for resource availability at various facilities.

Adds a tracker to the bottom of the screen displaying Support Ship status, Rations available at the Ingredient Center, items available from Material Retrieval and Festival Shares, Trinkets available in the nest in the Grand Hub, and when Poogie has an item.

Prerequisites:

    Ensure the latest nightly version of REFramework﻿ is installed. Also available in the "Downloads" of Fluffy Mod Manager. The version here﻿ is sometimes a bit behind.
    Ensure the latest version of REFramework Direct2D﻿ is installed. The latest version has been consistently uploaded here﻿ as well.

Installation:

    Method 1: Drag the archive to Fluffy Mod Manager
    Method 2: Extract 'reframework' folder to the game folder. If not using FMM, ignore the other files.

Updates:

    Fluffy Mod Manager: Uninstall the mod (toggle off in FMM). Drag the new archive to FMM. Ensure the version number is correct - FMM can occasionally fail to overwrite the old version.
    Manual: Extract 'reframework' folder to the game folder. Overwrite when prompted.
    If additional steps are necessary, instructions will be in both the release notes and the stickied post.

Uninstallation:

    Fluffy Mod Manager: Toggle the mod off to uninstall. Delete to remove the archive.
    Manual: Remove 'facility_tracker.lua' from /reframework/autorun/. Remove 'facility_tracker' and 'moon_tracker' from /reframework/images/. Optionally remove 'facility_tracker.json' from /reframework/data/.

When you first install the mod, the Material Retrieval counts WILL BE WRONG and the Support Ship might show an incorrect countdown. Material Retrieval can be corrected by progressing the game's day counter or collecting any available items. The Support Ship countdown can sometimes be corrected by progressing the day counter. Having the ship leave entirely should always ensure the countdown is correct the next time it is in port. Midnight passing naturally or changing the time of day by Resting progresses the day counter. Note that the day counter progresses no matter what time of day you choose when you Rest. Even Resting from Morning to Daytime progresses the day counter. Changing the weather does not progress the day counter.

Progress bars, timers, and flags ("!") can be toggled. Timers are off by default. Note that if you toggle all three off, you won't be able to see when Poogie has an item.

Planned features:

    Toggle-able progress bars - A small line at the bottom of the facility icon that fills up as the timer ticks down. Less intrusive than the timers.   --- ADDED!
    Hide with HUD - Detect when the HUD is not visible and hide the tracker.   --- ADDED!
    An option to reposition the tracker instead of hide it when the player is in a tent.   --- ADDED!
    Support Ship/Trades ticker - A scrolling ticker at the top of the screen displaying the items currently available at the Support Ship if it is in port and the currently available NPC trades. Figuring out how to see what these are has proven pretty difficult, so this may simply not happen.


Included is a toggle-able moon phase tracker I made after helping out a bit with BloodTide﻿'s Moon and Day Cycle Tracker. Made with my own images (made from the game's textures) and my own code, but mine is not customizable other than optionally displaying numerals. If you prefer a moon cycle tracker with more appearance options, ability to reposition, etc., head BloodTide's way.


Thanks to BloodTide for the inspiration to make this mod and archwizard1204 for Free Rest, which has been crucial in testing almost every aspect of it. Thanks also to praydog, cursey, and everyone who works on REFramework and REFramework Direct2D.