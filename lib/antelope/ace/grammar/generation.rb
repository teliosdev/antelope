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

      DEFAULT_GENERATORS = {
        "ruby" => [Generator::Ruby]
      }

      # Handles the generation of output for the grammar.
      module Generation

        # Generates the output.  First, it runs through every given
        # modifier, and instintates it.  It then calls every modifier,
        # turns it into a hash, and passes that hash to each of the
        # given generators.
        #
        # @param options [Hash] options.
        # @param generators [Array<Generator>] a list of generators
        #   to use in generation.
        # @param modifiers [Array<Array<(Symbol, #call)>>] a list of
        #   modifiers to apply to the grammar.
        # @return [void]
        def generate(options    = {},
                     generators = :guess,
                     modifiers  = DEFAULT_MODIFIERS)
          mods = modifiers.map(&:last).
            map  { |x| x.new(self) }
          mods.each do |mod|
            puts "Running mod #{mod.class}..."
            mod.call
          end
          hash = Hash[modifiers.map(&:first).zip(mods)]
          # This is when we'd generate

          find_generators(generators, options).each do |gen|
            gen.new(self, hash).generate
          end
        end

        private

        # Find the corresponding generators.  If the first argument
        # isn't `:guess`, it returns the first argument.  Otherwise,
        # it tries to "intelligently guess" by checking the type from
        # the options _or_ the compiler.  If it is unable to find the
        # type, it will raise a {NoTypeError}.
        #
        # @raise [NoTypeError] if it could not determine the type of
        #   the generator.
        # @param generators [Symbol, Array<Generator>]
        # @param options [Hash]
        # @return [Array<Generator>]
        def find_generators(generators, options)
          return generators unless generators == :guess

          generators = [Generator::Output]

          # command line precedence...
          type = options[:type] || options["type"] ||
            compiler.options.fetch(:type)

          generators += DEFAULT_GENERATORS.fetch(type)

          generators

        rescue KeyError => e
          raise NoTypeError, "Undefined type #{type}"
        end
      end
    end
  end
end
