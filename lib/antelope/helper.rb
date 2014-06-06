class String
  def trim_heredoc(count = 6)
    lines.map { |l| l.gsub(/[\s]{0, #{count}}/, "") }.join("\n")
  end
end
