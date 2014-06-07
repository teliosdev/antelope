module Antelope
  module Generator
    class Constructor
      module Lookahead

        def initialize
          @lookaheads = {}
          super
        end

        def lookahead(left, right = nil)
          @lookaheads.fetch([left, right]) do
            if right
              set = Set.new

              set += if nullable?(right)
                first(right) + follow(left)
              else
                first(right)
              end
            else
              set = lookahead_nonterminal(left)
            end

            @lookaheads[[left, right]] = set
          end
        end

        private

        def lookahead_nonterminal(left)
          set = Set.new
          parser.productions[left].each do |production|
            set += lookahead(left, production[:items])
          end

          set
        end
      end
    end
  end
end
