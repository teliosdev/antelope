module Antelope
  module Ace

    # Defines an error that can occur within the Ace module.  All
    # errors that are raised within the Ace module are subclasses of
    # this.
    class Error < Antelope::Error
    end

    # Used primarily in the {Scanner}, this is raised when an input
    # is malformed.  The message should contain a snippet of the input
    # which caused the error.
    class SyntaxError < Error
    end

    # This is used primarily in the {Grammar}; if a rule references a
    # token (a nonterminal or a terminal) that was not previously
    # defined, this is raised.
    class UndefinedTokenError < Error
    end

    # Pimarily used in the {Compiler}, if a scanner token appears that
    # should not be in the current state, this is raised.
    class InvalidStateError < Error
    end
  end
end
