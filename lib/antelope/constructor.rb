require "set"
require "antelope/constructor/nullable"
require "antelope/constructor/first"
require "antelope/constructor/follow"
require "antelope/constructor/lookahead"

module Antelope
  class Constructor

    include Nullable
    include First
    include Follow
    include Lookahead

    def initialize(start, parser)
      @start       = start
      @parser      = parser
      super()
    end

    private

    def incorrect_argument!(arg, *types)
      raise ArgumentError, "Expected one of #{types.join(", ")}, got #{arg.class}"
    end
  end
end
