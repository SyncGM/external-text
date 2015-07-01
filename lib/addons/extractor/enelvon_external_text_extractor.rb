# Name: SES - External Text Extractor
# Author: Enelvon
# URL: https://raw.githubusercontent.com/sesvxace/external-text/master/lib/external-text.rb
#
# Extracts game and database text for use with External Text. Some aspects of
# this plugin require the Database addon, found below:
# https://raw.githubusercontent.com/sesvxace/external-text/master/lib/addons/external-text-database/external-text-database.rb

require 'zlib'

# SES
# -----------------------------------------------------------------------------
# Top-level namespace for SES scripts.
module SES
  # ExternalText
  # ---------------------------------------------------------------------------
  # Module containing configuration information for the External Text script.
  module ExternalText
  
    (Override ||= {}).clear
    # Class       => [ Method names ],
    Override['RPG::Actor']  = [:name, :nickname, :description]
    Override['RPG::Class']  = [:name]
    Override['RPG::Skill']  = [:name, :description, :message1, :message2]
    Override['RPG::Item']   = [:name, :description]
    Override['RPG::Weapon'] = [:name, :description]
    Override['RPG::Armor']  = [:name, :description]
    Override['RPG::Enemy']  = [:name]
    Override['RPG::State']  = [:name, :message1, :message2,
                               :message3, :message4]
    Override['RPG::Map']    = [:display_name]
    
    # The background types, in order. Do not edit.
    Backgrounds ||= ['Normal', 'Dim', 'Transparent']
    
    # The position types, in order. Do not edit.
    Positions ||= ['Top', 'Center', 'Bottom']
    
    # Extracts actor text from the Database.
    #
    # @return [void]
    def self.extract_actor_text
      text = ''
      Data_Actors.each_with_index do |a|
        next unless a
        text << "#-----------------------------\n"
        text << "# Actor #{a.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::Actor'].each do |m|
          text << "[Key] Actor_#{a.id}_#{m}\n#{a.send(m)}\n\n"
        end
        text << "\n"
      end
      File.open(
            "#{$editor_window.project_directory}/Data/Text/Database/Actors.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts armor text from the Database.
    #
    # @return [void]
    def self.extract_armor_text
      text = ''
      Data_Armors.each_with_index do |a|
        next unless a
        text << "#-----------------------------\n"
        text << "# Armor #{a.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::Armor'].each do |m|
          text << "[Key] Armor_#{a.id}_#{m}\n#{a.send(m)}\n\n"
        end
        text << "\n"
      end
      File.open(
            "#{$editor_window.project_directory}/Data/Text/Database/Armors.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts and replaces text choices from events, common events, and troops.
    #
    # @param mid [Integer] the ID of the map containing the event, for events
    # @param eid [Integer] the ID of the event, common event, or troop
    # @param pid [Integer] the ID of the event or troop page
    # @param list [Array<RPG::EventCommand>] the list of event commands from
    #   which the choices will be extracted
    # @param index [Integer] the index of the choice in the list
    # @param count [Integer] the number of other choices there have been
    # @param type [Symbol] the type of event from which the choice should be
    #   extracted
    # @return [String] the External Text key for the choice
    def self.extract_choices(mid, eid, pid, list, index, count, type)
      text = ''
      base_indent = list[index].indent
      choice_index = 1
      text << "\n[Key] Map #{mid} Event #{eid} Page #{pid + 1} " <<
                                                             "Choice #{count}\n"
      default_choice = list[index].parameters[1]
      text << "[Default Choice] #{default_choice}\n"
      list[index].parameters[0].each { |choice| text << "#{choice}\n" }
      num_choices = list[index].parameters[0].size
      last = list[index].parameters[0].last
      list[index].code = 355
      case type
      when :map
        list[index].parameters = ["show_choices('Map #{mid} Event #{eid}" <<
                                           " Page #{pid + 1} Choice #{count}')"]
      when :common_event
        list[index].parameters = ["show_choices('Common Event #{eid}" <<
                                                           " Choice #{count}')"]
      when :troop
        list[index].parameters = ["show choices('Troop #{eid} Page" <<
                                                " #{pid + 1} Choice #{count}')"]
      end
      index += 1
      list[index].code = 111
      list[index].parameters = [12, '$game_variables[' <<
                  "SES::ExternalText::ChoiceVariable] == #{choice_index}", 0, 0]
      index += 1
      while index < list.size
        if list[index].code == 402 && list[index].indent == base_indent
          c = list[index].parameters[1]
          choice_index += 1
          list[index].code = 111
          list[index].indent = choice_index + base_indent - 1
          list[index].parameters = [12, '$game_variables[' <<
                  "SES::ExternalText::ChoiceVariable] == #{choice_index}", 0, 0]
          cmd = RPG::EventCommand.new
          cmd.code = 411
          cmd.indent = choice_index + base_indent - 2
          list.insert(index, cmd)
          index += 1
          if default_choice <= num_choices && c == last
            index += 1
            while list[index].indent > base_indent
              list[index].indent += choice_index - 1
              index += 1
            end
            choice_index.times do |i|
              cmd = RPG::EventCommand.new
              cmd.indent = i + base_indent + 1
              list.insert(index, cmd)
              cmd = RPG::EventCommand.new
              cmd.code = 412
              cmd.indent = i + base_indent + 1
              list.insert(index, cmd)
            end
            break
          end
        elsif list[index].code == 403 && list[index].indent == base_indent &&
                                                    default_choice > num_choices
          choice_index += 1
          list[index].code = 111
          list[index].indent = choice_index + base_indent - 1
          list[index].parameters = [12, '$game_variables[' <<
                "SES::ExternalText::ChoiceVariable] == #{default_choice}", 0, 0]
          cmd = RPG::EventCommand.new
          cmd.code = 411
          cmd.indent = choice_index + base_indent - 2
          list.insert(index, cmd)
          index += 2
          while list[index].indent > base_indent
            list[index].indent += choice_index - 1
            index += 1
          end
          choice_index.times do |i|
            cmd = RPG::EventCommand.new
            cmd.indent = i + base_indent + 1
            list.insert(index, cmd)
            cmd = RPG::EventCommand.new
            cmd.code = 412
            cmd.indent = i + base_indent + 1
            list.insert(index, cmd)
          end
          break
        else
          list[index].indent += choice_index - 1
        end
        index += 1
      end
      return text
    end
    
    # Extracts class text from the Database.
    #
    # @return [void]
    def self.extract_class_text
      text = ''
      Data_Classes.each_with_index do |c|
        next unless c
        text << "#-----------------------------\n"
        text << "# Class #{c.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::Class'].each do |m|
          text << "[Key] Class_#{c.id}_#{m}\n#{c.send(m)}\n\n"
        end
        text << "\n"
      end
      File.open(
           "#{$editor_window.project_directory}/Data/Text/Database/Classes.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts text from common events and replaces it with external text calls.
    #
    # @return [void]
    def self.extract_common_event_text
      FileUtils.mkdir_p(
                  "#{$editor_window.project_directory}/Data/Text/Common Events")
      text = ''
      common_events = nil
      File.open("#{$editor_window.project_directory}/Data/CommonEvents.rvdata2",
                                                                    'r+') do |f|
        common_events = Marshal.load(f)
      end
      common_events.each do |e|
        next unless e
        et = ''
        count = 0
        choice_count = 0
        scroll_count = 0
        scrolling_text = []
        text_ranges = []
        e.list.each_with_index do |c,ci|
          if c.code == 101
            text_ranges << ci
            count += 1
            et << "\n[Key] Common Event #{e.id} Text #{count}"
            unless c.parameters[0].empty?
              et << "[Face] #{c.parameters[0]}, #{c.parameters[1]}\n"
            end
            et << "[Background] #{Backgrounds[c.parameters[2]]}\n"
            et << "[Position] #{Positions[c.parameters[3]]}\n"
          elsif c.code == 401 || c.code == 405
            et << "#{c.parameters[0]}\n"
          elsif c.code == 102
            choice_count += 1
            et << extract_choices(-1, e.id, -1, e.list, ci, choice_count,
                                                                  :common_event)
          elsif c.code == 404
            c.code = 412
          elsif c.code == 105
            scrolling_text << ci
            scroll_count += 1
            et << "\n[Key] Common Event #{e.id}" <<
                                             " Scrolling Text #{scroll_count}\n"
          end
        end
        unless text_ranges.empty?
          offset = 0
          text_ranges.each_with_index do |r,ti|
            r -= offset
            e.list[r].code = 355
            e.list[r].parameters =
                      ["text('Common Event #{e.id} Text #{ti + 1}')"]
            pi = r + 1
            while e.list[pi].code == 401
              offset += 1
              e.list.delete_at(pi)
            end
          end
        end
        unless scrolling_text.empty?
          offset = 0
          scrolling_text.each_with_index do |s,ti|
            s -= offset
            sp = p.list[s].parameters[0]
            nf = p.list[s].parameters[1]
            p.list[s].code = 355
            p.list[s].parameters = ["scrolling_text('Common Event #{e.id} " <<
                                     "Scrolling Text #{ti + 1}', #{sp}, #{nf})"]
            pi = s + 1
            while p.list[pi].code == 405
              offset += 1
              p.list.delete_at(pi)
            end
          end
        end
        unless et.empty?
          text << "#-----------------------------\n"
          text << "# Common Event #{e.id}\n"
          text << "#-----------------------------"
          text << et << "\n\n"
          File.open("#{$editor_window.project_directory}/Data/Text/Common " <<
           "Events/Event #{sprintf('%03d', e.id)} - #{e.name}.txt", 'w+') do |f|
           f.write(text)
          end
          text = ''
        end
      end
      File.open("#{$editor_window.project_directory}/Data/CommonEvents.rvdata2",
                                                                    'w+') do |f|
        Marshal.dump(common_events, f)
      end
    end
    
    # Extracts enemy text from the Database.
    #
    # @return [void]
    def self.extract_enemy_text
      text = ''
      Data_Enemies.each_with_index do |e|
        next unless e
        text << "#-----------------------------\n"
        text << "# Enemy #{e.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::Enemy'].each do |m|
          text << "[Key] Enemy_#{e.id}_#{m}\n#{e.send(m)}\n\n"
        end
        text << "\n"
      end
      File.open(
           "#{$editor_window.project_directory}/Data/Text/Database/Enemies.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts text from event pages and replaces it with External Text calls.
    #
    # @return [void]
    def self.extract_event_text
      FileUtils.mkdir_p("#{$editor_window.project_directory}/Data/Text/Events")
      Dir.entries("#{$editor_window.project_directory}/Data").each do |e|
        next unless e[/Map(\d+)\.rvdata2/]
        k = $1.to_i
        mid = $1
        FileUtils.mkdir_p("#{$editor_window.project_directory}/Data/Text/" <<
                                                            "Events/Map #{mid}")
        map = nil
        File.open("#{$editor_window.project_directory}/Data/#{e}", 'r') do |f|
          map = Marshal.load(f)
        end
        map.events.each_value do |e|
          next unless e
          text = ''
          e.pages.each_with_index do |p,i|
            et = ''
            count = 0
            choice_count = 0
            scroll_count = 0
            scrolling_text = []
            text_ranges = []
            p.list.each_with_index do |c,ci|
              if c.code == 101
                text_ranges << ci
                count += 1
                et << "\n[Key] Map #{k} Event #{e.id} Page #{i + 1}" <<
                                                              " Text #{count}\n"
                unless c.parameters[0].empty?
                  et << "[Face] #{c.parameters[0]}, #{c.parameters[1]}\n"
                end
                et << "[Background] #{Backgrounds[c.parameters[2]]}\n"
                et << "[Position] #{Positions[c.parameters[3]]}\n"
              elsif c.code == 401 || c.code == 405
                et << "#{c.parameters[0]}\n"
              elsif c.code == 102
                choice_count += 1
                et << extract_choices(k, e.id, i, p.list, ci, choice_count,
                                                                           :map)
              elsif c.code == 404
                c.code = 412
              elsif c.code == 105
                scrolling_text << ci
                scroll_count += 1
                et << "\n[Key] Map #{k} Event #{e.id} Page #{i + 1}" <<
                                             " Scrolling Text #{scroll_count}\n"
              end
            end
            unless text_ranges.empty?
              offset = 0
              text_ranges.each_with_index do |r,ti|
                r -= offset
                p.list[r].code = 355
                p.list[r].parameters =
                 ["text('Map #{k} Event #{e.id} Page #{i + 1} Text #{ti + 1}')"]
                pi = r + 1
                while p.list[pi].code == 401
                  offset += 1
                  p.list.delete_at(pi)
                end
              end
            end
            unless scrolling_text.empty?
              offset = 0
              scrolling_text.each_with_index do |s,ti|
                s -= offset
                sp = p.list[s].parameters[0]
                nf = p.list[s].parameters[1]
                p.list[s].code = 355
                p.list[s].parameters = ["scrolling_text('Map #{k} " <<
                     "Event #{e.id} Page #{i + 1} Scrolling Text #{ti + 1}'," <<
                                                               " #{sp}, #{nf})"]
                pi = s + 1
                while p.list[pi].code == 405
                  offset += 1
                  p.list.delete_at(pi)
                end
              end
            end
            unless et.empty?
              text << "#-----------------------------\n"
              text << "# Page #{i + 1}\n"
              text << "#-----------------------------"
              text << et << "\n\n"
            end
          end
          unless text.empty?
            File.open("#{$editor_window.project_directory}/Data/Text/Events" <<
                                "/Map #{mid}/Event #{sprintf('%03d', e.id)} " <<
                                                 "- #{e.name}.txt", 'w+') do |f|
              f.write(text)
            end
            text = ''
          end
        end
        map_file = "#{$editor_window.project_directory}/Data/" <<
                                                   sprintf('Map%03d.rvdata2', k)
        File.open(map_file, 'w+') do |f|
          Marshal.dump(map, f)
        end
      end
    end
    
    # Extracts item text from the Database.
    #
    # @return [void]
    def self.extract_item_text
      text = ''
      Data_Items.each_with_index do |i|
        next unless i
        text << "#-----------------------------\n"
        text << "# Items #{i.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::Item'].each do |m|
          text << "[Key] Item_#{i.id}_#{m}\n#{i.send(m)}\n\n"
        end
        text << "\n"
      end
      File.open(
             "#{$editor_window.project_directory}/Data/Text/Database/Items.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts map text.
    #
    # @return [void]
    def self.extract_map_text
      text = ''
      Data_Maps.each_with_index do |m|
        next unless m
        text << "#-----------------------------\n"
        text << "# Map #{m.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::Map'].each do |me|
          text << "[Key] Map_#{m.id}_#{me}\n#{m.send(me)}\n\n"
        end
        text << "\n"
      end
      File.open(
              "#{$editor_window.project_directory}/Data/Text/Database/Maps.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts skill text from the Database.
    #
    # @return [void]
    def self.extract_skill_text
      text = ''
      Data_Skills.each_with_index do |s|
        next unless s
        text << "#-----------------------------\n"
        text << "# Skill #{s.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::Skill'].each do |m|
          text << "[Key] Skill_#{s.id}_#{m}\n#{s.send(m)}\n\n"
        end
        text << "\n"
      end
      File.open(
            "#{$editor_window.project_directory}/Data/Text/Database/Skills.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts state text from the Database.
    #
    # @return [void]
    def self.extract_state_text
      text = ''
      Data_States.each_with_index do |s|
        next unless s
        text << "#-----------------------------\n"
        text << "# State #{s.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::State'].each do |m|
          text << "[Key] State_#{s.id}_#{m}\n#{s.send(m)}\n\n"
        end
        text << "\n"
      end
      File.open(
            "#{$editor_window.project_directory}/Data/Text/Database/States.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts system text.
    #
    # @return [void]
    def self.extract_system_text
      text = ''
      system = nil
      File.open(
               "#{$editor_window.project_directory}/Data/System.rvdata2") do |f|
        system = Marshal.load(f)
      end
      text << "[Key]System_Level\n#{system.terms.basic[0]}\n"
      text << "\n[Key] System_Level_short\n#{system.terms.basic[1]}\n"
      text << "\n[Key] System_HP\n#{system.terms.basic[2]}\n"
      text << "\n[Key] System_HP_short\n#{system.terms.basic[3]}\n"
      text << "\n[Key] System_MP\n#{system.terms.basic[4]}\n"
      text << "\n[Key] System_MP_short\n#{system.terms.basic[5]}\n"
      text << "\n[Key] System_TP\n#{system.terms.basic[6]}\n"
      text << "\n[Key] System_TP_short\n#{system.terms.basic[7]}\n"
      text << "\n[Key] System_MHP\n#{system.terms.params[0]}\n"
      text << "\n[Key] System_MMP\n#{system.terms.params[1]}\n"
      text << "\n[Key] System_ATK\n#{system.terms.params[2]}\n"
      text << "\n[Key] System_DEF\n#{system.terms.params[3]}\n"
      text << "\n[Key] System_MAT\n#{system.terms.params[4]}\n"
      text << "\n[Key] System_MDF\n#{system.terms.params[5]}\n"
      text << "\n[Key] System_AGI\n#{system.terms.params[6]}\n"
      text << "\n[Key] System_LUK\n#{system.terms.params[7]}\n"
      text << "\n[Key] System_etype_0\n#{system.terms.etypes[0]}\n"
      text << "\n[Key] System_etype_1\n#{system.terms.etypes[1]}\n"
      text << "\n[Key] System_etype_2\n#{system.terms.etypes[2]}\n"
      text << "\n[Key] System_etype_3\n#{system.terms.etypes[3]}\n"
      text << "\n[Key] System_etype_4\n#{system.terms.etypes[4]}\n"
      text << "\n[Key] System_Fight\n#{system.terms.commands[0]}\n"
      text << "\n[Key] System_Escape\n#{system.terms.commands[1]}\n"
      text << "\n[Key] System_Attack\n#{system.terms.commands[2]}\n"
      text << "\n[Key] System_Defend\n#{system.terms.commands[3]}\n"
      text << "\n[Key] System_Item\n#{system.terms.commands[4]}\n"
      text << "\n[Key] System_Skill\n#{system.terms.commands[5]}\n"
      text << "\n[Key] System_Equip\n#{system.terms.commands[6]}\n"
      text << "\n[Key] System_Status\n#{system.terms.commands[7]}\n"
      text << "\n[Key] System_Sort\n#{system.terms.commands[8]}\n"
      text << "\n[Key] System_Save\n#{system.terms.commands[9]}\n"
      text << "\n[Key] System_Exit_Game\n#{system.terms.commands[10]}\n"
      text << "\n[Key]System_(not_used)\n#{system.terms.commands[11]}\n"
      text << "\n[Key] System_Weapon\n#{system.terms.commands[12]}\n"
      text << "\n[Key] System_Armor\n#{system.terms.commands[13]}\n"
      text << "\n[Key] System_Key_Item\n#{system.terms.commands[14]}\n"
      text << "\n[Key] System_Change_Equipment\n#{system.terms.commands[15]}\n"
      text << "\n[Key] System_Ultimate_Equipment\n#{system.terms.commands[16]}\n"
      text << "\n[Key] System_Remove_All\n#{system.terms.commands[17]}\n"
      text << "\n[Key] System_New_Game\n#{system.terms.commands[18]}\n"
      text << "\n[Key] System_Continue\n#{system.terms.commands[19]}\n"
      text << "\n[Key] System_Shut_Down\n#{system.terms.commands[20]}\n"
      text << "\n[Key] System_Go_to_Title\n#{system.terms.commands[21]}\n"
      text << "\n[Key] System_Cancel\n#{system.terms.commands[22]}"
      File.open("#{$editor_window.project_directory}/Data/Text/System.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts game text.
    #
    # @param database [Boolean] whether or not to extract database text
    # @param troop [Boolean] whether or not to extract troop page text
    # @param common_event [Boolean] whether or not to extract common event text
    # @param event [Boolean] whether or not to extract event text
    # @param system [Boolean] whether or not to extract system text
    # @param vocab [Boolean] whether or not to extract vocabulary text
    # @return [void]
    def self.extract_text(database, troop, common_event, event, system, vocab)
      $saving = true
      if database
        FileUtils.mkdir_p(
                       "#{$editor_window.project_directory}/Data/Text/Database")
        extract_actor_text
        extract_armor_text
        extract_class_text
        extract_enemy_text
        extract_item_text
        extract_map_text
        extract_skill_text
        extract_state_text
        extract_weapon_text
      end
      extract_troop_text if troop
      extract_common_event_text if common_event
      extract_event_text if event
      extract_system_text if system
      extract_vocab_text if vocab
      $saving = false
    end
    
    # Extracts text from troop event pages and replaces it with External Text
    # calls.
    #
    # @return [void]
    def self.extract_troop_text
      FileUtils.mkdir_p("#{$editor_window.project_directory}/Data/Text/Troops")
      troops = nil
      edit = false
      File.open("#{$editor_window.project_directory}/Data/Troops.rvdata2",
                                                                    'r+') do |f|
        troops = Marshal.load(f)
      end
      troops.each do |t|
        next unless t
        text = ''
        t.pages.each_with_index do |p,i|
          count = 0
          choice_count = 0
          scroll_count = 0
          et = ''
          scrolling_text = []
          text_ranges = []
          p.list.each_with_index do |c,ci|
            if c.code == 101
              edit = true
              text_ranges << ci
              count += 1
              et << "\n[Key] Troop #{t.id} Page #{i + 1} Text #{count}"
              unless c.parameters[0].empty?
                et << "[Face] #{c.parameters[0]}, #{c.parameters[1]}\n"
              end
              et << "[Background] #{Backgrounds[c.parameters[2]]}\n"
              et << "[Position] #{Positions[c.parameters[3]]}\n"
            elsif c.code == 401 || c.code == 405
              et << "#{c.parameters[0]}\n"
            elsif c.code == 102
              choice_count += 1
              et << extract_choices(-1, t.id, i, p.list, ci, choice_count,
                                                                         :troop)
            elsif c.code == 404
              c.code = 412
            elsif c.code == 105
              scrolling_text << ci
              scroll_count += 1
              et << "\n[Key] Troop #{t.id} Page #{i + 1}" <<
                                           " Scrolling Text #{scroll_count}\n"
            end
          end
          unless text_ranges.empty?
            offset = 0
            text_ranges.each_with_index do |r,ti|
              r -= offset
              p.list[r].code = 355
              p.list[r].parameters =
                          ["text('Troop #{t.id} Page #{i + 1} Text #{ti + 1}')"]
              pi = r + 1
              while p.list[pi].code == 401
                offset += 1
                p.list.delete_at(pi)
              end
            end
          end
          unless scrolling_text.empty?
            offset = 0
            scrolling_text.each_with_index do |s,ti|
              s -= offset
              sp = p.list[s].parameters[0]
              nf = p.list[s].parameters[1]
              p.list[s].code = 355
              p.list[s].parameters = ["scrolling_text('Troop #{t.id} " <<
                       "Page #{i + 1} Scrolling Text #{ti + 1}', #{sp}, #{nf})"]
              pi = s + 1
              while p.list[pi].code == 405
                offset += 1
                p.list.delete_at(pi)
              end
            end
          end
          unless et.empty?
            text << "#-----------------------------\n"
            text << "# Page #{i + 1}\n"
            text << "#-----------------------------"
            text << et << "\n\n"
          end
        end
        unless text.empty?
          File.open("#{$editor_window.project_directory}/Data/Text/Troops/" <<
                  "Troop #{sprintf('%03d', t.id)} - #{t.name}.txt", 'w+') do |f|
            f.write(text)
          end
        end
      end
      if edit
        File.open("#{$editor_window.project_directory}/Data/Troops.rvdata2",
                                                                    'w+') do |f|
          Marshal.dump(troops, f)
        end
      end
    end
    
    # Extracts vocabulary text from the game's scripts.
    #
    # @return [void]
    def self.extract_vocab_text
      vocab = {}
      text = ''
      scripts = nil
      File.open(
        "#{$editor_window.project_directory}/Data/Scripts.rvdata2", 'r+') do |f|
        scripts = Marshal.load(f)
      end
      scripts.each do |script|
        script = Zlib::Inflate.inflate(script[2])
        next unless (script = script[/^module Vocab[\r\n+](.+?)^end/m, 1])
        script.split(/[\r\n]+/).each do |line|
          next unless line[/(\w+)\s*=\s*(["'])(.+[^\\])\2/]
          vocab[$1] = $3
        end
      end
      vocab.each_pair { |k,v| text << "\n[Key] Vocab_#{k}\n#{v}\n" }
      text.strip!
      File.open(
         "#{$editor_window.project_directory}/Data/Text/Vocab.txt", 'w+') do |f|
        f.write(text)
      end
    end
    
    # Extracts weapon text from the Database.
    #
    # @return [void]
    def self.extract_weapon_text
      text = ''
      Data_Armors.each_with_index do |w|
        next unless w
        text << "#-----------------------------\n"
        text << "# Weapon #{w.id}\n"
        text << "#-----------------------------\n"
        Override['RPG::Weapon'].each do |m|
          text << "[Key] Weapon_#{w.id}_#{m}\n#{w.send(m)}\n\n"
        end
        text << "\n"
      end
      File.open(
           "#{$editor_window.project_directory}/Data/Text/Database/Weapons.txt",
                                                                    'w+') do |f|
        f.write(text)
      end
    end
  end
end

java_import java.awt.event.ActionListener
java_import javax.swing.JMenuItem

# DemiurgeWindow
# -----------------------------------------------------------------------------
# The main frame of the program. Contains all of Demiurge's other GUI objects
# and manages saving/loading.
class DemiurgeWindow < com.github.sesvxace.demiurge.MainWindow
  
  # Adds the extraction option to the Tools menu.
  #
  # @return [void]
  def add_extraction_menu_item
    unless @menu_item_extract_text
      @menu_item_extract_text = JMenuItem.new('Extract Text for External Text')
      @menu_item_extract_text.add_action_listener(ActionListener.impl {
        @external_text_extraction_buttons.each { |b| b.selected = false }
        d = @external_text_extraction_dialog.create_dialog(self, 'Extract Text')
        d.visible = true
        if @external_text_extraction_dialog.value
          if @external_text_extraction_buttons[1..3].any? { |b| b.selected }
            JOptionPane.show_message_dialog(self, 'Please make sure to close' <<
                              ' the RPG Maker VX Ace editor before proceeding.',
                                  'Text Extraction', JOptionPane::PLAIN_MESSAGE)
          end
          SES::ExternalText.extract_text(*@external_text_extraction_buttons
                                                    .collect { |b| b.selected })
        end
      })
    end
    tool_menu.add(@menu_item_extract_text)
  end
  
  # Creates the dialogs used for extracting text via External Text.
  #
  # @return [void]
  def create_external_text_extraction_dialog
    return if @external_text_extraction_dialog
    @external_text_extraction_dialog = JOptionPane.new
    @external_text_extraction_dialog.message = 'Select the text that you ' <<
                                                        'would like to extract.'
    panel = JPanel.new(GridBagLayout.new)
    c = GridBagConstraints.new
    c.gridx = 0
    c.gridy = 0
    c.anchor = GridBagConstraints::CENTER
    c.fill = GridBagConstraints::BOTH
    c.gridheight = 1
    c.weightx = 1
    c.weighty = 1
    @external_text_extraction_buttons = []
    ['Database', 'Troops', 'Common Events', 'Events', 'System',
                                                       'Vocabulary'].each do |t|
      b = JCheckBox.new(t)
      panel.add(b, c)
      @external_text_extraction_buttons << b
      c.gridy += 1
    end
    @external_text_extraction_dialog.add(panel)
  end
  
  # Sets up the plugin.
  #
  # @return [void]
  def setup_external_text_extractor
    create_external_text_extraction_dialog
    add_extraction_menu_item
  end
  
  unless method_defined?(:en_ete_dw_up)
    alias_method :en_ete_dw_up, :unload_plugins
  end
  # Aliased to remove the extraction option from projects that do not use the
  # plugin.
  #
  # @return [void]
  def unload_plugins
    en_ete_dw_up
    tool_menu.remove(@menu_item_extract_text)
  end
end

# Table
# -----------------------------------------------------------------------------
# Three-dimensional table class provided by RGSS3. Required to save and load
# map data.
class Table
  private
  def self._load(array)
    self.new.instance_eval do
      @size, @xsize, @ysize, @zsize, _, *@data = array.unpack('LLLLLS*')
      self
    end
  end
  
  def _dump(depth = 0)
    [@size, @xsize, @ysize, @zsize, (@xsize * @ysize * @zsize),
      *@data].pack('LLLLLS*')
  end
end

$editor_window.setup_external_text_extractor
