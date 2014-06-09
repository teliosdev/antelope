module Antelope
    class AceError < StandardError
    end

  module Ace
    class SyntaxError < AceError
    end
    class UndefinedTokenError < AceError
    end
    class UnknownDirectiveError < AceError
    end
  end
end
