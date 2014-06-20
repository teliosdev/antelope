# encoding: utf-8

require "pp"

module Antelope
  class Generator

    # Generates a ruby parser.
    class Ruby < Generator

      # Creates an action table for the parser.
      #
      # @return [String]
      def generate_action_table
        out = ""
        PP.pp(mods[:tableizer].table, out)
        out
      end

      # Outputs an array of all of the productions.
      #
      # @return [String]
      def generate_productions_list
        out = "["

        grammar.all_productions.each do |production|
          out                              <<
            "["                            <<
            production.label.name.inspect  <<
            ", "                           <<
            production.items.size.inspect  <<
            ", "

          block = if production.block.empty?
            "proc {}"
          else
            "proc #{production.block}"
          end

          out << block << "],\n"
        end

        out.chomp!(",\n")

        out << "]"
      end

      # Actually performs the generation.  Takes the template from
      # ruby.erb and outputs it to `<file>_parser.rb`.
      #
      # @return [void]
      def generate
        template "ruby.erb", "#{file}_parser.rb" do |body|
          sprintf(grammar.compiler.body, :write => body)
        end
      end
    end
  end
end
