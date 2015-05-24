External Text: MultiLang v2.1.0 by Enelvon
=============================================================================

Summary
-----------------------------------------------------------------------------
This script allows you to have multiple languages in your game. The user
can swap between them, and the game will remember which language was last
selected in between gaming sessions.

Compatibility Information
-----------------------------------------------------------------------------
**Required Scripts:**
SES - External Text v3.1.0 or higher

**Known Incompatibilities:**
None.

Usage
-----------------------------------------------------------------------------
Create a directory named Text in the Data folder for your project. Inside of
this directory, create a new directory with the name of each language that you
intend to include in your project -- make sure to add the names of these
directories to the Languages array in SES::ExternalText. Any text files that
you place in these language directories will be read into the project, so feel
free to organize them however you'd like! You can even add subfolders to the
language folders. The only thing that you *need* to do is use the same keys
in each language -- if you don't, the game won't know where to look for text
in alternate languages!

Note that each language can (and probably should) have different text for
the language select screen. The default is in English, obviously. To change
it, create a key in the language's file called 

    `Language Select`

Make sure it's spelled exactly the same way, space and capitalization
included. The text you use for this key will be displayed when selecting
languages with that language as the current game language.

Script Calls
-----------------------------------------------------------------------------
To call the language selection scene, use this:

    `SceneManager.call(Scene_LanguageSelect)`

You can use it on the map, or add it to a menu of some kind. Your choice.

New Methods
-----------------------------------------------------------------------------
* `module DataManager`
    - `self.check_language`
    - `self.set_language`

License
-----------------------------------------------------------------------------
This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
Put this script below Materials and above Main. It must also be below
SES - External Text v3.1.0 or higher.
