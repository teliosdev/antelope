module Antelope
  module Generator
    class Base
      # Handles coercion of directives and their values.
      module Coerce
        # Retrieves all directives from the grammar, and giving them
        # the proper values for this instance.
        #
        # @see .directive?
        # @see #coerce_directive_value
        # @return [Hash]
        def directives
          @_directives ||= begin
            hash = Hashie::Mash.new

            self.class.directives.each do |key, (_, definition)|
              directive_value =
                coerce_directive_value(grammar.options.key?(key),
                  grammar.options[key], definition)
              value = coerce_nested_hash(key, directive_value)
              hash.deep_merge!(value)
            end

            hash
          end
        end

        # Coerces a key of the format `<name>[.<name>]*` into a full
        # hash accessable by ruby.
        #
        # @param key [String] the key of the directive.
        # @param value [String] the value of the directive.
        # @return [Hash] the resultant hash.
        def coerce_nested_hash(key, value)
          parts = key.split('.').map { |p| p.gsub(/-/, '_') }
          top   = {}
          hash  = top
          parts.each do |part|
            hash[part] = if parts.last == part
                           value
                         else
                           {}
                         end
            hash = hash[part]
          end

          top[key] = value
          top
        end

        # Coerce the given directive value to the given type.  For the
        # type `nil`, it checks the size of the values; for no values,
        # it returns true; for one value, it returns that one value;
        # for any other size value, it returns the values.  For the
        # type `Boolean`, if no values were given, or if the first
        # value isn't "false", it returns true.  For the type
        # `:single` (or `:one`), it returns the first value.  For the
        # type `Array`, it returns the values.  For any other type
        # that is a class, it tries to initialize the class with the
        # given arguments.
        #
        # @param defined [Boolean] Whether or not the value was
        #   actively defined in the grammar.
        # @param values [Array<String>] The values that the directive
        #   was defined with.
        # @param type [Object?] The type expected of the arguments
        #   given.
        # @return [Object?]
        def coerce_directive_value(defined, values, type)
          return nil unless defined || type.is_a?(Array)

          case type
          when nil
            values.any? ? values[0] : true
          when :single, :one
            values[0]
          when Boolean
            values[0].to_s != 'false'
          when Array
            values.zip(type).map do |value, t|
              coerce_directive_value(defined, [value], t)
            end
          when Class
            coerce_directive_class(values, type)
          else
            raise UnknownTypeError, "unknown type #{type}"
          end
        end

        # If the expected of the directive is a Class, then we try to
        # determine which class is expected, and return the proper
        # values.
        #
        # @param values [Array<String>] The values that the directive
        #   was defined with.
        # @param type [Class] The type expected of the arguments
        #   given.
        # @return [Object]
        def coerce_directive_class(values, type)
          if type == Array
            values
          elsif type == String
            values[0].to_s
          elsif type == Fixnum || type == Integer || type == Numeric
            values[0].to_i
          elsif type == Float
            values[0].to_f
          else
            type.new(*values)
          end
        end
      end
    end
  end
end
