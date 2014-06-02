module Antelope
  class Parser
    module Tokens
      module ClassMethods

        def tokens
          if block_given?
            @_tokens = []
            TokenBuilder.new(self).run(&Proc.new)
          else
            @_tokens
          end
        end
      end

      module InstanceMethods

      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end

      class TokenBuilder < Builder

        def token(name)
          parent.tokens << name
        end

      end
    end
  end
end
