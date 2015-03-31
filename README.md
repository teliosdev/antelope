# Antelope

_Antelope_ is a parser generator that can generate parsers for any
language*.  In the sense of actually creating a parser, it works
kind of like [_Bison_][bison] - you give it an input file, say,
`language.ace`, and it generates a parser for it, in, say,
`language.rb`.  Only, instead of _Bison_'s support only for C, C++,
and Java, _Antelope_ is meant to generate parsers for multiple
languages.  _Antelope_ is also written in Ruby for understandability.

Enough about that, though, let's get into _Antelope_.

## Installation

Since you'll only typically use _Antelope_ from the command line, I
suggest you install it like so:

    $ gem install antelope

If, however, you plan on using it in an application, or need it as a
part of a library, you can add `gem "antelope"` to your Gemfile.

## Usage

_Antelope_ is fairly simple to use; you define an `.ace` file, compile
it, and use the proper API for the generated language.

### How Antelope Works

Before getting into Ace files, however, you have to understand how
_Antelope_ works.  _Antelope_ generates a LALR(1) parser, like
_Bison_; for your benefit, however, there are some terms here to
understand:

- LL: A type of parser.  If followed by parenthesis, the number (or
  letter) in the parenthesis denotes the number of tokens of
  lookahead; i.e., LL(0) has 0 tokens of lookahead.  Standing for
  **L** eft to Right, **L** eftmost Derivation, these tend to be
  handwritten as Recursive Decent parsers.  LL parsers can be
  represented normally by a set of _productions_.  LL parsers are
  _Top-Down parsers_, meaning they start with only the
  _Starting symbol_ and try to match the input.  A look at an LL
  parser is given [here][ll-parser]; check out
  [this post][tumblr-ll-parser] for more information about LL parsers.  
  _Antelope_ does not generate LL parsers.
- Production: In parsing, a production associates a _nonterminal_ with
  a _string_ of _nonterminals_ and _terminals_.  It is said that the
  string of nonterminals and terminals _reduces to_ the nonterminal.  
  Productions take the form of `A -> y`, with _A_ being the left hand
  side (and the _nonterminal_), and _y_ being the string.
- Starting symbol: In parsing, it is the _nonterminal_ that is used to
  represent any kind of valid input.
- Symbol: A _nonterminal_ or a _terminal_.
- Nonterminal: In parsing, a nonterminal is an abstraction used to
  represent any number of _strings_ of _nonterminals_ and _terminals_.
- String: In parsing, an ordered set of _symbols_.
- Terminal: In parsing, it is a concrete value given by the lexer.
- LR: A family of types of parsers.  If followed by parenthesis, the
  number (or letter) in the parenthesis denotes the number of tokens
  of lookahead; i.e., LR(0) has 0 tokens of lookahead.  Standing for
  **L** eft to Right, **R** ightmost Derivation, they tend to be more
  complicated than their LL brethren.  LR parsers work by starting
  with the entire input and finding _Handles_ from that input,
  eventually ending up at the _Starting symbol_.  LR parsers typically
  do this by splitting the input into two parts: the _stack_, and the
  _input_.  LR(0), LR(1), SLR(1), and LALR(1) are all examples of LR
  parsers.
- Handle: In a LR parser, it is the _Leftmost complete cluster of leaf
  nodes_ (in a representative AST).  When a handle is found, a
  _reduction_ is performed.
- Stack: Initially empty, it can contain any _symbol_, and is
  primarily used to represent what the parser has seen.  Finding handles
  will purely occur at the top of the stack.
- Reduction/Reduce: In a LR parser, this is an action corresponding to
  replacing the right side of a _production_ with its left side.  This
  purely occurs at the top of the _stack_, and correlates to finding a
  _Handle_.
- Input: Initially containing the full input, it can contain only
  _terminals_; it primarily contains what the parser has yet to see.
- LR(0): In parsing, it is a type of LR parser that uses no lookahead.  
  It essentially uses a deterministic finite automaton to find
  _possible_ handles.  It does no checking to make sure that the
  _possible_ handles are legitimate.
- SLR(1): A part of the LR family of parsers, it upgrades LR(0) by
  checking to make sure that the reduction that it will make (as a
  part of finding a handle) is valid in the context; basically, for
  every reduction that it can make, it defines a set of terminals that
  can _FOLLOW_ the corresponding nonterminal.
- FOLLOW(A) set: In parsing, it defines a set of terminals that can
  _follow_ the nonterminal _A_ anywhere in the grammar.
- LALR(1): A part of the LR family of parsers, it upgrades SLR by
  using a more precise _FOLLOW_ set, called _LA_.
- LA set: LA(q, A -> y) = { t | S =>* _aAtw_ and _ay_ reaches _q_ }
- Panic mode: In parsing, this is the mode that a parser can go in for
  recovery, if it encounters a terminal that it was not expecting.  In
  panic mode, the parser pops terminals off of the input until it
  reaches a valid _synchronization token_.  In order to utilize panic
  mode, at least one production must have the special _error_ terminal
  in it.  If the parser encounters an error, it will attempt to find a
  production it can use to resynchronize; if it cannot resynchronize,
  it will error.  It then attempts to resynchronize by continuously
  pop terminals off of the input and discarding them, attempting to
  find a synchronization token.  A synchronization token is a token
  that follows an _error_ terminal.
