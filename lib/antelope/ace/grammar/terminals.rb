module Antelope
  module Ace
    class Grammar
      module Terminals

        def terminals
          @_terminals ||= begin
            @compiler.options.fetch(:terminals, []).map do |v|
              Terminal.new(*v)
            end
          end
        end
      end
    end
  end
end
