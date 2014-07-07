# encoding: utf-8

module Antelope
  module Ace
    class Scanner

      # Scans the first section of the file.  This contains directives and
      # small blocks that can be copied directly into the body of the output.
      # The blocks are formatted as `%{ ... %}`; however, the ending tag _must_
      # be on its own line.  The directive is formatted as `%<name> <value>`,
      # with `<name>` being the key, and `<value>` being the value.  The value
      # can be a piece of straight-up text (no quotes), or it can be quoted.
      # There can be any number of values to a directive.
      module First

        # Scans until the first content boundry.  If it encounters anything but
        # a block or a directive (or whitespace), it will raise an error.
        #
        # @raise [SyntaxError] if it encounters anything but whitespace, a
        #   block, or a directive.
        # @return [void]
        def scan_first_part
          until @scanner.check(CONTENT_BOUNDRY)
            scan_first_copy || scan_first_directive ||
            scan_whitespace || error!
          end
        end

        # Scans for a block.  It is called `copy` instead of `block` because
        # contents of the block is _copied_ directly into the body.
        #
        # @return [Boolean] if it matched.
        def scan_first_copy
          if @scanner.scan(/%{([\s\S]+?)\n\s*%}/)
            tokens << [:copy, @scanner[1]]
          end
        end

        # Scans a directive.  A directive has one _name_, and any number of
        # arguments.  Every argument is a _value_.  The name can be any
        # combinations of alphabetical characters, underscores, and dashes;
        # the value can be word characters, or a quote-delimited string.
        # It emits a `:directive` token with the directive (Sring) as an
        # argument, and the passed arguments (Array<String>).
        #
        # @return [Boolean] if it matched.
        def scan_first_directive
          if @scanner.scan(/%([A-Za-z_.-]+) ?/)
            directive = @scanner[1]
            arguments = scan_first_directive_arguments

            tokens << [:directive, directive, arguments]
          end
        end

        def scan_first_directive_arguments
          arguments = []
          until @scanner.check(/\n/)
            if @scanner.scan(/\{/)
              arguments.push(
                Argument.new(:block, _scan_block[1..-2])
              )
            else
              @scanner.scan(/#{VALUE}/x) or error!
              arguments.push(
                Argument.new(:text, @scanner[2] || @scanner[3])
              )
              @scanner.scan(/ */)
            end
          end

          arguments
        end
      end
    end
  end
end
