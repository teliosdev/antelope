module Antelope
  module Generation

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
        #@table = #Hash.new { |hash, key|
        #  hash[key] = Hash.new { |h, k|
        #    h[k] = [] } }
        @table = Array.new(parser.states.size) do
          Hash.new { |h, k| h[k] = [] }
        end
        @rules = []

        parser.states.each do |state|
          state.transitions.each do |on, to|
            table[state.id][on] << [:state, to.id]
          end

          state.rules.each do |rule|
            @rules[rule.id] = rule
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

      def conflictize
        @table.each_with_index do |v, state|
          v.each do |on, data|
            if data.size == 1
              @table[state][on] = data[0]
              next
            end

            terminal = parser.presidence_for(on)

            state_part = data.select { |(t, d)| t == :state }.first
            rule_part  = data.select { |(t, d)| t == :reduce}.first

            result = @rules[rule_part[1]].presidence <=> terminal

            case result
            when 0
              p v, terminal, @rules[rule_part[1]].presidence
              raise UnresolvableConflictError,
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
