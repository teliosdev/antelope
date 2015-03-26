# encoding: utf-8

require "pp"

module Antelope
  module Generator

    # Generates a ruby parser.
    class Ruby < Base

      register_as "ruby", "rubby"

      has_directive "panic-mode", Boolean
      has_directive "ruby.error-class", String

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
            "DEFAULT_PROC"
          else
            "proc #{block}"
          end

          out << block << "],\n"
        end

        out.chomp!(   ",\n")

        out << "]"
      end

      def define_own_handler?
        directives.ruby.error_class? or
          panic_mode?
      end

      def panic_mode?
        directives.panic_mode &&
          directives.ruby.error_class? &&
          grammar.contains_error_token?
      end

      def error_class
        directives.ruby.error_class
      end

      # Actually performs the generation.  Takes the template from
      # ruby.ant and outputs it to `<file>.rb`.
      #
      # @return [void]
      def generate
        template "ruby", "#{file}.rb" do |body|
          sprintf(grammar.compiler.body, write: body)
        end
      end
    end
  end
end
