module Antelope
  class Parser
    class Token
      attr_reader :value
      def initialize(value)
        @value = value
      end

      include Comparable

      def terminal?
        false
      end

      def nonterminal?
        false
      end

      def epsilon?
        false
      end

      def to_s
        @value.to_s
      end

      def <=>(other)
        if other.is_a? Token
          other.to_a <=> other.to_a
        else
          super
        end
      end

      def hash
        to_a.hash
      end

      alias_method :eql?, :==

      def to_a
        [terminal?, nonterminal?, epsilon?, value]
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
    class Epsilon < Token
      def initialize
        super :epsilon
      end

      def epsilon?
        true
      end
    end
  end
end
