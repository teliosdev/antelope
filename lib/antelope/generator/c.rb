module Antelope
  module Generator
    class C < Group
      register_as "c", "C"

      has_directive "api.push-pull", String
      has_directive "namespace", String

      register_generator CHeader, "c-header"
      register_generator CSource, "c-source"

    end
  end
end
