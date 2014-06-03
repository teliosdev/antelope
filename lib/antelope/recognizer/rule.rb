module Antelope
  class Recognizer
    class Rule

      attr_accessor :left
      attr_accessor :right
      attr_accessor :position

      include Comparable

      def <=>(other)
        if other.is_a? Rule
          [left, right, position] <=> [other.left,
            other.right, other.position]
        else
          super
        end
      end

      def initialize(left, right, position)
        @left = left
        @right = right
        @position = position
      end

      def active
        right[position] or Parser::Token.new(nil)
      end

      def succ
        Rule.new(left, right, position + 1)
      end

      def succ?
        right.size > (position)
      end
    end
  end
end
