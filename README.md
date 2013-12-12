lazy_loader
========

[![Build Status](https://travis-ci.org/centzy/lazy_loader.png?branch=master)](https://travis-ci.org/centzy/lazy_loader)

Lazy loading for Ruby and JRuby.

Uses double-locking and a volatile variable if in JRuby, and uses ||= otherwise.

## Usage

```ruby
require 'lazy_loader'

i = 0

foo = LazyLoader.create_lazy_loader do
  i += 1
  i
end

(1..100).to_a.map do |_|
  Thread.new do
    foo.get     # always 1
  end
end.each do |thread|
  thread.join
end
```

Written for Locality  
http://www.locality.com

## Authors

Peter Edge  
peter@locality.com  
http://github.com/peter-edge

## License

MIT
