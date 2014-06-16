# encoding: utf-8

module Antelope
  module Generation
    class Recognizer

      # Defines a rule.  A rule has a corresponding production, and a
      # position in that production.  It also contains extra
      # information for other reasons.
      class Rule

        # The left-hand side of the rule.
        #
        # @return [Ace::Token::Nonterminal]
        attr_reader :left

        # The right-hand side of the rule.
        #
        # @return [Ace::Token]
        attr_reader :right

        # The current position inside of the rule.
        #
        # @return [Numeric]
        attr_reader :position

        # The block to be executed on production match.
        #
        # @deprecated Use {Production#block} instead.
        # @return [String]
        attr_reader :block

        # The lookahead set for this specific rule.  Contains nothing
        # unless {#succ?} returns false.
        #
        # @return [Set<Symbol>]
        attr_accessor :lookahead

        # The id for this rule.  Initialy, this is set to a string of
        # hexadecimal characters; after construction of all states,
        # however, it is a number.
        #
        # @return [String, Numeric]
        attr_accessor :id

        # The presidence for this rule.
        #
        # @return [Ace::Presidence]
        attr_accessor :presidence

        # The associated production.
        #
        # @return [Ace::Grammar::Production]
        attr_reader :production

        include Comparable

        def initialize(production, position, inherited = false)
          @left       = production.label
          @position   = position
          @lookahead  = Set.new
          @presidence = production.prec
          @production = production
          @block      = production.block
          @id         = SecureRandom.hex

          if inherited
            @right = inherited
          else
            @right = production.items.map(&:dup).freeze
          end
        end

        def inspect
          "#<#{self.class} id=#{id} left=#{left} right=[#{right.join(" ")}] position=#{position}>"
        end

        def to_s(dot = true)
          "#{id}/#{presidence.type.to_s[0]}#{presidence.level}: #{left} → #{right[0, position].join(" ")}#{" • " if dot}#{right[position..-1].join(" ")}"
        end

        def active
          right[position] or Ace::Token.new(nil)
        end

        def succ
          Rule.new(production, position + 1)
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
            Rule.new(production, position)
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
