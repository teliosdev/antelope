module Antelope
  module Ace
    class Grammar

      DEFAULT_MODIFIERS = [
        Generator::Recognizer,
        Generator::Constructor,
        Generator::Conflictor,
        Generator::Table
      ].freeze

      DEFAULT_GENERATOR = nil

      module Generation
        def generate(generator = DEFAULT_GENERATOR,
                     modifiers = DEFAULT_MODIFIERS)
          mods = modifiers.
            map  { |x| x.new(self) }
          results = mods.map(&:call)
          # This is when we'd generate
          mods
        end
      end
    end
  end
end
