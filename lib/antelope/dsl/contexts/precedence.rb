module Antelope
  module DSL
    module Contexts
      class Precedence < Base
        def precedence(type, contents)
          @precedences << [type].concat(contents)
        end

        private

        attr_reader :precedences
        alias_method :data, :precedences

        def before_call
          @precedences = []
        end
      end
    end
  end
end
