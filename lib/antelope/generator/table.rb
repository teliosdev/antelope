module Antelope
  class Generator

    class UnresolvableConflictError < StandardError; end

    class Table

      attr_accessor :parser
      attr_accessor :table
      attr_accessor :rules

      def initialize(parser)
        @parser = parser
      end

      def call
        tablize
        conflictize
      end

      def tablize
        @table = Hash.new { |hash, key|
          hash[key] = Hash.new { |h, k|
            h[k] = [] } }
        @rules = {}

        parser.states.each do |state|
          state.transitions.each do |on, to|
            table[state.id][on] << [:state, to.id]
          end

          state.rules.each do |rule|
            @rules[rule.id] = rule
            if rule.final?
              rule.lookahead.each do |look|
                table[state.id][look.name] << [:reduce, rule.production.id]
              end
            end
          end
        end

        table
      end

      def conflictize
        @new_updates = Hash.new { |hash, key|
          hash[key] = Hash.new { |h, k|
            h[k] = [] } }
        @table.each do |state, v|
          v.
            select { |_, d| d.size == 2 }.
            each do |on, data|
            terminal = parser.presidence_for(on)

            state_part = data.select { |(t, d)| t == :state }.first
            rule_part  = data.select { |(t, d)| t == :reduce}.first

            result = @rules[rule_part[1]].presidence <=> terminal

            case result
            when 0
              raise UnresolvableConflictError, "Could not determine move for #{on} in state #{state}"
            when 1
              @new_updates[state][on] << rule_part
            when -1
              @new_updates[state][on] << state_part
            end
          end
        end

        update_table
      end

      private

      def update_table
        @new_updates.each do |state, v|
          v.each do |k, d|
            @table[state][k] = d
          end
        end
      end
    end
  end
end
