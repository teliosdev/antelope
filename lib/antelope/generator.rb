require "antelope/generator/conflictor"
require "antelope/generator/constructor"
require "antelope/generator/recognizer"
require "antelope/generator/table"

module Antelope
  class Generator

    def initialize(parser, *mods)
      @parser = parser
      @mods   = mods
    end

  end
end
