require "antelope/generator/output"
require "antelope/generator/ruby"
require "erb"
require "pathname"

module Antelope

  # Generates a parser.  This is normally the parent class, and the
  # specific implementations inherit from this.  The generated
  # parser should, ideally, be completely independent (not requiring
  # any external source code), as well as be under a permissive
  # license.
  class Generator

    attr_reader :mods
    attr_reader :file
    attr_reader :grammar

    def self.source_root
      Pathname.new("../generator/templates").expand_path(__FILE__)
    end

    def initialize(grammar, mods)
      @file    = grammar.name
      @grammar = grammar
      @mods    = mods
    end

    def generate
      raise NotImplementedError
    end

    def template(source, destination)
      src_file  = self.class.source_root + source
      src       = src_file.open("r")
      context   = instance_eval('binding')
      content   = ERB.new(src.read, nil, "%").result(context)
      content   = yield content if block_given?
      dest_file = grammar.output + destination
      dest_file.open("w") do |f|
        f.write(content)
      end
    end

  end
end
