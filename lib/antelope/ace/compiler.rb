module Antelope
  module Ace
    class Compiler

      attr_accessor :body
      attr_accessor :rules
      attr_accessor :options

      def self.compile(tokens)
        compiler = new(tokens)
        compiler.compile
        compiler
      end

      def initialize(tokens)
        @tokens   = tokens
        @body     = ""
        @state    = :first
        @rules    = []
        @current  = nil
        @current_label = nil
        @options  = { :terminals => [], :prec => [] }
      end

      def compile
        @pos = 0

        until @tokens.size == @pos
          token = @tokens[@pos]
          @pos += 1
          send(:"compile_#{token[0]}", *token[1..-1])
        end

        self
      end

      def compile_directive(name, args)
        require_state! :first
        name = name.to_sym
        case name
        when :terminal
          @options[:terminals] << [args[0].intern, args[1]]
        when :require
          if args[0] > Antelope::VERSION
            raise IncompatibleVersionError,
              "Grammar requires #{args[0]}, " \
              "have #{Antelope::VERSION}"
          end
        when :left, :right, :nonassoc
          @options[:prec] << [name, *args.map(&:intern)]
        when :type
          @options[:type] = args[0]
        else
          raise UnknownDirectiveError, "Unknown Directive: #{name}"
        end
      end

      def compile_second
        @state = :second
      end

      def compile_third
        if @current
          @rules << @current
          @current_label = @current = nil
        end

        @state = :third
      end

      def compile_copy(body)
        require_state! :first
        @body << body
      end

      def compile_label(label)
        require_state! :second
        if @current
          @rules << @current
        end

        @current_label = label.intern

        @current = {
          label: @current_label,
          set:   [],
          block: "",
          prec:  ""
        }
      end

      def compile_part(text)
        require_state! :second
        @current[:set] << text.intern
      end

      def compile_or
        compile_label(@current_label)
      end

      def compile_prec(prec)
        require_state! :second
        @current[:prec] = prec
      end

      def compile_block(block)
        require_state! :second
        @current[:block] = block
      end

      def compile_body(body)
        require_state! :third
        @body << body
      end

      private

      def require_state!(state)
        raise InvalidStateError,
          "In state #{@state}, " \
          "required state #{state}" unless @state == state
      end

      def shift
        @tokens[@pos]
        @pos += 1
      end
    end
  end
end
