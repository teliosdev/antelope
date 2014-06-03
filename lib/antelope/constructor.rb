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

    def initialize(start, parser)
      @start       = start
      @parser      = parser
      @augmented   = {}
      super()
    end

    def augment
      augment_state(@start)
    end

    def augment_state(state)
      @augmented.fetch(state) do
        @augmented[state] = true
        state.each do |rule|
          next unless rule.active.nonterminal?

          rule.active.from = state
          rule.active.to   = state.transitions[rule.active]

          rule.left.from = state
          rule.left.to   = state.transitions[rule.left]

        end

        state.transitions.values.each { |st| augment_state(st) }
      end
    end

    private

    def incorrect_argument!(arg, *types)
      raise ArgumentError, "Expected one of #{types.join(", ")}, got #{arg.class}"
    end
  end
end
