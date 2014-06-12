module Antelope
  class Generator
    class Ruby < Generator

      def generate_action_table
        out = ""
        PP.pp(mods[:table].table, out)
        out
      end

      def generate_productions_list
        out = "["
        rules = mods[:table].rules.each do |rule|
          next out << "nil, " unless rule

          out                       <<
            "["                     <<
            rule.left.name.inspect  <<
            ", "                    <<
            rule.right.size.inspect <<
            ", "

          block = if rule.production.block.empty?
            "proc {}"
          else
            "proc #{rule.production.block}"
          end

          out << block << "],\n"
        end

        out.chomp!(",\n")

        out << "]"
      end

      def generate
        template "ruby.erb", "#{file}_parser.rb" do |body|
          sprintf(grammar.compiler.body, :write => body)
        end
      end
    end
  end
end
