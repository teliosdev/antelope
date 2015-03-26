# encoding: utf-8

module Antelope
  class Grammar
    class Token
      # Defines a terminal token.
      class Terminal < Token
        # (see Token#terminal?)
        def terminal?
          true
        end
      end
    end
  end
end
