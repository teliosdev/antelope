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
        # @return [Set<Ace::Token>]
        # @see Constructor#incorrect_argument!
        # @see #generate_follow_set
        def follow(token)
          unless token.is_a? Ace::Token::Nonterminal
            incorrect_argument! token, Ace::Token::Nonterminal
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
        # @param token [Ace::Token::Nonterminal]
        # @return [Set<Ace::Token>]
        # @see First#first
        # @see Nullable#nullable?
        def generate_follow_set(token)
          # Set it to the empty set so we don't end up recursing.
          @follows[token] = Set.new

          # This is going to be the output set.
          set = Set.new

          productions = grammar.states.map(&:rules).flatten.
            inject(Set.new, :merge)

          productions.each do |rule|
            items = rule.right

            # Find all of the positions within the rule that our token
            # occurs, and then increment that position by one.
            positions = items.each_with_index.
              find_all { |t, _| t == token }.
              map(&:last).map(&:succ)

            # Find the FIRST set of every item after our token, and
            # put that in our set.
            positions.map { |pos| first(items[pos..-1]) }.
              inject(set, :merge)

            positions.each do |pos|
              # If we're at the end of the rule...
              if pos == items.size || nullable?(items[pos..-1])
                # Then add the FOLLOW set of the left-hand side to our
                # set.
                set.merge follow(rule.left)
              end
            end
          end

          # Replace the cached empty set with our filled set.
          @follows[token] = set
        end
      end
    end
  end
end
