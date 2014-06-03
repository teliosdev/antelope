module Antelope
  class Parser
    module Presidence
      module ClassMethods

        def presidence
          if block_given?
            @_presidence = []
            PresidenceBuilder.new(self).run(&Proc.new)
          else
            @_presidence
          end
        end

      end

      class PresidenceBuilder < Builder

        def left(*level)
          _level(:left, level)
        end

        def right(*level)
          _level(:right, level)
        end

        def nonassoc(*level)
          _level(:nonassoc, level)
        end

        def _level(type, level)
          parent.presidence << [type, level]
        end

      end

      module InstanceMethods

      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
