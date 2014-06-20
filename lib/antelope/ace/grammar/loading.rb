# encoding: utf-8

module Antelope
  module Ace
    class Grammar

      # Handles loading to and from files and strings.
      module Loading

        # Defines class methods on the grammar.
        module ClassMethods

          # Loads a grammar from a file.  Assumes the output
          # directory and name from the file name.
          #
          # @param file_name [String] the file name.
          # @return [Grammar]
          # @see #from_string
          def from_file(file_name)
            body     = File.read(file_name)
            output   = File.dirname(file_name)
            name     = File.basename(file_name).gsub(/\.[A-Za-z]+/, "")
            from_string(name, output, body)
          end

          # Loads a grammar from a string.  First runs the scanner and
          # compiler over the string, and then instantiates a new
          # Grammar from the resultant.
          #
          # @param name [String] the name of the grammar.
          # @param output [String] the output directory.
          # @param string [String] the grammar body.
          # @return [Grammar]
          # @see Ace::Scanner
          # @see Ace::Compiler
          def from_string(name, output, string)
            scanner  = Ace::Scanner.scan(string)
            compiler = Ace::Compiler.compile(scanner)
            new(name, output, compiler)
          end
        end

        # Extends the grammar with the class methods.
        #
        # @param receiver [Grammar]
        # @see ClassMethods
        def self.included(receiver)
          receiver.extend ClassMethods
        end
      end
    end
  end
end
