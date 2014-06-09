module Antelope
  module Ace
    Presidence = Struct.new(:type, :tokens, :level) do
      def <=>(other)
        if level != other.level
          other.level <=> level
        else
          if type == :left
            1
          elsif type == :right
            -1
          else
            0
          end
        end
      end
    end
  end
end
