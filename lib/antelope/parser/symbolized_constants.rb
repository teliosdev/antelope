module Antelope
  class Parser
    module SymbolizedConstants
      module ClassMethods
        def const_missing(name)
          name
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
