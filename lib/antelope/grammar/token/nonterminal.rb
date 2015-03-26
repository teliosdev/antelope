# encoding: utf-8

module Antelope
  class Grammar
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
