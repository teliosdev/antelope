module Antelope
  module Generator
    class Constructor
      module Follow

        def initialize
          @follows = {}
          super
        end

        def follow(token)

          if token.nonterminal?
            token = token.value
          elsif token.is_a? Symbol
          else
            incorrect_argument! token, Parser::Nonterminal, Symbol
          end

          @follows.fetch(token) do
            @follows[token] = Set.new
            set = Set.new

            parser.productions.each do |key, value|
              value.each do |production|
                items = production[:items]
                positions = items.each_with_index.
                  find_all { |t, _| t.value == token }.
                  map(&:last).map(&:succ)
                positions.map { |pos| first(items[pos..-1]) }.
                  inject(set, :merge)
                positions.each do |pos|
                  if pos == items.size || nullable?(items[pos..-1])
                    set.merge follow(Parser::Nonterminal.new(key))
                  end
                end
              end
            end

            @follows[token] = set
          end
        end
      end
    end
  end
end
