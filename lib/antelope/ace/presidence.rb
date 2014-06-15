module Antelope
  module Ace

    # Defines a presidence.
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

      def <=>(other)
        return super unless other.is_a? Presidence
        if level != other.level
          level <=> other.level
        else
          if type == :left
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
end
