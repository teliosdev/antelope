require 'hashie/rash'
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
        Pathname.new("../templates").expand_path(__FILE__)
      end

      def self.register_as(*names)
        Generator.register_generator(self, *names)
      end

      # Allows a directive for this generator.  This is checked in
      # the compiler to allow the option.  If the compiler encounters
      # a bad directive, it'll error (to give the developer a warning).
      #
      # @param directive [Symbol, Regexp]
      # @param type [Object] used to define how the value should be
      #   coerced.
      # @see #directives
      # @see #coerce_directive_value
      # @return [void]
      def self.has_directive(directive, type = nil)
        # it doesn't matter if it's false, we check to see if there
        # is a key...
        directive = directive.to_s unless directive.is_a? Regexp
        directives[directive] = [self, type]
      end

      # The directives in the class.
      #
      # @see .has_directive
      # @return [Hash]
      def self.directives
        @_options ||= begin
          options = Hashie::Rash.new
          options.optimize_every = Float::INFINITY
          options
        end
      end

      class << self
        alias_method :has_directives, :has_directive
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

      # Retrieves all directives from the grammar, and giving them the
      # proper values for this instance.
      #
      # @see .has_directive
      # @see #coerce_directive_value
      # @return [Hash]
      def directives
        @_directives ||= begin
          hash = Hashie::Mash.new

          grammar.options.each do |key, values|
            dict = self.class.directives[key]
            dict = dict.last if dict

            hash[key] = coerce_directive_value(values, dict)
          end

          hash
        end
      end

      # Coerce the given directive value to the given type.  For the
      # type `nil`, it checks the size of the values; for no values,
      # it returns true; for one value, it returns that one value; for
      # any other size value, it returns the values.  For the type
      # `Boolean`, if no values were given, or if the first value isn't
      # "false", it returns true.  For the type `:single` (or `:one`),
      # it returns the first value.  For the type `Array`, it returns
      # the values.  For any other type that is a class, it tries to
      # initialize the class with the given arguments.
      def coerce_directive_value(values, type)
        case type
        when nil
          case values.size
          when 0
            true
          when 1
            values[0]
          else
            values
          end
        when :single, :one
          values[0]
        when Boolean
          # For bool, if there were no arguments, then return true;
          # otherwise, if the first argument isn't "false", return
          # true.
          values.empty? || values[0].to_s != "false"
        when Array
          values.zip(type).map do |value, t|
            coerce_directive_value([value], t)
          end
        when Class
          if type == Array
            values
          elsif type == String
            values[0].to_s
          elsif type <= Numeric
            values[0].to_i
          else
            type.new(*values)
          end
        else
          raise UnknownTypeError, "unknown type #{type}"
        end
      end

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
        src  = Pathname.new("#{source}.ant").
          expand_path(self.class.source_root)

        template = Template.new(src)
        content  = template.result(instance_eval('binding'))
        content.gsub!(/[ \t]+\n/, "\n")

        if block_given?
          content = yield content
        end

        dest = Pathname.new(destination).
          expand_path(grammar.output)

        dest.open("w") do |file|
          file.write(content)
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
