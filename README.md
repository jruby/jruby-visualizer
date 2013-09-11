# jruby-visualizer
The ```jruby_visualizer``` gem takes as input Ruby code and visualizes artifacts of JRuby's compiler/interpreter tool chain.
This includes
 * the Abstract Syntax Tree (AST)
 * the Intermediate Representation (IR)
 * the execution of compiler passes on IR
 * a visualization for the Control Flow Graphs (CFGs) on JRuby Scopes

# Installation
You can install this visualizer as gem into your jruby environment:

1. Clone the repository ```$ git clone https://github.com/jruby/jruby-visualizer.git```
2. Build the gem ```$ rake build```
3. Install the gem ```$ jruby -S gem install --local pkg/jruby_visualizer-0.1.gem```

# Usage
Either

1. call into the library

```
$ ./lib/jruby_visualizer.rb                             
RuntimeError: No ruby input for the JRuby Visualizer
  Usage: 
    ./lib/jruby_visualizer.rb "def foo; 42; end; foo"
  or
    ./lib/jruby_visualizer.rb foo.rb
  (root) at ./lib/jruby_visualizer.rb:15
```
This is also possible with the following command, to visualize ```foo.rb```:

```
$ jruby -Ilib ./bin/jruby_visualizer foo.rb
```

2. Execute the installed binary

```
$ jruby_visualizer foo.rb
```

3. Use the visualizer as gem in your jruby code

```ruby
#!/usr/bin/env jruby

require 'jruby_visualizer'

JRubyVisualizer::visualize('def bar; puts "spam HAM"; end; bar')
```
