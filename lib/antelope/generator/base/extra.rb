module Antelope
  module Generator
    class Base
      # Includes some extra processed information about the grammar
      # to be provided to general generators.
      module Extra
        # The actual table that is used for parsing.  This returns an
        # array of hashes; the array index corresponds to the state
        # number, and the hash keys correspond to the lookahead tokens.
        # The hash values are an array; the first element of that array
        # is the action to be taken, and the second element of the
        # array is the argument for that action.  Possible actions
        # include `:accept`, `:reduce`, and `:state`; `:accept` means
        # to accept the string; `:reduce` means to perform the given
        # reduction; and `:state` means to transition to the given
        # state.
        #
        # @return [Array<Hash<Symbol => Array<(Symbol, Numeric)>>>]
        def table
          if mods[:tableizer].is_a? Generation::Tableizer
            mods[:tableizer].table
          else
            []
          end
        end

        # Returns an array of the production information of each
        # production needed by the parser.  The first element of any
        # element in the array is an {Ace::Token::Nonterminal} that
        # that specific production reduces to; the second element
        # is a number describing the number of items in the right hand
        # side of the production; the string represents the action
        # that should be taken on reduction.
        #
        # This information is used for `:reduce` actions in the parser;
        # the value of the `:reduce` action corresponds to the array
        # index of the production in this array.
        #
        # @return [Array<Array<(Ace::Token::Nonterminal, Numeric, String)>]
        def productions
          grammar.all_productions.map do |production|
            [production[:label],
             production[:items].size,
             production[:block]]
          end
        end
      end
    end
  end
end
