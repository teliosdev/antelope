module Antelope
  module Generator
    class CHeader < Base

      register_as "c-header", "c_header"

      has_directive "union", Array[String, String]
      has_directive "api.prefix", String
      has_directive "api.push-pull", String
      has_directive "api.value.type", String
      has_directive "api.token.prefix", String
      has_directive "parse-param", Array
      has_directive "lex-param", Array
      has_directive "param", Array

      def push?
        directives.api.push_pull == "push"
      end

      def define_stype?
        !!directives.union[0] && !directives.api.value.type
      end

      def lex_params
        params = [directives.lex_param, directives.param].compact.
          flatten

        if params.any?
          ", " << params.join(", ")
        else
          ""
        end
      end

      def parse_params
        [directives.parse_param, directives.param].compact.flatten.
          join(", ")
      end

      def params
        if directives.param
          directives.param.join(", ")
        else
          ""
        end
      end

      def stype
        prefix.upcase << if directives.api.value.type
          directives.api.value.type
        elsif directives.union.size > 1
          directives.union[0]
        else
          "STYPE"
        end
      end

      def union_body
        directives.union.last
      end

      def terminal_type
        "int" # for now
      end

      def token_prefix
        if directives.api.token.prefix
          directives.api.token.prefix
        elsif directives.api.prefix
          prefix.upcase
        else
          ""
        end
      end

      def prefix
        if directives.api.prefix
          directives.api.prefix
        else
          "yy"
        end
      end

      def upper_prefix
        prefix.upcase
      end

      def symbols
        @_symbols ||= begin
          sym  = grammar.terminals.map(&:name) + grammar.nonterminals
          nums = sym.each_with_index.map { |v, i| [v, i + 257] }
          Hash[nums]
        end
      end

      def guard_name
        "#{prefix.upcase}#{file.gsub(/[\W]/, "_").upcase}"
      end

      def generate
        template "c_header", "#{file}.h"
      end
    end
  end
end
