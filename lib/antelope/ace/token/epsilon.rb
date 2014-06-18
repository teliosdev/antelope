module Antelope
  module Ace
    class Token

      # Defines an epsilon token.  An epsilon token represents
      # nothing.  This is used to say that a nonterminal can
      # reduce to nothing.
      class Epsilon < Token
        # Initialize.  Technically takes no arguments.  Sets
        # the name of the token to be `:$empty`.
        def initialize(*)
          super :"$empty"
        end

        # (see Token#epsilon?)
        def epsilon?
          true
        end
      end
    end
  end
end
