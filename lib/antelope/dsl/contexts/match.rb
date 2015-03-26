module Antelope
  module DSL
    module Contexts
      class Match < Base
        def match(options)
          body   = options.fetch(:body)
          action = options.fetch(:action)
          prec   = options.fetch(:prec, '')

          @matches << { body: body, action: "{#{action}}", prec: prec }
        end

        private

        attr_reader :matches
        alias_method :data, :matches

        def before_call
          @matches = []
        end
      end
    end
  end
end
