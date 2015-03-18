# encoding: utf-8
_out ||= ""
_out << "Productions:"
len = grammar.all_productions.size.to_s.size
productions = grammar.all_productions.
  map { |x| ["#{x.label} → #{x.items.join(' ')}", x.block] }
body = productions.map { |_| _.first.size }.max
productions.each_with_index do |prod, i|
_out << "\n  "
_out << begin
  sprintf("%#{len}s", i)
end.to_s
_out << " "
_out << begin
  sprintf("%-#{body}s", prod[0])
end.to_s
_out << " "
_out << begin
  prod[1]
end.to_s
end
_out << "\n"
if unused_symbols.any?
_out << "\nSymbols unused in grammar:"
  unused_symbols.each do |sym|
_out << "\n  "
_out << begin
  sym
end.to_s
  end
end
_out << "\n\nPrecedence:\n  --- highest"
 grammar.precedence.each do |pr|
_out << "\n  "
_out << begin
  "%-8s" % pr.type
end.to_s
_out << " "
_out << begin
  pr.level
end.to_s
_out << ":\n    "
_out << begin
  "{" << pr.tokens.to_a.join(", ") << "}"
end.to_s
 end
_out << "\n  --- lowest\n"
states = grammar.states.to_a
table.each_with_index do |v, i|
  state = states[i]
_out << "\n  State "
_out << begin
  i
end.to_s
_out << ":"
  state.rules.each do |rule|
_out << "\n    "
_out << begin
  rule
end.to_s
_out << "\n      "
_out << begin
  "{" << rule.lookahead.to_a.join(", ") << "}"
end.to_s
  end
  transitions = v.each.select { |_, a| a && a[0] == :state }
  reductions  = v.each.select { |_, a| a && a[0] == :reduce}
  accepting   = v.each.select { |_, a| a && a[0] == :accept}
  thing = [:transitions, :reductions, :accepting]
  num_type = {
    transitions: "State",
    reductions: "Rule",
    accepting: "Rule"
  }
  h = Hash[thing.zip([transitions, reductions, accepting])]
  h.each do |key, value|
    next unless value.any?
_out << "\n    "
_out << begin
  key
end.to_s
_out << ":"
    value.each do |token, (_, name)|
       token_value = grammar.terminals.
          find { |_| _.name == token } || token
_out << "\n      "
_out << begin
  token_value
end.to_s
_out << ": "
_out << begin
  num_type[key]
end.to_s
_out << " "
_out << begin
  name
end.to_s
     end
   end
_out << "\n"
end
_out << "\n"
_out
