require "antelope/template/errors"
require "antelope/template/scanner"
require "antelope/template/compiler"


module Antelope
  class Template

    NO_SOURCE = Object.new


    def initialize(input, source = NO_SOURCE)
      @input  = normalize_input(input)
      @source = determine_source(input, source)
    end

    def parse
      @result ||= begin
        scanner  = Scanner.new(@input, @source)
        compiler = Compiler.new(scanner.scan)
        compiler.compile
      end
    end

    def result(binding = TOPLEVEL_BINDING.dup)
      # sue me.
      data = parse
      File.open("#{@source}.rb", "w") { |f| f.write(data) } 
      eval(parse, binding, "_#{@source}.rb", 0)
    end

    alias_method :run, :result
    alias_method :call, :result

    private

    def normalize_input(input)
      case
      when String === input
        input
      when input.respond_to?(:read)
        input.read
      when input.respond_to?(:open)
        input.open("r") { |f| f.read }
      else
        raise ArgumentError, "Received #{input.class}, expected " \
          "#{String}, #read"
      end
    end

    def determine_source(input, source)
      case
      when source != NO_SOURCE
        source
      when input.respond_to?(:to_path)
        input.to_path
      else
        "(template)"
      end
    end
  end
end
