#--
# External Text: Database v1.0.1 by Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
# This script allows you to keep the text contents of your Database in external
# files. It can also hook into any method that returns a string and use keys in
# your External Text files to override them. It's compatible with MultiLang from
# the start, so your translation will be taken to the next level!
# 
# Compatibility Information
# -----------------------------------------------------------------------------
# **Required Scripts:**
# SES External Text v3.1.0 or higher
# (Optional) SES External Text: MultiLang v2.1.0 or higher
# 
# **Known Incompatibilities:**
# None.
#
# Warning
# -----------------------------------------------------------------------------
# v1.0.0 does not yet include support for mid-game changes to text that it
# overrides. If you intend to change text mid-game, you will need to leave out
# those override keys from your text files. v1.1.0, whenever it is released,
# should contain support for this.
# 
# Usage
# -----------------------------------------------------------------------------
# There are two parts to using this script: putting keys in your External Text
# files and adding new overrides.
#
# Keys are automatically generated and follow a simple format:
#
#    `[Key] Class_!ID!_!method!`
#
# For example, if I wanted to override actor 1's name I would use this key:
#
#    `[Key] Actor_1_name`
#
# If I wanted to override a skill's cast message, I might do this:
#
#    `[Key] Skill_3_message1`
#
# If a given override key is not present, the default value (as set in the
# Database) will be used. For overridden non-database methods, the default value
# is whatever the script that introduced it supplied.
#
# Custom overrides are slightly trickier (though not by much). Add the name of
# the class that contains the method you want to override to the Override hash
# in the SES::ExternalText module. Its value should be an array containing the
# names of the methods that you want to add overrides for. As above, keys will
# be automatically generated. If the class being overriden does not have an id,
# the format for the key changes to this:
#
#    `[Key] Class_!method!`
#
# For example, I could add this to the hash:
#
#    `'Game_Party' => [:name],`
#
# And the new key would be this:
#
#    `[Key] Game_Party_name`
#
# Finally, RPG::System::Terms uses an array-based method of storing its vocab.
# This has been given a manual override. For a list of the possible keys that it
# uses, please look at the RPG::System::Terms section of this script.
#
# Oh, and one last 'note'... You may be thinking "Well, Enelvon, the notes of
# Database objects are strings. Can I override those? What about character
# sprites and map battlebacks? Those are strings." The answer is "Absolutely!"
# Just add :note, :character_name, :battleback_floor_name, or whatever to the
# arrays, and you're golden. Have fun!
# 
# Overwritten Methods
# -----------------------------------------------------------------------------
# Anything you add, plus everything in RPG::System::Terms.
# 
# License
# -----------------------------------------------------------------------------
# This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
# Put this script below Materials and above Main. It must also be below
# SES - External Text v3.1.0 or higher. If you use MultiLang (must be v2.1.0 or
# higher), place this below that as well. Finally, if you add custom overrides,
# this script must be below all scripts that contain overriden methods.
# 
#++
module SES
  # ExternalText
  # ===========================================================================
  # Module containing configuration information for the External Text script.
  module ExternalText
    
    # Hash of methods to override
    Override = {
    # Class       => [ Method names ],
    'RPG::Actor'  => [:name, :nickname, :description],
    'RPG::Class'  => [:name],
    'RPG::Skill'  => [:name, :description, :message1, :message2],
    'RPG::Item'   => [:name, :description],
    'RPG::Weapon' => [:name, :description],
    'RPG::Armor'  => [:name, :description],
    'RPG::Enemy'  => [:name],
    'RPG::State'  => [:name, :message1, :message2, :message3, :message4],
    'RPG::Map'    => [:display_name],
    
    }
    
  end
end

$imported ||= {}
if !$imported["SES - External Text"] ||
                                      $imported["SES - External Text"] < '3.1.0'
  raise("You need SES - External Text v3.1.0 or higher to use SES - External" <<
                                                               "Text Database.")
end
$imported["SES - External Text Database"] = '1.0.1'

