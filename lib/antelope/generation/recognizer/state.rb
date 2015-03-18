# encoding: utf-8

require "forwardable"
require "securerandom"

module Antelope
  module Generation
    class Recognizer

      # A state within the parser.  A state has a set of rules, as
      # well as transitions on those rules.
      class State

        # All of the rules in this state.
        #
        # @return [Set<Rule>]
        attr_reader :rules

        # All of the transitions that can be made on this state.
        #
        # @return [Hash<(Symbol, State)>]
        attr_reader :transitions

        # The id of this state.  This starts off as a string of
        # hexadecmial characters, but after all of the states are
        # finalized, this becomes a numeric.
        #
        # @return [String, Numeric]
        attr_accessor :id

        include Enumerable
        extend Forwardable

        def_delegator :@rules, :each

        # Initialize the state.
        def initialize
          @rules = Set.new
          @transitions = {}
          @id = "%10x" % object_id
        end

        # Gives a nice string representation of the state.
        #
        # @return [String]
        def inspect
          "#<#{self.class} id=#{id} " \
            "transitions=[#{transitions.keys.join(", ")}] " \
            "rules=[{#{rules.to_a.join("} {")}}]>"
        end

        # Merges another state with this state.  It copies all of the
        # rules into this state, and then merges the transitions on
        # the given state to this state.  It then returns self.
        #
        # @raise [ArgumentError] if the given argument is not a state.
        # @param other [State] the state to merge.
        # @return [self]
        def merge!(other)
          raise ArgumentError, "Expected #{self.class}, " \
            "got #{other.class}" unless other.is_a? State

          self << other
          self.transitions.merge! other.transitions

          self
        end

        # Finds the rule that match the given production.  It
        # uses fuzzy equality checking.  It returns the first rule
        # that matches.
        #
        # @param production [Rule] the rule to compare.
        # @return [Rule?]
        def rule_for(production)
          rules.find { |rule| production === rule }
        end

        # Appends the given object to this state.  The given object
        # must be a state or a rule.  If it's a state, it appends all
        # of the rules in the state to this state.  If it's a rule, it
        # adds the rule to our rules.
        #
        # @raise [ArgumentError] if the argument isn't a {State} or a
        #   {Rule}.
        # @param rule [State, Rule] the object to append.
        # @return [self]
        def <<(rule)
          case rule
          when State
            rule.rules.map(&:clone).each { |r| self << r }
          when Rule
            rules << rule #unless rules.include? rule
          when Array, Set
            rule.each do |part|
              self << part
            end
          else
            raise ArgumentError, "Expected State or Rule, " \
              "got #{rule.class}"
          end

          self
        end

        alias_method :push, :<<

        # Check to see if this state is fuzzily equivalent to another
        # state.  It does this by checking if the transitions are
        # equivalent, and then that the rules are fuzzily equivalent.
        # Ideally, the method is commutative; that is,
        # `(a === b) == (b === a)`.
        #
        # @param other [State] the state to check.
        # @return [Boolean]
        # @see Rule#===
        def ===(other)
          return super unless other.is_a? State

          other_rules = other.rules.to_a
          other.transitions == transitions &&
            rules.size == other_rules.size &&
            rules.each_with_index.
            all? { |rule, i| rule === other_rules[i] }
        end

      end
    end
  end
end
