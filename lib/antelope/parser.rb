require 'antelope/parser/tokens'
require 'antelope/parser/presidence'
require 'antelope/parser/productions'

module Antelope
  class Parser
    include Tokens
    include Presidence
    include Productions

  end
end
