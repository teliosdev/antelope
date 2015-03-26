# encoding: utf-8

require 'hashie'
require 'antelope/grammar/symbols'
require 'antelope/grammar/productions'
require 'antelope/grammar/production'
require 'antelope/grammar/precedences'
require 'antelope/grammar/precedence'
require 'antelope/grammar/loading'
require 'antelope/grammar/generation'
require 'antelope/grammar/token'

module Antelope
  # Defines a grammar from an Ace file.  This handles setting up
  # productions, loading from files, symbols, precedence, and
  # generation.
  class Grammar
    include Symbols
    include Productions
    include Precedences
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

    # Extra options from the compiler.  This can be used by
    # generators for output information.
    #
    # @return [Hash]
    def options
      compiler.options[:extra]
    end
  end
end
