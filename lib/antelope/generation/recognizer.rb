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
      # and computing
      def compute_states
        fixed_point(states) do
          states.dup.each do |state|
            state.rules.each do |rule|
              next unless rule.succ?
              transitional = find_state_for(rule.succ) do |succ|
                ns = State.new
                ns << succ
                compute_closure(ns)
                states << ns
                ns
              end

              if state.transitions[rule.active.name]
                state.transitions[rule.active.name].merge! transitional
              else
                state.transitions[rule.active.name] = transitional
              end
            end
          end
        end
      end

      def compute_closure(state)
        fixed_point(state.rules) do
          state.rules.select { |_| _.active.nonterminal? }.each do |rule|
            grammar.productions[rule.active.name].each do |prod|
              state << Rule.new(prod, 0)
            end
          end
        end
      end

      private

      def find_state_for(rule)
        states.find { |state| state.include?(rule) } or yield(rule)
      end

      def redefine_state_ids
        states.each_with_index do |state, i|
          state.id = i
        end
      end

      def redefine_rule_ids
        start = 0

        states.each do |state|
          state.rules.each do |rule|
            rule.id = start
            start  += 1
          end
        end
      end

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
