# encoding: utf-8

module Antelope
  # Every error in antelope inherits this error class.
  class Error < StandardError
  end

  # This is used primarily in the {Grammar}; if a rule references a
  # token (a nonterminal or a terminal) that was not previously
  # defined, this is raised.
  class UndefinedTokenError < Error
  end

  # Used primarily in the {Compiler}, this is raised when the
  # version requirement of the Ace file doesn't match the running
  # version of Ace.
  class IncompatibleVersionError < Error
  end

  # Primarily used in the {Grammar} (specifically
  # {Grammar::Generation}), if the grammar could not determine the
  # generator to use for the generation, it raises this.
  class NoTypeError < Error
  end
end
