module Antelope
  module Ace
    class Grammar
      Production = Struct.new(:label, :items, :block, :prec, :id) do
        def self.from_hash(hash)
          new(hash[:label], hash[:items], hash[:block], hash[:prec], hash[:id])
        end
      end
    end
  end
end
