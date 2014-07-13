module Antelope
  module Generator
    class C < Group
      register_as "c", "C"

      register_generator CHeader, "c-header"
      register_generator CSource, "c-source"

    end
  end
end
