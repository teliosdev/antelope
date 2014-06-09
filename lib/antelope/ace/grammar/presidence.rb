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
          presidence = @compiler.options[:prec].
            each_with_index.map do |prec, i|
            Ace::Presidence.new(prec[0], prec[1..-1].to_set, i)
          end

          level = if presidence.any?
            presidence.last.level + 1
          else
            0
          end

          presidence << Ace::Presidence.new(:nonassoc,
                                            [:_].to_set, level)
          presidence.sort_by { |_| _.level }
        end

      end
    end
  end
end
