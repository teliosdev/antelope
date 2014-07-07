module Antelope
  module Generator
    class CSource < Base

      has_directive "union", String

      def guard_name
        namespace.upcase
      end

      def namespace
        if grammar.options[:namespace].any?
          grammar.options[:namespace][0]
        else
          grammar.name
        end.gsub(/[^A-Za-z]/, "_")

      end

      def generate
        template "c_source.erb", "#{file}.c"
      end
    end
  end
end
