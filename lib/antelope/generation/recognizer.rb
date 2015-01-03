# encoding: utf-8

require "antelope/generation/recognizer/rule"
require "antelope/generation/recognizer/state"

module Antelope
  module Generation

    # Recognizes all of the states in the grammar.
    #
    # @see http://redjazz96.tumblr.com/post/88446352960
    class Recognizer

      # A list of all of the states in the grammar.
      #
      # @return [Set<State>]
      attr_reader :states

      # The initial state.  This is the state that is constructed from
      # the rule with the left-hand side being `$start`.
      #
      # @return [State]
      attr_reader :start

      # The grammar that the recognizer is running off of.
      #
      # @return [Ace::Grammar]
      attr_reader :grammar

      # Initialize the recognizer.
      #
      # @param grammar [Ace::Grammar]
      def initialize(grammar)
        @grammar = grammar
        @states = Set.new
        @map = {}
      end

      # Runs the recognizer.  After all states have been created, it
      # resets the state ids into a more friendly form (they were
      # originally hexadecimal, see {State#initialize}), and then
      # resets the rule ids in each state into a more friendly form
      # (they were also originally hexadecmial, see {Rule#initialize}
      # ).
      #
      # @see #compute_initial_state
      # @return [void]
      def call
        @states = Set.new
        @start  = compute_initial_state
        redefine_state_ids
        redefine_rule_ids
        grammar.states = states
      end

      # Computes the initial state.  Starting with the default
      # production of `$start`, it then generates the whole state
      # and then the spawned states from it.
      #
      # @return [State]
      def compute_initial_state
        production = grammar.productions[:$start][0]
        rule = Rule.new(production, 0)
        compute_whole_state(rule)
      end

      # Computes the entire initial state from the initial rule.
      # It starts with a blank state, adds the initial rule to it, and
      # then generates the closure for that state; it then computes
      # the rest of the states in the grammar.
      #
      # @param rule [Rule] the initial rule.
      # @return [State]
      def compute_whole_state(rule)
        state = State.new
        state << rule
        compute_closure(state)
        states << state
        compute_states
        state
      end

      # Computes all states.  Uses a fix point iteration to determine
      # when no states have been added.  Loops through every state and
      # every rule, looking for rules that have an active nonterminal
      # and computing the closure for said rule.
      #
      # @return [void]
      # @see #compute_closure
      def compute_states
        fixed_point(states) do
          states.dup.each do |state|
            compute_gotos(state)
          end
        end
      end

      # Given a state, it does a fixed point iteration on the rules of
      # the state that have an active nonterminal, and add the
      # corresponding production rules to the state.
      #
      # @return [void]
      def compute_closure(state)
        fixed_point(state.rules) do
          state.rules.select { |_| _.active.nonterminal? }.each do |rule|
            grammar.productions[rule.active.name].each do |prod|
              state << Rule.new(prod, 0)
            end
          end
        end
      end

      def compute_gotos(state)
        actives = state.rules.map(&:active).select(&:name)

        actives.each do |active|
          next if state.transitions[active.name]
          rules = state.rules.
            select { |r| r.active == active && r.succ? }.
            map(&:succ).to_set
          s = states.find { |st| rules.subset? st.rules } || begin
            s = State.new << rules
            compute_closure(s)
            states << s
            s
          end

          state.transitions[active.name] = s
        end
      end

      private

      # Changes the IDs of the states into a more friendly format.
      #
      # @return [void]
      def redefine_state_ids
        states.each_with_index do |state, i|
          state.id = i
        end
      end

      # Redefines all of the rule ids to make them more friendly.
      # Every rule in every state is given a unique ID, reguardless if
      # the rules are equivalent.
      #
      # @return [void]
      def redefine_rule_ids
        start = 0

        states.each do |state|
          state.rules.each do |rule|
            rule.id = start
            start  += 1
          end
        end
      end

      # Begins a fixed point iteration on the given enumerable.  It
      # initializes the added elements to one; then, while the number
      # of added elements is not zero, it yields and checks for added
      # elements.
      #
      # @param enum [Enumerable]
      # @yield for every iteration.  Guarenteed to do so at least
      #   once.
      # @return [void]
      def fixed_point(enum)
        added = 1

        until added.zero?
          added = enum.size
          yield
          added = enum.size - added
        end
      end

    end
  end
end
