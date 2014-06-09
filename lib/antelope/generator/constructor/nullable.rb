module Antelope
  class Generator
    class Constructor
      module Nullable

        def initialize
          @nullifying = []
        end

        def nullable?(token)
          case token
          when Parser::Nonterminal
            nullifying(token) do
              productions = parser.productions[token.value]
              !!productions.any? { |prod| nullable?(prod[:items]) }
            end
          when Array
            token.dup.delete_if { |tok|
              @nullifying.include?(tok) }.all? { |tok| nullable?(tok) }
          when Parser::Epsilon
            true
          when Parser::Terminal
            false
          else
            incorrect_argument! token, Parser::Nonterminal, Array,
              Parser::Epsilon, Parser::Terminal
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
