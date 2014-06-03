require 'forwardable'

module Antelope
  class Recognizer
    class State

      attr_reader :rules
      attr_reader :transitions
      attr_reader :id

      include Enumerable
      extend Forwardable

      def_delegator :@rules, :each

      def self.id
        @_id ||= 0
      end

      def self.bump
        id
        @_id += 1
      end

      def initialize
        @rules = []
        @transitions = {}
        @id = self.class.bump
      end

      def merge!(other)
        raise ArgumentError, "Expected #{self.class}, " +
          "got #{other.class}" unless other.is_a? State

        self << other
        self.transitions.merge! other.transitions
        self
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
