module GrammarHelper
  def grammar_for(grammar_file = "simple")
    source_path = Pathname.new("../../fixtures").expand_path(__FILE__)
    Grammar.from_file(source_path.children.select(&:file?)
      .find { |x| x.to_s =~ /#{Regexp.escape(grammar_file)}\..*\z/ }.to_s)
  end

  def with_recognizer(grammar = simple_grammar)
    Generation::Recognizer.new(grammar).call
    grammar
  end

  alias_method :simple_grammar, :grammar_for
end
