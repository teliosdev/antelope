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

      attr_reader :conflicts

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
        defaultize
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
                table[state.id][:$end] =
                  [[:accept, rule.production.id]]
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
        states = grammar.states.to_a.sort_by(&:id)
        @conflicts = Hash.new { |h, k| h[k] = {} }
        @table.each_with_index do |v, state|
          v.each do |on, data|
            if data.size == 1
              @table[state][on] = data[0]
              next
            end

            terminal = if states[state].transitions.key?(on)
              states[state].rules.
                detect { |rule| rule.active.name == on }.precedence
            end
            rule_part, other_part = data.sort_by { |(t, _)| t }

            conflict = proc do |result|
              hash = { result: result,
                       terminal: terminal,
                       prec: @rules[rule_part[1]].prec,
                       data: data,
                       rules: [], transitions: [] }

              hash[:rules].concat(data.select { |part|
                  part[0] == :reduce || part[0] == :accept
                }.map { |(_, id)|
                  states[state].rules.select(&:final?).
                    detect { |rule| rule.production.id == id }
                })
              hash[:transitions].concat(data.select { |part|
                  part[0] == :state
                }.map { |_|
                  states[state].rules.
                    detect { |rule| rule.active.name == on }
                })

              conflicts[state][on] = hash
            end

            unless other_part[0] == :state
              conflict.call(0)
              $stderr.puts \
                "Could not determine move for #{on} in state " \
                "#{state} (reduce/reduce conflict)"
              next
            end

            result = @rules[rule_part[1]].prec <=> terminal
            conflict.call(result)

            case result
            when 0
              @table[state][on] = nil
              $stderr.puts \
                "Could not determine move for #{on} in state " \
                "#{state} (shift/reduce conflict)"
            when 1
              @table[state][on] = rule_part
            when -1
              @table[state][on] = other_part
            end
          end
        end
      end

      # Reduce many transitions into a single `$default` transition.
      # This only works if there is no `$empty` transition; if there
      # is an `$empty` transition, then the `$default` transition is
      # set to be the `$empty` transition.
      #
      # @return [void]
      def defaultize
        max = @table.map { |s| s.keys.size }.max
        @table.each_with_index do |state|
          common = state.group_by { |k, v| v }.values.
            sort_by(&:size).first

          if common.size > (max / 2)
            action = common[0][1]

            keys = common.map(&:first)
            state.delete_if { |k, _| keys.include?(k) }
            state[:$default] = action
          end
        end
      end
    end
  end
end
