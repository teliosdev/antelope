

class ExampleParser
  # This file assumes that the output of the generator will be placed
# within a module or a class.  However, the module/class requires a
# `type` method, which takes a terminal and gives its type, as a
# symbol.  These types should line up with the terminals that were
# defined in the original grammar.

ACTION_TABLE = [{:expression=>[:state, 1], :NUMBER=>[:state, 2], :LPAREN=>[:state, 7]},
 {:"$"=>[:state, 9],
  :ADD=>[:state, 10],
  :SUBTRACT=>[:state, 11],
  :MULTIPLY=>[:state, 12],
  :DIVIDE=>[:state, 13]},
 {:ADD=>[:reduce, 1],
  :SUBTRACT=>[:reduce, 1],
  :MULTIPLY=>[:reduce, 1],
  :DIVIDE=>[:reduce, 1],
  :RPAREN=>[:reduce, 1],
  :"$"=>[:reduce, 1]},
 {:ADD=>[:state, 10]},
 {:SUBTRACT=>[:state, 11]},
 {:MULTIPLY=>[:state, 12]},
 {:DIVIDE=>[:state, 13]},
 {:expression=>[:state, 14],
  :NUMBER=>[:state, 2],
  :LPAREN=>[:state, 7],
  :error=>[:state, 15]},
 {:error=>[:state, 15]},
 {:"$"=>[:accept, 0]},
 {:expression=>[:state, 16], :NUMBER=>[:state, 2], :LPAREN=>[:state, 7]},
 {:expression=>[:state, 17], :NUMBER=>[:state, 2], :LPAREN=>[:state, 7]},
 {:expression=>[:state, 18], :NUMBER=>[:state, 2], :LPAREN=>[:state, 7]},
 {:expression=>[:state, 19], :NUMBER=>[:state, 2], :LPAREN=>[:state, 7]},
 {:"$"=>[:state, 9],
  :ADD=>[:state, 10],
  :SUBTRACT=>[:state, 11],
  :MULTIPLY=>[:state, 12],
  :DIVIDE=>[:state, 13],
  :RPAREN=>[:state, 20]},
 {:RPAREN=>[:state, 21]},
 {:"$"=>[:reduce, 2],
  :ADD=>[:reduce, 2],
  :SUBTRACT=>[:reduce, 2],
  :MULTIPLY=>[:state, 12],
  :DIVIDE=>[:state, 13],
  :RPAREN=>[:reduce, 2]},
 {:"$"=>[:reduce, 3],
  :ADD=>[:reduce, 3],
  :SUBTRACT=>[:reduce, 3],
  :MULTIPLY=>[:state, 12],
  :DIVIDE=>[:state, 13],
  :RPAREN=>[:reduce, 3]},
 {:"$"=>[:reduce, 4],
  :ADD=>[:reduce, 4],
  :SUBTRACT=>[:reduce, 4],
  :MULTIPLY=>[:reduce, 4],
  :DIVIDE=>[:reduce, 4],
  :RPAREN=>[:reduce, 4]},
 {:"$"=>[:reduce, 5],
  :ADD=>[:reduce, 5],
  :SUBTRACT=>[:reduce, 5],
  :MULTIPLY=>[:reduce, 5],
  :DIVIDE=>[:reduce, 5],
  :RPAREN=>[:reduce, 5]},
 {:ADD=>[:reduce, 6],
  :SUBTRACT=>[:reduce, 6],
  :MULTIPLY=>[:reduce, 6],
  :DIVIDE=>[:reduce, 6],
  :RPAREN=>[:reduce, 6],
  :"$"=>[:reduce, 6]},
 {:ADD=>[:reduce, 7],
  :SUBTRACT=>[:reduce, 7],
  :MULTIPLY=>[:reduce, 7],
  :DIVIDE=>[:reduce, 7],
  :RPAREN=>[:reduce, 7],
  :"$"=>[:reduce, 7]}]
.freeze # >

PRODUCTIONS  = [[:$start, 2, proc {}],
[:expression, 1, proc { |a| a[1]        }],
[:expression, 3, proc { |a, _, b| a + b }],
[:expression, 3, proc { |a, _, b| a - b }],
[:expression, 3, proc { |a, _, b| a * b }],
[:expression, 3, proc { |a, _, b| a / b }],
[:expression, 3, proc { |_, a, _| a     }],
[:expression, 3, proc {}]].freeze # >

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


  def type(token)
    token[0]
  end
end

input = [[:NUMBER, 2], [:ADD], [:NUMBER, 2]]
input = [
  [:NUMBER, 2],
  [:ADD],
  [:NUMBER, 2],
  [:MULTIPLY],
  [:NUMBER, 3]
]

p ExampleParser.new.parse(input)
