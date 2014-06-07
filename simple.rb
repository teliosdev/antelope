class MyParser < Antelope::Parser
  terminals do
    terminal IDENT
    terminal STAR
    terminal EQUALS
  end

  start_production :e

  productions do
    production :e do
      match l, EQUALS, r
      match r
    end

    production :l do
      match IDENT
      match STAR, r
    end

    production :r do
      match l
    end
  end
end
