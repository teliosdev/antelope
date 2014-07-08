module Antelope
  module Ace
    class Scanner
      class Argument < BasicObject
        def initialize(type, value)
          @type = type
          @value = value
        end

        def block?
          @type == :block
        end

        def text?
          @type == :text
        end

        def ==(other)
          @value == other
        end

        def method_missing(method, *args, &block)
          begin
            @value.public_send(method, *args, &block)
          rescue ::NoMethodError => e
            ::Kernel.raise e, e.message, e.backtrace[2..-1]
          end
        end
      end
    end
  end
end
