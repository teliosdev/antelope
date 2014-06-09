require "antelope/generator/conflictor/conflict"

module Antelope
  class Generator
    class Conflictor

      attr_accessor :parser
      attr_accessor :conflicts

      def initialize(parser)
        @parser = parser
      end

      def call
        recognize_conflicts
      end

      def recognize_conflicts

        @conflicts = []

        parser.states.each do |state|
          state.rules.each do |rule|
            if rule.lookahead.
                any? { |tok| state.transitions.key?(tok.value) }
              @conflicts << Conflict.new(state, :shift_reduce, [rule],
                rule.lookahead - state.transitions.keys)
            end
          end

          final_rules = state.rules.select(&:final?)

          final_rules.each_cons(2) do |r1, r2|
            if r1.lookahead.intersect? r2.lookahead
              @conflicts << Conflict.new(state,
                :reduce_reduce,
                [r1, r2],
                r1.lookahead.intersection(r2.lookahead))
            end
          end
        end
      end
    end
  end
end
