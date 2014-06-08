class ExampleParser < Antelope::Parser
  terminals do
    terminal NUMBER
    terminal MULTIPLY
    terminal DIVIDE
    terminal ADD
    terminal SUBTRACT
    terminal LPAREN
    terminal RPAREN
  end

  presidence do
    left MULTIPLY, DIVIDE
    left ADD, SUBTRACT
  end

  productions do
    production :expression, start: true do
      match NUMBER do |a| a.to_i end

      match expression, ADD, expression do |a, _, b|
        a + b
      end

      match expression, SUBTRACT, expression do |a, _, b|
        a - b
      end

      match expression, MULTIPLY, expression do |a, _, b|
        a * b
      end

      match expression, DIVIDE, expression do |a, _, b|
        a / b
      end

      match LPAREN, expression, RPAREN do |_, a, _|
        a
      end

      match LPAREN, error, RPAREN
    end
  end
end
