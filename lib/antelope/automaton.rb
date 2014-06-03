module Antelope
  class Automaton
    attr_accessor :states
    attr_accessor :alphabet
    attr_accessor :start
    attr_accessor :accept
    attr_accessor :transitions
    attr_accessor :stack

    def initialize(states = [], alphabet = [],
                   start = nil, accept = [], transitions = {})
      @states      = states
      @alphabet    = alphabet
      @start       = start
      @accept      = accept
      @transitions = transitions
      @stack       = []
    end

    def run(input, &block)
      block = block || method(:default_transition)

      @stack = [@start]

      input.each do |part|
        @stack.push(block.call(@stack.last, part))
      end

      @accept.include? @stack.last
    end

    def default_transition(state, part)
      @transitions[state][part]
    end
  end
end
