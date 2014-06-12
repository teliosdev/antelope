require "pp"

module Antelope
  class Generator
    class Output < Generator

      def initialize(*)
        super
        mods.each do |k, v|
          define_singleton_method (k) { v }
        end
      end

      def generate
        template "output.erb", "#{file}.output"
      end

      def parser
        grammar
      end
    end
  end
end
