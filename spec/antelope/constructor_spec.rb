describe Generation::Constructor do
  let(:grammar)  { double("grammar") }
  let(:terminal) { token(:TERMINAL)  }
  let(:epsilon)  { token(:epsilon) }

  subject { described_class.new(grammar) }

  context "#nullable?" do
    context "when given an epsilon token" do
      it "returns true" do
        expect(subject.nullable?(epsilon)).to be true
      end
    end

    context "when given a terminal" do
      it "returns false" do
        expect(subject.nullable?(terminal)).to be false
      end
    end

    context "when given an array" do
      context "with one of the elements not nullable" do
        it "returns false" do
          expect(subject.nullable?([terminal, epsilon])).to be false
        end
      end

      context "with all of the elements nullable" do
        it "returns true" do
          expect(subject.nullable?([epsilon, epsilon])).to be true
        end
      end
    end

    context "when given a nonterminal" do
      let(:grammar) { with_recognizer }

      context "with no nullable productions" do
        let(:nonterminal) { Ace::Token::Nonterminal.new(:l) }

        it "returns false" do
          expect(subject.nullable?(nonterminal)).to be false
        end
      end

      context "with a nullable production" do
        let(:nonterminal) { Ace::Token::Nonterminal.new(:e) }

        it "returns true" do
          expect(subject.nullable?(nonterminal)).to be true
        end
      end
    end

    context "when given a bad argument" do
      it "raises an error" do
        expect { subject.nullable?(nil) }.to raise_error(ArgumentError)
      end
    end
  end

  context "#first" do
    context "when given an epsilon token" do
      it "generates an empty set" do
        expect(subject.first(epsilon)).to eq Set.new
      end
    end

    context "when given a terminal" do
      it "generates a set" do
        expect(subject.first(terminal)).to eq [terminal].to_set
      end
    end

    context "when given an array" do
      let(:terminal2) { token(:terminal, :TERMINAL2) }

      it "generates a set" do
        expect(subject.first([epsilon, terminal])).
          to eq [terminal].to_set
        expect(subject.first([terminal, terminal2])).
          to eq [terminal].to_set
      end
    end

    context "when given a nonterminal" do
      let(:grammar) { with_recognizer }
      let(:nonterminal) { token(:nonterminal, :e) }

      it "generates a set" do
        expect(subject.first(nonterminal)).
          to eq [token(:terminal, :IDENT), token(:terminal, :STAR, "*")].to_set
      end
    end

    context "when given a bad argument" do
      it "raises an error" do
        expect { subject.first(nil) }.to raise_error(ArgumentError)
      end
    end
  end

  context "#follow" do
    context "when given a bad argument" do
      it "raises an error" do
        expect { subject.follow(nil) }.to raise_error(ArgumentError)
      end
    end

    context "when given a nonterminal" do
      let(:grammar) { with_recognizer }
      let(:nonterminal) { token(:nonterminal, :l) }

      before do
        subject.productions.merge grammar.productions.values.flatten
      end

      it "generates a set" do
        expect(subject.follow(nonterminal)).to eq [
          token(:terminal, :EQUALS, "="),
          token(:terminal, :"$end")
        ].to_set
      end
    end
  end



  def token(type, name = nil, value = nil, ttype = nil, id = nil)
    type = Ace::Token.const_get(type.to_s.capitalize)
    type.new(name, ttype, id, value)
  end
end
