# encoding: utf-8

module Antelope
  module Ace
    class Scanner

      # Scans the second part of the file.  The second part of the
      # file _only_ contains productions (or rules).  Rules have a
      # label and a body; the label may be any lowercase alphabetical
      # identifier followed by a colon; the body consists of "parts",
      # an "or", a "prec", and/or a "block".  The part may consist
      # of any alphabetical characters.  An or is just a vertical bar
      # (`|`).  A prec is a precedence declaraction, which is `%prec `
      # followed by any alphabetical characters.  A block is a `{`,
      # followed by code, followed by a terminating `}`.  Rules _may_
      # be terminated by a semicolon, but this is optional.
      module Second

        # Scans the second part of the file.  This should be from just
        # before the first content boundry; if the scanner doesn't
        # find a content boundry, it will error.  It will then check
        # for a rule.
        #
        # @raise [SyntaxError] if no content boundry was found, or if
        #   the scanner encounters anything but a rule or whitespace.
        # @return [void]
        # @see #scan_second_rule
        # @see #scan_whitespace
        # @see #error!
        def scan_second_part
          scanner.scan(CONTENT_BOUNDRY) or error!
          tokens << [:second]

          until @scanner.check(CONTENT_BOUNDRY)
            scan_second_rule || scan_whitespace || error!
          end
        end

        # Scans a rule.  A rule consists of a label (the nonterminal
        # the production is for), a body, and a block; and then,
        # an optional semicolon.
        #
        # @return [Boolean] if it matched
        # @see #scan_second_rule_label
        # @see #scan_second_rule_body
        # @see #error!
        def scan_second_rule
          if @scanner.check(/(#{IDENTIFIER})(\[#{IDENTIFIER}\])?:/)
            scan_second_rule_label or error!
            scan_second_rule_body
            true
          end
        end

        # Scans the label for a rule.  It should contain only lower
        # case letters and a colon.
        #
        # @return [Boolean] if it matched.
        def scan_second_rule_label
          if @scanner.scan(/(#{IDENTIFIER})(?:\[(#{IDENTIFIER})\])?: ?/)
            tokens << [:label, @scanner[1], @scanner[2]]
          end
        end

        # The body can contain parts, ors, precs, or blocks (or
        # whitespaces).  Scans all of them, and then attempts to
        # scan a semicolon.
        #
        # @return [void]
        # @see #scan_second_rule_part
        # @see #scan_second_rule_or
        # @see #scan_second_rule_prec
        # @see #scan_second_rule_block
        # @see #scan_whitespace
        def scan_second_rule_body
          body = true
          while body
            scan_second_rule_prec || scan_second_rule_part ||
            scan_second_rule_or ||  scan_second_rule_block ||
            scan_whitespace || (body = false)
          end
          @scanner.scan(/;/)
        end

        # Attempts to scan a "part".  A part is any series of
        # alphabetical characters that are not followed by a
        # colon.
        #
        # @return [Boolean] if it matched.
        def scan_second_rule_part
          if @scanner.scan(/(%?#{IDENTIFIER})(?:\[(#{IDENTIFIER})\])?(?!\:|[A-Za-z._])/)
            tokens << [:part, @scanner[1], @scanner[2]]
          end
        end

        # Attempts to scan an "or".  It's just a vertical bar.
        #
        # @return [Boolean] if it matched.
        def scan_second_rule_or
          if @scanner.scan(/\|/)
            tokens << [:or]
          end
        end

        # Attempts to scan a precedence definition.  A precedence
        # definition is "%prec " followed by a terminal or nonterminal.
        #
        # @return [Boolean] if it matched.
        def scan_second_rule_prec
          if @scanner.scan(/%prec (#{IDENTIFIER})/)
            tokens << [:prec, @scanner[1]]
          end
        end

        # Attempts to scan a block.  This correctly balances brackets;
        # however, if a bracket is opened/closed within a string, it
        # still counts that as a bracket that needs to be balanced.
        # So, having extensive code within a block is not a good idea.
        #
        # @return [Boolean] if it matched.
        def scan_second_rule_block
          if @scanner.scan(/\{/)
            tokens << [:block, _scan_block]
          end
        end

        private

        # Scans the block; it scans until it encounters enough closing
        # brackets to match the opening brackets.  If it encounters
        # an opening brackets, it increments the bracket counter by
        # one; if it encounters a closing bracket, it decrements by
        # one.  It will error if it reaches the end before the
        # brackets are fully closed.
        #
        # @return [String] the block's body.
        # @raise [SyntaxError] if it reaches the end before the final
        #   bracket is closed.
        def _scan_block
          brack = 1
          body = "{"
          scan_for = %r{
            (
              (?: " ( \\\\ | \\" | [^"] )* "? )
            | (?: ' ( \\\\ | \\' | [^'] )* '? )
            | (?: // .*? \n )
            | (?: \# .*? \n )
            | (?: /\* [\s\S]+? \*/ )
            | (?: \} )
            | (?: \{ )
            )
          }x

          until brack.zero?
            if part = @scanner.scan_until(scan_for)
              body << part


              if @scanner[1] == "}"
                brack -= 1
              elsif @scanner[1] == "{"
                brack += 1
              end
            else
              if @scanner.scan(/(.+)/m)
                @line += @scanner[1].count("\n")
              end
              error!
            end
          end

          body
        end
      end
    end
  end
end
