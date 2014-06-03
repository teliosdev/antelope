module Antelope
  module Output

    extend self

    def output(outputtable, to = "")
      @outputted = [outputtable]
      @to_output = []

      to << out(outputtable)

      while @to_output.any?
        @to_output.reject! { |x| @outputted.include?(x) }
        outputtable = @to_output.shift
        @outputted << outputtable
        to << out(outputtable)
      end

      to
    end

    private

    def out(to_out)
      if to_out.is_a? Recognizer::State
        @to_output.concat(to_out.transitions.values)

        state_output to_out
      elsif to_out.is_a? Recognizer::Rule
        rule_output to_out
      elsif to_out.is_a? Array
        production_output to_out
      end
    end

    def state_output(state)
<<-BLOCK
State #{state.id}:
  rules:
#{state.rules.map { |r| rule_output(r)} }.join("\n")}

  transitions:
#{state_transitions_output(state)}

BLOCK
    end

    def rule_output(rule)
<<-RULE
    #{rule.left} → #{rule.right[0, rule.position].map(&:to_s).join(" ")} • #{rule.right[rule.position..-1].map(&:to_s).join(" ")}"
      #{rule.lookahead}
RULE
    end

    def production_output(prods)
      buf = "productions:\n  "
      buf << prods.map do |prod|
        p prod
        "#{prod.left} → #{prod.right.map(&:to_s).join(" ")}"
      end.join("\n  ") << "\n\n"
    end

    def state_transitions_output(state)
      state.transitions.map do |transition|
<<-BLOCK.chomp
    #{transition[0]}: State #{transition[1].id}
BLOCK
      end.join("\n")
    end
  end
end
