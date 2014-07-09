require 'strscan'

module Antelope
  class Template
    class Scanner
      attr_reader :scanner

      attr_reader :tokens

      def initialize(input, source = "(template)")
        @scanner = StringScanner.new(input)
        @source  = source
        @tokens  = []
        @line    = 1
      end

      def scan
        @line = 1

        until @scanner.eos?
          scan_escaped || scan_tag || scan_ending || scan_text
        end

        @tokens

      rescue SyntaxError => e
        start = [@scanner.pos - 8, 0].max
        stop  = [@scanner.pos + 8, @scanner.string.length].min
        snip  = @scanner.string[start..stop].strip.inspect
        char  = @scanner.string[@scanner.pos]
        char = if char
          char.inspect
        else
          "EOF"
        end

        new_line = "#{@source}:#{@line}: unexpected #{char} " \
          "(near #{snip})"

        raise e, e.message, [new_line, *e.backtrace]
      end

      private

      def scan_escaped
        if @scanner.scan(/\{\{\{/)
          tokens << [:text, "{{"]
        elsif @scanner.scan(/\}\}\}/)
          tokens << [:text, "}}"]
        end
      end

      def scan_tag
        if @scanner.scan(/\{\{/)
          scan_tag_contents
        end
      end

      def scan_tag_contents
        type = scan_tag_type
        if value = @scanner.scan_until(/\}\}(?!\})/)
          tokens << [type, value[0..-3], @in_full_line]
          if @in_full_line
            @scanner.scan(/\n/) # discard
            @in_full_line = !!@scanner.check(/\{\{(?!\{)/)
          end

          true
        else
          error!
        end
      end

      def scan_tag_type
        case
        when @scanner.scan(/\=/)
          :output_tag
        when @scanner.scan(/\!/)
          :comment_tag
        else
          :tag
        end
      end

      def scan_ending
        if @scanner.scan(/\}\}/)
          error!
        end
      end

      def scan_text
        if value = scan_until_brace
          tokens << [:text, value]
        else
          scan_everything
        end
      end

      def scan_until_brace
        if value = @scanner.scan_until(/\n?\{\{|\}\}/)
          @line += value.count("\n")

          if @scanner[0].length == 3
            @in_full_line = true
          end

          @scanner.pos -= 2
          value[0..-3]
        end
      end

      def scan_everything
        if value = @scanner.scan(/.+/m)
          tokens << [:text, value]
        end
      end

      def error!
        raise SyntaxError, "invalid syntax"
      end

    end
  end
end
