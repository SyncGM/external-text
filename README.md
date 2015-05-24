External Text v3.1.0 by Enelvon
=============================================================================

Summary
-----------------------------------------------------------------------------
This script allows you to create text files and use their contents in the
in-game message windows. It will automatically wrap text, allowing you to
avoid worrying about whether or not your text will fit in the message window.
It uses a simple tagging system to divide the files into messages and supply
them with faces to be displayed (if desired).

Compatibility Information
-----------------------------------------------------------------------------
**Required Scripts:**
None.

**Known Incompatibilities:**
None specifically - though while ordinary text codes (\c, \n, etc) can be
used, custom ones cannot if they are persistent (like \c is) - they will be
reset whenever text wraps to a new page. \c is handled so that it will not
be reset, and it is possible to add handlers for other persistent codes.

Usage
-----------------------------------------------------------------------------
Create a directory named Text in the Data folder for your project. Inside of
this directory, create a text file -- there, you've done the hard part! You
can add as many text files to the folder as you'd like, and can even add
subfolders for organization. The names don't matter, so do whatever works for
you! To add text to the files, use this format:

   `[Key] !Key!`
   `[Face] !File!, !Index!`
   `!Text!`

You may omit the `[Face]` line to have a message without a face, but the
`[Key]` line and the text itself are necessary. The replacements you should
use with the above format are:

   `!Key!` with an identifier for the text. Each of these *must* be unique.
   `!File!` with the name of the faceset you want to display, minus the
      extension.
   `!Index!` with the index of the face in the file, starting with 0.
   `!Text!` with the message you want to display. Note that new lines within
      a message have no effect other than adding a space.

Note that you must playtest the game before creating an encrypted archive,
or your changes in Text.txt will not be reflected in the game, as it reads
data by creating a Text.rvdata2 file from Text.txt - something that it will
be unable to do after encryption.

There are three additional face tags, one of which will require you to
modify the Faces hash in SES::ExternalText. I'll break them all down here:

   `[AFace] !Index!`

This is pretty self-explanatory. Replace `!Index!` with the ID of the actor
whose face you want to show.

   `[PFace] !Index!`

Another easy one. Replace !Index! with an index that will correspond to the
player's party at the time they receive the message. The first slot is 0,
the second is 1, and so on.

   `[DFace] !Key!`

This is the one that requires some modification. It's handy for recurring
NPCs - you define a face in the Faces hash of SES::ExternalText and replace
!Key! with the name you gave it in the hash. There is an example for Ralph
already in the hash, as well as format instructions, so this should be easy
for you to use as well.

Another tag you can include is `[Name]`. It will display a namebox with the
given name. Text codes will work with it.

   `[Name] \c[15]\n[1]`

Would use the first actor's name in color 15.

   `[Name] Ralph`

Would use 'Ralph', and so on. There are actually two styles for names: the
namebox (which is the default) and in-text names, which are displayed at the
top of each message page. You can toggle it with the NameStyle constant in
SES::ExternalText. Set it to :box to use the namebox or :text to use in-text
names.

As of v1.5, there is also the `[FName]` tag, which works like the `[Name]` tag
except it also sets the face to whatever is entered, like `[DFace]` would.
This method of setting the name does not allow you to use text codes, unlike
the normal one, unless you have set up the key in the Faces hash to include
them.

As of v3.0, the `[Line]` tag is deprecated (though still usable for backwards
compatibility). Add a new line instead.

You can comment out lines by beginning them with a or //. You can use this
to divide your Text file into sections, to help with organization.

v1.5 also alters how text tags are checked - they are now stored in a hash
in the SES::ExternalText module, making it easy to add your own. The keys
of the hash should be Regular Expressions, and the values should be strings
for evaluation.

New to v1.6 are the location and background tags. To alter the location of
the message window, use this tag:

   `[Position] !Pos!`

`!Pos!` can be Top, Center, or Bottom. You will likely never need to use the
Bottom tag, as the default position is Bottom. It is included for the sake
of completeness.

The background tag allows you to choose between Normal, Dim, and Transparent
backgrounds, like you would for normal text. You use it like this:

   `[Background] !Back!`

