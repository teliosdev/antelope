module Antelope
  class Parser
    module States
      module ClassMethods

        attr_accessor :states

      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
