describe Automaton do
  context "with a simple table" do
    let(:states) { [ :s1, :s2 ] }
    let(:alphabet) { [0, 1] }
    let(:accept) { [ :s1 ] }
    let(:transitions) { {
      :s1 => { 0 => :s2, 1 => :s1 },
      :s2 => { 0 => :s1, 1 => :s2 }
    } }

    subject do
      Automaton.new(states, alphabet, :s1, accept, transitions)
    end

    it "basically runs" do
      expect(subject.run([1, 1])).to be_truthy
    end

    it "yields for transitions" do
      expect { |b| subject.run([1], &b) }.to yield_control
    end

    it "runs fast" do
      expect(benchmark do
        subject.run([1, 1])
      end).to be < 5e-5
    end
  end
end
