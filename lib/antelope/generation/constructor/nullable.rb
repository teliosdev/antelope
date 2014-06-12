module Antelope
  module Generation
    class Constructor
      module Nullable

        def initialize
          @nullifying = []
        end

        def nullable?(token)
          case token
          when Ace::Nonterminal
            nullifying(token) do
              productions = parser.productions[token.name]
              !!productions.any? { |prod| nullable?(prod[:items]) }
            end
          when Array
            token.dup.delete_if { |tok|
              @nullifying.include?(tok) }.all? { |tok| nullable?(tok) }
          when Ace::Epsilon
            true
          when Ace::Terminal
            false
          else
            incorrect_argument! token, Ace::Nonterminal, Array,
              Ace::Epsilon, Ace::Terminal
          end
        end

        private

        def nullifying(tok)
          @nullifying << tok
          out = yield
          @nullifying.delete tok
          out
        end
      end
    end
  end
end
