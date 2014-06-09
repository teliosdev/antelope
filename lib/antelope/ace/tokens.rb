module Antelope
  module Ace
    class Token
      attr_reader :name
      attr_accessor :from
      attr_accessor :to

      def initialize(name, value = nil)
        @name  = name
        @value = value
        @from  = nil
        @to    = nil
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

      def error?
        false
      end

      def to_s
        buf = if @value
          @value.inspect
        else
          @name.to_s
        end
        if (from or to)
          buf << "("
          buf << "#{from.id}" if from
          buf << ":#{to.id}"  if to
          buf << ")"
        end

        buf
      end

      def <=>(other)
        if other.is_a? Token
          to_a <=> other.to_a
        else
          super
        end
      end

      def ===(other)
        if other.is_a? Token
          without_transitions == other.without_transitions
        else
          super
        end
      end

      def without_transitions
        self.class.new(name, @value)
      end

      def hash
        to_a.hash
      end

      alias_method :eql?, :==

      def to_a
        [to, from,
          terminal?, nonterminal?, epsilon?, error?,
          name, @value]
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
      def initialize(*)
        super :epsilon
      end

      def epsilon?
        true
      end
    end

    class Error < Terminal
      def initialize(*)
        super :error
      end

      def error?
        true
      end
    end
  end
end
