

class ExampleParser
  # This file assumes that the output of the generator will be placed
# within a module or a class.  However, the module/class requires a
# `type` method, which takes a terminal and gives its type, as a
# symbol.  These types should line up with the terminals that were
# defined in the original grammar.
#
# This file is still under the MIT license, due to the fact that
# this file is still considered "source code."

# Array<Hash<(token, action)>>
ACTION_TABLE = [{:expression=>[:state, 1], :NUMBER=>[:state, 2], :LPAREN=>[:state, 7]},
 {:"$"=>[:state, 9],
  :ADD=>[:state, 10],
  :SUBTRACT=>[:state, 11],
  :MULTIPLY=>[:state, 12],
  :DIVIDE=>[:state, 13]},
 {:ADD=>[:reduce, 54],
  :SUBTRACT=>[:reduce, 54],
  :MULTIPLY=>[:reduce, 54],
  :DIVIDE=>[:reduce, 54],
  :RPAREN=>[:reduce, 54],
  :"$"=>[:reduce, 54]},
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
 {:"$"=>[:reduce, 55],
  :ADD=>[:reduce, 55],
  :SUBTRACT=>[:reduce, 55],
  :MULTIPLY=>[:state, 12],
  :DIVIDE=>[:state, 13],
  :RPAREN=>[:reduce, 55]},
 {:"$"=>[:reduce, 56],
  :ADD=>[:reduce, 56],
  :SUBTRACT=>[:reduce, 56],
  :MULTIPLY=>[:state, 12],
  :DIVIDE=>[:state, 13],
  :RPAREN=>[:reduce, 56]},
 {:"$"=>[:reduce, 57],
  :ADD=>[:reduce, 57],
  :SUBTRACT=>[:reduce, 57],
  :MULTIPLY=>[:reduce, 57],
  :DIVIDE=>[:reduce, 57],
  :RPAREN=>[:reduce, 57]},
 {:"$"=>[:reduce, 58],
  :ADD=>[:reduce, 58],
  :SUBTRACT=>[:reduce, 58],
  :MULTIPLY=>[:reduce, 58],
  :DIVIDE=>[:reduce, 58],
  :RPAREN=>[:reduce, 58]},
 {:ADD=>[:reduce, 59],
  :SUBTRACT=>[:reduce, 59],
  :MULTIPLY=>[:reduce, 59],
  :DIVIDE=>[:reduce, 59],
  :RPAREN=>[:reduce, 59],
  :"$"=>[:reduce, 59]},
 {:ADD=>[:reduce, 60],
  :SUBTRACT=>[:reduce, 60],
  :MULTIPLY=>[:reduce, 60],
  :DIVIDE=>[:reduce, 60],
  :RPAREN=>[:reduce, 60],
  :"$"=>[:reduce, 60]}]
.freeze # >

# Array<Array<(prod_name, number_of_tokens, proc)>>
PRODUCTIONS  = [[:$start, 2, proc {}],
[:expression, 1, proc { |a| a[1]        }],
[:expression, 3, proc { |a, _, b| a + b }],
[:expression, 3, proc { |a, _, b| a - b }],
[:expression, 3, proc { |a, _, b| a * b }],
[:expression, 3, proc { |a, _, b| a / b }],
[:expression, 3, proc { |_, a, _| a     }],
[:expression, 3, proc {}],
nil, nil, nil, nil, nil, [:expression, 1, proc { |a| a[1]        }],
nil, nil, nil, nil, [:expression, 3, proc { |_, a, _| a     }],
[:expression, 1, proc { |a| a[1]        }],
[:expression, 3, proc { |a, _, b| a + b }],
[:expression, 3, proc { |a, _, b| a - b }],
[:expression, 3, proc { |a, _, b| a * b }],
[:expression, 3, proc { |a, _, b| a / b }],
[:expression, 3, proc { |_, a, _| a     }],
[:expression, 3, proc {}],
nil, [:expression, 3, proc {}],
[:$start, 2, proc {}],
[:expression, 3, proc { |a, _, b| a + b }],
[:expression, 1, proc { |a| a[1]        }],
[:expression, 3, proc { |a, _, b| a + b }],
[:expression, 3, proc { |a, _, b| a - b }],
[:expression, 3, proc { |a, _, b| a * b }],
[:expression, 3, proc { |a, _, b| a / b }],
[:expression, 3, proc { |_, a, _| a     }],
[:expression, 3, proc {}],
[:expression, 3, proc { |a, _, b| a - b }],
[:expression, 1, proc { |a| a[1]        }],
[:expression, 3, proc { |a, _, b| a + b }],
[:expression, 3, proc { |a, _, b| a - b }],
[:expression, 3, proc { |a, _, b| a * b }],
[:expression, 3, proc { |a, _, b| a / b }],
[:expression, 3, proc { |_, a, _| a     }],
[:expression, 3, proc {}],
[:expression, 3, proc { |a, _, b| a * b }],
[:expression, 1, proc { |a| a[1]        }],
[:expression, 3, proc { |a, _, b| a + b }],
[:expression, 3, proc { |a, _, b| a - b }],
[:expression, 3, proc { |a, _, b| a * b }],
[:expression, 3, proc { |a, _, b| a / b }],
[:expression, 3, proc { |_, a, _| a     }],
[:expression, 3, proc {}],
[:expression, 3, proc { |a, _, b| a / b }],
[:expression, 1, proc { |a| a[1]        }],
[:expression, 3, proc { |a, _, b| a + b }],
[:expression, 3, proc { |a, _, b| a - b }],
[:expression, 3, proc { |a, _, b| a * b }],
[:expression, 3, proc { |a, _, b| a / b }],
[:expression, 3, proc { |_, a, _| a     }],
[:expression, 3, proc {}],
[:expression, 3, proc { |_, a, _| a     }],
nil, nil, nil, nil, nil, [:expression, 3, proc {}],
[:expression, 3, proc { |a, _, b| a + b }],
nil, nil, nil, nil, nil, [:expression, 3, proc { |a, _, b| a - b }],
nil, nil, nil, nil, nil, [:expression, 3, proc { |a, _, b| a * b }],
nil, nil, nil, nil, nil, [:expression, 3, proc { |a, _, b| a / b }],
[:$start, 2, proc {}],
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

p ExampleParser.new.parse(input)
