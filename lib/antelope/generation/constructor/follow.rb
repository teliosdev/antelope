# encoding: utf-8

module Antelope
  module Generation
    class Constructor

      # Contains the methods to find the FOLLOW sets of nonterminals.
      module Follow

        # Initialize.
        def initialize
          @follows = {}
          super
        end

        # Returns the FOLLOW set of the given token.  If the given
        # token isn't a nonterminal, it raises an error.  It then
        # generates the FOLLOW set for the given token, and then
        # caches it.
        #
        # @return [Set<Grammar::Token>]
        # @see Constructor#incorrect_argument!
        # @see #generate_follow_set
        def follow(token)
          unless token.is_a? Grammar::Token::Nonterminal
            incorrect_argument! token, Grammar::Token::Nonterminal
          end

          @follows.fetch(token) { generate_follow_set(token) }
        end

        private

        # Generates the FOLLOW set for the given token.  It finds the
        # positions at which the token appears in the grammar, and
        # sees what could possibly follow it.  For example, given the
        # following production:
        #
        #     A -> aBz
        #
        # With `a` and `z` being any combination of terminals and
        # nonterminals, and we're trying to find the FOLLOW set of
        # `B` we add the FIRST set of `z` to the FOLLOW set of `B`:
        #
        #     FOLLOW(B) = FOLLOW(B) ∪ FIRST(z)
        #
        # In the case that `B` is at the end of a production, like so:
        #
        #     A -> aB
        #
        # or
        #
        #     A -> aBw
        #
        # (with `w` being nullable) We also add the FOLLOW set of `A`
        # to `B`:
        #
        #     FOLLOW(B) = FOLLOW(B) ∪ FOLLOW(A)
        #
        # In case this operation is potentially recursive, we make
        # sure to set the FOLLOW set of `B` to an empty set (since we
        # cache the result of a FOLLOW set, the empty set will be
        # returned).
        #
        # @param token [Grammar::Token::Nonterminal]
        # @return [Set<Grammar::Token>]
        # @see First#first
        # @see Nullable#nullable?
        def generate_follow_set(token)
          # Set it to the empty set so we don't end up recursing.
          @follows[token] = Set.new
          set = Set.new

          productions.each do |rule|
            items = rule.items
            i = 0

            # Find all of the positions within the rule that our token
            # occurs, and then increment that position by one.
            while i < items.size
              next i += 1 unless items[i] == token
              position = i.succ

              # Find the FIRST set of every item after our token, and
              # put that in our set.
              set.merge first(items[position..-1])

              # If we're at the end of the rule...
              if position == items.size || nullable?(items[position..-1])
                # Then add the FOLLOW set of the left-hand side to our
                # set.
                set.merge follow(rule.label)
              end

              i += 1
            end
          end

          # ReplGrammar the cached empty set with our filled set.
          @follows[token] = set
        end
      end
    end
  end
end
