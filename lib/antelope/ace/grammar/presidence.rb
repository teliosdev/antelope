require "set"

module Antelope
  module Ace
    class Grammar
      module Presidence

        def presidence
          @_presidence ||= generate_presidence
        end

        def presidence_for(token)
          token = token.name if token.is_a?(Token)

          set = Set.new([token, :_])

          presidence.
            select { |pr| set.intersect?(pr.tokens) }.
            first
        end

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
