module Antelope
  module Ace
    class Scanner
      module First
        def scan_first_part
          until @scanner.check(CONTENT_BOUNDRY)
            scan_first_copy || scan_first_directive ||
            scan_whitespace || error!
          end
        end

        def scan_first_copy
          if @scanner.scan(/%{([\s\S]+?)\n\s*%}/)
            tokens << [:copy, @scanner[1]]
          end
        end

        def scan_first_directive
          if @scanner.scan(/%([A-Za-z_-]+) ?/)
            directive = @scanner[1]
            arguments = []
            until @scanner.check(/\n/)
              @scanner.scan(/#{VALUE}/x) or error!
              arguments.push(@scanner[2] || @scanner[3])
              @scanner.scan(/ */)
            end

            tokens << [:directive, directive, arguments]
          end
        end

        def scan_whitespace
          @scanner.scan(/\s+/)
        end
      end
    end
  end
end
