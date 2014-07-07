module Antelope
  module Generator
    class CHeader < Base

      register_as "c-header", "c_header"

      has_directive "union", String

      def initialize(*)
        super
      end

      def push?
        grammar.options[:"api.push-pull"][0] == "push"
      end

      def guard_name
        namespace.upcase
      end

      # @return [Hash]
      def union
        @_union ||= begin
          union = grammar.options[:union]
          {
            type: if union.empty? || union.one?
              "#{namespace}_type"
            else
              grammar.options[:union][0]
            end,
            body: if union.empty?
              "{}"
            elsif union.one?
              union[0]
            else
              union[1]
            end
          }.freeze
        end
      end

      def namespace
        if grammar.options[:namespace].any?
          grammar.options[:namespace][0]
        else
          grammar.name
        end.gsub(/[^A-Za-z]/, "_")

      end

      def generate
        template "c_header.erb", "#{file}.h"
      end
    end
  end
end
