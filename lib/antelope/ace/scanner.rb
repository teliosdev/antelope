require "strscan"
require "antelope/ace/scanner/first"
require "antelope/ace/scanner/second"
require "antelope/ace/scanner/third"

module Antelope
  module Ace
    class Scanner

      include First
      include Second
      include Third

      attr_reader :scanner
      attr_reader :tokens

      CONTENT_BOUNDRY = /%%/
      VALUE = %{(?:
                    (?:("|')((?:\\"|\\'|.)+?)\\1)
                  | ([[:word:]]+)
                )}

      def self.scan(source)
        new(source).scan_file
      end

      def initialize(input)
        @scanner = StringScanner.new(input)
        @tokens  = []
      end

      def scan_file
        scan_first_part
        scan_second_part
        scan_third_part
        tokens
      end

      def error!
        start = [@scanner.pos - 8, 0].max
        stop  = [@scanner.pos + 8, @scanner.string.length].min
        snip  = @scanner.string[start..stop].strip
        char  = @scanner.string[@scanner.pos]
        p tokens
        raise SyntaxError, "invalid syntax near `#{snip.inspect}` (#{char.inspect})"
      end
    end
  end
end

__END__

The file comes in three parts:

[# First part]
[%%
# Second part]
[%%
# Third part]

the first part contains options for the compiler.
the second part contains rules for the compiler.
the thid part contains code for the compiler.
