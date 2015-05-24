#--
# External Text: MultiLang v2.0.1 by Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
# This script allows you to have multiple languages in your game. The user
# can swap between them, and the game will remember which language was last
# selected in between gaming sessions.
# 
# Compatibility Information
# -----------------------------------------------------------------------------
# **Required Scripts:**
# Puts this script below Materials and above Main. It must also be below
# SES - External Text v3.0.0 or higher.
# 
# **Known Incompatibilities:**
# None.
# 
# Usage
# -----------------------------------------------------------------------------
# Remember Text.txt from External Text? Yeah, you're not using that anymore.
# Go to SES::ExternalText in this script and find the Languages array. Add as
# many as you'd like. Now create a text file for each language you added, with
# the name being that of the language in question. Make sure to place it in
# the Data folder. Treat each of them like you would Text.txt - they work the
# same way. Make sure all of your keys are the same in each file - if the keys
# are different, the languages won't be compatible with each other.
# 
# Note that each language can (and probably should) have different text for
# the language select screen. The default is in English, obviously. To change
# it, create a key in the language's file called 
# 
#     `Language Select`
# 
# Make sure it's spelled exactly the same way, space and capitalization
# included. The text you use for this key will be displayed when selecting
# languages with that language as the current game language.
#
# Script Calls
# -----------------------------------------------------------------------------
# To call the language selection scene, use this:
# 
#     `SceneManager.call(Scene_LanguageSelect)`
# 
# You can use it on the map, or add it to a menu of some kind. Your choice.
# 
# New Methods
# -----------------------------------------------------------------------------
# * `module DataManager`
#     - `self.check_language`
#     - `self.set_language`
# 
# License
# -----------------------------------------------------------------------------
# This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
# Puts this script below Materials and above Main. It must also be below
# SES - External Text v3.0.0 or higher.
# 
#++
module SES
  # ExternalText
  # ===========================================================================
  # Module containing configuration information for the External Text script.
  module ExternalText

    # Array of languages present in the game.
    Languages = ["English"]
  
  end
end

$imported ||= {}
if !$imported["SES - External Text"] ||
                                      $imported["SES - External Text"] < '3.0.0'
  raise("You need SES - External Text v3.0.0 or higher to use SES - MultiLang.")
end
$imported["SES - MultiLang"] = '2.0.1'

# DataManager
# =============================================================================
# The singleton class of the default RPG Maker module for handling data.
class << DataManager
  
  # Checks what language the game should launch with.
  #
  # @return [String] the name of the default language
  def check_language
    language = SES::ExternalText::Languages[0]
    File.open("Game.ini", "r:BOM|UTF-8") do |f|
      f.readlines.each do |line|
        if line =~ /Language=(\w+)/
          language = $1 if SES::ExternalText::Languages.include?($1)
        end
      end
    end
    language
  end
  
  # Serializes all languages txt files to rvdata2 files, allowing them to be
  # read from inside an encrypted archive.
  #
  # @return [void]
  def create_text
    $game_text = {}
    text = {}
    key = ""
    SES::ExternalText::Languages.each do |l|
      $game_text.clear
      File.open("Data/#{l}.txt", "r:BOM|UTF-8") do |file|
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
      File.open("Data/#{l}.rvdata2", "w") do |file|
        Marshal.dump($game_text, file)
      end
    end
  end
  
  # Loads the game's databases.
  #
  # @return [void]
  def load_normal_database
    en_et_dm_lnd
    if FileTest.exist?("Data/#{SES::ExternalText::Languages[0]}.txt")
      create_text
    end
    $game_text = load_data("Data/#{check_language}.rvdata2")
  end
  
  # Loads the game's databases for a battle test.
  #
  # @return [void]
  def load_battle_test_database
    en_et_dm_lbd
    if FileTest.exist?("Data/#{SES::ExternalText::Languages[0]}.txt")
      create_text
    end
    $game_text = load_data("Data/#{check_language}.rvdata2")
  end
  
  # Changes the default language.
  #
  # @return [void]
  def set_language(language)
    lines = File.read("Game.ini")
    lines.gsub!(/Language=(\w+)/) { "Language=#{language}" }
    lines << "Language=#{language}\n" if !lines.include?("Language=#{language}")
    File.open("Game.ini", "w") { |f| f.write(lines) }
    $game_text = load_data("Data/#{language}.rvdata2")
  end
end

# Window_LanguageSelect
# =============================================================================
# The main window for the bare-bones language selection scene.
class Window_LanguageSelect < Window_Command
  
  # Creates a new instance of Window_LanguageSelect.
  #
  # @return [Window_LanguageSelect] a new instance of Window_LanguageSelect
  def initialize
    super((Graphics.width - window_width) / 2,
                                          (Graphics.height - window_height) / 2)
  end
  
  # The number of lines to display at once in the window.
  #
  # @return [Integer] the number of lines to display ato nce
  def visible_line_number
    [SES::ExternalText::Languages.size, 8].min
  end
  
  # The name of the language at the given index
  #
  # @return [String] the name of the language at the given index
  def command_name(index)
    @list[index]
  end
  
  # Whether or not the currently selected language is enabled.
  #
  # @return [TrueClass] always true
  def current_item_enabled?
    true
  end
  
  # Whether or not the currently selected language is enabled.
  #
  # @return [TrueClass] always true
  def command_enabled?(index)
    true
  end
  
  # Whether or not the user can select a language.
  #
  # @return [TrueClass] always true
  def ok_enabled?
    true
  end
  
  # Processing for when the user selects a language.
  #
  # @return [void]
  def call_ok_handler
    DataManager.set_language(command_name(@index))
    activate
  end
  
  # Gets the list of languages to display.
  #
  # @return [void]
  def make_command_list
    @list = SES::ExternalText::Languages
  end
end

# Scene_LanguageSelect
# =============================================================================
# A bare-bones language selection scene.
class Scene_LanguageSelect < Scene_Base
  
  # Initial processing for the scene.
  #
  # @return [void]
  def start
    super
    create_background
    @text_window = Window_Help.new(1)
    set_help_text
    @select_window = Window_LanguageSelect.new
  end
  
  # Creates the background for the scene.
  #
  # @return [void]
  def create_background
    @background = Sprite.new
    @background.bitmap = SceneManager.background_bitmap
  end
  
  # Sets the help text for the current language.
  #
  # @return [void]
  def set_help_text
    @text_window.set_text(SES::ExternalText.get_text("Language Select") ||
                          "Select a language from the list.")
  end
  
  # Updates the scene.
  #
  # @return [void]
  def update
    super
    set_help_text
    SceneManager.return if Input.trigger?(:B)
  end
  
  # Clears the scene.
  #
  # @return [void]
  def terminate
    Graphics.freeze
    dispose_all_windows
  end
end
