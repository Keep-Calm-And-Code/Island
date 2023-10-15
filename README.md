This repo was created for Timasomo 2023, a month long event where the tildes.net community makes stuff.

I'm making a simple economic strategy game where you develop an island. Don't have all the rules planned out, will see where design and development takes me.

This is written in Haxe. Text-only output, keyboard-only input to keep things code-focused. There are broadly two parts to the project: 

1) A text-windowing module (TextWindow.hx), this is an old personal project that treats the text console as rectangular regions (windows) within rectangular regions, which can then be e.g. moved around, made invisible. This lets me more comfortably render text in specific places rather than simply line-by-line.

TextWindow.hx supports displaying colored characters via ANSI escape codes and Jason Hood's ANSICON (https://github.com/adoxa/ansicon). This won't be used for this game.

2) The game itself. Build stuff on a hex-grid island which produce stuff so you can build more stuff.

I'm a hobby coder. My main aim of this project is to try to improve how I go about writing code. In particular, I'm putting this on GitHub to get in the habit of version control and to share it with other people.

-----

How to play:

  8
4   6  keys move the active hex. Best to use the numpad with NumLock on.
  2

Press the first letter of the action to perform it. If an action has a cost and you can afford it, it will be prefixed with *
e.g. to build a S)awmill, press 's'. You can skip to the N)ext week to just gain income.


How to win:

Haven't figured that out, there's no real game yet! 
