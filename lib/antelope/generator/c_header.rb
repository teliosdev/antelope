module Antelope
  module Generator
    class CHeader < Base

      register_as "c-header", "c_header"

      has_directive "union", Array[String, String]
      has_directive "c.namespace", String
      has_directive "api.push-pull", String

      def initialize(*)
        super
      end

      def push?
        directives.api.push_pull == "push"
      end

      def guard_name
        namespace.upcase
      end

      # @return [Hash]
      def union
        @_union ||= begin
          Hash[[:body, :type].zip(directives.union.reverse)]
        end
      end

      def namespace
        if directives["c.namespace"]
          directives["c.namespace"]
        else
          grammar.name
        end.gsub(/[^A-Za-z]/, "_")

      end

      def generate
        template "c_header", "#{file}.h"
      end
    end
  end
end
