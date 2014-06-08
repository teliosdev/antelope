module Antelope
  class Parser

    DEFAULT_MODIFIERS = [
      Generator::Recognizer,
      Generator::Constructor,
      Generator::Conflictor,
      Generator::Table
    ].freeze

    DEFAULT_GENERATOR = nil # we don't have one yet

    module Generation
      module ClassMethods

        def generate(generator = DEFAULT_GENERATOR,
                     modifiers = DEFAULT_MODIFIERS)
          results = modifiers.
            map  { |x| x.new(self) }.
            each { |x| x.call }
          # This is when we'd generate
          results
        end

      end

      module InstanceMethods

      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
