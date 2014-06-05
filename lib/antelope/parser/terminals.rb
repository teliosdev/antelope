module Antelope
  class Parser
    module Terminals
      module ClassMethods

        def terminals
          if block_given?
            @_tokens = []
            TerminalBuilder.new(self).run(&Proc.new)
          else
            @_tokens
          end
        end
      end

      class TerminalBuilder < Builder

        def terminal(name)
          parent.terminals << name
        end

      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
