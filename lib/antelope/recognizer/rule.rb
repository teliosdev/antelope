module Antelope
  class Recognizer
    class Rule

      attr_accessor :left
      attr_accessor :right
      attr_accessor :position

      include Comparable

      def initialize(left, right, position)
        @left = left
        @right = right
        @position = position
      end

      def active
        right[position] or Parser::Token.new(nil)
      end

      def succ
        @_succ ||= Rule.new(left, right, position + 1)
      end

      def succ?
        right.size > (position)
      end

      def <=>(other)
        if other.is_a? Rule
          to_a <=> other.to_a
        else
          super
        end
      end

      def hash
        to_a.hash
      end

      alias_method :eql?, :==

      def to_a
        [left, right, position]
      end
    end
  end
end
