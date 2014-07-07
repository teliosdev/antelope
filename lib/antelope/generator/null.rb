module Antelope
  module Generator

    # Represents a generator that does not generate anything.
    class Null < Base

      register_as "null"

      # Does nothing.
      #
      # @return [void]
      def generate; end
    end
  end
end
