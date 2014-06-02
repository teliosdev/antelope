module Antelope
  class Builder

    attr_reader :parent

    def initialize(parent)
      @parent = parent
    end

    def run(&block)
      instance_exec &block
    end

  end
end
