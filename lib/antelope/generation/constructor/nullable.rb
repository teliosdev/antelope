# encoding: utf-8

module Antelope
  module Generation
    class Constructor

      # Contains the methods to determine if an object is nullable.
      module Nullable

        # Initialize.
        def initialize
          @nullifying = Set.new
        end

        # Determine if a given token is nullable.  This is how the
        # method should behave:
        #
        #     nullable?(ϵ) == true  # if ϵ is the epsilon token
        #     nullable?(x) == false # if x is a terminal
        #     nullable?(αβ) == nullable?(α) && nullable?(β)
        #     nullable?(A) == nullable?(a_1) || nullable?(a_2) || ... nullable?(a_n)
        #       # if A is a nonterminal and a_1, a_2, ..., a_n are all
        #       # of the right-hand sides of its productions
        #
        # @param token [Grammar::Token, Array<Grammar::Token>] the token to
        #    check.
        # @return [Boolean] if the token can reduce to ϵ.
        def nullable?(token)
          case token
          when Grammar::Token::Nonterminal
            nullifying(token) do
              productions = grammar.productions[token.name]
              !!productions.any? { |prod| nullable?(prod[:items]) }
            end
          when Array
            token.dup.delete_if { |tok|
              @nullifying.include?(tok) }.all? { |tok| nullable?(tok) }
          when Grammar::Token::Epsilon
            true
          when Grammar::Token::Terminal
            false
          else
            incorrect_argument! token, Grammar::Token, Array
          end
        end

        private

        # Helps keep track of the nonterminals we're checking for
        # nullability.  This helps prevent recursion.
        #
        # @param tok [Grammar::Token::Nonterminal]
        # @yield once.
        # @return [Boolean]
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
