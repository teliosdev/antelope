# encoding: utf-8

module Antelope
  class Parser
    module Productions
      module ClassMethods

        def productions
          if block_given?
            @_productions = {}
            @_building_productions = true
            ProductionBuilder.new(self).run(&Proc.new)
            @_building_productions = false
            productions[:"$start"] = [{
              :items => [Nonterminal.new(start_production), Terminal.new(:"$")],
              :block => proc {} }]
          else
            @_productions
          end
        end

        def const_missing(name)
          if @_building_productions ||= false
            Terminal.new(name)
          else
            super
          end
        end

        def start_production(production = nil)
          if production
            @_start_production = production
          else
            @_start_production
          end
        end

      end

      class ProductionBuilder < Builder

        def production(name, options = {}, &block)
          rule = RuleBuilder.new(name).run(&block)
          parent.productions[name] = rule
          if options[:start]
            parent.start_production(name)
          end

          rule
        end
      end

      class RuleBuilder < Builder
        def initialize(name)
          @name = name
          @matches = []
        end

        def run
          super
          @matches
        end

        def match(*items, &block)
          @matches << { :items => [items].flatten, :block => block || proc{} }
        end

        def ε
          Epsilon.new
        end

        alias_method :nothing, :ε

        def method_missing(method)
          # It's a terminal!
          token = if method.to_s.upcase == method.to_s
            Terminal.new(method)
          else
            Nonterminal.new(method)
          end
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
