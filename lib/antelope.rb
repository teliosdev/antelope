# encoding: utf-8

require 'antelope/errors'
require 'antelope/generation'
require 'antelope/generator'
require 'antelope/version'
require 'antelope/grammar'
require 'antelope/ace'
require 'antelope/dsl'
require 'antelope/template'

# Antelope, the compiler compiler.
module Antelope
  def self.define(name, options = {}, &block)
    @grammar = [name, options, block]
  end

  class << self; attr_reader :grammar; end
end
