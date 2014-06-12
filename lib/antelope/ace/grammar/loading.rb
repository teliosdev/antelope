module Antelope
  module Ace
    class Grammar
      module Loading
        module ClassMethods
          def from_file(file_name)
            body = File.read(file_name)
            output   = File.dirname(file_name)
            name     = File.basename(file_name).gsub(/\.[A-Za-z]+/, "")
            from_string(name, output, body)
          end

          def from_string(name, output, string)
            scanner  = Ace::Scanner.scan(string)
            compiler = Ace::Compiler.compile(scanner)
            new(name, output, compiler)
          end
        end

        def self.included(receiver)
          receiver.extend ClassMethods
        end
      end
    end
  end
end
