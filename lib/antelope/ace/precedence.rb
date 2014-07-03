# encoding: utf-8

module Antelope
  module Ace

    # Defines a precedence.  A precedence has a type, tokens, and a
    # level.
    class Precedence < Struct.new(:type, :tokens, :level)

      # @!attribute [rw] type
      #   The type of precedence level.  This should be one of
      #   `:left`, `:right`, or `:nonassoc`.
      #
      #   @return [Symbol] the type.
      # @!attribute [rw] tokens
      #   An set of tokens that are on this specific precedence
      #   level.  The tokens are identified as symbols.  The special
      #   symbol, `:_`, represents any token.
      #
      #   @return [Set<Symbol>] the tokens on this level.
      # @!attribute [rw] level
      #   The level we're on.  The higher the level, the higher the
      #   precedence.

      include Comparable

      # Compares the other object to this object.  If the other object
      # isn't a {Precedence}, it returns nil.  If the other
      # precedence isn't on the same level as this one, then the
      # levels are compared and the result of that is returned.  If
      # it is, however, the type is checked; if this precedence is
      # left associative, then it returns 1 (it is greater than the
      # other); if this precedence is right associative, then it
      # returns -1 (it is less than the other); if this precedence is
      # nonassociative, it returns 0 (it is equal to the other).
      #
      # @param other [Object] the object to compare to this one.
      # @return [Numeric?]
      def <=>(other)
        return nil unless other.is_a? Precedence
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

      def to_s
        "#{type.to_s[0]}#{level}"
      end
    end
  end
end
