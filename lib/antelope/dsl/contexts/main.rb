module Antelope
  module DSL
    module Contexts
      # The main context of the Antelope DSL.
      class Main < Base
        def define(pass)
          pass.each do |key, value|
            case value
            when Array
              @defines[key] = value
            else
              @defines[key] = [value]
            end
          end
        end

        def terminals(&block)
          @terminals.merge! context(Terminal, &block)
        end

        def precedences(&block)
          @precedences = context(Precedence, &block)
        end

        def productions(&block)
          @productions = context(Production, &block)
        end

        def template(template)
          case template
          when Hash
            @templates.merge(template)
          when String
            @templates[:default] = template
          else
            raise ArgumentError, "Unexpected #{template.class}, " \
              "expected String or Hash"
          end
        end

        private

        def before_call
          @defines     = {}
          @templates   = {}
          @terminals   = {}
          @precedences = []
          @productions = []
        end

        def data
          {
            defines:     @defines,
            templates:   @templates,
            terminals:   @terminals,
            precedences: @precedences,
            productions: @productions
          }
        end
      end
    end
  end
end
