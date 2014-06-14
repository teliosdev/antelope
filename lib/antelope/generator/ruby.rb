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

        grammar.all_productions.each do |production|
          out                              <<
            "["                            <<
            production.label.name.inspect  <<
            ", " << production.items.size.inspect  <<
            ", "

          block = if production.block.empty?
            "proc {}"
          else
            "proc #{production.block}"
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
