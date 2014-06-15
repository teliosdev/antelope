module Antelope
  module Ace
    class Grammar
      module Terminals

        def terminals
          @_terminals ||= begin
            @compiler.options.fetch(:terminals, []).map do |v|
              Token::Terminal.new(*v)
            end
          end
        end

        def nonterminals
          @_nonterminals ||= productions.keys
        end

        def symbols
          @_symbols ||= terminals + nonterminals
        end
      end
    end
  end
end
