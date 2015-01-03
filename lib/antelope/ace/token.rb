# encoding: utf-8

require "antelope/ace/token/nonterminal"
require "antelope/ace/token/terminal"
require "antelope/ace/token/epsilon"
require "antelope/ace/token/error"


module Antelope
  module Ace

    # Defines a token type for productions/rules.
    #
    # @abstract This class should be inherited to define a real token.
    #   A base class does not match any token; however, any token can
    #   match the base class.
    class Token

      # The name of the token.
      #
      # @return [Symbol]
      attr_reader :name

      # The from state that this token is transitioned from.  This is
      # the _source_.  This is used in the constructor in order to
      # handle lookahead sets.
      #
      # @return [Recognizer::State]
      attr_reader :from

      # The to state that this token is transitioned to.  This is the
      # _destination_.  This is used in the constructor in order to
      # handle lookahead sets.
      #
      # @return [Recognizer::State]
      attr_reader :to

      # The type of the token.  This is given by a caret argument to
      # the grammar.  This is primarily used for generators.
      #
      # @return [String]
      attr_reader :type

      attr_accessor :id

      # Initialize.
      #
      # @param name [Symbol] the name of the token.
      # @param type [String?] the type of the token.  For definitions,
      #   this is the given type of the token (for typed language
      #   output).
      # @param id [String?] the id of the token in the production.
      #   For some languages, this allows references to the token via
      #   the id.
      # @param value [String?] the value of the token.  This is only
      #   used in output representation to the developer.
      def initialize(name, type = nil, id = nil, value = nil)
        @name  = name
        @value = value
        @type  = type
        @id    = id
        @from  = nil
        @to    = nil
      end

      include Comparable

      # Whether or not the token is a terminal.
      #
      # @abstract
      # @return [Boolean]
      def terminal?
        false
      end

      # Whether or not the token is a nonterminal.
      #
      # @abstract
      # @return [Boolean]
      def nonterminal?
        false
      end

      # Whether or not the token is an epsilon token.
      #
      # @abstract
      # @return [Boolean]
      def epsilon?
        false
      end

      # Whether or not the token is an error token.
      #
      # @abstract
      # @return [Boolean]
      def error?
        false
      end

      # Sets the from state of the token and invalidates the cache.
      #
      # @param state [Recognizer::State]
      # @return [void]
      def from=(state)
        invalidate_cache!
        @from = state
      end

      # Sets the to state of the token and invalidates the cache.
      #
      # @param state [Recognizer::State]
      # @return [void]
      def to=(state)
        invalidate_cache!
        @to = state
      end

      # Sets the type of the token and invalidates the cache.
      #
      # @param type [String]
      # @return [void]
      def type=(type)
        invalidate_cache!
        @type = type
      end

      # Gives a string representation of the token.  The output is
      # formatted like so: `<data>["(" [<from_id>][:<to_id>] ")"]`,
      # where `<data>` is either the value (if it's non-nil) or the
      # name, `<from_id>` is the from state id, and `<to_id>` is the
      # to state id.  The last part of the format is optional; if
      # neither the from state or to state is non-nil, it's non-
      # existant.
      #
      # @return [String] the string representation.
      # @see #from
      # @see #to
      # @see #name
      def to_s
        buf = if @value
          @value.inspect
        else
          @name.to_s
        end

        if from or to
          buf << "("
          buf << "#{from.id}" if from
          buf << ":#{to.id}"  if to
          buf << ")"
        end

        buf
      end

      # Returns a nice inspect.
      #
      # @return [String]
      def inspect
        "#<#{self.class} from=#{from.id if from} to=#{to.id if to} " \
          "name=#{name.inspect} value=#{@value.inspect}>"
      end

      # Compares this class to any other object.  If the other object
      # is a token, it converts both this class and the other object
      # to an array and compares the array.  Otherwise, it delegates
      # the comparison.
      #
      # @param other [Object] the other object to compare.
      # @return [Numeric]
      def <=>(other)
        if other.is_a? Token
          to_a <=> other.to_a
        else
          super
        end
      end

      def ==(other)
        hash == other.hash if other.respond_to?(:hash)
      end

      alias_method :eql?, :==

      # Compares this class and another object, fuzzily.  If the other
      # object is a token, it removes the transitions (to and from)
      # on both objects and compares them like that.  Otherwise, it
      # delegates the comparison.
      #
      # @param other [Object] the other object to compare.
      # @return [Boolean] if they are equal.
      def ===(other)
        if other.is_a? Token
          without_transitions == other.without_transitions
        else
          super
        end
      end

      # Creates a new token without to or from states.
      #
      # @return [Token]
      def without_transitions
        self.class.new(name, @type, @id, @value)
      end

      # Invalidates the cache.
      #
      # @return [void]
      def invalidate_cache!
        @_hash = nil
        @_array = nil
      end

      # Generates a hash for this class.
      #
      # @note This is not intended for use.  It is only defined to be
      #   compatible with Hashs (and by extension, Sets).
      # @private
      # @return [Object]
      def hash
        @_hash ||= to_a.hash
      end

      alias_method :eql?, :==

      # Creates an array representation of this class.
      #
      # @note This is not intended for use.  It is only defined to
      #   make equality checking easier, and to create a hash.
      # @private
      # @return [Array<(Recognizer::State, Recognizer::State, Class, Symbol, String?)>]
      def to_a
        @_array ||= [to, from, self.class, name, @value]
      end
    end
  end
end