- Shift/reduce conflict: This occurs when the parser is unable to
  decide if it should shift the next token over from the input to the
  stack, or to reduce the top token on the stack.  If a shift/reduce
  conflict cannot be solved by changing the grammar, then precedence
  rules may be used (see `examples/example.ace`).
- Reduce/reduce conflict: This occurs when the parser is unable to
  decide which production to reduce.  This cannot be solved by
  precedence.
- Precedence: In some grammars, the _Antelope_ runs into _Shift/reduce
  conflicts_ when attempting to construct a parser.  To resolve these
  conflicts, _Antelope_ provides precedence declarations.  Precedence
  is separated into levels, which each have a type; levels can be
  _left-associative_, _right-associative_, or _non-associative_.  The
  higher the level, the higher the precedence.  Think of the Order of
  Operations here; the operations multiply and divide are left
  associative, and on a higher level than add and subtract, which are
  still left-associative:

        MULTIPLY, DIVIDE (left-associative)
        ADD, SUBTRACT (left-associative)

  Exponentiation, however, is right-associative, and is higher than
  MULTIPLY or DIVIDE; basically, `2**2**2` would be parsed as
  `2**(2**2)`, instead of the left-associative `(2**2)**2`.  For an
  example of a grammar that uses precedence, see
  `examples/example.ace`.

### Defining the Ace file

The Ace file format is very similar to _Bison_'s _y_ files; this was
intentional, to make transitions between the two easy.  The Ace file
should be formatted like so:

```
<directives>
%%
<rules>
%%
<code>
```

Both `%%` (internally called _content boundaries_) are required; the
minimum file that is _technically_ accepted by _Antelope_ is therefore
two content boundaries separated by a newline.

In the `<directives>` section, there can be any number and
combinations of _code blocks_ and _directives_.  _Code blocks_ are
blocks of code delimited by `%{` and `%}`, with the ending delimiter
on its own line.  These are copied into the output of the file
directly.  _Directives_ tell _Antelope_ information about the grammar.  
An example directive would be the `token` or `terminal` directive;
this lets _Antelope_ know that a terminal by the given name exists.  
Directives take the form `%<name> [<value>]*`, with `<name>` being the
directive name, and `<value>` being a string delimited by braces,
angle brackets, quotes, or nothing at all.  An example of a directive
would be `%token ADD "+"`.  The available directives are determined by
the code generators available to _Antelope_ at the time that the Ace
file is being compiled.  Some directives, however, are always
available:

- `require` (1 argument): This makes _Antelope_ check its version
  against the first argument to this.  If the versions do _not_ match,
  _Antelope_ will raise an error and fail to parse the file.  It is
  recommended to at least require the minor version of _Antelope_
  (i.e. `%require "~> 0.1"`).
- `token`, `terminal` (1-2 arguments): Defines a terminal.  The first
  argument defines its name; the second argument defines its value.  
  Its value isn't used anywhere but the `.output` file, to make it
  easier to read.
- `left`, `right`, `nonassoc` (1+ arguments): Defines a precedence
  level, and sets the type of the level based on the directive name
  used.
- `type`: The code generator to use.  Currently, the possible values
  for this can be `null`, `ruby`, and `output`.
- `define` (1+ arguments): Sets a key to a value.  This would do the
  exact same thing that using the key as a directive would do, i.e.
  `%define something "value"` does the same thing as
  `%something "value"`. _(note: This is not entirely true.  If the key
  were one of the above, it would most likely raise an error,
  complaining that there is no directive named that.)_
- `panic-mode` (0-1 arguments): Enables/disables panic mode being put
  in the output code.  Not included by default, but should be.

In the `<rules>` section, there can be any number of rules (which are
definitions for productions).  Rules have this syntax:

```
<head>: <body> ["|" <body>]* [";"]
```

With `<head>` being the nonterminal that the production(s) reduce to,
and `<body>` being one or more symbols followed by an optional block
that is executed when is a reduction is made using that production.  A
semicolon terminating the rule is optional.  Rules are what make up
the grammar. `error`, `nothing`, and `ε` are all special symbols; the
first one defines the special `error` terminal (used for panic mode,
ignored otherwise), whereas the second two are used to literally
mean nothing (i.e., the rule reduces to nothing).  It is not always
a good idea to use the `nothing` symbol, since most rules can be
written without it.

In the `<code>` section, custom code used to wrap the generated parser
can be placed.  In order to embed the generated parser, you must place
`%{write}` where you want the generated parser.

### Compiling the Ace file

Compiling the Ace file is somewhat straightforward;
`antelope compile /path/to/file.ace` will cover most use cases.  If
you want to override the type in the Ace file, you can use the
`--type=` command option.  If it is giving an error, and you're not
sure what's causing it, you can use the `--verbose` command option to
see a backtrace.

By default, _Antelope_ always includes the `Output` generator as a
part of the output.  This means that an `.output` file will always be
generated along with any other files.  The `.output` file contains
information about the parser, like the productions that were used,
precedence levels, states, and lookahead sets.

### Language API

todo.

## Contributing

1. Fork it (<https://github.com/medcat/antelope/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

\* Only if there's a generator for it.
[bison]: http://www.gnu.org/software/bison/
[ll-parser]: http://i.imgur.com/XhJKrDW.png
[tumblr-ll-parser]: http://redjazz96.tumblr.com/post/88336053195/what-antelope-does-and-what-i-hope-it-will-do-part
