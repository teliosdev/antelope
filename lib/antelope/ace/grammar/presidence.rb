require "set"

module Antelope
  module Ace
    class Grammar

      # Manages presidence for tokens.
      module Presidence

        # Accesses the generated presidence list.  Lazily generates
        # the presidence rules on the go, and then caches it.
        #
        # @return [Array<Ace::Presidence>]
        def presidence
          @_presidence ||= generate_presidence
        end

        # Finds a presidence rule for a given token.  If no direct
        # rule is defined for that token, it will check for a rule
        # defined for the special symbol, `:_`.  By default, there
        # is always a rule defined for `:_`.
        #
        # @param token [Ace::Token, Symbol]
        # @return [Ace::Presidence]
        def presidence_for(token)
          token = token.name if token.is_a?(Token)

          set = Set.new([token, :_])

          presidence.
            select { |pr| set.intersect?(pr.tokens) }.
            first
        end

        private

        # Generates the presidence rules.  Loops through the compiler
        # given presidence settings, and then adds two default
        # presidence rules; one for `:$` (level 0, nonassoc), and one
        # for `:_` (level 1, nonassoc).
        #
        # @return [Array<Ace::Presidence>]
        def generate_presidence
          size = @compiler.options[:prec].size + 1
          presidence = @compiler.options[:prec].
            each_with_index.map do |prec, i|
            Ace::Presidence.new(prec[0], prec[1..-1].to_set, size - i)
          end

          presidence <<
            Ace::Presidence.new(:nonassoc, [:"$"].to_set, 0) <<
            Ace::Presidence.new(:nonassoc, [:_].to_set, 1)
          presidence.sort_by { |_| _.level }.reverse
        end

      end
    end
  end
end
