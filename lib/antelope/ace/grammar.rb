require "antelope/ace/grammar/terminals"
require "antelope/ace/grammar/productions"
require "antelope/ace/grammar/presidence"
require "antelope/ace/grammar/loading"
require "antelope/ace/grammar/generation"

module Antelope
  module Ace
    class Grammar

      include Terminals
      include Productions
      include Presidence
      include Loading
      include Generation

      attr_accessor :states

      def initialize(compiler)
        @compiler = compiler
      end
    end
  end
end
