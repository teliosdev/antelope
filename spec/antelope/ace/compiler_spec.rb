describe Ace::Compiler do
  let :file do
    <<-DOC
    %{
      test
    %}

    %require "0.0.1"
    %type "ruby"

    %terminal NUMBER
    %terminal SEMICOLON ";"
    %terminal ADD "+"
    %terminal LPAREN "("
    %terminal RPAREN ")"

    %%

    s: e
    e: t ADD e
    t: NUMBER | LPAREN e RPAREN

    %%

    hello
    DOC
  end

  let :tokens do
    Ace::Scanner.scan(file)
  end

  let :compiler do
    Ace::Compiler.new(tokens)
  end

  subject do
    compiler.compile
    compiler
  end

  its(:body) { should =~ /test/  }
  its(:body) { should =~ /hello/ }
  its(:options) { should have_key :type }

  it "should have the proper terminals" do
    expect(subject.options[:terminals].map(&:first)).to eq ["NUMBER",
      "SEMICOLON", "ADD", "LPAREN", "RPAREN"]
  end
end
