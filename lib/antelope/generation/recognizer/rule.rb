# encoding: utf-8

require "securerandom"

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
        # @deprecated Use {Ace::Grammar::Production#block} instead.
        # @return [String]
        attr_reader :block

        # The lookahead set for this specific rule.  Contains nothing
        # unless {#final?} returns true.
        #
        # @return [Set<Symbol>]
        attr_accessor :lookahead

        # The id for this rule.  Initialy, this is set to a string of
        # hexadecimal characters; after construction of all states,
        # however, it is a number.
        #
        # @return [String, Numeric]
        attr_accessor :id

        # The precedence for this rule.
        #
        # @return [Ace::Precedence]
        attr_accessor :precedence

        # The associated production.
        #
        # @return [Ace::Grammar::Production]
        attr_reader :production

        include Comparable

        # Initialize the rule.
        #
        # @param production [Ace::Grammar::Production] the production
        #   that this rule is based off of.
        # @param position [Numeric] the position that this rule is in
        #   the production.
        # @param inherited [nil] do not use.
        def initialize(production, position, inherited = false)
          @left       = production.label.dup
          @position   = position
          @lookahead  = Set.new
          @precedence = production.prec
          @production = production
          @block      = production.block
          @id         = SecureRandom.hex

          if inherited
            @right = inherited
          else
            @right = production.items.map(&:dup).freeze
          end
        end

        # Give a nice representation of the rule as a string.
        #
        # @return [String]
        def inspect
          "#<#{self.class} id=#{id} left=#{left} " \
            "right=[#{right.join(" ")}] position=#{position}>"
        end

        # Give a nicer representation of the rule as a string.  Shows
        # the id of the rule, the precedence, and the actual
        # production; if the given argument is true, it will show a
        # dot to show the position of the rule.
        #
        # @param dot [Boolean] show the current position of the rule.
        # @return [String]
        def to_s(dot = true)
          "#{id}/#{precedence.type.to_s[0]}#{precedence.level}: " \
            "#{left} → #{right[0, position].join(" ")}" \
            "#{" • " if dot}#{right[position..-1].join(" ")}"
        end

        # Returns the active token.  If there is no active token, it
        # returns a blank {Ace::Token}.
        #
        # @return [Ace::Token]
        def active
          right[position] or Ace::Token.new(nil)
        end

        # Creates the rule after this one by incrementing the position
        # by one.  {#succ?} should be called to make sure that this
        # rule exists.
        #
        # @return [Rule]
        def succ
          Rule.new(production, position + 1)
        end

        # Checks to see if a rule can exist after this one; i.e. the
        # position is not equal to the size of the right side of the
        # rule.
        #
        # @return [Boolean]
        def succ?
          right.size > position
        end

        # Checks to see if this is the final rule, as in no rule can
        # exist after this one; i.e. the position is equal to the
        # size of the right side.
        #
        # @return [Boolean]
        def final?
          !succ?
        end

        # The complete opposite of {#final?} - it checks to see if
        # this is the first rule, as in no rule can exist before this
        # one; i.e. the position is zero.
        #
        # @return [Boolean]
        def start?
          position.zero?
        end

        # Compares this rule to another object.  If the other object
        # is not a rule, it delegates the comparison.  Otherwise, it
        # converts both this and the other rule into arrays and
        # compares the result.
        #
        # @param other [Object] the object to compare.
        # @return [Numeric]
        def <=>(other)
          if other.is_a? Rule
            to_a <=> other.to_a
          else
            super
          end
        end

        # Fuzzily compares this object to another object.  If the
        # other object is not a rule, it delegates the comparison.
        # Otherwise, it fuzzily compares the left and right sides.
        #
        # @param other [Object] the object to compare.
        # @return [Numeric]
        def ===(other)
          if other.is_a? Rule
            left === other.left and right.each_with_index.
              all? { |e, i| e === other.right[i] }
          else
            super
          end
        end

        # Generates a hash for this class.
        #
        # @note This is not intended for use.  It is only defined to be
        #   compatible with Hashs (and by extension, Sets).
        # @private
        # @return [Object]
        def hash
          to_a.hash
        end

        alias_method :eql?, :==

        # Creates an array representation of this class.
        #
        # @note This is not intended for use.  It is only defined to
        #   make equality checking easier, and to create a hash.
        # @private
        # @return [Array<(Ace::Token::Nonterminal, Array<Ace::Token>, Numeric)>]
        def to_a
          [left, right, position]
        end
      end
    end
  end
end
