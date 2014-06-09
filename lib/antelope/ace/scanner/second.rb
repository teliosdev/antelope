module Antelope
  module Ace
    class Scanner
      module Second

        def scan_second_part
          scanner.scan(CONTENT_BOUNDRY) or error!
          tokens << [:second]

          until @scanner.check(CONTENT_BOUNDRY)
            scan_second_rule || scan_whitespace || error!
          end
        end

        def scan_second_rule
          if @scanner.check(/([a-z]+):/)
            scan_second_rule_label or error!
            scan_second_rule_body
            true
          end
        end

        def scan_second_rule_label
          if @scanner.scan(/([a-z]+): ?/)
            tokens << [:label, @scanner[1]]
          end
        end

        def scan_second_rule_body
          body = true
          while body
            scan_second_rule_part || scan_second_rule_or ||
            scan_second_rule_prec || scan_second_rule_block ||
            scan_whitespace || (body = false)
          end
          @scanner.scan(/;/)
        end

        def scan_second_rule_part
          if @scanner.scan(/([A-Za-z]+)(?!\:)/)
            tokens << [:part, @scanner[1]]
          end
        end

        def scan_second_rule_or
          if @scanner.scan(/\|/)
            tokens << [:or]
          end
        end

        def scan_second_rule_prec
          if @scanner.scan(/%prec ([A-Za-z]+)/)
            tokens << [:prec, @scanner[1]]
          end
        end

        def scan_second_rule_block
          if @scanner.scan(/\{/)
            tokens << [:block, _scan_block]
          end
        end

        def _scan_block
          brack = 1
          body = "{"

          until brack.zero?
            if part = @scanner.scan_until(/(\}|\{)/)
              body << part

              if @scanner[1] == "}"
                brack -= 1
              else
                brack += 1
              end
            else
              error!
            end
          end

          body
        end
      end
    end
  end
end
