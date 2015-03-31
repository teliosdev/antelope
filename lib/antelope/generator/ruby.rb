# encoding: utf-8

require 'pp'

module Antelope
  module Generator
    # Generates a ruby parser.
    class Ruby < Base
      register_as 'ruby', 'rubby'

      has_directive 'output.panic-mode', Boolean
      has_directive 'ruby.error-class', String
      directive 'ruby.indent', Integer

      # Creates an action table for the parser.
      #
      # @return [String]
      def generate_action_table
        parts = []
        table.each do |state|
          out = ''
          state.each do |token, action|
            inspect = %(:"#{token}" =>)
            out << "#{basic_indent}#{inspect} #{action.inspect},\n"
          end
          parts << "{\n#{out.chomp(",\n")}\n}"
        end

        "[#{parts.join(', ')}]"
      end

      def indent
        basic_indent * (directives.ruby.indent || 2)
      end

      def basic_indent
        @_indent ||= case indent_type
                     when 'space'
                       ' '
                     when 'tab'
                       "\t"
                     else
                       indent_type
                     end * indent_size
      end

      def indent_type
        directives.ruby.indent_type || 'space'
      end

      def indent_size
        directives.ruby.indent_size ||
          case indent_type
          when 'tab'
            1
          else
            2
          end
      end

      # Outputs an array of all of the productions.
      #
      # @return [String]
      def generate_productions_list
        out = "[\n"

        productions.each do |(label, size, block)|
          out << '[' << label.name.inspect << ', ' <<
            size.inspect << ', '

          block = if block.empty?
                    'DEFAULT_PROC'
                  else
                    "proc { |match| #{block[1..-2]} }"
                  end

          out << block << "],\n"
        end
        out.chomp!(",\n")
        out << ']'
      end

      def define_own_handler?
        directives.ruby.error_class? ||
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
        template 'ruby', "#{file}.rb" do |body|
          body
            .gsub!("\n", "\n#{indent}")
            .gsub!(/^[ \t]*\n/, "\n")
          format(grammar.compiler.body, write: body)
        end
      end
    end
  end
end
