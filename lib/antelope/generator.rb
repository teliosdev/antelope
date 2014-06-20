# encoding: utf-8

require "antelope/generator/output"
require "antelope/generator/ruby"
require "erb"
require "pathname"

module Antelope

  # Generates a parser.  This is normally the parent class, and the
  # specific implementations inherit from this.  The generated
  # parser should, ideally, be completely independent (not requiring
  # any external source code), as well as be under a permissive
  # license.
  class Generator

    # The modifiers that were applied to the grammar.
    #
    # @return [Hash<(Symbol, Object)>]
    attr_reader :mods

    # The file name (not including the extension) that the grammar
    # should output to.
    #
    # @return [String]
    attr_reader :file

    # The grammar that the generator is for.
    #
    # @return [Ace::Grammar]
    attr_reader :grammar

    # The source root directory for templates.  Overwrite to change.
    #
    # @return [Pathname]
    def self.source_root
      Pathname.new("../generator/templates").expand_path(__FILE__)
    end

    # Initialize the generator.
    #
    # @param grammar [Grammar]
    # @param mods [Hash<(Symbol, Object)>]
    def initialize(grammar, mods)
      @file    = grammar.name
      @grammar = grammar
      @mods    = mods
    end

    # Actually does the generation.  A subclass should implement this.
    #
    # @raise [NotImplementedError]
    # @return [void]
    def generate
      raise NotImplementedError
    end

    protected

    # Copies a template from the source, runs it through erb (in the
    # context of this class), and then outputs it at the destination.
    # If given a block, it will call the block after the template is
    # run through erb with the content from erb; the result of the
    # block is then used as the content instead.
    #
    # @param source [String] the source file.  This should be in
    #   {.source_root}.
    # @param destination [String] the destination file.  This will be
    #   in {Ace::Grammar#output}.
    # @yieldparam [String] content The content that ERB created.
    # @yieldreturn [String] The new content to write to the output.
    # @return [void]
    def template(source, destination)
      src_file  = self.class.source_root + source
      src       = src_file.open("r")
      context   = instance_eval('binding')
      content   = ERB.new(src.read, nil, "%").result(context)
      content   = yield content if block_given?
      dest_file = grammar.output + destination
      dest_file.open("w") do |f|
        f.write(content)
      end
    end

  end
end
