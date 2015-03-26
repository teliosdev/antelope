module Antelope
  module DSL
    module Contexts
      # The base context, which implements some helper methods.
      class Base
        attr_reader :options

        def initialize(options)
          @options = options
          @contexts = Hash.new { |h, k| h[k] = k.new(@options) }
        end

        def call(&block)
          before_call
          instance_exec(self, &block)
          data
        end

        def context(name, &block)
          @contexts[name].call(&block)
        end

        def before_call; end

        def data; end
      end
    end
  end
end
