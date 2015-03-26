# encoding: utf-8

module Antelope
  class Grammar

    # Manages a list of the symbols in the grammar.
    module Symbols

      # A list of all terminals in the grammar.  Checks the compiler
      # options for terminals, and then returns an array of
      # terminals.  Caches the result.
      #
      # @return [Array<Token::Terminal>]
      def terminals
        @_terminals ||= begin
          @compiler.options.fetch(:terminals) { [] }.map do |v|
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

      # A list of all nonterminals, with types.
      #
      # @return [Array<Token::Nonterminal>>]
      def typed_nonterminals
        @_typed_nonterminals ||= begin
          typed = []
          compiler.options[:nonterminals].each do |data|
            data[1].each do |nonterm|
              typed << Token::Nonterminal.new(nonterm, data[0])
            end
          end
          typed
        end
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

      # Checks to see if the grammar uses the `error` terminal
      # anywhere.
      #
      # @return [Boolean]
      def contains_error_token?
        all_productions.any? { |_| _.items.any?(&:error?) }
      end
    end
  end
end
