module Antelope
  module DSL
    module Contexts
      class Terminal < Base
        def terminal(map, value = true)
          case map
          when Hash
            @terminals.merge!(map)
          when Symbol, String
            @terminals[map] = value
          else
            raise ArgumentError, "Unexpected #{map.class}, expected " \
              "Hash or Symbol"
          end
        end

        private

        attr_reader :terminals
        alias_method :data, :terminals

        def before_call
          @terminals = {}
        end
      end
    end
  end
end
