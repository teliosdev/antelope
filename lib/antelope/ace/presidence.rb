module Antelope
  module Ace

    # Defines a presidence.  A presidence has a type, tokens, and a
    # level.
    class Presidence < Struct.new(:type, :tokens, :level)

      # @!attribute [rw] type
      #   The type of presidence level.  This should be one of
      #   `:left`, `:right`, or `:nonassoc`.
      #
      #   @return [Symbol] the type.
      # @!attribute [rw] tokens
      #   An set of tokens that are on this specific presidence
      #   level.  The tokens are identified as symbols.  The special
      #   symbol, `:_`, represents any token.
      #
      #   @return [Set<Symbol>] the tokens on this level.
      # @!attribute [rw] level
      #   The level we're on.  The higher the level, the higher the
      #   presidence.

      include Comparable

      # Compares the other object to this object.  If the other object
      # isn't a {Presidence}, it returns nil.  If the other
      # presidence isn't on the same level as this one, then the
      # levels are compared and the result of that is returned.  If
      # it is, however, the type is checked; if this presidence is
      # left associative, then it returns 1 (it is greater than the
      # other); if this presidence is right associative, then it
      # returns -1 (it is less than the other); if this presidence is
      # nonassociative, it returns 0 (it is equal to the other).
      #
      # @param other [Object] the object to compare to this one.
      # @return [Numeric?]
      def <=>(other)
        return nil unless other.is_a? Presidence
        if level != other.level
          level <=> other.level
        elsif type == :left
          1
        elsif type == :right
          -1
        else
          0
        end
      end
    end
  end
end
