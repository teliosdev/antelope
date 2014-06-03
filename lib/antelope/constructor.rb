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

    def initialize(start, parser)
      @start       = start
      @parser      = parser
      @queue       = []
      @productions = []
      @position    = 0
      super()
    end

    def augment
      @productions = []
      add_state(@start)

      while @queue.size > @position
        augment_state(@queue[@position])
        @position += 1
      end

      @productions
    end

    def augment_state(state)
      state.rules.each do |rule|
        next unless rule.position.zero?
        trace_rule(state, rule)
      end
    end

    private

    def trace_rule(state, rule)
      states = [state]

      rule.right.each do |token|
        transition = states.last.transitions[token.value]
        if token.nonterminal?
          token.from = states.last
          token.to   = transition
        end

        raise unless transition
        add_state(transition)
        states << transition
      end

      rule.left.from = state
      rule.left.to   = state.transitions[rule.left.value]

      @productions << Recognizer::Rule.new(rule.left, rule.right)
    end

    def add_state(state)
      @queue << state unless @queue.include?(state)
    end

    def incorrect_argument!(arg, *types)
      raise ArgumentError, "Expected one of #{types.join(", ")}, got #{arg.class}"
    end
  end
end
