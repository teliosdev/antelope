
  require "antelope"

class SimpleParser < Antelope::Parser
  # This file assumes that the output of the generator will be placed
# within a module or a class.  However, the module/class requires a
# `type` method, which takes a terminal and gives its type, as a
# symbol.  These types should line up with the terminals that were
# defined in the original grammar.

ACTION_TABLE = [{:e=>[:state, 1],
  :l=>[:state, 2],
  :r=>[:state, 3],
  :IDENT=>[:state, 4],
  :STAR=>[:state, 5]},
 {:"$"=>[:state, 7]},
 {:EQUALS=>[:state, 8], :"$"=>[:reduce, 5]},
 {:"$"=>[:reduce, 2]},
 {:EQUALS=>[:reduce, 3], :"$"=>[:reduce, 3]},
 {:r=>[:state, 9], :l=>[:state, 2], :IDENT=>[:state, 4], :STAR=>[:state, 5]},
 {:"$"=>[:reduce, 5]},
 {:"$"=>[:accept, 0]},
 {:r=>[:state, 10], :l=>[:state, 2], :IDENT=>[:state, 4], :STAR=>[:state, 5]},
 {:EQUALS=>[:reduce, 4], :"$"=>[:reduce, 4]},
 {:"$"=>[:reduce, 1]}]
.freeze # >

PRODUCTIONS  = [[:$start, 2, proc {}],
[:e, 3, proc {}],
[:e, 1, proc {}],
[:l, 1, proc {}],
[:l, 2, proc {}],
[:r, 1, proc {}]].freeze # >

# input should be an array.
def parse(input)
  stack = []
  stack.push([nil, 0])
  input = input.dup
  last  = nil

  until stack.empty? do
    peek_token = if input.empty?
      :"$"
    else
      type(input.first)
    end

    action = ACTION_TABLE[stack.last.last].fetch(peek_token)
    case action.first
    when :accept
      production = PRODUCTIONS[action.last]
      last       = stack.pop(production[1]).first.first
      stack.pop
    when :reduce
      production = PRODUCTIONS[action.last]
      removing   = stack.pop(production[1])
      value = production[2].call(*removing.map(&:first))
      goto  = ACTION_TABLE[stack.last.last][production[0]]
      stack.push([value, goto.last])
    when :state
      stack.push([input.shift, action.last])
    else
      raise
    end
  end

  last
end

end
