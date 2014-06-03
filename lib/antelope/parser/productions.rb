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
              :block => nil }]
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
        def method_missing(production, &block)
          rule = RuleBuilder.new(production).run(&block)
          parent.productions[production] = rule
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

        def match(items, &block)
          @matches << { :items => [items].flatten, :block => block }
        end

        def ε
          Epsilon.new
        end

        alias_method :nothing, :ε

        def method_missing(method, *args)
          # It's a terminal!
          token = if method.to_s.upcase == method.to_s
            Terminal.new(method)
          else
            Nonterminal.new(method)
          end

          [token, args].flatten
        end
      end

      module InstanceMethods

      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
