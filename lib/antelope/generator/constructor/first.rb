module Antelope
  module Generator
    class Constructor
      module First

        def initialize
          @firstifying = []
          super
        end

        def first(token)
          case token
          when Parser::Nonterminal
            firstifying(token) do
              productions = parser.productions[token.value]
              productions.map { |prod|
                first(prod[:items]) }.inject(Set.new, :+)
            end
          when Array
            first_array(token)
          when Parser::Epsilon
            Set.new
          when Parser::Terminal
            Set.new([token])
          else
            incorrect_argument! token, Parser::Nonterminal, Array,
              Parser::Epsilon, Parser::Terminal
          end
        end

        private

        def first_array(token)
          token.dup.delete_if { |tok| @firstifying.include?(tok) }.
          each_with_index.take_while do |tok, i|
            if i.zero?
              true
            else
              nullable?(token[i - 1])
            end
          end.map(&:first).map { |tok| first(tok) }.inject(Set.new, :+)
        end

        def firstifying(tok)
          @firstifying << tok
          out = yield
          @firstifying.delete tok
          out
        end
      end
    end
  end
end
