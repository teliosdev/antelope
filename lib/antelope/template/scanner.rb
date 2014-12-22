require 'strscan'

module Antelope
  class Template
    class Scanner
      attr_reader :scanner

      attr_reader :tokens

      def initialize(input, source = "(template)")
        @scanner = StringScanner.new(input)
        @source  = source
        @tokens  = nil
        @line    = 1
      end

      def scan

        @tokens ||= begin
          @tokens = []
          @line   = 1
          @scanner.pos = 0
          until @scanner.eos?
            scan_tag || scan_until_tag || scan_until_end
          end

          @tokens
        end

      rescue SyntaxError => e
        start = [@scanner.pos - 8, 0].max
        stop  = [@scanner.pos + 8, @scanner.string.length].min
        snip  = @scanner.string[start..stop].inspect
        char  = @scanner.string[@scanner.pos]
        char = if char
          char.inspect
        else
          "EOF"
        end

        new_line = "#{@source}:#{@line}:#{@scanner.pos}: "\
          "unexpected #{char} (near #{snip})"

        raise e, e.message, [new_line, *e.backtrace]
      end

      private

      def scan_until_tag
        case
        when value = @scanner.scan_until(/(\%|\{|\}|\\|\n)/)
          @scanner.pos -= 1
          tokens << [:text, value[0..-2]]
        end
      end

      def scan_until_end
        tokens << [:text, @scanner.scan(/.+/m)]
      end

      def scan_tag
        case
        when @scanner.scan(/\\(\{\{|\}\}|\%)/)
          tokens << [:text, @scanner[1]]
        when @scanner.scan(/\n?\%\{/)
          update_line
          scan_tag_start(:output_tag, :_, /\}/)
        when @scanner.scan(/\n?\%/)
          update_line
          tokens << [:tag, value]
        when @scanner.scan(/\n?\{\{=/)
          update_line
          scan_tag_start(:output_tag)
        when @scanner.scan(/\n?\{\{!/)
          update_line
          scan_tag_start(:comment_tag)
        when @scanner.scan(/\n?\{\{/)
          update_line
          scan_tag_start(:tag)
        when @scanner.scan(/\}\}/)
          @scanner.pos -= 2
          error!
        when @scanner.scan(/\{|\}|\%|\\|\n/)
          tokens << [:text, @scanner[0]]
        else
          false
        end
      end

      def scan_tag_start(type, online = :_, ending = /\}\}/)
        if online == :_
          online = @scanner[0][0] == "\n"
        end

        value = @scanner.scan_until(ending) or error!
        tokens << [type, value[0..-(@scanner[0].length + 1)]]
      end

      def error!
        raise SyntaxError, "invalid syntax"
      end

      def update_line
        @line += @scanner[0].count("\n")
      end

    end
  end
end
