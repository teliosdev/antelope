module Antelope
  class Template
    class Error < Antelope::Error; end

    class SyntaxError < Error; end

    class NoTokenError < Error; end
  end
end
