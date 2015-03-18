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
if table.any? { |_, i| tableizer.conflicts[i].any? }
_out << "\nNo errors :)"
else
_out << "\nError:"
  table.each_with_index do |v, i|
    conflicts = tableizer.conflicts[i].each
    next unless conflicts.any?
    conflicts.each do |token, (value, first, second, rule, terminal)|
      both = [first, second]
_out << "\n  Conflict in State "
_out << begin
  i
end.to_s
_out << ":\n    "
_out << begin
  [token, value, first, second, rule, terminal]
end.to_s
#    On %{token} {{= '(resolved)' if value != 0 }}:
#      %{first.join(' ')}/%{second.join(' ')} (%{rule} vs %{terminal})
#    Rule:
#     both.select { |_| _[0] == :reduce }.each do |(_, rule)|
#        %{productions[rule][0]}
#     end
#    State:
#      both.select { |_| _[0] == :state }.each do |(_, state)|
#
    end
  end
end
_out << "\n"
_out
