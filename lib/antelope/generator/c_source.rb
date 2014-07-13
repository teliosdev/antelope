module Antelope
  module Generator
    class CSource < Base

      has_directive "union", Array[String, String]
      has_directive "c.namespace", String
      has_directive "api.push-pull", String

      def guard_name
        namespace.upcase
      end

      def namespace
        if directives["c.namespace"]
          directives["c.namespace"]
        else
          grammar.name
        end.gsub(/[^A-Za-z]/, "_")

      end

      def generate
        template "c_source", "#{file}.c"
      end
    end
  end
end
