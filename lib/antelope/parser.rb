require "antelope/parser/token"
require "antelope/parser/terminals"
require "antelope/parser/presidence"
require "antelope/parser/productions"
require "antelope/parser/symbolized_constants"

module Antelope
  class Parser
    include SymbolizedConstants
    include Terminals
    include Presidence
    include Productions

  end
end