require "set"
require "antelope/generator/constructor/nullable"
require "antelope/generator/constructor/first"
require "antelope/generator/constructor/follow"
require "antelope/generator/constructor/lookahead"

module Antelope
  module Generator
    class Constructor

      include Nullable
      include First
      include Follow
      include Lookahead

      attr_reader :parser
      attr_reader :productions

      def initialize(parser)
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
            transition = current_state.transitions[part.value]
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

      def states
        parser.states
      end

      def incorrect_argument!(arg, *types)
        raise ArgumentError, "Expected one of #{types.join(", ")}, got #{arg.class}"
      end
    end
  end
end
