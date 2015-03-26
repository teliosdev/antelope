# encoding: utf-8

require 'rubygems/requirement'

module Antelope
  module DSL
    class Compiler
      # The body of the output compiler.  This should be formatted in
      # the language that the parser is to be written in.  Some output
      # generators may have special syntax that allows the parser to
      # be put in the body; see the output generators for more.
      #
      # For the DSL compiler, this is the :default template; if the
      # :default template does not exist, the compilation will error.
      #
      # @return [String]
      attr_reader :body

      # A list of all the rules that are defined in the file.  The
      # rules are defined as such:
      #
      # - **`label`** (`Symbol`) &mdash; The left-hand side of the rule;
      #   this is the nonterminal that the right side reduces to.
      # - **`set`** (`Array<Symbol>`) &mdash; The right-hand side of the
      #   rule.  This is a combination of terminals and nonterminals.
      # - **`block`** (`String`) &mdash; The code to be run on a reduction.
      #   this should be formatted in the language that the output
      #   parser is written in.  Optional; default value is `""`.
      # - **`prec`** (`String`) &mdash; The precedence level for the
      #   rule.  This should be a nonterminal or terminal.  Optional;
      #   default value is `""`.
      #
      # @return [Array<Hash>]
      attr_reader :rules

      # Options defined by the file itself.
      #
      # - **`:terminals`** (`Array<Symbol, String?)>)` &mdash; A list
      #   of all of the terminals in the language.  If this is not
      #   properly defined, the grammar will throw an error saying
      #   that a symbol used in the grammar is not defined.
      # - **`:prec`** (`Array<(Symbol, Array<Symbol>)>`) &mdash; A list
      #   of the precedence rules of the grammar.  The first element
      #   of each element is the _type_ of precedence (and should be
      #   any of `:left`, `:right`, or `:nonassoc`), and the second
      #   element should be the symbols that are on that level.
      # - **`:type`** (`String`) &mdash; The type of generator to
      #   generate; this should be a language.
      # - **`:extra`** (`Hash<Symbol, Array<Object>>`) &mdash; Extra
      #   options that are not defined here.
      # @return [Hash]
      attr_reader :options

      def self.compile(env = {}, &block)
        new(env, &block).tap(&:compile)
      end

      def initialize(env = {}, &block)
        @env = env
        @options = {}
        @block = block
      end

      def compile
        call
        handle_requirement
        handle_rules
        handle_options
        @body = @context[:templates].fetch(:default)
      end

      def call
        @context ||= Contexts::Main.new(options.fetch(:context, {}))
                     .call(&@block)
      end

      protected

      def handle_requirement
        required = @options.fetch(:require, ">= 0.0.0")
        antelope_version = Gem::Version.new(Antelope::VERSION)
        required_version = Gem::Requirement.new(required)

        raise IncompatibleVersionError, "Grammar requires " \
          "#{required}, have #{Antelope::VERSION}" unless
          required_version =~ antelope_version
      end

      def handle_rules
        @rules = []

        @context[:productions].each do |label, rules|
          rules.each do |rule|
            @rules << { label: label,
                        set: rule[:body].map { |x| [x, nil] },
                        block: rule[:action],
                        prec: rule[:prec] }
          end
        end
      end

      def handle_options
        @options[:prec]         = @context[:precedences]
        @options[:extra]        = @context[:defines]
        @options[:type]         = @env[:output]
        @options[:nonterminals] = []
        @options[:terminals]    = @context[:terminals].map do |name, value|
          if value.is_a?(TrueClass)
            [name.intern, nil, nil, nil]
          else
            [name.intern, nil, nil, value]
          end
        end
      end
    end
  end
end
