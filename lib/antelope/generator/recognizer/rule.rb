# encoding: utf-8

module Antelope
  module Generator
    class Recognizer
      class Rule

        attr_reader :left
        attr_reader :right
        attr_reader :position
        attr_accessor :lookahead
        attr_accessor :id

        include Comparable

        def initialize(left, right, position = 0)
          @left      = left
          @right     = right.freeze
          @position  = position
          @lookahead = Set.new
          @id        = SecureRandom.hex
        end

        def inspect
          "#<#{self.class} id=#{id} left=#{left} right=[#{right.join(" ")}] position=#{position}>"
        end

        def to_s(dot = true)
          "#{id}: #{left} → #{right[0, position].join(" ")}#{" • " if dot}#{right[position..-1].join(" ")}"
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

        def final?
          !succ?
        end

        def <=>(other)
          if other.is_a? Rule
            to_a <=> other.to_a
          else
            super
          end
        end

        def without_transitions
          @_without_transitions ||=
            Rule.new(left.without_transitions,
                     right.map(&:without_transitions), position)
        end

        def ===(other)
          if other.is_a? Rule
            left === other.left and right.each_with_index.
              all? { |e, i| e === other.right[i] }
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
end
