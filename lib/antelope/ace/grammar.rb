require "antelope/ace/grammar/terminals"
require "antelope/ace/grammar/productions"
require "antelope/ace/grammar/presidence"
require "antelope/ace/grammar/loading"
require "antelope/ace/grammar/generation"
require "antelope/ace/grammar/production"

module Antelope
  module Ace

    # Defines a grammar from an Ace file.  This handles setting up
    # productions, loading from files, terminals, presidence, and
    # generation.
    class Grammar

      include Terminals
      include Productions
      include Presidence
      include Loading
      include Grammar::Generation

      # Used by a generation class; this is all the generated states
      # of the grammar.
      #
      # @return [Set<Generation::Recognizer::State>]
      # @see Generation::Recognizer
      attr_accessor :states

      # The name of the grammar.  This is normally assumed from a file
      # name.
      #
      # @return [String]
      attr_accessor :name

      # The output directory for the grammar.  This is normally the
      # same directory as the Ace file.
      #
      # @return [Pathname]
      attr_accessor :output

      # The compiler for the Ace file.
      #
      # @return [Compiler]
      attr_reader :compiler

      # Initialize.
      #
      # @param name [String]
      # @param output [String] the output directory.  Automagically
      #   turned into a Pathname.
      # @param compiler [Compiler]
      def initialize(name, output, compiler)
        @name     = name
        @output   = Pathname.new(output)
        @compiler = compiler
      end
    end
  end
end
