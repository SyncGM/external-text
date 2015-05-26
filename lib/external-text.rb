#--
# External Text v3.2.0 by Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
# This script allows you to create text files and use their contents in the
# in-game message windows. It will automatically wrap text, allowing you to
# avoid worrying about whether or not your text will fit in the message window.
# It uses a simple tagging system to divide the files into messages and supply
# them with faces to be displayed (if desired).
# 
# Compatibility Information
# -----------------------------------------------------------------------------
# **Required Scripts:**
# None.
# 
# **Known Incompatibilities:**
# None specifically - though while ordinary text codes (\c, \n, etc) can be
# used, custom ones cannot if they are persistent (like \c is) - they will be
# reset whenever text wraps to a new page. \c is handled so that it will not
# be reset, and it is possible to add handlers for other persistent codes.
# 
# Usage
# -----------------------------------------------------------------------------
# Create a directory named Text in the Data folder for your project. Inside of
# this directory, create a text file -- there, you've done the hard part! You
# can add as many text files to the folder as you'd like, and can even add
# subfolders for organization. The names don't matter, so do whatever works for
# you! To add text to the files, use this format:
# 
#    `[Key] !Key!`
#    `[Face] !File!, !Index!`
#    `!Text!`
# 
# You may omit the `[Face]` line to have a message without a face, but the
# `[Key]` line and the text itself are necessary. The replacements you should
# use with the above format are:
# 
#    `!Key!` with an identifier for the text. Each of these *must* be unique.
#    `!File!` with the name of the faceset you want to display, minus the
#       extension.
#    `!Index!` with the index of the face in the file, starting with 0.
#    `!Text!` with the message you want to display. Note that new lines within
#       a message have no effect other than adding a space.
# 
# Note that you must playtest the game before creating an encrypted archive,
# or your changes in Text.txt will not be reflected in the game, as it reads
# data by creating a Text.rvdata2 file from Text.txt - something that it will
# be unable to do after encryption.
# 
# There are three additional face tags, one of which will require you to
# modify the Faces hash in SES::ExternalText. I'll break them all down here:
# 
#    `[AFace] !Index!`
# 
# This is pretty self-explanatory. Replace `!Index!` with the ID of the actor
# whose face you want to show.
# 
#    `[PFace] !Index!`
# 
# Another easy one. Replace !Index! with an index that will correspond to the
# player's party at the time they receive the message. The first slot is 0,
# the second is 1, and so on.
# 
#    `[DFace] !Key!`
# 
# This is the one that requires some modification. It's handy for recurring
# NPCs - you define a face in the Faces hash of SES::ExternalText and replace
# !Key! with the name you gave it in the hash. There is an example for Ralph
# already in the hash, as well as format instructions, so this should be easy
# for you to use as well.
# 
# Another tag you can include is `[Name]`. It will display a namebox with the
# given name. Text codes will work with it.
# 
#    `[Name] \c[15]\n[1]`
# 
# Would use the first actor's name in color 15.
# 
#    `[Name] Ralph`
# 
# Would use 'Ralph', and so on. There are actually two styles for names: the
# namebox (which is the default) and in-text names, which are displayed at the
# top of each message page. You can toggle it with the NameStyle constant in
# SES::ExternalText. Set it to :box to use the namebox or :text to use in-text
# names.
# 
# As of v1.5, there is also the `[FName]` tag, which works like the `[Name]` tag
# except it also sets the face to whatever is entered, like `[DFace]` would.
# This method of setting the name does not allow you to use text codes, unlike
# the normal one, unless you have set up the key in the Faces hash to include
# them.
# 
# As of v3.0, the `[Line]` tag is deprecated (though still usable for backwards
# compatibility). Add a new line instead.
# 
# You can comment out lines by beginning them with a # or //. You can use this
# to divide your Text file into sections, to help with organization.
# 
# v1.5 also alters how text tags are checked - they are now stored in a hash
# in the SES::ExternalText module, making it easy to add your own. The keys
# of the hash should be Regular Expressions, and the values should be strings
# for evaluation.
# 
# New to v1.6 are the location and background tags. To alter the location of
# the message window, use this tag:
# 
#    `[Position] !Pos!`
# 
# `!Pos!` can be Top, Center, or Bottom. You will likely never need to use the
# Bottom tag, as the default position is Bottom. It is included for the sake
# of completeness.
# 
# The background tag allows you to choose between Normal, Dim, and Transparent
# backgrounds, like you would for normal text. You use it like this:
# 
#    `[Background] !Back!`
# 
# Replace `!Back!` with Normal, Dim, or Transparent. You will probably never use
# Normal, as it's the default. Much like Bottom for positions, it was included
# solely for the sake of completeness.
# 
# v1.7 adds in a text code that can be used to call text. I would only bother
# using it if you have a global text codes script of some kind - this script
# does not provide such a function, and I do not intend to add one. Note that
# the text code *will not* auto-wrap text, so you will still have to test
# its length yourself. You can use this alongside a global text codes script
# to make translating your game into multiple languages easy - just use it
# in the names/descriptions of Database objects. You use it like this:
# 
#    `\t[!Key!]`
# 
# `!Key!` is, of course, the key of the text you're referencing.
# 
# Script Calls
# -----------------------------------------------------------------------------
# To display text, place this in an event's script command:
# 
#   `text(!Key!)`
# 
#   `!Key!` should be replaced with a string corresponding to the key of the
#    text that you want to display. As an example, if I had a text key called
#    Intro, I would use this to call it:
# 
#   `text('Intro')`
# 
# You can also display multiple sections of text at once with this:
# 
#   `block_text(!Key!)`
# 
#   `!Key!` should be replaced with either a Regular Expression or a string.
#    If you use a regular expression, it will display the text for all
#    keys that match it. If you use a string, it will display the text
#    for all keys that include it. This is simply a faster way to display
#    scenes. As an example, let's say we have a number of messages for
#    our introduction. Their keys are called Intro 1 through Intro 12.
#    Instead of 12 calls of `text("Intro #")`, we could use one of these:
# 
#   `block_text(/^Intro \d+/)`
# 
#   `block_text("Intro")`
# 
#   The first one is better, of course, but both work. The problem with
#    the second comes in if we have another key that's similar - let's
#    say Ralph's Introduction. It would be called too, because it contains
#    Intro. It would not be called with the first one.
#
# v3.0 has added two optional parameters to `block_text`. It can now be called
# like this:
#
#   `block_text(!Key!, !Start!, !End!)`
#
#  `!Key!` is the same as it would be for the original `block_text`.
#  `!Start!` is an integer referencing the starting point for text iteration:
#   rather than display every piece of text whose key matches the given
#   `!Key!`, it will start at the nth occurence of `!Key!`.
#  `!End!` is an integer referencing the end point for text iteration. Only
#   text up to the nth occurence will be displayed.
#
# v3.0 also adds the `block_text_us` method. It takes the same parameters as
# `block_text`, but does not sort the keys before iterating.
# 
# As of v1.7, there are two get_text calls. One can be used only in an event,
# and is used like this:
# 
#   `get_text(!Key!)`
# 
# I would recommend you use this with variable assignment, as it has no real
# use otherwise. !Key! is obviously the key of the text you want to use. You
# can also use a form of this command in your own scripts, by calling this:
# 
#   `SES::ExternalText.get_text(key)`
# 
# As of v2.0, you can now use External Text in conjunction with the Scrolling
# Text feature by using this call:
# 
#   `scrolling_text(!Key!, !Speed!, !NoFast!)`
# 
# `!Key!` is obviously the key for the text. `!Speed!` is how quickly you want
# it to move - 2 is the default. !NoFast! is whether or not the player should be
# blocked from hold the action key to increase the scroll speed - false allows
# them to do so, true prevents it. The default is false.
#
# As of v3.2, you may override any key with the contents of another on a
# file-by-file basis. To provide an override, use this script call:
#
#   `$game_system.add_override(!Key1!, !Key2!)`
#
#   `!Key1!` is the key that you want to override.
#   `!Key2!` is the key that contains the value that `!Key1!` should now
#    reference.
#
# As an example, let's say I'm doing an alignment system for an NPC. If I want
# to change an NPC's default dialogue (let's say it's named NeutralDialogue) to
# the evil dialogue, I might use this:
#
#   `$game_system.add_override('NeutralDialogue', 'EvilDialogue')
#
# You can also remove overrides with this:
#
#   `$game_system.delete_override(!Key!)`
#
#   `!Key!` is the key whose override you want to delete.
#
# Using the above example, I might use this to reset NeutralDialogue:
#
#   `$game_system.delete_override('NeutralDialogue')
#
# You do not need to delete an override before replacing it. If you call
# add_override for a key that already has an override, the override will be
# replaced. Overrides are fully compatible with both MultiLang and Database.
# 
# Aliased Methods
# -----------------------------------------------------------------------------
# * `module DataManager`
#     - `self.load_battle_test_database`
#     - `self.load_normal_database`
#
# * `class Game_System`
#     - `initialize`
#
# * `class Window_Base`
#     - `convert_escape_characters`
#
# * `class Window_ChoiceList`
#     - `max_choice_width`
#
# * `class Scene_Map`
#     - `create_all_windows`
#
# * `class Scene_Battle`
#     - `create_all_windows`
# 
# New Methods
# -----------------------------------------------------------------------------
# * `module DataManager`
#     - `self.create_text`
#
# * `class Game_System`
#     - `add_override`
#     - `delete_override`
#     - `get_override`
#
# * `class Game_Message`
#     - `add_line`
#     - `clear`
#     - `get_color`
#     - `load_text`
#     - `too_wide?`
#
# * `class Game_Interpreter`
#     - `block_text`
#     - `block_text_us`
#     - `get_block`
#     - `get_text`
#     - `scrolling_text`
#     - `text`
#
# * `class Window_Base`
#     - `slice_escape_characters`
#
# * `class Scene_Map`
#     - `create_namebox`
#
# * `class Scene_Battle`
#     - `create_namebox`
# 
# License
# -----------------------------------------------------------------------------
# This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
# Place this script below the SES Core (v2.0 or higher) script (if you are
# using it) or the Materials header, but above all other custom scripts. This
# script does not require the SES Core, but it is highly recommended.
# 
#++
module SES
  # ExternalText
  # ===========================================================================
  # Module containing configuration information for the External Text script.
  module ExternalText
    
    # Enable this if you're not using a choice script like Raizen's and want to
    # use text codes in choices. It will force the choice window to evaluate
    # escape characters before displaying, causing it to size properly. In
    # general, it won't hurt to leave this on as long as this script is above
    # any other scripts that affect the choice window.
    ChoiceFix = true
    
    # Add faces here. The format is "Name" => ["Faceset", Index],
    Faces = {
      
      'Ralph' => ['Actor1', 0],
      
    }
    
    # Set this to either :box or :text. :box uses the name box, :text will
    # include the name at the top of each page.
    NameStyle = :box
    
    # This is a hash of tags that will be searched for in the Text.txt file. You
    # can customize this to add new tags. Scripters can add new tags in their
    # scripts by making a new hash and calling SES::ExternalText::Tags.merge!
    # with it.
    Tags = {
    
      /^\[Key\]\s*(.+)/i =>
        proc do |key|
          @key = key
          $game_text[key] = [
            # Face and Name
            # Filename, Index, Actor Index, Party Index, Name
            [ '',       0,     nil,         nil,         ''   ],
            
            # Text
              '',
            
            # Options
            # Position, Background
            [ 2,        0          ]
          ]
        end,
                                         
      /^\[Face\]\s*(.+),(?:\s*)(\d+)/i =>
        proc do |name, index|
          $game_text[@key][0][0] = name
          $game_text[key][0][1] = index.to_i
        end,
                        
      /^\[AFace\]\s*(\d+)/i =>
        proc do |actor_index|
          $game_text[@key][0][2] = actor_index.to_i
        end,
    
      /^\[PFace\]\s*(\d+)/i =>
        proc do |party_index|
          $game_text[@key][0][3] = party_index.to_i
        end,
    
      /^\[DFace\]\s*(.+)/i =>
        proc do |name|
          $game_text[@key][0][0] = SES::ExternalText::Faces[name][0]
          $game_text[@key][0][1] = SES::ExternalText::Faces[name][1]
        end,
                    
      /^\[Name\]\s*(.+)/i =>
        proc do |name|
          $game_text[key][0][4] = name
        end,
          
      /^\[FName\]\s*(.+)/ =>
        proc do |name|
          $game_text[@key][0][4] = name
          $game_text[@key][0][0] = SES::ExternalText::Faces[name][0]
          $game_text[@key][0][1] = SES::ExternalText::Faces[name][1]
        end,
              
      /^\[Position\]\s*(Top|Center|Bottom)/i =>
        proc do |pos|
          $game_text[@key][2][0] = if pos.downcase == 'top' then 0
                                   elsif pos.downcase == 'center' then 1
                                   else 2 end
        end,
                                  
      /^\[Background\]\s*(Normal|Dim|Transparent)/i =>
        proc do |bg|
          $game_text[@key][2][1] = if bg.downcase == 'normal' then 0
                                   elsif bg.downcase == 'dim' then 1
                                   else 2 end
        end,
    }
    
    # Iterates through all files in a chain of directories.
    #
    # @param dir [String] the base directory from which to iterate
    # @yield performs operations on files in a given directory chain
    # @yieldparam [String] file the path to a file
    # @return [void]
    def self.each_file(dir, &block)
      Dir.new(dir).entries.each do |file|
        next if file[/^\.+$/]
        if FileTest.directory?("#{dir}/#{file}")
          each_file("#{dir}/#{file}", &block)
        else
          yield "#{dir}/#{file}"
        end
      end
    end
    
    # Gets the text referenced by a particular key.
    #
    # @param key [String] the key referring to the desired text
    # @return [String] the text referenced by the given key
    def self.get_text(key)
      return nil unless $game_text
      if $game_system
        $game_system.get_override(key) ||
        ($game_text[key].nil? ? nil : $game_text[key][1].strip)
      else
        $game_text[key].nil? ? nil : $game_text[key][1].strip
      end
    end
    
    # Returns the current key during serialization.
    #
    # @return [String] the current key
    def self.key
      @key
    end
    
    # TextWrapper
    # =========================================================================
    # Wrapper class for string constants and variables to allow proper access
    # to game text.
    class TextWrapper
      attr_reader :is_key
      
      # Creates a new instance of TextWrapper.
      #
      # @param src [String] the name of the constant or variable that contains
      #   the default value of the wrapper; may also be a key for External Text
      # @param obj [Object] the object that contains the constant or variable;
      #   if nil, src is treated as an External Text key
      # @return [TextWrapper] a new instance of TextWrapper
      def initialize(src, obj = nil)
        @is_key = false
        klass_name = (obj.class == Module ? obj.name : obj.class.name)
        klass_name = klass_name[/(?:\w+::)?(\w+)/, 1]
        if (id = obj.instance_variable_get(:@id))
          @key = "#{klass_name}_#{id}_#{src}"
        elsif obj.nil? then @is_key = true and @key = src
        else @key = "#{klass_name}_#{src}" end
        if obj.nil? then @string = "Missing Key: #{src}."
        else
          if src[/^[A-Z]/] &&
                     (obj.class == Module ? obj : obj.class).const_defined?(src)
            @string = obj.const_get(src)
          else @string = obj.instance_variable_get("@#{src}") end
        end
      end
      
      # Handles unknown methods. If a String would respond to them, they are
      # passed to the String form of the wrapper.
      #
      # @param method [Symbol] the name of the method
      # @param args   [Array] the arguments passed to the method
      # @return [Object] whatever the method returns, if a string can handle it
      def method_missing(method, *args, &block)
        (s = to_s).respond_to?(method) ? s.send(method, *args, &block) : super
      end
      
      # Checks if a String can respond to the passed method.
      #
      # @param method [Symbol,String] the name of a method
      # @return [Boolean] whether or not Strings respond to the method
      def respond_to?(method)
        return @string.respond_to?(method)
      end
      
      # Converts the wrapper to its string form.
      #
      # @return [String] the string form of the wrapper
      def to_s
        SES::ExternalText.get_text(@key) || @string
      end
      # Alias for to_s. Required for proper treatment.
      alias_method :to_str, :to_s
    end
  end
