module Antelope
  class Template
    class Compiler

      attr_reader :buffer

      attr_reader :tokens

      def initialize(tokens, buffer_variable = "_out")
        @tokens = tokens.dup
        @buffer = ""
        @buffer_variable = buffer_variable
      end

      def compile
        merge_text_tokens

        @buffer = "\# encoding: utf-8\n#{@buffer_variable} ||= \"\"\n"

        until @tokens.empty?
          token = @tokens.shift
          parse_method = "parse_#{token[0]}".intern

          send(parse_method, token[1])
        end

        @buffer << "#{@buffer_variable}\n"

        @buffer

      rescue NoMethodError => e

        if e.name == parse_method
          raise NoTokenError, "No token #{token[0]} exists"
        else
          raise
        end
      end

      private

      def parse_text(value)
        buffer << "#{@buffer_variable} << #{value.to_s.inspect}\n"
      end

      def parse_tag(value)
        value.gsub!(/\A([\s\S]*?)\s*\Z/, "\\1")
        buffer << "#{value}\n"
      end

      def parse_output_tag(value)
        value.gsub!(/\A\s*([\s\S]*?)\s*\Z/, "\\1")
        buffer << "#{@buffer_variable} << begin\n  " \
          "#{value}\nend.to_s\n"
      end

      def parse_newline(_)
        parse_text("\n")
      end

      def parse_comment_tag(_)
      end

      def merge_text_tokens
        new_tokens = []
        @tokens.chunk(&:first).each do |type, tokens|
          if type == :text
            new_tokens << [:text, tokens.map(&:last).join('')]
          else
            new_tokens.push(*tokens)
          end
        end

        @tokens = new_tokens
      end
    end
  end
end
