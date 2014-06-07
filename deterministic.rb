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
    production :s do
      match e
    end

    production :e do
      match t, SEMICOLON
      match t, ADD, e
    end

    production :t do
      match NUMBER
      match LPAREN, e, RPAREN
    end
  end
end
