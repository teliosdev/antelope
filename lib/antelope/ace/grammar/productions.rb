module Antelope
  module Ace
    class Grammar
      module Productions
        def productions
          @_productions || generate_productions
        end

        def generate_productions
          @_productions = Hash.new { |h, k| h[k] = [] }
          @compiler.rules.each do |rule|
            @_productions[rule[:label]] = []
          end.each do |rule|
            left  = rule[:label]
            items = rule[:set].map { |_| find_token(_) }
            prec  = unless rule[:prec].empty?
              find_token(rule[:prec])
            else
              items.select(&:terminal?).last
            end
            prec  = presidence_for(prec)

            @_productions[rule[:label]] << {
              items: items,
              block: rule[:block],
              pres:  prec
            }
          end

          @_productions[:"$start"] = [{
            items: [
              Nonterminal.new(@compiler.rules.first[:label]),
              Terminal.new(:"$")
            ], block: "", pres: presidence.last
          }]

          @_productions
        end

        private

        def find_token(value)
          value = value.to_sym
          if @_productions.key?(value)
            Nonterminal.new(value)
          elsif terminal = terminals.
              find { |term| term.name == value }
            terminal
          elsif value == :error
            Error.new
          elsif [:nothing, :ε].include?(value)
            Epsilon.new
          else
            raise UndefinedTokenError, "Could not find a token named #{value.inspect}"
          end
        end
      end
    end
  end
end
