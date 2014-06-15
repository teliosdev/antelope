module Antelope
  module Generation
    class Constructor
      module Nullable

        def initialize
          @nullifying = []
        end

        def nullable?(token)
          case token
          when Ace::Token::Nonterminal
            nullifying(token) do
              productions = parser.productions[token.name]
              !!productions.any? { |prod| nullable?(prod[:items]) }
            end
          when Array
            token.dup.delete_if { |tok|
              @nullifying.include?(tok) }.all? { |tok| nullable?(tok) }
          when Ace::Token::Epsilon
            true
          when Ace::Token::Terminal
            false
          else
            incorrect_argument! token, Ace::Token, Array
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
