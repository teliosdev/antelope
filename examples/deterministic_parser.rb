
  require "antelope"

class DeterministicParser < Antelope::Parser
  # This file assumes that the output of the generator will be placed
# within a module or a class.  However, the module/class requires a
# `type` method, which takes a terminal and gives its type, as a
# symbol.  These types should line up with the terminals that were
# defined in the original grammar.

ACTION_TABLE = [{:s=>[:state, 1],
  :e=>[:state, 2],
  :t=>[:state, 3],
  :NUMBER=>[:state, 5],
  :LPAREN=>[:state, 6]},
 {:"$"=>[:state, 7]},
 {:"$"=>[:reduce, 1]},
 {:SEMICOLON=>[:state, 8], :ADD=>[:state, 9]},
 {:ADD=>[:state, 9]},
 {:SEMICOLON=>[:reduce, 4], :ADD=>[:reduce, 4]},
 {:e=>[:state, 10],
  :t=>[:state, 3],
  :NUMBER=>[:state, 5],
  :LPAREN=>[:state, 6]},
 {:"$"=>[:accept, 0]},
 {:"$"=>[:reduce, 2], :RPAREN=>[:reduce, 2]},
 {:e=>[:state, 11],
  :t=>[:state, 3],
  :NUMBER=>[:state, 5],
  :LPAREN=>[:state, 6]},
 {:RPAREN=>[:state, 12]},
 {:"$"=>[:reduce, 3], :RPAREN=>[:reduce, 3]},
 {:SEMICOLON=>[:reduce, 5], :ADD=>[:reduce, 5]}]
.freeze # >

PRODUCTIONS  = [[:$start, 2, proc {}],
[:s, 1, proc {}],
[:e, 2, proc {}],
[:e, 3, proc {}],
[:t, 1, proc {}],
[:t, 3, proc {}]].freeze # >

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