end

($imported ||= {})['SES - External Text'] = '3.2.0'

# DataManager
# =============================================================================
# The singleton class of the default RPG Maker module for handling data.
class << DataManager
  
  # Serializes Text.txt to Text.rvdata2, allowing it to be read from inside an
  # encrypted archive.
  #
  # @return [void]
  def create_text
    $game_text = {}
    SES::ExternalText.each_file('Data/Text') do |f|
      File.open(f, 'r:BOM|UTF-8') do |file|
        file.readlines.each_with_index do |v,i|
          next if v =~ /(^\s*(#|\/\/).*|^\s*$)/
          SES::ExternalText::Tags.each_pair do |k,p|
            if v =~ k
              p.call(*$~[1..-1])
              v.clear
            end
          end
          if SES::ExternalText.key && !v.empty?
            v = "\n#{v}" unless $game_text[SES::ExternalText.key][1].empty?
            $game_text[SES::ExternalText.key][1] << v
          end
        end
      end
    end
    File.open("Data/Text.rvdata2", "w") do |file|
      Marshal.dump($game_text, file)
    end
  end
  
  alias_method :en_et_dm_lbd, :load_battle_test_database
  # Loads the game's databases for a battle test.
  #
  # @return [void]
  def load_battle_test_database
    en_et_dm_lbd
    create_text if FileTest.directory?('Data/Text')
    $game_text = load_data('Data/Text.rvdata2') unless $game_text
  end
  
  alias_method :en_et_dm_lnd, :load_normal_database
  # Loads the game's databases.
  #
  # @return [void]
  def load_normal_database
    en_et_dm_lnd
    create_text if FileTest.directory?('Data/Text')
    $game_text = load_data('Data/Text.rvdata2') unless $game_text
  end
end

# Game_System
# =============================================================================
# Holds basic system information for the game.
class Game_System
  
  alias_method :en_et_gs_i, :initialize
  def initialize
    en_et_gs_i
    @text_overrides = {}
  end
  
  # Adds an override to the text overrides hash.
  #
  # @param key [String] the key of the text being overridden
  # @param value [String] the text of the override
  # @return [void]
  def add_override(key, value)
    @text_overrides[key] = SES::ExternalText::TextWrapper.new(value)
  end
  
  # Deletes an override from the text overrides hash.
  #
  # @param key [String] the override to delete
  # @return [void]
  def delete_override(key)
    @text_overrides.delete(key)
  end
  
  # Gets the value of a text override, if it exists.
  #
  # @param key [String] the override to grab
  # @return [String,NilClass] the value of the override, or nil if it does not
  #   exist
  def get_override(key)
    @text_overrides[key]
  end
end

# Game_Message
# =============================================================================
# Controls the game's message window.
class Game_Message
  attr_reader :name
  
  # Adds a new line to the message window.
  #
  # @param lines [Array<String>] the current lines in the message window
  # @param i [Integer] the current line index
  # @param cc [String] the current text color code for the message window
  # @param name [Boolean] whether or not to display the name
  # @return [Integer] the modified line index
  def add_line(lines, i, cc, name)
    i += 1
    lines[i] = ''
    if i % 4 == 0
      if name && SES::ExternalText::NameStyle == :text && @name
        lines[i] << @name
        i += 1
        lines[i] = ''
      end
      lines[i] << cc
    end
    return i
  end
  
  alias_method :en_et_gm_c, :clear
  # Clears the message window.
  #
  # @return [void]
  def clear
    en_et_gm_c
    @name = ''
  end
  
  # Converts escape characters in the given text.
  #
  # @param text [String] the text to convert
  # @return [String] the text with escape characters converted
  def convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i) { actor_name($1.to_i) }
    result.gsub!(/\eP\[(\d+)\]/i) { party_member_name($1.to_i) }
    result.gsub!(/\eG/i)          { Vocab::currency_unit }
    result.gsub!(/\eT\[(.+)\]/i) do
      if $game_text.keys.include?($1) then $game_text[$1][1]
      else "Invalid key [#{$1}]. No matching text exists."
      end
    end
    result
  end

  
  # Gets the most recently used text color code.
  #
  # @param text [String] the string to scan for color codes
  # @return [String, NilClass] the last color code used in the passed text, or
  #   nil if there are no color codes in use
  def get_color(text)
    cc = nil
    convert_escape_characters(text).gsub(/\eC(?:\[\w+?\])?/i) { |s| cc = s }
    return cc
  end
  
  # Sets up the called text, as well as any face and name data it contains.
  #
  # @param data [Array<Array<String,Integer,NilClass>,String>] the called text
  #   data
  # @param name [Boolean] whether or not to display the name
  # @return [Array<String>] the lines to display in the message window
  def load_text(data, name = true)
    if data[0][2]
      actor = $game_actors[data[0][2]].actor
      @face_name = actor.face_name
      @face_index = actor.face_index
    elsif data[0][3]
      actor = $game_party.members[data[0][3]]
      @face_name = actor.face_name
      @face_index = actor.face_index
    else
      @face_name = data[0][0]
      @face_index = data[0][1]
    end
    @position = data[2][0]
    @background = data[2][1]
    text = data[1]
    new_page
    lines = ['']
    i = 0
    cc = ''
    if name
      @name = data[0][4].empty? ? nil : "#{data[0][4]}"
      if SES::ExternalText::NameStyle == :text
        @name << '\c[0]'
        lines[0] = @name
        i += 1
        lines[i] = ''
      end
    end
    text.gsub!(/[\r\n]+/) { '[line]' }
    text.split(/\s+/).each do |w|
      cc = get_color(w) || cc
      if w[/\[line\]/i]
        w.split(/\[line\]/i).each_with_index do |v,l|
          i = add_line(lines, i, cc, name) if l > 0 || too_wide?(lines[i] + v)
          lines[i] << "#{v} "
        end
      elsif too_wide?(lines[i] + w)
        i = add_line(lines, i, cc, name)
        lines[i] << "#{w} "
      else
        lines[i] << "#{w} "
      end
    end
    return lines
  end
  
  # Sets the current message window text.
  #
  # @param text [Array<String>] the array of lines to display
  # @return [void]
  def set_text(text)
    @texts = text
  end
  
  # Removes all escape characters from the given text and returns it.
  #
  # @param text [String] the text to adjust
  # @return [String] the text with escape characters removed
  def slice_escape_characters(text)
    convert_escape_characters(text).gsub(/\e(\w)(\[(\w+)\])?/) {""}
  end
  
  # Checks if given text is too wide for the message window.
  #
  # @param text [String] the text to check
  # @return [Boolean] whether or not the text is too wide to fit
  def too_wide?(text)
    unless @message_width
      win = Window_Message.new
      @message_width = win.contents_width
      win.dispose
    end
    @dummy_bitmap ||= Bitmap.new(1,1)
    width = @message_width
    width -= 112 unless @face_name.empty?
    @dummy_bitmap.text_size(slice_escape_characters(text)).width > width
  end
end

# Game_Interpreter
# =============================================================================
# Executes event commands.
class Game_Interpreter
  
  # Allows you to call multiple lines of text at once. Sorts keys before
  # iterating.
  #
  # @param key [String,Regexp] the key to match in called text
  # @param from [Integer] the index at which to begin iteration
  # @param to [Integer] the index at which to stop iterating
  # @return [void]
  def block_text(key, from = 0, to = -1)
    get_block($game_text.keys.sort, key, from, to)
  end
  
  # Allows you to call multiple lines of text at once. Does not sort keys before
  # iterating.
  #
  # @param key [String,Regexp] the key to match in called text
  # @param from [Integer] the index at which to begin iteration
  # @param to [Integer] the index at which to stop iterating
  # @return [void]
  def block_text_us(key, from = 0, to = -1)
    get_block($game_text.keys, key, from, to)
  end
  
  # Does the actual processing for block text iteration.
  #
  # @param text [Array<String>] the array of text keys to iterate through
  # @param key [String,Regexp] the key to match in called text
  # @param from [Integer] the index at which to begin iteration
  # @param to [Integer] the index at which to stop iterating
  # @return [void]
  def get_block(text, key, from, to)
    text.each do |k|
      break if to == 0
      if key.is_a?(String)
        if k.include?(key)
          if from == 0
            text(k)
            to -= 1
          else from -= 1 end
        end
      else
        if k =~ key
          if from == 0
            text(k)
            to -= 1
          else from -= 1 end
        end
      end
    end
  end
  
  # Retrieves the text of a given key.
  #
  # @param key [String] the key whose text you wish to obtain
  # @return [String] the text present at the given key
  def get_text(key)
    SES::ExternalText.get_text(key).strip
  end
  
  # Displays the given key's text as scrolling text.
  #
  # @param key [String] the key whose text you wish to display
  # @param speed [Integer] the scroll speed for the text
  # @param no_fast [Boolean] whether or not the user should be able to speed up
  #   the scrolling
  # @return [void]
  def scrolling_text(key, speed = 2, no_fast = false)
    Fiber.yield while $game_message.visible
    $game_message.scroll_mode = true
    $game_message.scroll_speed = speed
    $game_message.scroll_no_fast = no_fast
    list = $game_message.load_text($game_text[key], false)
    index = 0
    while index < list.size
      $game_message.add(list[index])
      index += 1
    end
    wait_for_message
  end
  
  # Displays the given key's text in the message window.
  #
  # @param key [String] the key whose text you wish to display
  # @return [void]
  def text(key)
    $game_message.set_text($game_message.load_text($game_text[key]) ||
                                        "There is no text for the key #{key}.")
    case next_event_code
    when 102
      @index += 1
      setup_choices(@list[@index].parameters)
    when 103
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end
end

# Window_Base
# =============================================================================
# Base class for windows in the game.
class Window_Base
  
  alias_method :en_et_wb_cec, :convert_escape_characters
  # Converts escape characters in the given text.
  #
  # @param text [String] the text to convert
  # @return [String] the text with escape characters converted
  def convert_escape_characters(*args, &block)
    result = en_et_wb_cec(*args, &block)
    result.gsub!(/\eT\[(.+)\]/i) do
      if $game_text.keys.include?($1) then $game_text[$1][1]
      else "Invalid key [#{$1}]. No matching text exists."
      end
    end
    result
  end
  
  # Removes all escape characters from the given text and returns it.
  #
  # @param text [String] the text to adjust
  # @return [String] the text with escape characters removed
  def slice_escape_characters(text)
    convert_escape_characters(text).gsub(/\e(\w)(\[(\w+)\])?/) {""}
  end
end

if SES::ExternalText::ChoiceFix
  # Window_ChoiceList
  # ===========================================================================
  # Displays choices for the player to select.
  class Window_ChoiceList < Window_Command
    alias_method :en_et_wcl_mcw, :max_choice_width
    def max_choice_width
      $game_message.choices.collect do |s| 
        text_size(slice_escape_characters(s)).width
      end.max
    end
  end
end

if SES::ExternalText::NameStyle == :box
  # Window_NameBox
  # ===========================================================================
  # Creates a window to display the name of the speaker.
  class Window_NameBox < Window_Base
    
    # Creates a new instance of Window_NameBox.
    #
    # @return [Window_NameBox] a new instance of Window_NameBox
    def initialize
      super(0, Graphics.height - 168, 0, 0)
      @position = 2
      self.visible = false; close
      self.height = 48
      self.width = 130
      @name = ""
      self.arrows_visible = false
    end
    
    # Sets the display name of the speaker.
    #
    # @param name [String] the name of the speaker
    # @return [void]
    def set_name(name)
      return unless name
      @name = name
      self.visible = true
      if @name.empty?
        close if open?
      else
        if $game_message.position > 0 && $game_message.position != @position
          @position = $game_message.position
          self.y = @position * (Graphics.height - fitting_height(4)) / 2 -
                                                                     self.height
        else
          unless $game_message.position == @position
            @position = $game_message.position
            self.y = fitting_height(4)
          end
        end
        open unless open?
        create_contents
        self.draw_text_ex((contents_width - text_size(@name).width) / 2, 0,
                                                                          @name)
      end
    end
    
    # Updates the window.
    #
    # @return [void]
    def update
      super
      set_name($game_message.name) if @name != $game_message.name
    end
  end
  
  # Scene_Map
  # ===========================================================================
  # The game's map scene.
  class Scene_Map < Scene_Base
    
    alias_method :en_et_sm_caw, :create_all_windows
    # Creates all of the windows used by the scene.
    #
    # @return [void]
    def create_all_windows
      en_et_sm_caw
      create_namebox
    end
    
    # Creates the name box used by messages in the scene.
    #
    # @return [void]
    def create_namebox
      @namebox = Window_NameBox.new
    end
  end

  # Scene_Battle
  # ===========================================================================
  # The game's battle scene.
  class Scene_Battle < Scene_Base
    
    # Creates all of the windows used by the scene.
    #
    # @return [void]
    alias_method :en_et_sb_caw, :create_all_windows
    def create_all_windows
      en_et_sb_caw
      create_namebox
    end
    
    # Creates the name box used by messages in the scene.
    #
    # @return [void]
    def create_namebox
      @namebox = Window_NameBox.new
    end
  end
end
