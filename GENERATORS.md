# Generators

_Antelope_ comes with an assortment of generators; however, if you wish to create a custom generator, here's how.

First, you'll want to make your generator a subclass of `Antelope::Generator::Base`.  This sets up a basic framework for you to build upon.

```Ruby
class MyGenerator < Antelope::Generator::Base

end
```

Next, you'll want to define a `generate` method on your generator that takes no arguments.  This is used internally by _Antelope_ to actually have your generator perform its generation.  In the case of this generator, we'll have it copy over a template (after running ERb over it).

```Ruby
class MyGenerator < Antelope::Generator::Base
    
  def generate
    template "my_template.erb", "#{file}.my_file"
  end
end
```

`Base` provides a few convienince methods for you, one of them being [`template`](http://rubydoc.info/github/medcat/antelope/master/Antelope/Generator/Base#template-instance_method); `file` is also provided, and it contains the base part of the file name of the parser ace file that this is being generated for.  The template, by default, should rest in `<lib path>/lib/antelope/generator/templates` (with `<lib path>` being the place that _Antelope_ was installed); however, if it should be changed, you can overwrite the `source_root` method on the class:

```Ruby
class MyGenerator < Antelope::Generator::Base
  
  def self.source_root
    Pathname.new("/path/to/source")
  end

  def generate
    template "my_template.erb", "#{file}.my_file"
  end
end
```

In the template, the code is run in the context of the instance of the class, so you have access to instance variables and methods as if you were defining a method on the class:

```
% table.each_with_index do |hash, i|
  state <%= i %>:
%   hash.each do |token, action|
    for <%= token %>, I'll <%= action[0] %> <%= action[1] %>
%   end
% end
```

_Note: in templates, the ERb syntax allows lines starting with `%` to be interpreted as ruby; this helps remove unwanted line space._

`table` here is defined on the base class, and we're iterating over all of the values of it.

The last thing to do is to register the generator with _Antelope_.  This is as simple as adding a line `register_as "my_generator"` to the class definition.  Then, if any grammar file has the type `"my_generator"`, your generator will be run (assuming it's been required by _Antelope_).

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
# my_template.erb
% table.each_with_index do |hash, i|
  state <%= i %>:
%   hash.each do |token, action|
    for <%= token %>, I'll <%= action[0] %> <%= action[1] %>
%   end
% end
```

## Bundling

If you want to bundle a few generators together such that the bundle is generated together, you can use an `Antelope::Generator::Group`.  This would be useful for something like a C language generator, which may need to generate both a header and a source file:

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

The `register_generator` takes a generator class and a name for the generator, and adds the generator to the list of generators on the receiver (in this case, the `C` class).  Now, when `C#generate` is run, it will run both `CHeader#generate` and `CSource#generate`.
