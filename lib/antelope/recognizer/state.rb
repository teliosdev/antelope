require "forwardable"
require "securerandom"

module Antelope
  class Recognizer
    class State

      attr_reader :rules
      attr_reader :transitions
      attr_accessor :id

      include Enumerable
      extend Forwardable

      def_delegator :@rules, :each

      def initialize
        @rules = Set.new
        @transitions = {} #Hash.new { |hash, key| hash[key] = State.new }
        @id = SecureRandom.hex
      end

      def inspect
        "#<#{self.class} id=#{id} transitions=[#{transitions.keys.join(", ")}] rules=[{#{rules.to_a.join("} {")}}]>"
      end

      def merge!(other)
        return if other == :_ignore
        raise ArgumentError, "Expected #{self.class}, " +
          "got #{other.class}" unless other.is_a? State

        self << other
        self.transitions.merge! other.transitions

        self
      end

      def rule_for(production)
        rules.find { |rule| production === rule }
      end

      def <<(rule)
        if rule.is_a? State
          rule.rules.each { |r| self << r }
        else
          rules << rule unless rules.include? rule
        end
      end

      alias_method :push, :<<

    end
  end
end
