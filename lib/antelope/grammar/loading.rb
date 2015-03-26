# encoding: utf-8

module Antelope
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
          ext = File.extname(file_name)
          case ext
          when ".rb", ".ate"
            from_dsl_file(file_name)
          when ".ace"
            from_ace_file(file_name)
          else
            raise ArgumentError, "Unexpected file extension #{ext},"\
              " expected one of .rb, .ate, or .ace"
          end
        end

        def from_dsl_file(file_name)
          body   = File.read(file_name)
          output = File.dirname(file_name)
          from_dsl_string(file_name, output, body)
        end

        def from_ace_file(file_name)
          body   = File.read(file_name)
          output = File.dirname(file_name)
          name   = File.basename(file_name)
          from_ace_string(name, output, body)
        end

        # Loads a grammar from a string.  First runs the scanner and
        # compiler over the string, and then instantiates a new
        # Grammar from the resultant.
        #
        # @param file [String] the path of the grammar.  This is
        #   used for eval.
        # @param output [String] the output directory.
        # @param string [String] the grammar body.
        # @return [Grammar]
        # @see DSL::Compiler
        def from_dsl_string(file, output, string)
          eval(string, TOPLEVEL_BINDING, file, 0)
          grammar = Antelope.grammar
          compiler = DSL::Compiler.compile(grammar[1], &grammar[2])
          new(File.basename(file), output, compiler)
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
        def from_ace_string(name, output, string)
          scanner  = Ace::Scanner.scan(string, name)
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
