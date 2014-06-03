module Antelope
  class Constructor
    module Follow

      def initialize
        @follows = {}
        super
      end

      def follow(token)
        return Set.new unless token.nonterminal?

        @follows.fetch(token) do
          @follows[token] = Set.new
          set = Set.new
          parser.productions.each do |key, value|
            value.each do |production|
              items = production[:items]
              parts = items.each_with_index.
                find_all { |t, i| t == token }
              parts.each do |(_, i)|
                set = set + items.slice(i + 1).
                  map { |item| first(item) }
              end
            end
          end

          @follows[token] = set
        end
      end
    end
  end
end
