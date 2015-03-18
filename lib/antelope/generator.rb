# encoding: utf-8
require "erb"
require "pathname"

module Antelope

  # Contains the classes that generate parsers.  This contains a
  # registery of all of the generators available to antelope.
  module Generator

    # Returns a hash of all of the generators registered within this
    # module.  If a generator is accessed that does not exist on the
    # hash, it by default returns the {Generator::Null} class.
    #
    # @return [Hash<(Symbol, String) => Generator::Base>]
    def generators
      @_generators ||= Hash.new { |h, k| h[k] = Generator::Null }
    end
    # Returns a hash of all of the directives that are available in
    # the generators of this module.
    #
    # @see .generators
    # @return [Hash]
    def directives
      generators.values.map(&:directives).
        inject({}, :merge)
    end

    # Registers a generator with the given names.  If multiple names
    # are given, they are assigned the generator as a value in the
    # {#generators} hash; otherwise, the one name is assigned the
    # generator as a value.
    #
    # @param generator [Generator::Base] the generator class to
    #   associate the key with.
    # @param name [String, Symbol] a name to associate the generator
    #   with.
    def register_generator(generator, *names)
      names = [names].flatten
      raise ArgumentError,
        "Requires at least one name" unless names.any?
      raise ArgumentError,
        "All name values must be a Symbol or string" unless names.
        all? {|_| [Symbol, String].include?(_.class) }

      names.each do |name|
        generators[name.to_s.downcase] = generator
      end
    end

    extend self

  end
end

require "antelope/generator/base"
require "antelope/generator/group"
require "antelope/generator/info"
require "antelope/generator/error"
require "antelope/generator/output"
require "antelope/generator/html"
require "antelope/generator/ruby"
require "antelope/generator/null"
require "antelope/generator/c_header"
require "antelope/generator/c_source"
require "antelope/generator/c"
