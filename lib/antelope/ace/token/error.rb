# encoding: utf-8

module Antelope
  module Ace
    class Token

      # Defines an error token.  This may be used internally by the
      # parser when it enters panic mode; any tokens following this
      # are the synchronisation tokens.  This is considered a terminal
      # for the purposes of rule definitions.
      class Error < Terminal

        # Initialize the error token.  Technically takes no arguments.
        # Sets the name to be `:$error`.
        def initialize(*)
          super :$error
        end

        # (see Token#error?)
        def error?
          true
        end
      end
    end
  end
end
