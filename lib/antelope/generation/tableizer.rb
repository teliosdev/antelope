# encoding: utf-8

module Antelope
  module Generation

    # Constructs the table required for the parser.
    class Tableizer

      # The grammar that the table is based off of.
      #
      # @return [Ace::Grammar]
      attr_accessor :grammar

      # The table itself.
      #
      # @return [Array<Hash<(Symbol, Array<(Symbol, Numeric)>)>>]
      attr_accessor :table

      # All rules in the grammar.
      #
      # @return [Hash<(Numeric, Recognizer::Rule)>]
      attr_accessor :rules

      # Initialize.
      #
      # @param grammar [Ace::Grammar]
      def initialize(grammar)
        @grammar = grammar
      end

      # Construct the table, and then check the table for conflicts.
      #
      # @return [void]
      # @see #tablize
      # @see #conflictize
      def call
        tablize
        conflictize
      end

      # Construct a table based on the grammar.  The table itself is
      # an array whose elements are hashes; the index of the array
      # corresponds to the state ID, and the keys of the hashes
      # correspond to acceptable tokens.  The values of the hashes
      # should be an array of arrays (at this point).
      #
      # @return [void]
      def tablize
        @table = Array.new(grammar.states.size) do
          Hash.new { |h, k| h[k] = [] }
        end
        @rules = []

        grammar.states.each do |state|
          state.transitions.each do |on, to|
            table[state.id][on] << [:state, to.id]
          end

          state.rules.each do |rule|
            @rules[rule.production.id] = rule.production
            if rule.final?
              rule.lookahead.each do |look|
                table[state.id][look.name] <<
                  [:reduce, rule.production.id]
              end

              if rule.production.id.zero?
                table[state.id][:"$"] = [[:accept, rule.production.id]]
              end
            end
          end
        end

        table
      end

      # Resolve any conflicts through precedence, if we can.  If we
      # can't, let the user know.  This makes sure that every value
      # of the hashes is a single array.
      #
      # @raise [UnresolvableConflictError] if a conflict could not be
      #   resolved using precedence rules.
      # @return [void]
      def conflictize
        @table.each_with_index do |v, state|
          v.each do |on, data|
            if data.size == 1
              @table[state][on] = data[0]
              next
            end

            terminal = grammar.precedence_for(on)

            state_part = data.select { |(t, d)| t == :state }.first
            rule_part  = data.select { |(t, d)| t == :reduce}.first

            result = @rules[rule_part[1]].prec <=> terminal

            case result
            when 0
              $stderr.puts \
                "Could not determine move for #{on} in state #{state}"
            when 1
              @table[state][on] = rule_part
            when -1
              @table[state][on] = state_part
            end
          end
        end
      end
    end
  end
end
