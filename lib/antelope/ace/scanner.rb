# encoding: utf-8

require "strscan"
require "antelope/ace/scanner/argument"
require "antelope/ace/scanner/first"
require "antelope/ace/scanner/second"
require "antelope/ace/scanner/third"

module Antelope
  module Ace

    # Scans a given input.  The input should be a properly formatted
    # ACE file; see the Ace module for more information.  This scanner
    # uses the StringScanner class internally; see the ruby
    # documentation for more on that.  This scanner seperates scanning
    # into three seperate stages: First, Second, and Third, for each
    # section of the file, respectively.
    #
    # @see Ace
    # @see http://ruby-doc.org/stdlib-2.1.2/libdoc/strscan/rdoc/StringScanner.html
    class Scanner

      IDENTIFIER = "[a-zA-Z_.][a-zA-Z0-9_.-]*"

      include First
      include Second
      include Third

      # The string scanner that we're using to scan the string with.
      #
      # @return [StringScanner]
      attr_reader :scanner

      # An array of the tokens that the scanner scanned.
      #
      # @return [Array<Array<(Symbol, Object, ...)>>]
      attr_reader :tokens

      # The boundry between each section.  Placed here to be easily.
      # modifiable. **MUST** be a regular expression.
      #
      # @return [RegExp]
      CONTENT_BOUNDRY = /%%/

      # The value regular expression.  It should match values; for
      # example, things quoted in strings or word letters without
      # quotes.  Must respond to #to_s, since it is embedded within
      # other regular expressions.  The regular expression should
      # place the contents of the value in the groups 2 or 3.
      #
      # @return [#to_s]
      VALUE = %q{(?:
                    (?:("|')((?:\\\\|\\"|\\'|.)+?)\\1)
                  | ([A-Za-z0-9_.<>*-]+)
                )}

      # Scans a file.  It returns the tokens resulting from scanning.
      #
      # @param source [String] the source to scan.  This should be
      #   compatible with StringScanner.
      # @param name [String] the name of the source file.  This is
      #   primarilyused in backtrace information.
      # @return [Array<Array<(Symbol, Object, ...)>>]
      # @see #tokens
      def self.scan(source, name = "(ace file)")
        new(source, name).scan_file
      end

      # Initialize the scanner with the input.
      #
      # @param input [String] The source to scan.
      # @param source [String] the source file.  This is primarily
      #   used in backtrace information.
      def initialize(input, source = "(ace file)")
        @source  = source
        @scanner = StringScanner.new(input)
        @tokens  = []
      end

      # Scans the file in parts.
      #
      # @raise [SyntaxError] if the source is malformed in some way.
      # @return [Array<Array<(Symbol, Object, ...)>>] the tokens that
      #   were scanned in this file.
      # @see #scan_first_part
      # @see #scan_second_part
      # @see #scan_third_part
      # @see #tokens
      def scan_file
        @line = 1
        scan_first_part
        scan_second_part
        scan_third_part
        tokens
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

      # Scans for whitespace.  If the next character is whitespace, it
      # will consume all whitespace until the next non-whitespace
      # character.
      #
      # @return [Boolean] if any whitespace was matched.
      def scan_whitespace
        if @scanner.scan(/(\s+)/)
          @line += @scanner[1].count("\n")
        end
      end

      private

      # Raises an error.
      #
      # @raise [SyntaxError] always.
      # @return [void]
      def error!
        raise SyntaxError, "invalid syntax"
      end
    end
  end
end
