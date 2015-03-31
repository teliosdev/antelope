require 'antelope/generator/base/coerce'
require 'antelope/generator/base/extra'
require 'hashie/mash'

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
      include Coerce
      include Extra

      Boolean = Object.new
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
        Pathname.new('../templates').expand_path(__FILE__)
      end

      def self.register_as(*names)
        Generator.register_generator(self, *names)
      end

      # Called by ruby on subclassing.
      #
      # @param subclass [Class]
      # @return [void]
      def self.inherited(subclass)
        directives.each do |name, (_, type)|
          subclass.directive(name, type)
        end
      end

      # Allows a directive for this generator.  This is checked in
      # the compiler to allow the option.  If the compiler encounters
      # a bad directive, it'll error (to give the developer a warning).
      #
      # @param directive [Symbol, String]
      # @param type [Object] used to define how the value should be
      #   coerced.
      # @see #directives
      # @see #coerce_directive_value
      # @return [void]
      def self.directive(directive, type = nil)
        directive = directive.to_s
        directives[directive] = [self, type]
      end

      # The directives in the class.
      #
      # @see .has_directive
      # @return [Hash]
      def self.directives
        @_directives ||= {}
      end

      class << self
        alias_method :has_directives, :directive
        alias_method :has_directive,  :directive
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

      # Actually does the generation.  A subclass should implement
      # this.
      #
      # @raise [NotImplementedError]
      # @return [void]
      def generate
        raise NotImplementedError
      end

      # Copies a template from the source, runs it through mote (in the
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
        src  = Pathname.new("#{source}.erb")
               .expand_path(self.class.source_root)

        template = ERB.new(src.read, nil, '-')
        content  = template.result(instance_eval('binding'))

        block_given? && content = yield(content)

        dest = Pathname.new(destination).expand_path(grammar.output)

        dest.open('w') do |file|
          file.write(content)
        end
      end
    end
  end
end
