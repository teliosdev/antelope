require "hashie/mash"
require "erb"

module Antelope
  module Output

    extend self

    class Context < Hashie::Mash
      def bind
        binding
      end
    end

    def output(parser, others = {})
      context = Context.new
      context.parser = parser
      context.merge!   others
      template.result(context.bind)
    end

    def template
      @template ||= begin
        file = File.open(
              File.expand_path("../output.erb", __FILE__), "r")
        ERB.new(file.read, 0, "%")
      end
    end
  end
end
