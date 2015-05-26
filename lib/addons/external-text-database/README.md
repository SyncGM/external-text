External Text: Database v1.1.0 by Enelvon
=============================================================================

Summary
-----------------------------------------------------------------------------
This script allows you to keep the text contents of your Database in external
files. It can also hook into any method that returns a string and use keys in
your External Text files to override them. It's compatible with MultiLang from
the start, so your translation will be taken to the next level!

Compatibility Information
-----------------------------------------------------------------------------
**Required Scripts:**
SES External Text v3.2.0 or higher
(Optional) SES External Text: MultiLang v2.1.0 or higher

**Known Incompatibilities:**
None.

Usage
-----------------------------------------------------------------------------
There are two parts to using this script: putting keys in your External Text
files and adding new overrides.

Keys are automatically generated and follow a simple format:

   `[Key] Class_!ID!_!method!`

For example, if I wanted to override actor 1's name I would use this key:

   `[Key] Actor_1_name`

If I wanted to override a skill's cast message, I might do this:

   `[Key] Skill_3_message1`

If a given override key is not present, the default value (as set in the
Database) will be used. For overridden non-database methods, the default value
is whatever the script that introduced it supplied.

Custom overrides are slightly trickier (though not by much). Add the name of
the class that contains the method you want to override to the Override hash
in the SES::ExternalText module. Its value should be an array containing the
names of the methods that you want to add overrides for. As above, keys will
be automatically generated. If the class being overriden does not have an id,
the format for the key changes to this:

   `[Key] Class_!method!`

For example, I could add this to the hash:

   `'Game_Party' => [:name],`

And the new key would be this:

   `[Key] Game_Party_name`

Finally, RPG::System::Terms uses an array-based method of storing its vocab.
This has been given a manual override. For a list of the possible keys that it
uses, please look at the RPG::System::Terms section of this script.

Oh, and one last 'note'... You may be thinking "Well, Enelvon, the notes of
Database objects are strings. Can I override those? What about character
sprites and map battlebacks? Those are strings." The answer is "Absolutely!"
Just add :note, :character_name, :battleback_floor_name, or whatever to the
arrays, and you're golden. Have fun!

Aliased Methods
-----------------------------------------------------------------------------
* `class Game_Actor`
    - `setup`

Overwritten Methods
-----------------------------------------------------------------------------
Anything you add, plus everything in RPG::System::Terms. Additionally:

* `class Game_Actor`
    - `set_graphic`

* `class Game_Interpreter`
    - `command_320`
    - `command_324`

License
-----------------------------------------------------------------------------
This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
Put this script below Materials and above Main. It must also be below
SES - External Text v3.1.0 or higher. If you use MultiLang (must be v2.1.0 or
higher), place this below that as well. Finally, if you add custom overrides,
this script must be below all scripts that contain overriden methods.

Uninstallation
-----------------------------------------------------------------------------
This only applies to you if you have savegames made while using this script
that you would like to preserve. Set the Uninstall constant in
SES::ExternalText to true and play the game. Load and save every file that you
would like to keep. You may now remove the script with no problems.