# RPG::System::Terms
# ============================================================================
# Class containing basic vocabulary for the game.
class RPG::System::Terms
  
  # Basic status vocabulary.
  #
  # @return [Array<String>] basic status vocabulary
  def basic
    [SES::ExternalText.get_text('System_Level ') || @basic[0],
     SES::ExternalText.get_text('System_Level_short') || @basic[1],
     SES::ExternalText.get_text('System_HP') || @basic[2],
     SES::ExternalText.get_text('System_HP_short') || @basic[3],
     SES::ExternalText.get_text('System_MP') || @basic[4],
     SES::ExternalText.get_text('System_MP_short') || @basic[5],
     SES::ExternalText.get_text('System_TP') || @basic[6],
     SES::ExternalText.get_text('System_TP_short') || @basic[7]] 
  end
  
  # Parameter vocabulary.
  #
  # @return [Array<String>] parameter vocabulary
  def params
    [SES::ExternalText.get_text('System_MHP') || @params[0],
     SES::ExternalText.get_text('System_MMP') || @params[1],
     SES::ExternalText.get_text('System_ATK') || @params[2],
     SES::ExternalText.get_text('System_DEF') || @params[3],
     SES::ExternalText.get_text('System_MAT') || @params[4],
     SES::ExternalText.get_text('System_MDF') || @params[5],
     SES::ExternalText.get_text('System_AGI') || @params[6],
     SES::ExternalText.get_text('System_LUK') || @params[7]]
  end
  
  # Equipment type vocabulary.
  #
  # @return [Array<String>] equipment type vocabulary
  def etypes
    [SES::ExternalText.get_text('System_etype_0') || @etypes[0],
     SES::ExternalText.get_text('System_etype_1') || @etypes[1],
     SES::ExternalText.get_text('System_etype_2') || @etypes[2],
     SES::ExternalText.get_text('System_etype_3') || @etypes[3],
     SES::ExternalText.get_text('System_etype_4') || @etypes[4]]
  end
  
  # System command vocabulary.
  #
  # @return [Array<String>] system command vocabulary
  def commands
    [SES::ExternalText.get_text('System_Fight') || @commands[0],
     SES::ExternalText.get_text('System_Escape') || @commands[1],
     SES::ExternalText.get_text('System_Attack') || @commands[2],
     SES::ExternalText.get_text('System_Defend') || @commands[3],
     SES::ExternalText.get_text('System_Item') || @commands[4],
     SES::ExternalText.get_text('System_Skill') || @commands[5],
     SES::ExternalText.get_text('System_Equip') || @commands[6],
     SES::ExternalText.get_text('System_Status') || @commands[7],
     SES::ExternalText.get_text('System_Sort') || @commands[8],
     SES::ExternalText.get_text('System_Save') || @commands[9],
     SES::ExternalText.get_text('System_Exit_Game') || @commands[10],
     SES::ExternalText.get_text('System_(not_used)') || @commands[11],
     SES::ExternalText.get_text('System_Weapon') || @commands[12],
     SES::ExternalText.get_text('System_Armor') || @commands[13],
     SES::ExternalText.get_text('System_Key_Item') || @commands[14],
     SES::ExternalText.get_text('System_Change_Equipment') || @commands[15],
     SES::ExternalText.get_text('System_Ultimate_Equipment') || @commands[16],
     SES::ExternalText.get_text('System_Remove_All') || @commands[17],
     SES::ExternalText.get_text('System_New_Game') || @commands[18],
     SES::ExternalText.get_text('System_Continue') || @commands[19],
     SES::ExternalText.get_text('System_Shut_Down') || @commands[20],
     SES::ExternalText.get_text('System_Go_to_Title') || @commands[21],
     SES::ExternalText.get_text('System_Cancel') || @commands[22]]
  end
end

# Overrides all methods present in the SES::ExternalText::Override hash.
#
# @param k [String,Symbol] the class in which the overrides take place
# @param v [Array<String,Symbol>] an array of methods to override
# @return [void]
SES::ExternalText::Override.each_pair do |k,v|
  chain = []
  klass = "#{k}"
  klass.gsub!(/(\w+)::(\w+)/) do
    chain << $1
    chain << $2
    ''
  end
  chain << klass unless klass.empty?
  klass_name = chain.last
  klass = Object
  klass = klass.const_get(chain.shift) until chain.empty?
  # The actual override process.
  #
  # @param method [String,Symbol] the method to override
  v.each do |method|
    klass.send(:alias_method, :"en_etd_#{method}", method) rescue nil
    klass.send(:define_method, method) do
      en_generated_text_key = ''
      if instance_variable_get("@id")
        en_generated_text_key = "#{klass_name}_#{@id}_#{method}"
      else
        en_generated_text_key = "#{klass_name}_#{method}"
      end
      SES::ExternalText.get_text(en_generated_text_key) ||
           (send("en_etd_#{method}") rescue instance_variable_get("@#{method}"))
    end
  end
end
