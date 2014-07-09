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
_out << "hello\\n"
_out << begin
  something
end.to_s
_out << "world\\n\\n"
thing
_out << "a\\n\\n"
_out
TEST
    end
  end
end
