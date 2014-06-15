module Antelope
  module Ace
    class Token

      # Defines a nonterminal token.
      class Nonterminal < Token

        # (see Token#nonterminal?)
        def nonterminal?
          true
        end
      end
    end
  end
end
