module Antelope
  module Ace
    class Grammar

      # The default modifiers for generation.  It's not really
      # recommended to (heh) modify this; however, adding your own
      # modifier is always acceptable.
      DEFAULT_MODIFIERS = [
        [:recognizer,  Generation::Recognizer ],
        [:constructor, Generation::Constructor],
        [:tableizer,   Generation::Tableizer  ]
      ].freeze

      # The (as of right now) default generators.  Later on, the
      # grammar will guess which generators are needed for the
      # specific ace file.
      DEFAULT_GENERATORS = [Generator::Output, Generator::Ruby].freeze

      # Handles the generation of output for the grammar.
      module Generation

        # Generates the output.  First, it runs through every given
        # modifier, and instintates it.  It then calls every modifier,
        # turns it into a hash, and passes that hash to each of the
        # given generators.
        #
        # @param generators [Array<Generator>] a list of generators
        #   to use in generation.
        # @param modifiers [Array<Array<(Symbol, #call)>>] a list of
        #   modifiers to apply to the grammar.
        # @return [void]
        def generate(generators = DEFAULT_GENERATORS,
                     modifiers  = DEFAULT_MODIFIERS)
          mods = modifiers.map(&:last).
            map  { |x| x.new(self) }
          mods.map(&:call)
          hash = Hash[modifiers.map(&:first).zip(mods)]
          # This is when we'd generate
          generators.each do |gen|
            gen.new(self, hash).generate
          end
        end
      end
    end
  end
end
