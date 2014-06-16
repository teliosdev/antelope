module Antelope
  module Ace
    class Grammar

      # Manages a list of the terminals in the grammar.
      module Terminals

        # A list of all terminals in the grammar.  Checks the compiler
        # options for terminals, and then returns an array of
        # terminals.  Caches the result.
        #
        # @return [Array<Token::Terminal>]
        def terminals
          @_terminals ||= begin
            @compiler.options.fetch(:terminals, []).map do |v|
              Token::Terminal.new(*v)
            end
          end
        end

        # A list of all nonterminals in the grammar.
        #
        # @return [Array<Symbol>]
        # @see #productions
        def nonterminals
          @_nonterminals ||= productions.keys
        end

        # A list of all symbols in the grammar; includes both
        # terminals and nonterminals.
        #
        # @return [Array<Token::Terminal, Symbol>]
        # @see #terminals
        # @see #nonterminals
        def symbols
          @_symbols ||= terminals + nonterminals
        end
      end
    end
  end
end
