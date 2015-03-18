# encoding: utf-8

require "set"

module Antelope
  module Ace
    class Grammar

      # Manages precedence for tokens.
      module Precedences

        # Accesses the generated precedence list.  Lazily generates
        # the precedence rules on the go, and then caches it.
        #
        # @return [Array<Ace::Precedence>]
        def precedence
          @_precedence ||= generate_precedence
        end

        # Finds a precedence rule for a given token.  If no direct
        # rule is defined for that token, it will check for a rule
        # defined for the special symbol, `:_`.  By default, there
        # is always a rule defined for `:_`.
        #
        # @param token [Ace::Token, Symbol]
        # @return [Ace::Precedence]
        def precedence_for(token)
          token = token.name if token.is_a?(Token)

          prec = precedence.
            detect { |pr| pr.tokens.include?(token) } ||
          precedence.
            detect { |pr| pr.tokens.include?(:_) }

          prec
        end

        private

        # Generates the precedence rules.  Loops through the compiler
        # given precedence settings, and then adds two default
        # precedence rules; one for `:$` (level 0, nonassoc), and one
        # for `:_` (level 1, nonassoc).
        #
        # @return [Array<Ace::Precedence>]
        def generate_precedence
          size = @compiler.options[:prec].size + 1
          index = 0
          precedence = []

          while index < @compiler.options[:prec]
            prec = @compiler.options[:prec][index]
            precedence <<
              Ace::Precedence.new(prec[0], prec[1..-1].to_set,
              size - index)
          end

          precedence <<
            Ace::Precedence.new(:nonassoc, [:$end].to_set, 0) <<
            Ace::Precedence.new(:nonassoc, [:_].to_set, 1)
          precedence.sort_by(&:level).reverse
        end

      end
    end
  end
end
