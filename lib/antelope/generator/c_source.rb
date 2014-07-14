module Antelope
  module Generator
    class CSource < CHeader

      def action_for(state)
        out = ""

        grammar.terminals.each do |terminal|
          action = state[terminal.name]

          if action.size == 2 && action[0] == :state
            out << "#{action[1] + 1}, "
          elsif action.size == 2 &&
            [:reduce, :accept].include?(action[0])
            if $DEBUG
              out << "#{prefix.upcase}STATES + #{action[1] + 1}, "
            else
              out << "#{table.size + action[1] + 1}, "
            end
          else
            out << "0, "
          end

        end

        out.chomp(", ")
      end

      def cify_block(block)
        block.gsub(/\$([0-9]+)/, "#{prefix}vals[\\1]")
             .gsub(/\$\$/, "#{prefix}out")
      end

      def generate
        template "c_source", "#{file}.c"
      end
    end
  end
end
