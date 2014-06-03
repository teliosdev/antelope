require "antelope/recognizer/rule"
require "antelope/recognizer/state"

module Antelope
  class Recognizer

    attr_reader :states

    def initialize(parser)
      @parser = parser
      @states = []
    end

    def parse
      @states = []
      state = compute_initial_state
      reassign_state_ids
    end

    def compute_initial_state
      rule = Rule.new(Parser::Nonterminal.new(:"$start"),
        @parser.productions[:"$start"][0][:items], 0)

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

        if state.transitions[rule.active.value]
          state.transitions[rule.active.value].merge!(transitional)
        else
          state.transitions[rule.active.value] = transitional
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
        rule = Rule.new(for_rule.active, production[:items], 0)
        state << rule

        if rule.active.nonterminal? and rule.active != rule.left
          state << compute_closure(rule)
        end
      end

      state
    end

    def find_state_for(rule)
      @states.select { |x| x.member?(rule) }.last or yield
    end

    def reassign_state_ids
      @states.each_with_index do |state, i|
        state.id = i
      end

      @states
    end

  end
end
