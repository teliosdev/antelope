# encoding: utf-8

module Antelope
  module Ace
    class Grammar

      # Manages the productions of the grammar.
      module Productions

        # Returns a hash of all of the productions.  The result is
        # cached.
        #
        # @return [Hash<(Symbol, Array<Production>)>]
        def productions
          @_productions || generate_productions
        end

        # Returns all productions for all nonterminals, sorted by id.
        #
        # @return [Array<Production>]
        def all_productions
          productions.values.flatten.sort_by(&:id)
        end

        # Finds a token based on its corresponding symbol.  First
        # checks the productions, to see if it's a nonterminal; then,
        # tries to find it in the terminals; otherwise, if the symbol
        # is `error`, it returns a {Token::Error}; if the symbol is
        # `nothing` or `ε`, it returns a {Token::Epsilon}; if it's
        # none of those, it raises an {UndefinedTokenError}.
        #
        # @raise [UndefinedTokenError] if the token doesn't exist.
        # @param value [String, Symbol, #intern] the token's symbol to
        #   check.
        # @return [Token]
        def find_token(value)
          value = value.intern

          if productions.key?(value)
            typed_nonterminals.find { |term| term.name == value } ||
              Token::Nonterminal.new(value)
          elsif terminal = terminals.
              find { |term| term.name == value }
            terminal
          elsif value == :error
            Token::Error.new
          elsif [:nothing, :ε].include?(value)
            Token::Epsilon.new
          else
            raise UndefinedTokenError, "Could not find a token " \
              "named #{value.inspect}"
          end
        end

        private

        # Actually generates the productions.  Uses the rules from the
        # compiler to construct the productions.  Makes two loops over
        # the compiler's rules; the first to tell the grammar that the
        # nonterminal does exist, and the second to actually construct
        # the productions.  The first loop is for {#find_token},
        # because otherwise it wouldn't be able to return a
        # nonterminal properly.
        #
        # @return [Hash<(Symbol, Array<Production>)>]
        def generate_productions
          @_productions = {}

          @compiler.rules.each do |rule|
            productions[rule[:label]] = []
          end.each_with_index do |rule, id|
            productions[rule[:label]] <<
              generate_production_for(rule, id)
          end

          productions[:$start] = [default_production]

          productions
        end

        # Generates a production for a given compiler rule.  Converts
        # the tokens in the set to their {Token} counterparts,
        # and then sets the precedence for the production.  If the
        # precedence declaration from the compiler rule is empty,
        # then it'll use the last terminal from the set to check for
        # precedence; otherwise, it'll use the precedence declaration.
        # This is to make sure that every production has a precedence
        # declaration.
        #
        # @param rule [Hash] the compiler's rule.
        # @param id [Numeric] the id for the production.
        # @return [Production]
        def generate_production_for(rule, id)
          left  = Token::Nonterminal.new(rule[:label])
          items = rule[:set].map { |_| find_token(_[0]) }
          prec  = if rule[:prec].empty?
            items.select(&:terminal?).last
          else
            rule[:prec].intern
          end

          prec  = precedence_for(prec)
          left.type = type_for(rule[:label])
          left.id = rule[:label_id]

          rule[:set].each_with_index do |tok, i|
            items[i] = items[i].dup
            items[i].id = tok[1]
          end

          Production.new(left, items, rule[:block], prec, id + 1)
        end

        # Returns the defined type for the given token name.
        # Uses the `%type` directive to infer the corresponding types.
        #
        # @param token [Symbol] the token to check for
        #   types.
        def type_for(token)
          token = find_token(token) unless token.is_a?(Token)

          case token
          when Token::Nonterminal
            token.type
          when Token::Terminal
            token.type
          when Token::Epsilon
            ""
          when Token::Error
            ""
          end
        end

        # Creates the default production for the grammar.  The left
        # hand side of the production is the `:$start` symbol, with
        # the right hand side being the first rule's left-hand side
        # and the terminal `$`.  This production is automagically
        # given the last precedence, and an id of 0.
        #
        # @return [Production]
        def default_production
          Production.new(Token::Nonterminal.new(:$start), [
              Token::Nonterminal.new(@compiler.rules.first[:label]),
              Token::Terminal.new(:$end)
            ], "", precedence.last, 0)
        end
      end
    end
  end
end
