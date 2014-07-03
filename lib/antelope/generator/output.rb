# encoding: utf-8

require "pp"

module Antelope
  class Generator

    # Generates an output file, mainly for debugging.  Included always
    # as a generator for a grammar.
    class Output < Generator

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

      def unused_symbols
        @_unused_symbols ||= begin
          used = grammar.all_productions.map(&:items).flatten.uniq
          all  = grammar.symbols.map do |s|
            if Symbol === s
              grammar.find_token(s)
            else
              s
            end
          end

          all - used - [grammar.find_token(:"$start")]
        end
      end

      # Actually performs the generation.  Uses the template in
      # output.erb, and generates the file `<file>.output`.
      #
      # @return [void]
      def generate
        template "output.erb", "#{file}.output"
      end
    end
  end
end
