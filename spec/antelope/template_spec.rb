describe Template do

  let(:content) { "hello {{ world }} test" }

  subject { Template.new(content) }

  it "generates ruby code" do
    expect(subject.parse).to eq %Q(_out ||= ""\n_out << "hello "\nworld\n_out << " test"\n_out\n)
  end

  context "when the tag is on its own line" do

    let :content do
<<-TEST
hello
{{= something }}
world

{{ thing }}
a

TEST
    end

    it "removes surrounding whitespace" do
      expect(subject.parse).to eq <<-TEST
_out ||= ""
_out << "hello"
_out << begin
  something
end.to_s
_out << "\\nworld\\n"
thing
_out << "\\na\\n\\n"
_out
TEST
    end

    it "runs in ruby" do
      object = Object.new
      result = nil
      def object.something; "-" end
      def object.thing; end

      expect { result = object.instance_eval(subject.parse) }.to_not raise_error
      expect(result).to eq "hello-\nworld\n\na\n\n"
    end
  end
end
