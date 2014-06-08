module Antelope
  class Parser
    module Presidence
      module ClassMethods

        def presidence
          if block_given?
            @_presidence = []
            PresidenceBuilder.new(self).run(&Proc.new)
            presidence.sort_by! { |pr| pr.level }
            presidence << lowest_presidence
          else
            @_presidence ||= [lowest_presidence(0)]
          end
        end

        def presidence_for(token)
          token = token.value if token.is_a? Token

          set = Set.new([token, :_])
          presidence.
            select { |pr| set.intersect?(pr.tokens.to_set) }.
            first
        end

        def lowest_presidence(level = presidence.last.level + 1)
          Presidence.new(:nonassoc, [:_], level)
        end

      end

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

      class PresidenceBuilder < Builder

        def left(*tokens)
          _level(:left, tokens)
        end

        def right(*tokens)
          _level(:right, tokens)
        end

        def nonassoc(*tokens)
          _level(:nonassoc, tokens)
        end

        def _level(type, tokens)
          @line ||= 0
          parent.presidence << Presidence.new(type, tokens, @line)
          @line += 1
        end

      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
