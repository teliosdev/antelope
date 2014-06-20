# encoding: utf-8

module Antelope
  module Ace
    class Scanner

      # Scans the third part.  Everything after the content
      # boundry is copied directly into the output.
      module Third

        # Scans the third part.  It should start with a content
        # boundry; raises an error if it does not.  It then scans
        # until the end of the file.
        #
        # @raise [SyntaxError] if somehow there is no content
        #   boundry.
        # @return [void]
        def scan_third_part
          @scanner.scan(CONTENT_BOUNDRY) or error!

          tokens << [:third]
          tokens << [:copy, @scanner.scan(/[\s\S]+/m) || ""]
        end
      end
    end
  end
end
