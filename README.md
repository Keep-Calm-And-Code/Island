# Island

This repo was created for TiMaSoMo 2023, a month-long event where the tildes.net community makes stuff. I'm making a simple economic strategy game where you develop an island.

Here's the Windows version running via Hashlink: https://github.com/Keep-Calm-And-Code/Island/releases/download/Island/Island.windows.hashlink.zip Unzip to a folder and run Island.bat to play. Hashlink is a VM for Haxe bytecode. There are Linux versions, as well as native, non-VM versions in the Releases.

This is written in Haxe. Text-only output, keyboard-only input to keep things code-focused. There are broadly two parts to the project:

A text-windowing module (TextScreen.hx), this is an old personal project that treats the text console as rectangular regions (windows) within rectangular regions, which can then be e.g. moved around, made invisible. This lets me more comfortably render text in specific places rather than simply line-by-line. TextScreen.hx supports displaying colored characters via Jason Hood's ANSICON (https://github.com/adoxa/ansicon). This won't be used for this game.

The game itself. Build stuff on a hex-grid island which produce stuff so you can build more stuff. I'm a hobby coder. My main aim of this project is to try to improve how I go about writing code. In particular, I'm putting this on GitHub to get in the habit of version control and to share it with other people. Lots of things I'm figuring out for the first time here, some things may be in a mess or not what you might normally expect in an open-source project on Git, apologies!

How to play:
------------

Use the number pad with NumLock on to move the active cell. e.g. 6 moves the active cell right, 1 moves the active cell down and to the left.

Press the first letter of an action to perform it. If an action has a cost and you can afford it, it will be prefixed with * e.g. to build a S)awmill, press 's'. You can skip to the Next W)eek to just gain income.

Each House level is home for up to 3 islanders. Each islander eats 4 food per week, either Grain or Fish. Build:

Farms on Grass to produce Grain,
Sawmills on Forest to produce Wood,
Mines on Hills to produce Metal, and
Ports on Grass along the coast to produce Fish and Goods.

Farms, Sawmills and Mines gain adjacency bonuses when identical buildings are next to each other. Temples gain adjacency bonus being next to Houses.

Blacksmiths turn Wood and Metal into Tools, which are needed to upgrade buildings to higher levels.

Temples increase Happiness. Islanders will consume Fish and Goods, increasing Happiness.

All buildings other than Houses require islanders to work at their Jobs. 1 Job per building level and 1 population needed per Job. Production falls if there are not enough workers.

V)iew population to see more details about Happiness and food consumption.


How to win:
-----------

Achieve 100 or more Happiness. Temples and Ports will increase Happiness, be sure to leave enough room for them.

The game isn't difficult, you mainly want to be patient and keep population in pace with food production and jobs. There's no lose condition, you lose by getting stuck and not producing enough food or primary resources to continue building, or not having enough room left to build Happiness buildings. There's no way to demolish buildings (this is currently by design, albeit unfriendly), once something is built, that cells building slot is committed.
