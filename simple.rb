class MyParser < Antelope::Parser
  terminals do
    terminal IDENT
    terminal STAR
    terminal EQUALS
  end

  start_production :e

  productions do
    production :e do
      match l EQUALS r
      match r
    end

    production :l do
      match IDENT
      match STAR r
    end

    production :r do
      match l
    end
  end
end

recognizer = Antelope::Recognizer.new(MyParser)
recognizer.call
c = Antelope::Constructor.new(MyParser)
c.call

File.open("simple.output", "w") do |f|
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
