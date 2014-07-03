module Antelope
  module Generator

    # For use to use multiple generators as a bundle.  Works exactly
    # like a normal generator, i.e. responds to both {.register_as}
    # and {#generate}, but also responds to {.register_generator},
    # like {Generator}.  Any generators registered to the group are
    # used to generate the files.
    #
    # @abtract Subclass and use {.register_generator} to create a
    #   group generator.
    class Group < Base

      extend Generator

      # Initialize the group generator.  Calls {Base#initialize}, and
      # then instantizes all of the generators in the group.
      def initialize(*_)
        super

        generators.map! do |gen|
          gen.new(*_)
        end
      end

      # Generates files using the generators contained within this
      # group.  If it encounters an error in one of the generators, it
      # will continue to try to generate the rest of the generators.
      # It will then raise the last error given at the end.
      #
      # @return [void]
      def generate
        error = nil
        generators.map do |gen|
          begin
            gen.generate
          rescue => e
            $stderr.puts "Error running #{gen.class}: #{e.message}"
            error = e
          end
        end

        raise error if error
      end

      private

      # Retrieve a list of all of the generators that are contained
      # within this group.
      #
      # @return [Array<Generator::Base>]
      def generators
        @_generators ||= self.class.generators.values
      end
    end
  end
end
