# encoding: utf-8

require "thor"

module Antelope

  # Handles the command line interface.
  class CLI < Thor

    class_option :verbose, default: false, type: :boolean

    option :type, default: nil, type: :string,
      desc: "The type of generator to use"
    desc "compile FILE [FILE]*", "compile the given files"

    # Compile.
    def compile(*files)
      files.each do |file|
        compile_file(file)
      end
    end

    desc "check FILE [FILE]*", "check the syntax of the given files"

    # Check.
    def check(*files)
      files.each do |file|
        compile_file(file, [Generator::Null])
      end
    end

    private

    # Compiles the given file, and then generates.  If an error
    # occurs, it prints it out to stderr, along with a backtrace if
    # the verbose flag was set.
    #
    # @param file [String] the file to compile.
    # @param gen [Array, Symbol] the generator to use.
    # @return [void]
    def compile_file(file, gen = :guess)
      puts "Compiling #{file}... "

      grammar = Ace::Grammar.from_file(file)
      grammar.generate(options, gen)

    rescue => e
      $stderr.puts "Error while compiling: #{e.class}: #{e.message}"

      if options[:verbose]
        $stderr.puts e.backtrace[0..10].map { |_| "\t#{_}" }
      end
    end
  end
end
