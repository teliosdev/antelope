class MyParser < Antelope::Parser
  terminals do
    terminal NUMBER
    terminal SEMICOLON
    terminal ADD
    terminal LPAREN
    terminal RPAREN
  end

  start_production :s

  productions do
    s do
      match e
    end

    e do
      match t SEMICOLON
      match t ADD e
    end

    t do
      match NUMBER
      match LPAREN e RPAREN
    end
  end
end

recognizer = Antelope::Recognizer.new(MyParser)
recognizer.call
c = Antelope::Constructor.new(MyParser)
c.call

File.open("deterministic.output", "w") do |f|
  f << "productions:\n"
  c.productions.each do |rule|
    f << "#{Antelope::Output.output(rule)}"
  end

  f << "\nfollow():\n"
  c.productions.map { |x| x.left }.uniq.each do |p|
    f << "  #{p}: #{c.follow(p).to_a.join(" ")}\n"
  end

  f << "\n"
  Antelope::Output.output(recognizer.start, f)
end