Replace `!Back!` with Normal, Dim, or Transparent. You will probably never use
Normal, as it's the default. Much like Bottom for positions, it was included
solely for the sake of completeness.

v1.7 adds in a text code that can be used to call text. I would only bother
using it if you have a global text codes script of some kind - this script
does not provide such a function, and I do not intend to add one. Note that
the text code *will not* auto-wrap text, so you will still have to test
its length yourself. You can use this alongside a global text codes script
to make translating your game into multiple languages easy - just use it
in the names/descriptions of Database objects. You use it like this:

   `\t[!Key!]`

`!Key!` is, of course, the key of the text you're referencing.

Script Calls
-----------------------------------------------------------------------------
To display text, place this in an event's script command:

   `text(!Key!)`

   `!Key!` should be replaced with a string corresponding to the key of the
       text that you want to display. As an example, if I had a text key
       called Intro, I would use this to call it:

       `text("Intro")`

You can also display multiple sections of text at once with this:

   `block_text(!Key!)`

   `!Key!` should be replaced with either a Regular Expression or a string.
       If you use a regular expression, it will display the text for all
       keys that match it. If you use a string, it will display the text
       for all keys that include it. This is simply a faster way to display
       scenes. As an example, let's say we have a number of messages for
       our introduction. Their keys are called Intro 1 through Intro 12.
       Instead of 12 calls of `text("Intro ")`, we could use one of these:

       `block_text(/^Intro \d+/)`

       `block_text("Intro")`

       The first one is better, of course, but both work. The problem with
       the second comes in if we have another key that's similar - let's
       say Ralph's Introduction. It would be called too, because it contains
       Intro. It would not be called with the first one.

v3.0 has added two optional parameters to `block_text`. It can now be called
like this:

   `block_text(!Key!, !Start!, !End!)`

   `!Key!` is the same as it would be for the original `block_text`.
   `!Start!` is an integer referencing the starting point for text iteration:
       rather than display every piece of text whose key matches the given
       `!Key!`, it will start at the nth occurence of `!Key!`.
   `!End!` is an integer referencing the end point for text iteration. Only
       text up to the nth occurence will be displayed.

v3.0 also adds the `block_text_us` method. It takes the same parameters as
`block_text`, but does not sort the keys before iterating.

As of v1.7, there are two get_text calls. One can be used only in an event,
and is used like this:

   `get_text(!Key!)`

I would recommend you use this with variable assignment, as it has no real
use otherwise. !Key! is obviously the key of the text you want to use. You
can also use a form of this command in your own scripts, by calling this:

   `SES::ExternalText.get_text(key)`

As of v2.0, you can now use External Text in conjunction with the Scrolling
Text feature by using this call:

   `scrolling_text(!Key!, !Speed!, !NoFast!)`

`!Key!` is obviously the key for the text. `!Speed!` is how quickly you want
it to move - 2 is the default. !NoFast! is whether or not the player should be
blocked from hold the action key to increase the scroll speed - false allows
them to do so, true prevents it. The default is false.

Aliased Methods
-----------------------------------------------------------------------------
* `module DataManager`
    - `self.load_battle_test_database`
    - `self.load_normal_database`

* `class Window_Base`
    - `convert_escape_characters`

* `class Window_ChoiceList`
    - `max_choice_width`

* `class Scene_Map`
    - `create_all_windows`

* `class Scene_Battle`
    - `create_all_windows`

New Methods
-----------------------------------------------------------------------------
* `module DataManager`
    - `self.create_text`

* `class Game_Message`
    - `add_line`
    - `clear`
    - `get_color`
    - `load_text`
    - `too_wide?`

* `class Game_Interpreter`
    - `block_text`
    - `block_text_us`
    - `get_block`
    - `get_text`
    - `scrolling_text`
    - `text`

* `class Window_Base`
    - `slice_escape_characters`

* `class Scene_Map`
    - `create_namebox`

* `class Scene_Battle`
    - `create_namebox`

License
-----------------------------------------------------------------------------
This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
Place this script below the SES Core (v2.0 or higher) script (if you are
using it) or the Materials header, but above all other custom scripts. This
script does not require the SES Core, but it is highly recommended.
