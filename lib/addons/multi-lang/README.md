External Text: MultiLang v2.0.0 by Enelvon
=============================================================================

Summary
-----------------------------------------------------------------------------
This script allows you to have multiple languages in your game. The user
can swap between them, and the game will remember which language was last
selected in between gaming sessions.

Compatibility Information
-----------------------------------------------------------------------------
**Required Scripts:**
Puts this script below Materials and above Main. It must also be below
SES - External Text v3.0.0 or higher.

**Known Incompatibilities:**
None.

Usage
-----------------------------------------------------------------------------
Remember Text.txt from External Text? Yeah, you're not using that anymore.
Go to SES::ExternalText in this script and find the Languages array. Add as
many as you'd like. Now create a text file for each language you added, with
the name being that of the language in question. Make sure to place it in
the Data folder. Treat each of them like you would Text.txt - they work the
same way. Make sure all of your keys are the same in each file - if the keys
are different, the languages won't be compatible with each other.

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
Puts this script below Materials and above Main. It must also be below
SES - External Text v3.0.0 or higher.
