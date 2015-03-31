# Generators

_Antelope_ comes with an assortment of generators; however, if you
wish to create a custom generator, here's how.

First, you'll want to make your generator a subclass of
`Antelope::Generator::Base`.  This sets up a basic framework for you
to build upon.

```Ruby
class MyGenerator < Antelope::Generator::Base

end
```

Next, you'll want to define a `generate` method on your generator that
takes no arguments.  This is used internally by _Antelope_ to actually
have your generator perform its generation.  In the case of this
generator, we'll have it copy over a template (after running the
templating generator over it over it).

```Ruby
class MyGenerator < Antelope::Generator::Base

  def generate
    template "my_template", "#{file}.my_file"
  end
end
```

`Base` provides a few convienince methods for you, one of them being [`template`](http://rubydoc.info/github/medcat/antelope/master/Antelope/Generator/Base#template-instance_method);
`file` is also provided, and it contains the base part of the file
name of the parser ace file that this is being generated for.  The
template, by default, should rest in
`<lib path>/lib/antelope/generator/templates` (with `<lib path>` being
  the place that _Antelope_ was installed); however, if it should be
  changed, you can overwrite the `source_root` method on the class:

```Ruby
class MyGenerator < Antelope::Generator::Base

  def self.source_root
    Pathname.new("/path/to/source")
  end

  def generate
    template "my_template", "#{file}.my_file"
  end
end
```

In the template, the code is run in the context of the instance of the
class, so you have access to instance variables and methods as if you
were defining a method on the class:

```
{{ table.each_with_index do |hash, i| }}
  state {{= i }}:
{{   hash.each do |token, action| }}
    for {{= token }}, I'll {{= action[0] }} {{= action[1] }}
{{   end }}
{{ end }}
```

_Note: in templates, blocks that start at the beginning of a line and
end at the end of a line do not produce any whitespace._

`table` here is defined on the base class, and we're iterating over
all of the values of it.

The last thing to do is to register the generator with _Antelope_.  
This is as simple as adding a line `register_as "my_generator"` to the
class definition.  Then, if any grammar file has the type
`"my_generator"`, your generator will be run (assuming it's been
required by _Antelope_).

The finialized product:

```Ruby
# my_generator.rb
class MyGenerator < Antelope::Generator::Base

  register_as "my_generator"

  def self.source_root
    Pathname.new("/path/to/source")
  end

  def generate
    template "my_template.erb", "#{file}.my_file"
  end
end
```

```
# my_template.ant
{{ table.each_with_index do |hash, i| }}
  state {{= i }}:
{{   hash.each do |token, action| }}
    for {{= token }}, I'll {{= action[0] }} {{= action[1] }}
{{   end }}
{{ end }}
```

## Bundling

If you want to bundle a few generators together such that the bundle
is generated together, you can use an `Antelope::Generator::Group`.  
This would be useful for something like a C language generator, which
may need to generate both a header and a source file:

```Ruby
class CHeader < Antelope::Generator::Base
  # ...
end

class CSource < Antelope::Generator::Base
  # ...
end


class C < Antelope::Generator::Group
  register_generator CHeader, "c-header"
  register_generator CSource, "c-source"
end
```

The `register_generator` takes a generator class and a name for the
generator, and adds the generator to the list of generators on the
receiver (in this case, the `C` class).  Now, when `C#generate` is
run, it will run both `CHeader#generate` and `CSource#generate`.

## Using Compiler Directives

Directives are statements that are used in Ace files in order to pass
information to _Antelope_.  They normally follow the syntax
`%<directive name> [directive arguments]*`.  See
[the Ace file format](http://rubydoc.info/github/medcat/antelope/Antelope/Ace)
for more information about directives.

In some cases, like in the [Ruby generator][Ruby], options from the
Ace file are needed for generation.  In the case of the Ruby
generator, we need the error class that the developer wants the
generator to use; and we reference it through the `ruby.error-class`
directive.  In order to define directives that can be used in custom
generators, you just need to add a few lines:

```Ruby
class MyGenerator < Antelope::Generator::Base

  has_directive "my-generator.some-value", Boolean

end
```

In this example, we define a directive named
`my-generator.some-value`; this directive is eventually coerced into
a `true`/`false` value.  In order to actually use the value of the
directive, in either the template or a method on the generator, you
can reference `directives["my-generator.some-value"]`, which will be
`nil` (it wasn't defined), `true` (it was defined, with any
arguments), or `false` (it was explicitly defined with one argument,
`"false"`).  Some other values you can pass in place of `Boolean`
would be `:single` (or `:one`), which only gives the first argument
passed to the directive; an `Array` of types, which would coerce each
argument into its corresponding element of the array; `Array`, which
will give an array of the given arguments; `String`, which gives a
string representation of the first argument; any `Numeric` subclass,
which would coerce the first argument into an integer; `Float`, which
would coerce the first argument into a float; any class, which would
be instantized with the arguments to the directive.  Any other values
would yield an error.

It is recommended that you namespace directives that only your
generator would use, using dashed syntax, like in our example above.  
However, some directives are not namespaced, or are not namespaced
under a generator; these may be used by any generator.  It is also
recommended that you declare every directive that you use.

[Ruby]: http://rubydoc.info/github/medcat/antelope/Antelope/Generator/Ruby
