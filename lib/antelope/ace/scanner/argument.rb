module Antelope
  module Ace
    class Scanner

      # Represents an argument to a directive.  It encapsulates a
      # string object, which is the value of the argument.
      class Argument < String

        # Initialize the argument.
        #
        # @param type [Symbol] the type of argument it is; it can be
        #   a `:block`, `:text`, or `:caret`.  The type is defined by
        #   the encapsulating characters.  If the encapsulating
        #   characters are `{` and `}`, it's a `:block`; if they are
        #   `<` and `>`, it's a `:caret`; otherwise, it's a `:text`.
        # @param value [String] the value of the argument.
        def initialize(type, value)
          @type = type
          super(value)
        end

        # If this argument is type `:block`.
        #
        # @return [Boolean]
        # @see type?
        def block?
          type? :block
        end

        # If this argument is type `:text`.
        #
        # @return [Boolean]
        # @see type?
        def text?
          type? :text
        end

        # If this argument is type `:caret`.
        #
        # @return [Boolean]
        # @see type?
        def caret?
          type? :caret
        end

        # Checks to see if any of the given arguments match the type
        # of this argument.
        #
        # @param inc [Array<Symbol>]
        # @return [Boolean]
        def type?(*inc)
          inc.include?(@type)
        end
      end
    end
  end
end
