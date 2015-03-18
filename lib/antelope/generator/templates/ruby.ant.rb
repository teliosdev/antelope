# encoding: utf-8
_out ||= ""
_out << "\n# This file assumes that the output of the generator will be placed\n# within a module or a class.  However, the module/class requires a\n# `type` method, which takes a terminal and gives its type, as a\n# symbol.  These types should line up with the terminals that were\n# defined in the original grammar.\n\n# The actions to take during parsing.  In every state, there are a\n# set of acceptable peek tokens; this table tells the parser what\n# to do on each acceptable peek token.  The possible actions include\n# `:accept`, `:reduce`, and `:state`; `:accept` means to accept the\n# input and return the value of the pasing.  `:reduce` means to\n# reduce the top of the stack into a given nonterminal.  `:state`\n# means to transition to another state.\n#\n# @return [Array<Hash<(Symbol, Array<(Symbol, Numeric)>)>>]\nACTION_TABLE = "
_out << begin
  generate_action_table
end.to_s
_out << ".freeze\n\n# The default action that is taken for most reductions.\n#\n# @return [Proc]\nDEFAULT_PROC = proc { |_| _ }\n# A list of all of the productions.  Only includes the left-hand side,\n# the number of tokens on the right-hand side, and the block to call\n# on reduction.\n#\n# @return [Array<Array<(Symbol, Numeric, Proc)>>]\nPRODUCTIONS  = "
_out << begin
  generate_productions_list
end.to_s
_out << ".freeze\n\n# Runs the parser.\n#\n# @param input [Array] the input to run the parser over.\n# @return [Object] the result of the accept.\ndef parse(input)\n  stack = []\n  stack.push([nil, 0])\n  last  = nil\n  input = input.to_a.dup\n\n  until stack.empty? do\n    last = parse_action(stack, input)\n  end\n\n  last\n\nend\n\n# Actually performs the parsing action on the given stack on input.\n# If you want to implement a push parser, than messing with this\n# method is probably the way to go.\n#\n# @param stack [Array<Array<(Object, Numeric)>>] the stack of the\n#   parser.  The actual order of the stack is important.\n# @param input [Array<Object>] the input to run the parser over.\n#   The elements of this may be passed to the `type` method.\n# @return [Object] the result of the last accepting reduction.\ndef parse_action(stack, input)\n  last = nil\n  peek_token = if input.empty?\n    :$end\n  else\n    type(input.first)\n  end\n\n  action = ACTION_TABLE[stack.last.last].fetch(peek_token) do\n    ACTION_TABLE[stack.last.last].fetch(:$default)\n  end\n\n  case action.first\n  when :accept\n    production = PRODUCTIONS[action.last]\n    last       = stack.pop(production[1]).first.first\n    stack.pop\n  when :reduce\n    production = PRODUCTIONS[action.last]\n    removing   = stack.pop(production[1])\n    value = instance_exec(*removing.map(&:first), &production[2])\n    goto  = ACTION_TABLE[stack.last.last][production[0]]\n    stack.push([value, goto.last])\n  when :state\n    stack.push([input.shift, action.last])\n  else\n    raise NotImplementedError, \"Unknown action \#{action.first}\"\n  end\n\n  last\n\nrescue KeyError => e\n  peek = input.first\n\n  if handle_error({\n      :stack     => stack,\n      :peek      => peek_token,\n      :remaining => input,\n      :error     => e,\n      :line      => line_of(peek),\n      :column    => column_of(peek),\n      :expected  => ACTION_TABLE[stack.last.last].keys\n    })\n    retry\n  else\n    raise\n  end\nend\n\nprivate\n\ndef line_of(peek)\n  if peek.respond_to?(:line)\n    peek.line\n  else\n    0\n  end\nend\n\ndef column_of(peek)\n  if peek.respond_to?(:column)\n    peek.column\n  else\n    0\n  end\nend\n"
 if define_own_handler?
_out << "\ndef handle_error(data, _ = false)"
   if panic_mode?
_out << "\n  if _ || data[:peek] == :$end # we can't recover if\n                               # we're at the end"
   end
_out << "\n    raise "
_out << begin
  error_class
end.to_s
_out << ",\n      \"Unexpected token \#{data[:peek]} on line \#{data[:line]}, \" \\\n      \"column \#{data[:column]}; expected one of \" \\\n      \"\#{data[:expected].join(', ')}\",\n      data[:error].backtrace"
   if panic_mode?
_out << "\n  end\n\n  new_peek = :$error\n  acceptable_state = false\n  state = nil\n\n  until data[:stack].empty? or acceptable_state\n    state = data[:stack].last.last\n\n    if ACTION_TABLE[state].key?(new_peek)\n      acceptable_state = true\n    else\n      data[:stack].pop # discard\n    end\n  end\n\n  return handle_error(data, true) unless acceptable_state\n\n  action = ACTION_TABLE[state][new_peek]\n  lookaheads = nil\n\n  until lookaheads\n    if action[0] == :state\n      lookaheads = ACTION_TABLE[action.last].keys\n    elsif action[0] == :reduce\n      rule   = PRODUCTIONS[action.last]\n      action = ACTION_TABLE[stack[-rule[1]].last][rule[0]]\n    end\n  end\n\n  begin\n    until lookaheads.include?(data[:remaining][0].peek)\n      data[:remaining].next\n    end\n  rescue StopIteration\n  end\n\n  data[:remaining].unshift([new_peek, data[:error]])\n  true\n"
   end
_out << "\nend"
 end
_out << "\n"
_out
