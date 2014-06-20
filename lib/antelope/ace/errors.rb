# encoding: utf-8

module Antelope
  module Ace

    # Defines an error that can occur within the Ace module.  All
    # errors that are raised within the Ace module are subclasses of
    # this.
    class Error < Antelope::Error
    end

    # Used primarily in the {Compiler}, this is raised when the
    # version requirement of the Ace file doesn't match the running
    # version of Ace.
    class IncompatibleVersionError < Error
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

    # Primarily used in the {Compiler}, if a scanner token appears
    # that should not be in the current state, this is raised.
    class InvalidStateError < Error
    end

    # Primarily used in the {Grammar} (specifically
    # {Grammar::Generation}), if the grammar could not determine the
    # generator to use for the generation, it raises this.
    class NoTypeError < Error
    end
  end
end
