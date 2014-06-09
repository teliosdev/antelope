module Antelope
  module Ace
    class Scanner
      module Third

        def scan_third_part
          @scanner.scan(CONTENT_BOUNDRY) or error!

          tokens << [:third]
          tokens << [:body, @scanner.scan(/[\s\S]+/m)]
        end
      end
    end
  end
end
