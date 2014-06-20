# encoding: utf-8

require "antelope/ace/errors"
require "antelope/ace/scanner"
require "antelope/ace/compiler"
require "antelope/ace/token"
require "antelope/ace/precedence"
require "antelope/ace/grammar"

module Antelope

  # Defines the Ace file.  The Ace file format works similarly to
  # bison's y file format.  The Ace file is seperated into three
  # parts:
  #
  #      <first>
  #      %%
  #      <second>
  #      %%
  #      <third>
  #
  # All parts may be empty; thus, the minimal file that Ace will
  # accept would be
  #
  #     %%
  #     %%
  #
  # The first part consists of _directives_ and _blocks_; directives
  # look something like `"%" <directive>[ <argument>]*\n`, with
  # `<directive>` being any alphanumerical character, including
  # underscores and dashes, and `<argument>` being any word character
  # or a quote-delimited string.  Blocks consist of
  # `"%{" <content> "\n" "\s"* "%}"`, with `<content>` being any
  # characters.  The content is copied directly into the body of the
  # output.
  #
  # The second part consists of rules.  Rules look something like
  # this:
  #
  #     <nonterminal>: (<nonterminal> | <terminal>)* ["{" <content> "}"] ["|" (<nonterminal> | <terminal>)* ["{" <content> "}"]]* [;]
  #
  # Where `<nonterminal>` is any lowercase alphabetical cahracter,
  # `<terminal>` is any uppercase alphabetical character, and
  # `<content>` is code to be used in the output file upon matching
  # the specific rule.
  #
  # The third part consists of a body, which is copied directly into
  # the output.
  module Ace

  end
end
