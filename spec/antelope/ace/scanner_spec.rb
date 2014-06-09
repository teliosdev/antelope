describe Ace::Scanner do

  it "properly scans" do
    expect(scan("%test \"a\" hi\n%%\nt: d { { } }\n%%\nhi\n")).to eq [
      [:directive, "test", ['"a"', "hi"]],
      [:second],
      [:label, "t"],
      [:part, "d"],
      [:block, "{ { } }"],
      [:third],
      [:body, "\nhi\n"]
    ]
  end

  it "throws an error" do
    expect {
      scan("% %% %% ")
    }.to raise_error(Ace::SyntaxError)
  end

  def scan(source)
    Timeout.timeout(5) do
      Ace::Scanner.scan(source)
    end
  end

end
