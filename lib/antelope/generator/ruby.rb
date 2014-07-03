# encoding: utf-8

require "pp"

module Antelope
  module Generator

    # Generates a ruby parser.
    class Ruby < Base

      register_as "ruby", "rubby"

      # Creates an action table for the parser.
      #
      # @return [String]
      def generate_action_table
        out = ""
        PP.pp(table, out)
        out
      end

      # Outputs an array of all of the productions.
      #
      # @return [String]
      def generate_productions_list
        out = "["

        productions.each do |(label, size, block)|
          out                   <<
            "["                 <<
            label.name.inspect  <<
            ", "                <<
            size.inspect        <<
            ", "

          block = if block.empty?
            "proc { |_| _ }"
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
        template "ruby.erb", "#{file}.rb" do |body|
          sprintf(grammar.compiler.body, :write => body)
        end
      end
    end
  end
end
