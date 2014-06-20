# encoding: utf-8

module Antelope
  module Generation
    class Constructor

      # Contains the methods to construct first sets for tokens.
      module First

        # Initialize.
        def initialize
          @firstifying = []
          super
        end

        # Constructs the first set for a given token.  This is how
        # the method should behave:
        #
        #     FIRST(ε)  == []  # if ϵ is the epsilon token
        #     FIRST(x)  == [x] # if x is a terminal
        #     FIRST(αβ) == if nullable?(α)
        #       FIRST(α) U FIRST(β)
        #     else
        #       FIRST(α)
        #     end
        #     FIRST(A)  == FIRST(a_1) U FIRST(a_2) U ... U FIRST(a_n)
        #       # if A is a nonterminal and a_1, a_2, ..., a_3 are all
        #       # of the right-hand sides of its productions.
        #
        # @param token [Ace::Token, Array<Ace::Token>]
        # @return [Set<Ace::Token::Terminal>]
        # @see #first_array
        def first(token)
          case token
          when Ace::Token::Nonterminal
            firstifying(token) do
              productions = grammar.productions[token.name]
              productions.map { |prod|
                first(prod[:items]) }.inject(Set.new, :+)
            end
          when Array
            first_array(token)
          when Ace::Token::Epsilon
            Set.new
          when Ace::Token::Terminal
            Set.new([token])
          else
            incorrect_argument! token, Ace::Token, Array
          end
        end

        private

        # Determines the FIRST set of an array of tokens.  First, it
        # removes any terminals we are finding the FIRST set for;
        # then, it determines which tokens we have to find the FIRST
        # sets for (since some tokens may be nullable).  We then add
        # those sets to our set.
        #
        # @param tokens [Array<Ace::Token>]
        # @return [Set<Ace::Token>]
        def first_array(tokens)
          tokens.dup.delete_if { |_| @firstifying.include?(_) }.
          each_with_index.take_while do |token, i|
            if i.zero?
              true
            else
              nullable?(tokens[i - 1])
            end
          end.map(&:first).map { |_| first(_) }.inject(Set.new, :+)
        end

        # Helps keep track of the nonterminals we're finding FIRST
        # sets for. This helps prevent recursion.
        #
        # @param tok [Ace::Token::Nonterminal]
        # @yield once.
        # @return [Set<Ace::Token>]
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
