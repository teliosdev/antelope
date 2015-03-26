# encoding: utf-8

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

    # Primarily used in the {Compiler}, if a scanner token appears
    # that should not be in the current state, this is raised.
    class InvalidStateError < Error
    end

    # Primarily used in the {Compiler}, it is raised if it encounters
    # a directive it cannot handle.  This is more to warn the
    # developer that a directive they wrote may not be accepted by any
    # generator.
    class NoDirectiveError < Error
    end
  end
end
