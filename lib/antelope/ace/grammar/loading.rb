module Antelope
  module Ace
    class Grammar
      module Loading
        module ClassMethods
          def from_file(file_name)
            from_string File.read(file_name)
          end

          def from_string(string)
            scanner  = Ace::Scanner.scan(string)
            compiler = Ace::Compiler.compile(scanner)
            new(compiler)
          end
        end

        def self.included(receiver)
          receiver.extend ClassMethods
        end
      end
    end
  end
end
