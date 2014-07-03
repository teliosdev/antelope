module Antelope
  module Generator

    # Generates a parser.  This is normally the parent class, and the
    # specific implementations inherit from this.  The generated
    # parser should, ideally, be completely independent (not requiring
    # any external source code), as well as be under a permissive
    # license.
    #
    # @abstract Subclass and redefine {#generate} to create a
    #   generator.
    class Base
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
        Pathname.new("../templates").expand_path(__FILE__)
      end

      def self.register_as(*names)
        Generator.register_generator(self, *names)
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
        src_file  = Pathname.new(source)
          .expand_path(self.class.source_root)
        src       = src_file.open("r")
        context   = instance_eval('binding')
        erb       = ERB.new(src.read, nil, "%")
        erb.filename = source
        content   = erb.result(context)
        content   = yield content if block_given?
        dest_file = Pathname.new(destination)
          .expand_path(grammar.output)
        dest_file.open("w") do |f|
          f.write(content)
        end
      end

      # The actual table that is used for parsing.  This returns an
      # array of hashes; the array index corresponds to the state
      # number, and the hash keys correspond to the lookahead tokens.
      # The hash values are an array; the first element of that array
      # is the action to be taken, and the second element of the
      # array is the argument for that action.  Possible actions
      # include `:accept`, `:reduce`, and `:state`; `:accept` means
      # to accept the string; `:reduce` means to perform the given
      # reduction; and `:state` means to transition to the given
      # state.
      #
      # @return [Array<Hash<Symbol => Array<(Symbol, Numeric)>>>]
      def table
        mods[:tableizer].table
      end

      # Returns an array of the production information of each
      # production needed by the parser.  The first element of any
      # element in the array is an {Ace::Token::Nonterminal} that
      # that specific production reduces to; the second element
      # is a number describing the number of items in the right hand
      # side of the production; the string represents the action
      # that should be taken on reduction.
      #
      # This information is used for `:reduce` actions in the parser;
      # the value of the `:reduce` action corresponds to the array
      # index of the production in this array.
      #
      # @return [Array<Array<(Ace::Token::Nonterminal, Numeric, String)>]
      def productions
        grammar.all_productions.map do |production|
          [production[:label],
           production[:items].size,
           production[:block]]
        end
      end
    end
  end
end
