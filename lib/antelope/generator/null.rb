module Antelope
  module Generator

    # Represents a generator that does not generate anything.
    class Null < Base

      register_as "null"

      has_directive "null.data"
      has_directive "comment"

      # Does nothing.
      #
      # @return [void]
      def generate; end
    end
  end
end
