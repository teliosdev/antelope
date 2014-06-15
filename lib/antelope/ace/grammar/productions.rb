module Antelope
  module Ace
    class Grammar
      module Productions
        def productions
          @_productions || generate_productions
        end

        def all_productions
          productions.values.flatten.sort_by(&:id)
        end

        def generate_productions
          @_productions = Hash.new { |h, k| h[k] = [] }
          @compiler.rules.each do |rule|
            productions[rule[:label]] = []
          end.each_with_index do |rule, id|
            left  = rule[:label]
            items = rule[:set].map { |_| find_token(_) }
            prec  = unless rule[:prec].empty?
              find_token(rule[:prec])
            else
              items.select(&:terminal?).last
            end
            prec  = presidence_for(prec)

            productions[rule[:label]] <<
              Production.new(Token::Nonterminal.new(left), items,
                             rule[:block], prec, id + 1)
          end

          productions[:$start] = [
            Production.new(Token::Nonterminal.new(:$start), [
                Token::Nonterminal.new(@compiler.rules.first[:label]),
                Token::Terminal.new(:"$")
              ], "", presidence.last, 0)
          ]

          productions
        end

        private

        def find_token(value)
          value = value.to_sym
          if productions.key?(value)
            Token::Nonterminal.new(value)
          elsif terminal = terminals.
              find { |term| term.name == value }
            terminal
          elsif value == :error
            Token::Error.new
          elsif [:nothing, :ε].include?(value)
            Token::Epsilon.new
          else
            raise UndefinedTokenError, "Could not find a token named #{value.inspect}"
          end
        end
      end
    end
  end
end
