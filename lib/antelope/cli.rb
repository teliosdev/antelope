require "thor"

module Antelope
  class CLI < Thor

    class_option :verbose, default: false, type: :boolean

    option :type, default: nil, type: :string,
      desc: "The type of generator to use"
    desc "compile FILE [FILE]*", "compile the given files"
    def compile(*files)
      files.each do |file|
        compile_file(file)
      end
    end

    private

    def compile_file(file)
      puts "Compiling #{file}... "

      grammar = Ace::Grammar.from_file(file)
      grammar.generate(options)

    rescue => e
      $stderr.puts "Error while compiling: #{e.class}: #{e.message}"

      if options[:verbose]
        $stderr.puts e.backtrace[0..10].map { |_| "\t#{_}" }
      end
    end
  end
end
