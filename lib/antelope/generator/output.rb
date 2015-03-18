# encoding: utf-8

module Antelope
  module Generator

    # Generates an output file, mainly for debugging.  Included always
    # as a generator for a grammar.
    class Output < Group

      register_as "output"

      register_generator Info,  "info"
      register_generator Error, "error"

    end
  end
end
