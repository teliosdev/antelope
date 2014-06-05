require "set"
require "antelope/constructor/nullable"
require "antelope/constructor/first"
require "antelope/constructor/follow"
require "antelope/constructor/lookahead"

module Antelope
  class Constructor

    include Nullable
    include First
    include Follow
    include Lookahead

    attr_reader :parser
    attr_reader :productions
    attr_reader :states

    def initialize(parser)
      @states      = parser.states
      @parser      = parser
      @productions = []
      super()
    end

    def call
      states.each do |state|
        augment_state(state)
      end.each do |state|
        augment_rules(state)
      end

      @productions
    end

    def augment_state(state)
      state.rules.select { |x| x.position.zero? }.each do |rule|
        current_state = state

        rule.left.from = state
        rule.left.to   = state.transitions[rule.left.value]

        states = [state]

        rule.right.each_with_index do |part, pos|
          begin
            transition = current_state.transitions[part.value]
          rescue
            puts "WATING TRANSITION FOR #{part.value}"
            p states[-2]
            p rule
            p pos
            raise
          end
          if part.nonterminal?
            part.from = current_state
            part.to   = transition
          end

          states.push(transition)
          current_state = transition
        end

        productions << rule unless productions.include?(rule)
      end
    end

    def augment_rules(state)
      state.rules.select { |x| x.position.zero? }.each do |rule|
        current_state = state

        rule.right.each do |part|
          transition = current_state.transitions[part.value]
          current_state = transition
        end

        final = current_state.rule_for(rule)

        final.lookahead = follow(rule.left)
      end
    end

    private

    def incorrect_argument!(arg, *types)
      raise ArgumentError, "Expected one of #{types.join(", ")}, got #{arg.class}"
    end
  end
end
