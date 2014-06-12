module Antelope
  module Ace
    class Grammar

      DEFAULT_MODIFIERS = {
        recognizer:  Generation::Recognizer,
        constructor: Generation::Constructor,
        conflictor:  Generation::Conflictor,
        table:       Generation::Table
      }.freeze

      DEFAULT_GENERATORS = [Generator::Output, Generator::Ruby]

      module Generation
        def generate(generators = DEFAULT_GENERATORS,
                     modifiers  = DEFAULT_MODIFIERS)
          mods = modifiers.values.
            map  { |x| x.new(self) }
          mods.map(&:call)
          hash = Hash[modifiers.keys.zip(mods)]
          # This is when we'd generate
          generators.each do |gen|
            gen.new(self, hash).generate
          end
        end
      end
    end
  end
end
