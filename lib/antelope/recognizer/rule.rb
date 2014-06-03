module Antelope
  class Recognizer
    class Rule

      attr_accessor :left
      attr_accessor :right
      attr_accessor :position

      def initialize(left, right, position)
        @left = left
        @right = right
        @position = position
      end

      def active
        right[position]
      end

      def succ
        Rule.new(left, right, position + 1)
      end
    end
  end
end
