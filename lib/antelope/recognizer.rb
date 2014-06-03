require "antelope/recognizer/output"
require "antelope/recognizer/rule"
require "antelope/recognizer/state"

module Antelope
  class Recognizer

    include Output
    def initialize(parser)
      @parser = parser
      @automaton = Automaton.new
      @states = []
    end

    def parse
      #compute_state(@parser.start_production)
      compute_initial_state
    end

    def compute_initial_state
      rule = Rule.new(:"$start", @parser.productions[:"$start"][:items], 0)

      compute_state(rule)
    end

    def compute_state(for_rule)
      state = compute_closure(for_rule)
      @states << state
      state.each do |rule|
        next unless rule.succ?
        transitional = find_state_for(rule.succ) do
          compute_state(rule.succ)
        end

        if state.transitions[rule.active]
          state.transitions[rule.active].merge!(transitional)
        else
          state.transitions[rule.active] = transitional
        end
      end

      state
    end

    def compute_closure(for_rule)
      state = State.new
      productions = if for_rule.active.nonterminal?
        @parser.productions[for_rule.active.value]
      else
        []
      end

      state << for_rule

      productions.each do |production|
        rule = Rule.new(for_rule.active.value, production[:items], 0)
        state << rule

        if rule.active.nonterminal? and rule.active.value != rule.left
          state << compute_closure(rule)
        end
      end

      state
    end

    def find_state_for(rule)
      @states.select { |x| x.member?(rule) }.last or yield
    end
  end
end
