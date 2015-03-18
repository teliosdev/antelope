# encoding: utf-8

module Antelope
  module Generator

    # Generates an output file, mainly for debugging.  Included always
    # as a generator for a grammar.
    class Error < Base

      register_as "error"

      has_directive "output.show-lookahead", Boolean

      # Defines singleton method for every mod that the grammar passed
      # to the generator.
      #
      # @see Generator#initialize
      def initialize(*)
        super
        mods.each do |k, v|
          define_singleton_method (k) { v }
        end
      end

      # Actually performs the generation.  Uses the template in
      # output.erb, and generates the file `<file>.output`.
      #
      # @return [void]
      def generate
        template "error", "#{file}.err"
      end
    end
  end
end
