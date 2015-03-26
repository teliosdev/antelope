module Antelope
  module DSL
    module Contexts
      class Production < Base
        def production(name, &block)
          @productions[name].concat(context(Match, &block))
        end

        private

        attr_reader :productions
        alias_method :data, :productions

        def before_call
          @productions = Hash.new { |h, k| h[k] = [] }
        end

        def data
          @productions
        end
      end
    end
  end
end
