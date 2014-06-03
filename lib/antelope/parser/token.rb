module Antelope
  class Parser
    class Token
      attr_reader :value
      def initialize(value)
        @value = value
      end

      include Comparable

      def <=>(other)
        if other.is_a? Token
          [terminal?, nonterminal?, value] <=> [other.terminal?,
            other.nonterminal?, other.value]
        else
          super
        end
      end

      def terminal?
        false
      end

      def nonterminal?
        false
      end

      def to_s
        @value.to_s
      end
    end

    class Nonterminal < Token
      def nonterminal?
        true
      end
    end
    class Terminal < Token
      def terminal?
        true
      end
    end
  end
end
