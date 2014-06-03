require "antelope/recognizer/output"
require "antelope/recognizer/rule"
require "antelope/recognizer/state"

module Antelope
  class Recognizer

    include Output
    def initialize(parser)
      @parser = parser
      @automaton = Automaton.new
    end

    def parse
      compute_state(@parser.start_production)
    end

    def compute_state(production, position = 0)
      state = compute_closure(production, position)
      state.each do |rule|
        state.transitions[rule.active] = compute_state(rule.left,
                                          rule.position + 1)
      end

      state
    end

    def compute_closure(left, position = 0)
      state = State.new
      productions = @parser.productions[left]

      productions.each do |production|
        if production[:items].size > position
          rule = Rule.new(left, production[:items], position)
          state << rule

          if rule.active.nonterminal? and rule.active.value != left
            state << compute_closure(rule.active.value, position)
          end
        end
      end

      state
    end
  end
end
