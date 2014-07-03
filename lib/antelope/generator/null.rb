module Antelope
  module Generator

    # Represents a generator that does not generate anything.
    class Null < Base

      # Does nothing.
      #
      # @return [void]
      def generate; end
    end
  end
end
